# Terminal control/Restricted width positional input/With wrapping

**Excluded from Silver: terminal control.** The task needs a bounded-string line editor with a fixed 8-character visible window (showing the trailing characters when input is longer), positioned on the terminal at row 3, column 5. Nothing in it breaks an Oracle rule: it only needs terminal, stdin and console-output effects that Silver lacks today, plus bounded strings and loops.

## Language surface beyond today's Silver

String operations, loops, subprograms, characters and integers.

## External effects

- **terminal control** (not allowed): Needs cursor positioning at row 3, column 5, per-keystroke raw input and redisplay of the visible 8-character window.
- **standard input** (allowed): Reads the user's typed characters one key at a time, including backspace and Enter.
- **console output** (allowed): Echoes the visible window of the field and the entered value.

Assessed on 2026-10-15 against page revision 384794 of the [task](https://rosettacode.org/wiki/Terminal_control/Restricted_width_positional_input/With_wrapping) by claude-sonnet-5-5 at medium effort, escalated from claude-haiku-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
