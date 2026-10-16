# Linux CPU utilization

**Excluded from Silver: delay.** The task reads one line from /proc/stat, parses unsigned counters, sums them, takes deltas across a sleep, and prints a percentage. Bounded integer arithmetic with a guard for a zero total delta and a defined outcome for malformed input fits the Oracle rules. It needs file reading, a delay and console output, which are effects Silver lacks today and are not conflicts.

## Language surface recorded by this assessment

Integers, string operations, loops, subprograms and arrays.

## External effects

- **files** (allowed): Reads the first line of /proc/stat, twice, to get cumulative CPU times.
- **delay** (not allowed): Sleeps for a short interval between the two samples so the time deltas give real-time utilization.
- **console output** (allowed): Prints the computed CPU utilization percentage.

Assessed on 2026-10-15 against page revision 410712 of the [task](https://rosettacode.org/wiki/Linux_CPU_utilization) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
