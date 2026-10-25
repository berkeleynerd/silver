# Munching squares

**Candidate: proofs likely to discharge automatically.** All indexes are for-loop variables over static ranges and the xor result lives in a mod 256 type that exactly matches the table range, so every check follows from types and bounds. The only dependency is an admitted file-output operation with specified failure outcomes.

Position 1416 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Use a 256x256 two-dimensional array of a mod 256 pixel type and a constant 256-entry color table built from a simple formula. Nested for loops over x and y compute x xor y, look up the table, and store RGB bytes into a fixed-size byte buffer. The buffer is then written as a binary PPM file, with the failure outcome handled by rejecting. About 45 lines.

## Proof obligations to watch

- **range**: Pixel colors come from x xor y on a 256-valued modular type indexing a constant color table of 256 entries, so the index range follows from the type.
- **index**: Output buffer position is computed from for-loop indexes bounded by a 256x256 fixed array, so index checks follow from the static bounds.
- **other**: File-write failure must be reported as a specified visible outcome through the admitted file-output operation.

## Language surface recorded by this assessment

Integers, modular types, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, file output, characters and string building.

## External effects

- **files** (allowed): Writes the rendered pattern as a PGM or PPM image file (or text art could use console-output).

Assessed on 2026-10-15 against page revision 414973 of the [task](https://rosettacode.org/wiki/Munching_squares) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
