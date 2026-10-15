# Check output device is a terminal

**Excluded from Silver: terminal control.** The task asks a program to report whether standard output is a terminal, which needs one admitted library query about the output device and a conditional print. Nothing in it conflicts with an Oracle rule, so it is a candidate once Silver has a specified terminal-detection operation.

## External effects

- **console output** (allowed): The program reports its result by printing a line of text.
- **terminal control** (not allowed): It must ask the operating system whether standard output is attached to a terminal (an isatty-style query).

Assessed on 2026-10-15 against page revision 413159 of the [task](https://rosettacode.org/wiki/Check_output_device_is_a_terminal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
