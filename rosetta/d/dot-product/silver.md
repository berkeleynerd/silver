# Dot product

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded element ranges, a fixed maximum length and a for loop over the array's own range, so no annotation is needed.

Position 965 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Declare a bounded element subtype (-1000..1000), a vector type indexed 1..100 as an unconstrained array, and a function that returns 0 and rejects visibly when lengths differ or exceed 100, otherwise sums products in a for loop over a'Range into an Integer accumulator. Main embeds the two 3-element vectors, calls the function, and prints the result with Integer'Image through Put_Line. The accumulator is declared with a range wide enough for 100 products of the bounded elements, so every addition discharges from types alone. About 40 lines.

## Proof obligations to watch

- **overflow**: The accumulator is loop-carried, so element subtypes bounded to +/-1000 and a sum subtype sized for 100 elements keep each product and partial sum within Integer, with a length guard rejecting longer vectors.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, unconstrained arrays, for loops, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the dot product result 3 via Put_Line.

Assessed on 2026-10-15 against page revision 413360 of the [task](https://rosettacode.org/wiki/Dot_product) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
