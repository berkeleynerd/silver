# Terminal control/Cursor movement

**Excluded from Silver: terminal control.** The task asks only for a demonstration of how to move the terminal cursor in eight ways without overwriting the screen. Printing ANSI escape sequences as constant strings does this, so it needs console-output and terminal cursor control. No fixed Oracle rule is broken, and out-of-bounds behavior is left to the implementer.

## Language surface recorded by this assessment

String operations and loops.

## External effects

- **console output** (allowed): Cursor movement is done by printing ANSI escape sequences (left, right, up, down, line start/end, top-left, bottom-right) to standard output.
- **terminal control** (not allowed): The task is about moving the terminal cursor without overwriting any characters, so it needs terminal cursor control.

Assessed on 2026-10-15 against page revision 414544 of the [task](https://rosettacode.org/wiki/Terminal_control/Cursor_movement) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
