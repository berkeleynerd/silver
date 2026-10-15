# Color separation

**Candidate: proofs likely to discharge automatically.** All arithmetic is on 0..255 subtypes with loops over the array's own ranges, and the only division is guarded by a test just before it, so every check follows from types and guards. The task does not require a specific image format or display, so embedded data and text output meet it.

Position 672 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The program embeds a small fixed-size image as a constant two-dimensional array of pixel records with Red, Green and Blue components in a 0..255 subtype, then uses nested for loops over the array's own index ranges to print the RGB layers (one channel kept, others zero), the CMY layers (255 minus channel) and the naive CMYK layers. For CMYK, K is the minimum complement and C, M and Y are scaled by 255 / (255 - K) under an explicit K /= 255 guard, with a white result otherwise. Output is a procedure that prints each pixel's layer values as text rows using Image conversion and Put, so no image file is needed. About 90 lines.

## Proof obligations to watch

- **division**: The CMYK divisor 255 - K is nonzero only when K /= 255, so the program guards the division with an explicit if on K just before computing C, M and Y.
- **range**: Products such as (Rc - K) * 255 stay within 0..65025 because every channel is a 0..255 subtype and K is the minimum complement, so conversions back into the channel subtype discharge from these bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, records, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Each separated layer is printed as rows of numeric channel values on standard output.

Assessed on 2026-10-15 against page revision 414876 of the [task](https://rosettacode.org/wiki/Color_separation) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
