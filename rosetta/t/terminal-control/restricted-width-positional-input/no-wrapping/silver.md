# Terminal control/Restricted width positional input/No wrapping

**Excluded from Silver: terminal control.** The task needs a routine taking row, column and width that reads a bounded string via raw keystrokes at a fixed screen position, stopping at 8 characters with no wrapping. A bounded string and a loop with explicit length guards express this, so it only lacks terminal and stdin support today and breaks no Oracle rule.

## Language surface beyond today's Silver

Integers, characters, string operations, loops and subprograms.

## External effects

- **terminal control** (not allowed): Positions the cursor at row 3, column 5 and reads raw keystrokes (including backspace) one at a time while echoing in place.
- **console output** (allowed): Echoes typed characters and prints the entered string.

Assessed on 2026-10-15 against page revision 402970 of the [task](https://rosettacode.org/wiki/Terminal_control/Restricted_width_positional_input/No_wrapping) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
