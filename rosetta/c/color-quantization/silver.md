# Color quantization

**Candidate: proofs plausibly discharge automatically.** Everything can use iteration, bounded arrays and guarded loops in procedures with no recursion, so checks follow from subtype ranges and guards, but the many loop-carried indexes and PPM parsing make the program shape delicate, and it needs file input and argument support that Silver lacks today.

Position 1475 in the [progression](../../progression.md#stage-29), in stage 29.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program reads a PPM image named by the first argument into a fixed-capacity array of RGB records after validating its header and size, then runs iterative median cut over an index array. Each of at most 16 boxes is split by sorting its index range on the widest channel with an insertion sort in a procedure, and each box's mean color is computed under a count greater than zero guard. It prints the 16 palette entries with Put_Line and Image, and rejects invalid or oversized input with a specified failure outcome. About 230 lines.

## Proof obligations to watch

- **index**: Pixel, box and sort-index accesses use subtypes bounded by a fixed pixel capacity and guards before each use, with the image dimensions validated against that capacity at load.
- **overflow**: Per-channel sums over at most the fixed capacity of 0..255 values fit in Integer, and each loop-carried accumulator is bounded by its subtype or a guard.
- **termination**: Sorting is an iterative insertion sort using loops inside procedures only, so no function loop needs a variant.
- **division**: Mean division by box population is guarded by a count greater than zero, and empty boxes are skipped visibly.
- **range**: Loop-carried box start and end indexes and the box count are held in ranged subtypes with explicit guards before each split, because no invariant can be written.
- **other**: The image is limited to a documented pixel capacity, so larger inputs get a specified rejection rather than being truncated.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, packages, Put without a newline, file input, further arguments and exit status.

## External effects

- **files** (allowed): Reads the input image file (a PPM rendering of the frog, since PNG decoding is out of scope) named by the first argument.
- **arguments** (allowed): The first command-line argument names the image file.
- **console output** (allowed): Prints the 16 resulting palette colors as text lines.
- **exit status** (allowed): Unreadable, oversized or malformed image input is rejected with a nonzero status.

Assessed on 2026-10-15 against page revision 413978 of the [task](https://rosettacode.org/wiki/Color_quantization) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
