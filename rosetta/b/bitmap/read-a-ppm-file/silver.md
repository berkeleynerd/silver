# Bitmap/Read a PPM file

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged subtypes, fixed maximum dimensions and guards in the header parser, with no annotation needed, but the loop-carried parse state and computed pixel indexes require careful program shape and an admitted binary file-read and file-write library.

Position 1426 in the [progression](../../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program takes a file name from the first argument, reads bytes through a bounded file-read operation into a fixed buffer, and parses the P6 magic, width, height and maxval in a procedure with a while loop that skips whitespace and comments and rejects anything malformed or beyond the fixed maximum dimensions. Pixels are stored in a two-dimensional array of RGB record components with 0..255 subtypes, converted to gray by an integer weighted sum, and written back as a P6 file built in a bounded output buffer. Every invalid or truncated input produces a specified message and nonzero exit status. About 170 lines.

## Proof obligations to watch

- **overflow**: Header number parsing accumulates digits in a loop, so each step is guarded by a digit-count and value limit that rejects oversized dimensions rather than clamping them.
- **index**: Pixel indexes are computed from row, column and channel, so they are held in ranged subtypes bounded by the fixed maximum image size and for loops run over the array's own ranges.
- **termination**: Header scanning uses while loops, which is acceptable only because they live in procedures that get no termination check.
- **length**: The header and pixel data are read through a library file operation that reports how many bytes were obtained, and a short read is rejected before any pixel is used.
- **overflow**: The luminance weighted sum is nonlinear but bounded by 0..255 channel subtypes and a fixed divisor, so overflow checks discharge from types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, file input, file output, exit status, Boolean objects and conditional expressions.

## External effects

- **files** (allowed): Reads a binary P6 PPM file by name and writes the grayscale result as a PPM file.
- **arguments** (allowed): The input file name is taken from the first command-line argument.
- **console output** (allowed): Reports success or the specific rejection reason for malformed or oversized input.
- **exit status** (allowed): A rejected or unreadable file yields a nonzero exit status.

Assessed on 2026-10-15 against page revision 414087 of the [task](https://rosettacode.org/wiki/Bitmap/Read_a_PPM_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
