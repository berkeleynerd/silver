# Peano curve

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by small declared subtypes and fixed for-loop ranges, with no recursion, accumulators or annotations needed, so the checks should discharge from types alone.

Position 779 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Walk the 729 points of the order-3 curve with a for loop over k in 0..728, extracting the six base-3 digits with / and mod, applying the parity-based reflections to get x and y in 0..26 by straight-line code, and drawing each unit segment and point into a 53x53 Character array. Then copy each row into a 53-character String and print it with Put_Line. The previous point is kept in range-typed variables, and the segment cell index is guarded by being computed from subtype-bounded coordinates. About 80 lines.

## Proof obligations to watch

- **range**: The reflected digits and the weighted sums 9*a+3*b+c stay within the 0..26 subtype only if digits are typed 0..2 and flips are written as 2-d, which keeps every step bounded without a loop invariant.
- **index**: Canvas indices 2*x, 2*y and x+px are computed from 0..26 subtypes so they stay within 0..52, with no loop-carried accumulator.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, case statements, string indexing, string building and procedures.

## External effects

- **console output** (allowed): Prints the 53 text rows of the ASCII-art curve.

Assessed on 2026-10-15 against page revision 415426 of the [task](https://rosettacode.org/wiki/Peano_curve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
