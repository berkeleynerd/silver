# Draw a sphere

**Candidate: proofs likely to discharge automatically.** A static ASCII-art sphere needs only bounded integer arithmetic and for loops over fixed ranges with a clamped ramp index, so every check follows from types and guards. No floating point, recursion or annotations are needed, and the task explicitly allows ASCII art.

Position 431 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The program uses a fixed 41 by 21 grid, with for loops over row and column ranged subtypes. For each cell it computes x*x + y*y with integer arithmetic (x scaled for the character aspect ratio) and compares it with a constant radius squared. Cells outside the radius print a space. Cells inside get a depth-based brightness from an integer approximation of the sphere normal, which indexes a constant shade-ramp string through a clamped index. Each row is built in a fixed-length String buffer and printed with Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: Shading uses integer-only arithmetic on grid coordinates in a small range (about -20..20), so squared sums stay far below the Integer limit.
- **index**: The shade-ramp index is clamped by an explicit guard before the array access, so it always lies within the ramp's bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string building, for loops, procedures, Put without a newline and while loops.

## External effects

- **console output** (allowed): The ASCII-art sphere is printed to standard output line by line.

Assessed on 2026-10-15 against page revision 415029 of the [task](https://rosettacode.org/wiki/Draw_a_sphere) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
