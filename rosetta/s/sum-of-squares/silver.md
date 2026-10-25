# Sum of squares

**Candidate: proofs likely to discharge automatically.** Element squares are bounded by the declared element subtype and indexes by Count's range, and the only loop-carried value (the sum) is protected by one guard just before the addition, so everything discharges without annotations. Integers stand in for the numeric vector, avoiding floating-point proof difficulty.

Position 49 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

The vector is a fixed-capacity array of a ranged element subtype (for example -1000..1000) plus a Count in 0..capacity, so a zero-length vector is Count = 0. A procedure loops with a for loop over 1..Count, squares each element (bounded by the subtype), guards the accumulation against exceeding Integer'Last by reporting a rejection, and prints the result with Integer'Image. The main program calls it on an empty vector and on the sample 3,1,4,1,5,9 giving 133. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Sum is known only by its type after the first iteration, so an explicit guard before each addition rejects with a visible message if the sum would exceed the Integer limit, which is unreachable for the bounded elements but provable.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the sum of squares for an empty vector and for an embedded sample vector.

Assessed on 2026-10-15 against page revision 415389 of the [task](https://rosettacode.org/wiki/Sum_of_squares) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
