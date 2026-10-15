# Draw a rotating sphere

**Excluded from Silver: delay.** Text-art frames meet the task without a window, and the arithmetic is integer fixed point over declared ranges with guards before every grid index, so every check follows from types and guards.

## Approach

The program embeds a sine table in integer fixed point, enumerates sphere points by nested for loops over latitude and longitude steps, rotates each about two axes by the frame angle, projects with integer perspective division, and sets cells in a fixed 40x80 Character grid. It then prints the grid row by row as text art for a fixed finite number of frames, with each frame's angle derived from the loop index; all loops are for loops inside procedures. About 90 lines.

## Proof obligations to watch

- **overflow**: Rotation uses integer fixed-point arithmetic with a precomputed sine/cosine table whose entries and coordinates are bounded by ranged subtypes, so products stay far below the 64-bit limit.
- **index**: Projected coordinates are computed from bounded values and guarded by explicit range tests before indexing the fixed-size character grid, with out-of-range points simply not plotted.
- **division**: The perspective divisor is a bounded positive constant minus a bounded depth, so a guard or the type range excludes zero.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string building, for loops, procedures, Put without a newline, 'Image of scalars and case statements.

## External effects

- **console output** (allowed): The program prints each rotation frame as text art to standard output.
- **delay** (not allowed): A continuous animation needs a pause between frames; a fixed finite frame count could avoid this, but pacing the display needs a delay.

Assessed on 2026-10-15 against page revision 408268 of the [task](https://rosettacode.org/wiki/Draw_a_rotating_sphere) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
