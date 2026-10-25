# Factorions

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges, a constant factorial table indexed by values mod Base, and for loops with a single guard on the digit sum, so proofs should discharge without annotations. The only real gaps are Silver's missing arrays, loops, functions and Integer'Image output.

Position 883 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

A constant array of factorials 0..11 is embedded as an aggregate, and a function Is_Factorion extracts digits in a bounded for loop of at most 8 iterations (enough for 1,500,000 in base 9), using an exit when remaining is 0 or the sum exceeds the limit. A procedure loops over candidates 1..1_500_000 for bases 9, 10, 11 and 12, printing each factorion with Integer'Image and a final count to show the expected 3, 4, 5 and 2. All ranges are typed subtypes (Base 9..12, Candidate 1..1_500_000), so no recursion, while loops in functions or heap are needed. About 55 lines.

## Proof obligations to watch

- **overflow**: The loop-carried digit sum is only known by its type, so an exit-when guard stops accumulation once it exceeds the 1,500,000 search limit (it can no longer equal the candidate), keeping sum plus a factorial of at most 39,916,800 within a 32-bit range.
- **index**: Digits come from mod Base with Base a subtype 9..12, so each digit lies in 0..11 and indexes the 12-entry factorial constant array without a guard.
- **division**: The Base subtype excludes 0, so the division and mod by Base discharge from the declared range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, functions, conditional expressions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints a header, each factorion found and a count for bases 9 to 12.

Assessed on 2026-10-15 against page revision 414198 of the [task](https://rosettacode.org/wiki/Factorions) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
