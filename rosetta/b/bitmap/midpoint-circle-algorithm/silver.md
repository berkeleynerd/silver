# Bitmap/Midpoint circle algorithm

**Candidate: proofs plausibly discharge automatically.** Every check follows from small declared ranges and guards just before each update or array write, with no annotation needed, but the loop-carried F, X and Y require careful guarding so the outlook is plausible rather than likely.

Position 1540 in the [progression](../../../progression.md#stage-32), in stage 32.

## Approach

The program holds a 16x16 constrained 2D array of Character initialized to blanks, a Fill-equivalent loop, and a Circle procedure running the midpoint algorithm with small ranged-subtype X, Y and F inside a while loop in a procedure, plotting eight symmetric pixels through a guarded plot step. Center and Radius are embedded constants validated up front (circle must fit the image, otherwise Reject), and the image is printed by copying each row into a 16-character String and calling Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The loop-carried decision value F (and Y) only has its type range after the first iteration, so each update is preceded by a range guard on F with Reject on failure, and the 2*X+3 and 2*Y terms are recomputed from bounded X and Y rather than carried.
- **index**: Pixel coordinates Center plus or minus X or Y are checked by a single up-front test that the circle lies inside the 16x16 image (Reject otherwise), but the prover must relate the loop-carried X and Y to the bounds, so each plot is also guarded by a coordinate range test before the array write.
- **range**: Y := Y - 1 is guarded by Y > 0 and X := X + 1 by X < Y, so the subtype ranges of X and Y hold without an invariant.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures and block statements.

## External effects

- **console output** (allowed): The finished bitmap is printed row by row as text art with Put_Line.

Assessed on 2026-10-15 against page revision 411660 of the [task](https://rosettacode.org/wiki/Bitmap/Midpoint_circle_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
