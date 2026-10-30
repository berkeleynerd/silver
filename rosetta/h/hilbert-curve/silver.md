# Hilbert curve

**Candidate: proofs plausibly discharge automatically.** Order-3 ASCII art needs only fixed-size arrays, for loops and small ranged integer arithmetic, so all checks are bounded by types and a few explicit guards, but the loop-carried coordinate reflection needs careful guard placement.

Position 684 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The program walks the 64 curve indices of an order-3 Hilbert curve with a for loop, converting each index to (x,y) by a fixed three-step loop using integer division and mod with guarded reflect and swap. Each point is marked on a 15x15 Character canvas (2D array) and the segment to the previous point is filled with '-' or '|', then each canvas row is copied into a 15-character String and printed with Put_Line. All loops are for loops with fixed bounds inside the Main procedure, with no recursion. About 70 lines.

## Proof obligations to watch

- **range**: The reflect step s-1-x in the index-to-coordinate conversion works on loop-carried x and y, so each use is guarded by an explicit x <= s-1 test (never taken for valid indexes) to discharge without an invariant.
- **index**: Canvas indexes are computed as 2*x and 2*y plus a neighbour offset from loop-carried coordinates, so they are held in subtypes 0..7 and 0..14 with guards before each canvas write.
- **overflow**: Coordinate arithmetic uses small ranged integer types so every sum and product is statically bounded, though the bit-extraction by division and mod is mildly nonlinear.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The ASCII-art curve is printed line by line to standard output.

Assessed on 2026-10-15 against page revision 411670 of the [task](https://rosettacode.org/wiki/Hilbert_curve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
