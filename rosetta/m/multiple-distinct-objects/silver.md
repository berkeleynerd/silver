# Multiple distinct objects

**Candidate: proofs likely to discharge automatically.** Every check follows from declared subtype ranges, for-loop indexes over the array's own range, and an up-front validation of n, so no loop invariant or other annotation is needed. The outlook is likely because the loops are plain for loops with bounded values and the only non-routine part, text parsing, is a validated library operation.

Position 1112 in the [progression](../../progression.md#stage-18), in stage 18.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Declare a subtype Count is Integer range 1 .. 100 and an array of 1 .. 100 of an Item subtype, fully initialized by an others aggregate. Parse the first argument to n with validation, rejecting missing, non-numeric or out-of-range input through Reject. Then a for loop over 1 .. n assigns each element a distinct value I * 10, one element is modified, and a second for loop prints every item and confirms the others differ. About 45 lines.

## Proof obligations to watch

- **overflow**: Item values are I * 10 with I in a declared 1..100 subtype, so the product stays within a bounded element subtype and discharges from types.
- **length**: The output line is built in a fixed-size buffer sized for three image fields, which the declared subtype ranges bound statically.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, text parsing, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the items and a check that changing one item leaves the others unchanged.
- **arguments** (allowed): The first command-line argument supplies n at run time.

Assessed on 2026-10-15 against page revision 412931 of the [task](https://rosettacode.org/wiki/Multiple_distinct_objects) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
