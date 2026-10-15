# Readline interface

**Excluded from Silver: terminal control.** The task asks for a command loop with at least two application commands, a recallable history and line editing. A Silver-friendly version reads lines, parses them against a fixed command set, keeps a bounded history array and has a specified outcome for unknown commands. Line editing and recall need terminal and stdin effects that Silver lacks today, but no Oracle rule is broken.

## Language surface beyond today's Silver

String operations, arrays, enumerations, loops and subprograms.

## External effects

- **console output** (allowed): Prints a prompt, command responses (hello, help, history listing) and an unknown-command message.
- **standard input** (allowed): Reads typed command lines interactively from standard input.
- **terminal control** (not allowed): A readline-style interface needs line editing (cursor movement, backspace) and recall of earlier commands, which means raw keystroke handling and cursor control. A plain line-read loop with an in-program history list would only partly meet this.

Assessed on 2026-10-15 against page revision 411117 of the [task](https://rosettacode.org/wiki/Readline_interface) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
