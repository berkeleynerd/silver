# Harmonic series

**Candidate: proofs plausibly discharge automatically.** Every check is a division by a ranged positive index or a guarded Float addition, and the while loops live in procedures so no variant is needed; the plausible rating reflects floating-point accumulation in loops and the need for float-to-text formatting.

Position 968 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Use a ranged subtype for the term index (1 .. 20000) and a Float accumulator; a procedure with a for loop prints the first 20 harmonic numbers as index, arrow and Float image via string concatenation. A second procedure loops over thresholds 1 through 10 as for-loop values, and for each runs a while loop adding 1.0 / Float (N) with guards on the accumulator and the index until the sum exceeds the threshold, then prints the position and value. About 55 lines.

## Proof obligations to watch

- **floating point**: The Float accumulator is loop-carried so the prover knows only its type, hence each addition is guarded by a visible test that the sum is below a fixed limit like 1000.0 before adding 1.0 / Float (N).
- **division**: The divisor Float (N) comes from a ranged subtype N of 1 .. 20000 whose lower bound excludes zero, so it discharges from types.
- **range**: The position counter in the while loop is loop-carried, so an explicit guard that it is below the subtype's upper bound precedes each increment, with a specified stop outcome at the limit of 20000 terms.
- **other**: Float'Image output must be bounded in length for the output buffer, and the library must admit float-image formatting with a documented width.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, floating-point images, 'Image of scalars, string building, for loops, while loops, procedures, functions and Boolean objects.

## External effects

- **console output** (allowed): Prints the first 20 harmonic numbers and the first positions exceeding 1 through 10, one line each.

Assessed on 2026-10-15 against page revision 415512 of the [task](https://rosettacode.org/wiki/Harmonic_series) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
