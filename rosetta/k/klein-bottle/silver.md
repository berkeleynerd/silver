# Klein bottle

**Candidate: proofs plausibly discharge automatically.** The task only requires drawing an image, which text art satisfies, and replacing floating-point trig with an integer lookup table keeps all arithmetic in bounded integer subtypes with guards on plotting, so no annotation is needed. The risk is only the nonlinear scaled arithmetic and projected index guards, hence plausible rather than likely.

Position 812 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program holds a constant integer table of sine values (scaled by 1000) over one full period, and cosine is read from the same table with an offset index reduced by mod. A nested for loop over u and v steps evaluates the classic Klein bottle parametric equations in scaled integer arithmetic, projects each point to 2D, and marks a cell in a fixed-size 2D Character canvas only if it falls within the canvas bounds. A final loop copies each canvas row into a fixed-length String and prints it with Silver_IO.Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: Products of scaled sine values (about 1000) with radius terms and the projection scale are nonlinear, but bounded subtypes keep every intermediate far below 2**31 so provers can discharge them.
- **index**: Projected screen coordinates are computed from loop-carried values with integer division, so an explicit if guard against the canvas bounds just before each plot is needed, and out-of-range points are simply left unplotted.
- **range**: The sine and cosine table lookups use an index reduced with mod into the table's own range, which follows from the array index subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, procedures, string building and case statements.

## External effects

- **console output** (allowed): The bottle is rendered as text art and printed row by row to standard output.

Assessed on 2026-10-15 against page revision 414841 of the [task](https://rosettacode.org/wiki/Klein_bottle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
