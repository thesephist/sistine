---
title: Sistine CLI
order: 0
description: A catalog of the Sistine command line commands and options
---

Sistine is distributed as a single command-line utility called `sistine`, written in Ink. You can find a bash script that invokes it in the repository as `sistine`. The script errors and bails if Ink is not found on the system `$PATH`.

_(If you know what you're doing, you can also run the Sistine CLI manually by running `./src/main.ink` with Ink.)_

**`sistine build`** builds the static site described and configured in the current folder into `./public`. If any necessary files or folders cannot be found, it will error. This is the default command that runs when `sistine` is invoked without any arguments.

**`sistine help`** prints the help menu in the CLI and exits.
