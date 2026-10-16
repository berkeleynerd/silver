# Time a function

**Excluded from Silver: clock.** This task can be included in Silver. The program calls a bounded procedure directly (no access-to-subprogram value is needed), reads a CPU-time or monotonic clock before and after the call, and prints the difference. That needs a clock library operation that Silver has not admitted yet, but it breaks no fixed Oracle rule.

## Language surface recorded by this assessment

Integers, loops, subprograms and string operations.

## External effects

- **clock** (not allowed): The program reads a timer before and after the call, ideally the process's CPU time (as Ada.Execution_Time provides) or a monotonic clock, and works out the elapsed time.
- **console output** (allowed): It prints the measured time.

Assessed on 2026-10-15 against page revision 415064 of the [task](https://rosettacode.org/wiki/Time_a_function) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
