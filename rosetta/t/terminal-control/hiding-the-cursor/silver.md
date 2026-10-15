# Terminal control/Hiding the cursor

**Excluded from Silver: terminal control.** The task only asks for the cursor to be hidden and shown again. A faithful solution writes the two terminal escape sequences to the console, so it needs the terminal and console-output effects and breaks no Oracle rule. Silver has no cursor-control operation yet.

## External effects

- **terminal control** (not allowed): Hiding and showing the cursor is terminal cursor control, done by writing escape sequences such as ESC[?25l and ESC[?25h to the terminal.
- **console output** (allowed): The escape sequences and any message text are written to standard output.

Assessed on 2026-10-15 against page revision 415092 of the [task](https://rosettacode.org/wiki/Terminal_control/Hiding_the_cursor) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
