# Polyspiral

**Candidate: proofs plausibly discharge automatically.** Everything is bounded by fixed for loops, ranged angle and length types and explicit clipping guards, so only the floating-point trigonometry and float-to-index conversion need careful shaping and no annotation is required.

Position 869 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Render one frame (fixed increment, 150 segments, length starting at 5 and growing by 3, angle advancing by incr mod 360) onto a fixed-size Character grid (for example 120x60), plotting each segment by stepping a bounded number of interpolation points with floating-point Sin/Cos on a range-constrained position, and skipping points outside the grid. Then print each row of the grid with Put_Line; all loops are for loops inside a procedure, and no recursion is used. About 70 lines.

## Proof obligations to watch

- **floating point**: Sin/Cos must come from an admitted library with contracts and the float position is carried through a loop, so it is held in a range-constrained subtype and guarded before each addition.
- **range**: Converting the float position to a grid index needs an explicit guard that skips points outside the grid, a specified clipping outcome, before the conversion.
- **overflow**: Segment length (at most 455) and angle (kept in 0..359 by mod) are bounded by ranged subtypes and a fixed 150-iteration for loop, so integer arithmetic is routine.
- **index**: Each line segment is rasterized by a fixed number of interpolation steps and every plotted cell is guarded to lie inside the grid.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, floating point, arrays, multidimensional arrays, string building, for loops, while loops, procedures, functions, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): The single frame is printed as text art, one row per Put_Line.

Assessed on 2026-10-15 against page revision 414411 of the [task](https://rosettacode.org/wiki/Polyspiral) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
