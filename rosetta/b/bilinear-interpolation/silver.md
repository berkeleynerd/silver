# Bilinear interpolation

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over fixed ranges with no loop-carried values, and every index, overflow and division check follows from ranged subtypes plus a clamp guard, but the nonlinear integer interpolation arithmetic needs careful bounding so the outlook is plausible rather than likely. The embedded image and text PPM output stand in for opening and saving an image file, which keeps it free of file effects.

Position 703 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The program embeds a small constant RGB image (for example 8x6) as a two-dimensional array of ranged samples, computes the output size as size*16/10, and for each output pixel and channel finds the source cell with integer arithmetic, clamps the neighbour indexes with guards, and blends with integer-weighted bilinear sums divided by the weight total. It prints a P3 PPM header and one text line per output row using Put_Line with integer-to-text conversion into a bounded buffer. About 90 lines.

## Proof obligations to watch

- **index**: Source indexes x*(W-1)/NewW and the +1 neighbour are nonlinear, so the program clamps the neighbour index with an explicit if guard just before use.
- **overflow**: Weighted sums multiply four 0..255 samples by products of weights up to the bounded output dimensions, which fit in Integer because dimensions are ranged subtypes capped at small constants.
- **division**: Divisors are the output width/height, declared as subtypes of positive range, so non-zero follows from types.
- **length**: Each PPM output line is built in a fixed bounded buffer sized for three 3-digit samples per pixel, with the pixel count capped.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars, string building, Put without a newline, procedures and Boolean objects.

## External effects

- **console output** (allowed): The enlarged image is written as plain-text PPM (P3) lines through Put_Line.

Assessed on 2026-10-15 against page revision 415000 of the [task](https://rosettacode.org/wiki/Bilinear_interpolation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
