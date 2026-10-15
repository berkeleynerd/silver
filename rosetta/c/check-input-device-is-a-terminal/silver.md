# Check input device is a terminal

**Excluded from Silver: terminal control.** The task asks only for a demonstration that checks whether stdin is a terminal and prints the answer. This needs a library operation that reports whether stdin is a terminal, plus text output. It raises no fixed-rule conflict.

## External effects

- **standard input** (allowed): The program must inspect standard input to determine whether it is attached to a terminal.
- **console output** (allowed): It reports the result as text, on standard output or standard error.
- **terminal control** (not allowed): The answer depends on whether stdin is a terminal, so Silver needs an admitted library operation that reports this.

Assessed on 2026-10-15 against page revision 413158 of the [task](https://rosettacode.org/wiki/Check_input_device_is_a_terminal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
