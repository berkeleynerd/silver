# Angles (geometric), normalization and conversion

**Candidate: proofs plausibly discharge automatically.** All indexes come from for loops over the array range and all float operations are bounded by the subtype and loop guards, but float arithmetic and float-to-text formatting need careful range-shaped code, so discharge is plausible rather than routine.

Position 1111 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the twelve test values in a constant array of a bounded Float subtype, and implement normalization as procedures using while loops that add or subtract one turn only while the magnitude is at least a turn, preserving sign. Conversions are functions multiplying by constant factors, and a for loop over the array's own range prints each row of four tables through a float formatting routine into fixed-width text. About 170 lines.

## Proof obligations to watch

- **floating point**: Multiplications by conversion factors and subtractions stay finite because every angle is a subtype bounded to about +/-1.0E7 and normalization shrinks magnitude, though provers must handle float range checks.
- **termination**: Normalization loops are written as procedures with out parameters so no termination check applies, and each loop's guard keeps the value inside the subtype so no variant is needed.
- **range**: Loop-carried tmp is reassigned to the subtype only after a guard (tmp >= 360.0 or tmp <= -360.0) makes the result in range, which holds from the loop condition alone.
- **length**: Float-to-text formatting into fixed-width bounded buffers with 8 decimals needs a library or hand-built routine whose output length is provably bounded by the value range.

## Language surface beyond today's Silver

Floating point, floating-point images, ranged subtypes, arrays, for loops, while loops, procedures, functions, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints four tables of the twelve test angles with normalized and converted values.

Assessed on 2026-10-15 against page revision 413638 of the [task](https://rosettacode.org/wiki/Angles_%28geometric%29,_normalization_and_conversion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
