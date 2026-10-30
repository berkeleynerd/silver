# Archimedean spiral

**Candidate: proofs plausibly discharge automatically.** Everything is bounded loops over fixed grids with guards before each Float-to-Integer conversion and array store, so it should prove without annotations, though floating-point trig and conversions need careful range guards.

Position 859 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

A constant 2D Character grid (about 41 by 41) is filled with spaces, then a for loop over a ranged step index computes T, R = A + B*T and plots '*' at the rounded offsets from the centre when the Float values pass a range guard. Finally a for loop over rows copies each grid row into a String buffer and prints it with Put_Line; the constants A, B and the step count are embedded. About 45 lines.

## Proof obligations to watch

- **floating point**: The angle is Float(I)*Step with I in a declared range, so Cos and Sin arguments and R are bounded by types and no float overflow is possible, but provers must bound the products.
- **range**: The Float-to-Integer conversions of R*Cos(T) and R*Sin(T) are discharged by an explicit guard comparing the Float against the grid half-width before converting, and out-of-grid points are simply not plotted (documented clipping, since the grid is sized to contain the whole curve).
- **index**: Grid indexes are formed only after the guard shows the converted offsets lie within the subtype range, so the array store is safe.
- **termination**: All loops are for loops over fixed ranges, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, floating point, multidimensional arrays, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The spiral is drawn as text art, one row per Put_Line.

Assessed on 2026-10-15 against page revision 415335 of the [task](https://rosettacode.org/wiki/Archimedean_spiral) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
