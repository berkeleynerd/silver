# Hashtron inference

**Candidate: proofs likely to discharge automatically.** Everything is fixed-size for loops over constant arrays with wraparound modular arithmetic, so no loop-carried value needs an invariant and no run-time check can fail. The cost is only the surface growth (modular types, 2-D arrays, image output), not any proof difficulty.

Position 1287 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

Embed both programs as constant two-dimensional arrays of 32-bit modular values (a 1x2 test program and the 256x2 square-root program), with a Hashtron function on a 32-bit modular type using shifts and xor, and Lemire reduction in a 64-bit modular type. An Inference function loops over output bits and over program rows with for loops, accumulating the output bits in a 64-bit modular value. The main procedure prints the test result with 'Image, then 256 square-root results in rows of 16 using Put and Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: All hash mixing, subtraction of the salt and Lemire reduction use 32-bit and 64-bit modular types where wraparound is defined and carries no check, and the 32x32 product is formed in a 64-bit modular type so it cannot lose bits.
- **index**: Program rows are read only through for loops over the constant array's own range and output bit positions run over 0..63, so shift amounts and indices are statically in range.

## Language surface beyond today's Silver

Modular types, ranged subtypes, integers, integer division, arrays, multidimensional arrays, for loops, functions, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the 64-bit test result and the 16x16 table of square-root results to standard output.

Assessed on 2026-10-15 against page revision 413740 of the [task](https://rosettacode.org/wiki/Hashtron_inference) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
