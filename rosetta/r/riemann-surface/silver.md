# Riemann surface

**Candidate: proofs plausibly discharge automatically.** All loops are bounded for loops in a procedure over constant ranges, so only the floating-point math and float-to-index conversion need attention, and both are handled with bounded types and explicit guards before use. Floating-point elementary functions are the only non-routine part, which makes discharge plausible rather than likely.

Position 872 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Keep a fixed 2D Character grid (about 60 columns by 30 rows) initialized to spaces, then loop over a fixed number of radius steps and angle steps covering two turns (4*pi) to compute x = r cos t, y = r sin t and z = sqrt(r) cos(t/2) for f(z) = sqrt(z), apply a fixed rotation and orthographic projection, and plot a character chosen from the height z (two sheets get different glyphs). Before each plot the computed row and column are guarded against the grid bounds, then the grid rows are copied into fixed-length Strings and printed with Silver_IO.Put_Line. About 60 lines.

## Proof obligations to watch

- **floating point**: Sqrt, Cos and Sin results are used in arithmetic, so the program relies on the admitted elementary-function contracts and on loop indexes of a bounded subtype keeping r and theta in a small fixed range.
- **range**: Converting the projected floating-point coordinates to grid indexes is guarded by an explicit comparison against the grid bounds, and points outside the grid are skipped as a documented visible outcome of the fixed canvas.
- **overflow**: Scale multiplications on floats stay far below the float limit because r, theta and the scale are bounded constants, so only the guarded integer conversion needs care.
- **index**: Each grid write happens only after the row and column are tested against the array bounds just before the assignment.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, floating point, arrays, multidimensional arrays, string indexing, string building, for loops, procedures and functions.

## External effects

- **console output** (allowed): The projected surface is printed as rows of text art to standard output, which meets the task without a display.

Assessed on 2026-10-15 against page revision 414982 of the [task](https://rosettacode.org/wiki/Riemann_surface) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
