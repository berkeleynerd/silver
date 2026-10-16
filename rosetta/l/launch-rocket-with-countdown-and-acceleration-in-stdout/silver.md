# Launch rocket with countdown and acceleration in stdout

**Excluded from Silver: delay.** The task needs bounded loops, integer-based position and velocity arithmetic (altitude grows by an integer accelerating step each frame) and fixed ASCII-art strings printed to stdout, with sleeps for timing. Nothing in it breaks an Oracle rule, so it is a candidate once Silver gains console loops, integer arithmetic and a delay operation.

## Language surface recorded by this assessment

Integers, loops, string operations and arrays.

## External effects

- **console output** (allowed): Prints the countdown numbers 5 to 0 and each ASCII-art rocket frame to standard output.
- **delay** (not allowed): A one-second countdown and a frame-by-frame animation with shrinking frame intervals need sleeping between outputs.

Assessed on 2026-10-15 against page revision 388719 of the [task](https://rosettacode.org/wiki/Launch_rocket_with_countdown_and_acceleration_in_stdout) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
