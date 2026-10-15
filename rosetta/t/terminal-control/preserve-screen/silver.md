# Terminal control/Preserve screen

**Excluded from Silver: terminal control.** The task clears the terminal, prints some text, then restores the earlier screen with its attributes, which a text program can do with the alternate screen buffer. It needs terminal control and console output, but nothing in it breaks an Oracle rule, so it is a candidate once Silver has a terminal operation.

## External effects

- **terminal control** (not allowed): Clearing the screen and later restoring the prior screen contents and attributes requires terminal control, such as the alternate screen buffer or save and restore of the screen.
- **console output** (allowed): The task prints something on the temporary screen.

Assessed on 2026-10-15 against page revision 413246 of the [task](https://rosettacode.org/wiki/Terminal_control/Preserve_screen) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
