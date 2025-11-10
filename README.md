# shell-script
Shell script that retrieves JSON documents from a web server based on a list of URLs.

---
🖥️ 1. Console

A console is the physical or virtual interface that connects a user to the computer’s system.

Historically: It was the hardware — a screen and keyboard — connected directly to the computer.

Today: It’s a software abstraction that can host multiple terminals (e.g., Linux virtual consoles accessed with Ctrl+Alt+F1–F6).

A console only produces output and does not receive input.

📌 Think of it as the overall “seat” you sit in to talk to your computer.

---

💬 2. Terminal

A terminal is a program that emulates the behavior of old text terminals inside a modern graphical environment.

Examples:

macOS → Terminal.app, iTerm2

Linux → GNOME Terminal, Konsole

Windows → Windows Terminal, PowerShell

The terminal is responsible for:

Displaying text (input/output)

Sending what you type to another program (the shell)

Rendering the output you get back

📌 Think of it as the “window” where the conversation happens.

---

🐚 3. Shell

A shell is the command-line interpreter — the program that actually understands and executes your commands.

Common shells:

Bash (/bin/bash)

Zsh

Fish

PowerShell

cmd.exe

Its main roles:

Interpret and run commands typed by the user

Provide scripting capabilities (loops, variables, etc.)

Handle input/output redirection and pipelines

📌 Think of it as the “person” on the other end of the conversation, interpreting what you say, and which will ask the system to execute a particular programme, and report back with the response.

---

⚙️ 4. Commands and Arguments

A command is an instruction given to the shell, often followed by arguments (options or data).

Example:

ls -l /home/user


Breakdown:

ls → the command (program)

-l → an option (argument modifying the behavior)

/home/user → another argument (target directory)

How it’s processed

You type a line in the terminal.

The terminal sends it to the shell.

The shell:

1. Parses the line (splits into command and arguments)

2. Looks up the command (e.g., searches $PATH)

3. Creates a child process to execute it

4. Passes the arguments to that process

5. The command runs, produces output (stdout/stderr).

6. The shell displays the output back in the terminal.

---

📜 Simplified diagram:

You type → [Terminal] → [Shell] → [Program/Command] → Output returned → [Shell] → [Terminal]
