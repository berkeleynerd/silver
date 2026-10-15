# Active object

**Excluded from Silver: clock, delay.** The task requires an active object: a task inside the object updates the integral against the clock, while Input and Output stay callable from outside under synchronization. SPARK can express this with a Ravenscar/Jorvik task plus a protected object, and an enumeration can stand in for the access-to-function input. So the task needs future tasking, clock, delay and floating-point sine support, but it breaks no fixed Oracle rule. Confidence is medium for two reasons: the Ravenscar/Jorvik profile has to be set outside the program source, because rule 3 permits only pragma SPARK_Mode, and proving that the float accumulator cannot overflow needs explicit guards.

## Language surface beyond today's Silver

Tasking, floating point, enumerations, records, loops, subprograms and packages.

## External effects

- **clock** (not allowed): The integrator reads the current time to get t0 and t1 for each trapezoid step, and the test measures elapsed time.
- **delay** (not allowed): The test must wait 2 s with the sine input, then 0.5 s with zero input.
- **console output** (allowed): The integrated output S is printed to check that it is approximately 0.

Assessed on 2026-10-15 against page revision 413970 of the [task](https://rosettacode.org/wiki/Active_object) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
