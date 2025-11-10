#!/bin/bash
set -euo pipefail

TMP_DIR="/tmp/temp_dir"

# --- Arguments ---
URLS_FILE="${1:?Usage: $0 <urls_file> <download_dir>}"
DOWNLOAD_DIR="${2:?Usage: $0 <urls_file> <download_dir>}"
ARCHIVES_DIR="${3:?Usage: $0 <urls_file> <download_dir> <archives_dir>}"

# Couleurs
BLUE_UL="\033[34;4m"   # bleu + souligné
GREEN="\033[32m"
RESET="\033[0m"

starting_script() {
    echo "> Bash script starting at: $(gdate '+%Y-%m-%dT%H:%M:%S.%3N%z')"
    echo "Script full path: $(realpath "$0" 2>/dev/null || echo "$(cd "$(dirname "$0")" && pwd)/$(basename "$0")")"

}

create_temp_dir() {
    if [ ! -d "$TMP_DIR" ]; then
        mkdir -p "$TMP_DIR"
    fi
}

fmt_url() {
    # 1 argument : l'URL
    printf "%b%s%b" "$BLUE_UL" "$1" "$RESET"
}

download_each_file() {
    while IFS= read -r url; do
        # Affichage avec URL en bleu souligné
        printf "> Downloading '%b%s%b'…\n" "$BLUE_UL" "$url" "$RESET"

        base="$(basename "${url%%\?*}")"
        [[ "$base" == *.json ]] || base="${base:-file}.json"

        json_file="$TMP_DIR/$base"
        headers_file="$TMP_DIR/$base.headers"

        curl -sS -fSL \
             --retry 3 --retry-delay 1 \
             --connect-timeout 10 -m 60 \
             -H 'Accept: application/json' \
             -D "$headers_file" \
             -o "$json_file" \
             "$url"

        printf "  %bDone%b\n" "$GREEN" "$RESET"
    done < "$URLS_FILE"
}

copy_json_files() {
    local TEMP_NAME
    TEMP_NAME="$(basename "$TMP_DIR")"

    printf "> Copying JSON files from '%s' to '%s'…\n" "$TEMP_NAME" "$DOWNLOAD_DIR"

    # (Re)create the download directory
    if [ -d "$DOWNLOAD_DIR" ]; then
        rm -rf "$DOWNLOAD_DIR"
    fi
    mkdir -p "$DOWNLOAD_DIR"

    # Copy all .json files from TMP_DIR to DOWNLOAD_DIR
    cp -f "$TMP_DIR"/*.json "$DOWNLOAD_DIR"/

    # Display "Done" in green
    printf "  %bDone%b\n" "$GREEN" "$RESET"
}

compile_headers_files() {
  local TEMP_NAME DL_NAME OUT
  TEMP_NAME="$(basename "$TMP_DIR")"
  DL_NAME="$(basename "$DOWNLOAD_DIR")"
  OUT="$DOWNLOAD_DIR/headers.txt"

  printf "> Compiling HTTP response headers from '%s' to '%s'…\n" "$TEMP_NAME" "$DL_NAME"

  mkdir -p "$DOWNLOAD_DIR"
  : > "$OUT"  # crée/vider le fichier de destination

  # Lister les *.headers du TMP en ordre alphabétique et les concaténer
  # -print0 / -z : sûrs pour les noms avec espaces
  local had_any=false
  while IFS= read -r -d '' hf; do
    had_any=true
    local name
    name="$(basename "$hf")"
    printf "### %s:\n" "$name" >> "$OUT"
    cat "$hf" >> "$OUT"
    printf "\n" >> "$OUT"
  done < <(find "$TMP_DIR" -maxdepth 1 -type f -name '*.headers' -print0 | sort -z)

  # Si aucun header trouvé, on laisse un fichier vide mais valide
  # (optionnel) tu peux écrire une note :
  # if [ "$had_any" = false ]; then echo "# No headers found" >> "$OUT"; fi

  printf "  %bDone%b\n" "$GREEN" "$RESET"
}

compress_downloads() {
  local DL_NAME AR_NAME
  DL_NAME="$(basename "$DOWNLOAD_DIR")"
  AR_NAME="$(basename "$ARCHIVES_DIR")"

  printf "> Compressing all files in '%s' to '%s'…\n" "$DL_NAME" "$AR_NAME"

  # Crée le dossier d'archives si besoin
  mkdir -p "$ARCHIVES_DIR"

  # Timestamp pour le nom d'archive : DYYYY-MM-DDTHH-MM-SS.tar.gz
  local stamp
  if command -v gdate >/dev/null 2>&1; then
    stamp="$(gdate '+%Y-%m-%dT%H-%M-%S')"
  else
    stamp="$(date '+%Y-%m-%dT%H-%M-%S')"
  fi
  local archive_name="D${stamp}.tar.gz"
  local archive_path="$ARCHIVES_DIR/$archive_name"

  # Compression maximale :
  # - "tar -c -C <dir> ." crée un flux tar du contenu de <dir>
  # - "gzip -9" compresse au niveau max
  # (macOS et Linux compatibles)
  tar -c -C "$DOWNLOAD_DIR" . | gzip -9 > "$archive_path"

  # Affiche Done en vert + nom du fichier
  printf "  %bDone%b (archive file name: %s)\n" "$GREEN" "$RESET" "$archive_name"
}

ending_script() {
    echo "> Bash script ended at: $(gdate '+%Y-%m-%dT%H:%M:%S.%3N%z')"
    echo "Bye!"
}


# Script

starting_script
create_temp_dir
download_each_file
copy_json_files
compile_headers_files
compress_downloads
ending_script