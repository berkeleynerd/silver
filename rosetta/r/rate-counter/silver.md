# Rate counter

**Excluded from Silver: clock.** The task needs a sequential loop of jobs, a clock to take timestamps, and printed reports of at least three times. Tasking is not required because the jobs can run one after another. Needing a clock is an effect Silver lacks, not a rule conflict.

## Language surface recorded by this assessment

Integers, loops, subprograms and floating point.

## External effects

- **clock** (not allowed): Measures elapsed time and the time at which each job finishes, so it needs a clock to take at least three distinct timestamps.
- **console output** (allowed): Reports the measured times and rates as text.

Assessed on 2026-10-15 against page revision 415235 of the [task](https://rosettacode.org/wiki/Rate_counter) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
