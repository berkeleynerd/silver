# Dining philosophers

**Excluded from Silver: delay, clock.** The task is in the Concurrency category and explicitly requires concurrency: the five philosophers are tasks contending for five fork resources. A faithful solution needs library-level tasks and protected Fork objects with simple Boolean entry barriers, with deadlock prevented by grabbing forks in a fixed global order. This fits SPARK's Ravenscar/Jorvik tasking subset, so the task is a candidate once Silver admits tasking, delays and the real-time clock. One open point: SPARK tasking needs a pragma Profile configuration pragma, which has to come from Silver's toolchain configuration rather than from program source, because only pragma SPARK_Mode (On) is allowed in source.

## Language surface recorded by this assessment

Tasking, enumerations, arrays, loops, integers, subprograms, packages and string operations.

## External effects

- **console output** (allowed): Each philosopher reports thinking, hungry, eating and leaving states as text lines.
- **delay** (not allowed): Eating and thinking take a random amount of time, so tasks must sleep for a duration chosen by a deterministic pseudo-random generator.
- **clock** (not allowed): Under SPARK's Ravenscar/Jorvik tasking profile, sleeping is done with delay until on Ada.Real_Time.Clock, so the program has to read the monotonic clock.

Assessed on 2026-10-15 against page revision 414157 of the [task](https://rosettacode.org/wiki/Dining_philosophers) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
