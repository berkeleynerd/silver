# Nautical bell

**Excluded from Silver: clock, delay.** The task is to ring a ship's bell pattern at half-hour boundaries in GMT. A solution needs the clock, a delay to wait for the next boundary, and text output, and the task explicitly allows written notices instead of a real bell. Nothing in it breaks a fixed Oracle rule.

## Language surface recorded by this assessment

Integers, loops, subprograms and string operations.

## External effects

- **clock** (not allowed): The bell must sound at specific GMT times of day, so the program needs the current time.
- **console output** (allowed): The bell pattern is written as text, for example 'Two Bells Gone' or repeated 'bang' strings.
- **delay** (not allowed): A program that keeps emulating the bell waits until the next half-hour boundary.

Assessed on 2026-10-15 against page revision 413801 of the [task](https://rosettacode.org/wiki/Nautical_bell) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
