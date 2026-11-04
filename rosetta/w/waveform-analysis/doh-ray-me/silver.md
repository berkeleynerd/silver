# Waveform analysis/Doh ray me

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded integer work over static-size arrays with for loops, so every check follows from types and constants and no loop invariant is needed. The task needs no input beyond embedded sample data, so only console output is required.

Position 356 in the [progression](../../../progression.md#stage-8), in stage 8.

## Approach

Embed a fixed-length constant array of integer waveform samples and a calibration constant, count sign changes in a for loop to estimate frequency in integer tenths of Hz (no floating point), then scan a constant array of 21 band thresholds with a for loop to find the note index. Print the trigraph through an if/elsif chain of String literals, with the plus or minus suffix chosen by comparing the frequency against the band midpoint, via concatenation and Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The zero-crossing count times the sample rate stays in range because the sample array length and rate are static constants and the count is a for-loop accumulator typed to a subtype bounded by the array length.
- **index**: The note lookup scans a constant 21-entry threshold array with a for loop over its own range and picks the note by a guarded comparison chain, so every index is statically in bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, Boolean objects, functions, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the computed average frequency band and the sol-fa trigraph with its plus or minus mark via Put_Line.

Assessed on 2026-10-15 against page revision 373343 of the [task](https://rosettacode.org/wiki/Waveform_analysis/Doh_ray_me) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
