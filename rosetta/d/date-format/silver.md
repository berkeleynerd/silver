# Date format

**Excluded from Silver: clock.** The program reads the current date from the clock and prints it as 2007-11-23 and as Friday, November 23, 2007. A clock operation that returns a validated year, month and day would make this provable, and the day-of-week and month names are fixed lookups. Nothing in the task breaks an Oracle rule; the clock is an effect Silver does not have yet.

## Language surface beyond today's Silver

Integers, enumerations, string operations and subprograms.

## External effects

- **clock** (not allowed): The task requires the current date, so the program must read the system clock.
- **console output** (allowed): The program prints two lines of text: the ISO date and the long-form date.

Assessed on 2026-10-15 against page revision 413304 of the [task](https://rosettacode.org/wiki/Date_format) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
