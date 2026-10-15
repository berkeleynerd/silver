# Terminal control/Cursor positioning

**Excluded from Silver: terminal control.** The task only needs to move the cursor to row 6, column 3 and print Hello, which is a fixed-text program with a terminal cursor-control effect. Nothing in it breaks an Oracle rule, so it is a candidate once Silver gains an admitted terminal-positioning operation.

## External effects

- **console output** (allowed): Prints the word Hello to standard output.
- **terminal control** (not allowed): Needs cursor positioning to row 6, column 3 (Set_Line/Set_Col or ANSI escape sequence) so H lands at that position.

Assessed on 2026-10-15 against page revision 415090 of the [task](https://rosettacode.org/wiki/Terminal_control/Cursor_positioning) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
