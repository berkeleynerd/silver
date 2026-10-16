# Waveform analysis/Top and tail

**Candidate: proofs plausibly discharge automatically.** All checks follow from a fixed-size buffer, guarded header parsing and range-bounded sample arithmetic with for-loop scans, but many file-derived offsets each need an explicit guard and the program depends on admitted binary file read and write operations that do not exist yet.

Position 1454 in the [progression](../../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Read the input WAV into a fixed-capacity byte array through an admitted file library, validate the RIFF/fmt/data chunk headers (PCM, 16-bit, known channel count) and reject anything else. Scan frames forward and backward with for loops comparing the absolute sample value of every channel against the squelch threshold parsed from an argument, then write the original header with patched chunk sizes followed by the retained frames, preserving the format. About 150 lines.

## Proof obligations to watch

- **index**: Header fields and data offsets come from file contents, so every buffer index must be guarded against the bytes actually read and the fixed buffer capacity before use.
- **overflow**: Chunk sizes, sample values (signed 16-bit assembled from two bytes) and frame offsets are bounded by the buffer capacity and by range guards before arithmetic, so no overflow remains.
- **range**: The squelch argument is parsed with validation into a bounded subtype and rejected if out of range, and the end index search must stay within the data chunk.
- **termination**: Scanning loops are for loops over frame indexes or while loops inside procedures, which need no termination check.
- **other**: Files larger than the fixed buffer capacity must be rejected visibly rather than truncated, and an all-silent input needs a specified outcome such as an empty data chunk.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, characters, arrays, for loops, while loops, procedures, functions, text parsing, further arguments, file input, file output, exit status, string indexing, string building, Boolean objects and 'Image of scalars.

## External effects

- **arguments** (allowed): Input file name, output file name and squelch level are taken from command-line arguments.
- **files** (allowed): The WAV file is read as bytes and a new cropped WAV file is written in the same format.
- **exit status** (allowed): Invalid arguments, unreadable or unsupported WAV input, or a write failure are reported through a rejecting exit status.
- **console output** (allowed): A short message reports the outcome, such as frames kept or why the input was rejected.

Assessed on 2026-10-15 against page revision 384335 of the [task](https://rosettacode.org/wiki/Waveform_analysis/Top_and_tail) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
