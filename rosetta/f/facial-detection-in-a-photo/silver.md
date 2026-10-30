# Facial detection in a photo

**Candidate: proofs plausibly discharge automatically.** The task needs no construct outside SPARK. Every check depends on file-derived values or loop-carried sums, which careful guards and clamping can cover without annotations, but the JPEG decoder, the integral image and the floating-point cascade evaluation make discharge depend on how carefully the program is shaped.

Position 1466 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program reads the JPEG into a fixed-capacity byte array and decodes baseline Huffman/IDCT into a 2-D grayscale array whose maximum dimensions are documented. Every header field and table reference is validated, and an unsupported or corrupt file is rejected with a message. It then builds integral and squared-integral images and runs a Viola-Jones Haar cascade, with the cascade data embedded as constant record arrays, over sliding windows at a for-loop-driven set of scales. Overlapping hits are grouped in a fixed-capacity box array, and the count and each [X, Y, W, H] box are printed. About 2500 lines.

## Proof obligations to watch

- **index**: Huffman code lengths, table selectors, component counts, image dimensions and run-lengths come from untrusted file bytes, so the program checks each one against its declared range just before using it as an index and rejects the file if a check fails.
- **overflow**: Dequantized coefficients, integer IDCT sums and integral-image sums are loop-carried, so the program clamps them or guards them against their documented maximum (255 times the pixel capacity) before each store, with an explicit error report on the branch that cannot be reached in practice.
- **range**: IDCT output and YCbCr-to-gray conversion are clamped to 0..255, which is what the JPEG specification itself requires, so the check discharges and no required result changes.
- **floating point**: Window variance from the squared integral image is guarded to be positive before Sqrt and the division by it, and scaled feature sums are bounded by the declared ranges of the window size and pixel values.
- **length**: The bit reader and the marker scanner advance through a fixed-capacity byte buffer, so each read needs a guard against the file length that leads to a visible rejection of a truncated file.
- **stack**: The pixel, integral-image and cascade arrays are sized to a documented maximum and declared at package level, so they do not sit on the stack, and no recursion is used.
- **termination**: Entropy decoding and marker scanning use while loops, which are placed in procedures, and every function uses only for loops, so no variant is needed.
- **other**: If the photograph turns out to be progressive JPEG rather than baseline, the decoder roughly doubles in size, though its proof obligations stay the same kind.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, floating point, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, packages, 'Image of scalars and file input.

## External effects

- **files** (allowed): The program reads the photograph AOBABA176.jpg from a local file and decodes it itself.
- **console output** (allowed): It prints the number of faces detected and one bounding box [X, Y, Width, Height] per face.

Assessed on 2026-10-15 against page revision 415229 of the [task](https://rosettacode.org/wiki/Facial_detection_in_a_photo) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence low. The inclusion policy is in `rosetta/coverage.json`.
