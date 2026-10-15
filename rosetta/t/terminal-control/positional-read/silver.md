# Terminal control/Positional read

**Excluded from Silver: terminal control.** The task reads the character shown at a fixed screen position into a variable, which needs a terminal positional-read facility that Silver lacks today. Ada/SPARK can express this through a future admitted terminal library operation, so it breaks no fixed Oracle rule.

## Language surface beyond today's Silver

Characters and string operations.

## External effects

- **console output** (allowed): Text must be written to the screen so there is a displayed character at column 3, row 6.
- **terminal control** (not allowed): The task reads the character displayed at a given screen position, which needs terminal screen-buffer query or a system-maintained display record.

Assessed on 2026-10-15 against page revision 415094 of the [task](https://rosettacode.org/wiki/Terminal_control/Positional_read) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
