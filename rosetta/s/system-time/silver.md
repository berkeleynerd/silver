# System time

**Excluded from Silver: clock.** The task only asks the program to read the system clock and print the time with its units noted. That breaks no Oracle rule; Silver just needs an admitted clock library operation (such as Ada.Calendar.Clock with a formatting function) with a specified contract.

## Language surface recorded by this assessment

Integers, string operations, records and packages.

## External effects

- **clock** (not allowed): The program has to read the current system time, for example through Ada.Calendar.Clock.
- **console output** (allowed): The program prints the time, with its units noted, to standard output.

Assessed on 2026-10-15 against page revision 415099 of the [task](https://rosettacode.org/wiki/System_time) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
