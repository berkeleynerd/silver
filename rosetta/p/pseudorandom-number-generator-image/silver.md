# Pseudorandom number generator image

**Candidate: proofs likely to discharge automatically.** The checks that matter are the modular arithmetic, which wraps and never overflows, the mod-256 conversion, which has a static range, and the for loops, which have static bounds, so every proof obligation is routine. What Silver lacks is surface, chiefly modular types and named-file output, not provability.

Position 1421 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

A Main procedure keeps a fixed-seed linear congruential generator in a 32-bit modular variable and opens a PPM file through an admitted file-output library. Nested for loops over 0 .. 249 rows and columns advance the generator three times per pixel, take the byte (State / 65536) mod 256 for red, green and blue, and write it with 'Image. If the file cannot be opened or written, the program reports a specified failure message. About 40 lines.

## Proof obligations to watch

- **overflow**: The LCG state is a 32-bit modular type, so its multiply-add wraps by definition and the wraparound is the generator's specified behavior, not a suppressed check.
- **range**: Each color byte is (State / 2**16) mod 256 converted to a 0..255 subtype, and the static mod bound makes the conversion provably in range.
- **other**: Failure to create or write the output file must be a specified outcome of the admitted file library, reported to the console, rather than an exception.

## Language surface beyond today's Silver

Integers, modular types, integer division, ranged subtypes, for loops, 'Image of scalars and file output.

## External effects

- **files** (allowed): The program writes the generated 250x250 image as a plain-text PPM (P3) file through an admitted file-output operation with a specified failure outcome.
- **console output** (allowed): A one-line status message reports whether the image file was written or the write was rejected.

Assessed on 2026-10-15 against page revision 414826 of the [task](https://rosettacode.org/wiki/Pseudorandom_number_generator_image) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
