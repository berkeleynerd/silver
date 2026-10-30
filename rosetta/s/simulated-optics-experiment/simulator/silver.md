# Simulated optics experiment/Simulator

**Candidate: proofs likely to discharge automatically.** Everything is a bounded for loop over a fixed pulse count with a wraparound generator and constant integer thresholds, so every check follows from types and static bounds. The only extra is the documented fixed-point precision replacing floating-point trigonometry.

Position 1274 in the [progression](../../../progression.md#stage-21), in stage 21.

## Approach

A 64-bit modular linear congruential generator is advanced in a procedure; each of 1000 loop iterations draws a source bit, two splitter-setting bits and four detector draws, compared against a constant table of integer intensity thresholds (cos-squared and sin-squared of the fixed angle differences, which take only a few values). The seven 0/1 values are put in a 13-character String built by concatenation of characters and printed with Put_Line after a header line holding the count. About 90 lines.

## Proof obligations to watch

- **overflow**: The generator state lives in a 64-bit modular type whose wraparound is defined, and uniform values are derived by shifting down to a fixed-point scale, so no overflow check can fail.
- **floating point**: The program avoids floating point by embedding the fixed cosine-squared and sine-squared intensities as integer thresholds on a 2**24 scale, so no elementary functions or float checks arise.
- **range**: Table indices are small subtypes (source setting, splitter setting) set from comparisons with the random value, so each index is in range by construction.

## Language surface recorded by this assessment

Modular types, ranged subtypes, integers, integer division, arrays, for loops, procedures, functions, string building, 'Image of scalars and case statements.

## External effects

- **console output** (allowed): The count line and 1000 data lines are written to standard output with Put_Line.

Assessed on 2026-10-15 against page revision 408293 of the [task](https://rosettacode.org/wiki/Simulated_optics_experiment/Simulator) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
