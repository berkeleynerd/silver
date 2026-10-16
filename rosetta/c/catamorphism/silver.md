# Catamorphism

**Candidate: proofs plausibly discharge automatically.** Higher-order function parameters are not available in SPARK, so reduce is expressed with an operation enumeration, and all indexes come from the array's own range while the only loop-carried arithmetic is bounded by subtype limits and explicit guards. Discharge depends on careful guard placement for the accumulator but needs no annotation.

Position 1182 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

Declare a small element subtype, a fixed array of four embedded values (1,2,3,4), and an enumeration of fold operations (Min, Max, Add, Mul); a Fold procedure takes the operation and array, seeds the accumulator from the first element, then runs a for loop over the remaining indexes applying a case on the operation. Before Add and Mul the loop tests the accumulator against a declared limit and, on exceeding it, sets an overflow-rejected status that is reported in the output. Main calls Fold for each operation and prints each result with Put_Line using 'Image. About 55 lines.

## Proof obligations to watch

- **overflow**: The product accumulator is loop-carried so the prover knows only its subtype; the program uses a bounded accumulator subtype and a guard before each multiplication that reports a visible rejection message rather than clamping.
- **range**: The accumulator assignment must fit its subtype for Add and Mul, which the same pre-operation guard on the bound discharges.

## Language surface recorded by this assessment

Integers, ranged subtypes, enumerations, arrays, for loops, case statements, functions, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): The four fold results (min, max, sum, product) are printed to standard output.

Assessed on 2026-10-15 against page revision 412096 of the [task](https://rosettacode.org/wiki/Catamorphism) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
