# Filter

**Candidate: proofs likely to discharge automatically.** All indexes come from for-loop ranges over the array's own bounds and the only loop-carried value is a count whose increment is guarded by a capacity test, so no annotation is needed.

Position 115 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Embed a constant Integer array of 1..10 and a result array of the same length with a count subtype of 0..10, then loop over the source's own range with a for loop, copying each element with mod 2 = 0 into the result at count + 1 under a guard that the count is below the capacity. A second for loop over 1..Count prints each stored element with Put_Line of its image. About 30 lines.

## Proof obligations to watch

- **range**: The loop-carried count of selected items is incremented only under an explicit guard that it is below the result array's capacity, so the increment and the result index follow from the guard and the count subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): The selected even numbers are printed to standard output.

Assessed on 2026-10-15 against page revision 414205 of the [task](https://rosettacode.org/wiki/Filter) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
