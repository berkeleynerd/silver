# Sierpinski curve

**Candidate: proofs plausibly discharge automatically.** Everything is bounded iteration over fixed-size arrays with guards just before each index or append, so no annotation is needed, though loop-carried turtle position and buffer length need careful guard placement.

Position 822 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Expand the Sierpinski curve L-system iteratively for order 3 in a fixed-capacity Character buffer (a for loop over the rewrite steps, with a capacity guard before each append), then interpret the result as a turtle with eight headings on a fixed 2D Character grid. Each move checks the new coordinates against the grid bounds before drawing, and the grid rows are printed with Put_Line, with a visible message if a guard trips. About 110 lines.

## Proof obligations to watch

- **index**: Turtle x and y are loop-carried, so each step is guarded by a bounds test before moving and a visible 'grid too small' message is printed if the guard fails.
- **length**: Each L-system rewrite appends into a fixed-capacity buffer with a capacity guard before every append, reporting overflow visibly instead of truncating.
- **termination**: The while loops live in procedures, which get no termination check, and the rewrite count is a for loop over a fixed order.
- **overflow**: Heading is a modular-style subtype index kept in 0..7 by an explicit wrap guard, and positions are range-typed so +/-1 steps are guarded.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, case statements, for loops, while loops and procedures.

## External effects

- **console output** (allowed): The ASCII-art grid is printed to the console line by line.

Assessed on 2026-10-15 against page revision 411682 of the [task](https://rosettacode.org/wiki/Sierpinski_curve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
