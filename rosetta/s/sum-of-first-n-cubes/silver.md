# Sum of first n cubes

**Candidate: proofs likely to discharge automatically.** The loop index has static bounds 0 .. 49, so the closed-form expressions are bounded by at most 1,500,625 and cannot overflow, and no loop-carried accumulator exists that would need an invariant. The only new surface is integer arithmetic, a for loop and Integer'Image, so the proofs should discharge automatically.

Position 107 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A for loop runs N over 0 .. 49 and computes the triangular number T = N * (N + 1) / 2, then the sum of the first N cubes as T * T, so nothing is carried between iterations. Each result is printed with Silver_IO.Put_Line (Integer'Image (Sum)), one entry per line. About 12 lines.

## Language surface beyond today's Silver

Integers, integer division, for loops and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the 50 running sums to standard output, one per line.

Assessed on 2026-10-15 against page revision 408965 of the [task](https://rosettacode.org/wiki/Sum_of_first_n_cubes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
