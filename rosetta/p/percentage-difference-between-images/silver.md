# Percentage difference between images

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged types and guards before each operation, but header parsing and the loop-carried bounded sum need careful guarded shape, and the task needs file-input operations Silver lacks today; decoding the JPEGs is replaced by the permitted bitmap alternative.

Position 1456 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Read both PPM files through an admitted file-input operation into fixed-capacity byte arrays, parse the P6 header with a guarded while loop into width, height and maxval ranged integers, and reject on any malformed header, oversized image, unequal dimensions or truncated data. Sum absolute per-byte differences in a for loop using a guarded bounded accumulator, then compute the percentage in scaled integer arithmetic (sum times 10^7 over 765 times pixel count) and print it with five decimals using integer image and string building. About 170 lines.

## Proof obligations to watch

- **overflow**: The absolute-difference sum is carried through nested loops with no invariant, so each addition is guarded against a declared maximum (about 2e8 for a 512x512 limit) with a visible reject branch, and the scaled percentage product stays inside 64 bits by the bounds on the sum and pixel count.
- **index**: The PPM header parser walks a bounded byte buffer in a while loop, so every index needs a guard against the buffer length before it is used, and the header fields are range-checked before they size the pixel loops.
- **division**: The divisor 765 times width times height is shown nonzero only by rejecting images whose parsed width or height is zero.
- **stack**: Two fixed-capacity pixel buffers of roughly 786 KB each depend on sufficient memory, which is a fixed environmental premise outside the proof.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, Put without a newline, further arguments, exit status and file input.

## External effects

- **files** (allowed): Reads two named binary PPM bitmap files, the bitmap alternative the task allows in place of JPEG decoding.
- **arguments** (allowed): The two image file names come from command-line arguments.
- **console output** (allowed): Prints the percentage difference, or a rejection message when an input is invalid.
- **exit status** (allowed): Unreadable, malformed, oversized or mismatched-size files must end with a specified failure status.

Assessed on 2026-10-15 against page revision 412443 of the [task](https://rosettacode.org/wiki/Percentage_difference_between_images) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
