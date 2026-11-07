# Geohash

**Candidate: proofs plausibly discharge automatically.** All checks follow from subtype ranges, for-loop bounds and a few guards, but the float midpoint range proof and the bit-accumulation shape need care without invariants, so discharge is plausible rather than certain.

Position 866 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the four test coordinates and precisions in constant arrays; latitude and longitude are subtype-constrained Long_Float values and precision is a subtype 1..22. An Encode procedure fills a bounded Boolean bit array by alternately bisecting longitude and latitude in a for loop over 1..5*Precision, then groups each five bits into a guarded code and indexes the base-32 alphabet constant into a fixed 22-character buffer, and the main procedure prints the used part of the buffer with Put_Line. About 70 lines.

## Proof obligations to watch

- **floating point**: Midpoint (mn+mx)/2 must stay inside the declared subtype range -180.0..180.0 for loop-carried mn and mx, which holds by type bounds but needs the float provers to show the average of two in-range values is in range.
- **overflow**: The 5-bit digit accumulator is loop-carried, so doubling it is guarded by an explicit check before each shift (or the five steps are unrolled with fixed weights), rejecting otherwise.
- **index**: Bit-array and output-buffer indices are computed from precision times 5, so precision is a subtype capped at 22 and indices come from for-loop ranges over the arrays.
- **range**: Alphabet lookup uses a code subtype 0..31 into a 32-character constant string; the guarded accumulator keeps the code in range.

## Language surface recorded by this assessment

Floating point, ranged subtypes, integers, arrays, characters, string building, string indexing, for loops, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints each test coordinate's geohash with Put_Line.

Assessed on 2026-10-15 against page revision 415203 of the [task](https://rosettacode.org/wiki/Geohash) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
