# Sierpinski square curve

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges plus explicit guards before each buffer write and grid move, and all loops sit in procedures, so no annotation is needed, but the loop-carried turtle position and expansion lengths demand careful guard placement.

Position 1540 in the [progression](../../progression.md#stage-32), in stage 32.

## Approach

Expand the axiom F+XF+F+XF for order 3 with the X rule into two fixed-capacity Character buffers (about 1000 symbols), alternating source and destination in a for loop with capacity guards. Then walk the final string as a turtle with a heading in 0..3 (a case statement gives dx and dy), marking cells of a fixed 2D Character grid after a bounds guard. Finally copy each grid row into a String buffer and print it with Silver_IO.Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: The turtle position is loop-carried, so each step is guarded by an explicit test that the next cell lies inside the grid, and a failed test rejects with a visible outcome rather than clipping the drawing.
- **overflow**: Buffer write positions and coordinates are declared with bounded ranges and each increment is preceded by a capacity guard, so no invariant is needed.
- **length**: The L-system expansion into fixed-capacity buffers is guarded so that a rule application that would exceed capacity is rejected, with capacity sized above the exact order-3 length of 807 symbols.
- **termination**: All iteration is for loops or while loops inside procedures, which get no termination check, so no variant is required.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, case statements, procedures and membership tests.

## External effects

- **console output** (allowed): The ASCII-art curve is printed line by line to the console.

Assessed on 2026-10-15 against page revision 411683 of the [task](https://rosettacode.org/wiki/Sierpinski_square_curve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
