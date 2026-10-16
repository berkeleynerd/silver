# Latin Squares in reduced form/Randomizing using Jacobson and Matthews' technique

**Excluded from Silver: clock.** The task needs only integer and array computation: a bounded n*n*n incidence cube for n up to 256, a Jacobson-Matthews move loop driven by a deterministic pseudo-random generator, reduction to reduced form, and frequency counts over 4 or 56 reduced squares. It also needs text output and elapsed-time measurement, and nothing in it breaks an Oracle rule. The order-256 cube has about 16.7 million cells, which a fixed-capacity array can hold within documented resource limits.

## Language surface recorded by this assessment

Integers, arrays, records, loops, subprograms and big numbers.

## External effects

- **console output** (allowed): Prints the reduced order-4 squares with their counts, the 56 order-5 counts, the 750th order-42 square, and summary text.
- **clock** (not allowed): Part 4 asks to confirm the approximate time taken for 1000 order-256 squares, which needs elapsed-time measurement.

Assessed on 2026-10-15 against page revision 413759 of the [task](https://rosettacode.org/wiki/Latin_Squares_in_reduced_form/Randomizing_using_Jacobson_and_Matthews'_technique) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
