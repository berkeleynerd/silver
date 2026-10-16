# Random number generator (device)

**Excluded from Silver: system randomness.** This task can be covered once Silver admits a library operation that reads system entropy (for example from /dev/urandom), has a specified outcome when that source is unavailable, and returns a 32-bit integer for the program to print. It needs nothing that breaks an Oracle rule: it is a single bounded read, a 32-bit integer (or modular) type, and text output.

## Language surface recorded by this assessment

Integers.

## External effects

- **system randomness** (not allowed): The task specifically requires obtaining a 32-bit value from a system or hardware randomness source such as /dev/urandom, so a deterministic software generator does not satisfy it; this needs an admitted entropy operation with a specified failure outcome.
- **console output** (allowed): The obtained random number must be shown, which means printing it as text.

Assessed on 2026-10-15 against page revision 414741 of the [task](https://rosettacode.org/wiki/Random_number_generator_%28device%29) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
