# Check Machin-like formulas

**Candidate: proofs plausibly discharge automatically.** The task needs exact big-integer arithmetic, which Silver can do with fixed-capacity limb arrays whose carries and indexes are bounded by types and for loops, so no annotation is needed, though the careful signed big-number shape makes it plausible rather than likely.

Position 1391 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Store each formula as a record of up to five (multiplier, numerator, denominator) terms in a constant array, and compute exact tan of the sum by multiplying Gaussian integers (b + a i) raised to each multiplier (conjugate for negative terms), via repeated multiplication of a fixed-capacity sign-magnitude big integer pair by small coefficients in for loops. A formula is correct when the imaginary and real parts are equal and positive, which avoids rational division and gcd entirely. A guard on the top limb rejects capacity overflow, and the main procedure prints a verdict line for each of the 16 formulas, the last being the incorrect one. About 230 lines.

## Proof obligations to watch

- **overflow**: Each limb product (limb up to 9999 times a coefficient up to 12944 plus carry) stays inside a declared 64-bit range type, and carries are bounded by their type so propagation through the loop needs no invariant.
- **index**: Limb loops are for loops over the array's own range, and carry out of the top limb is tested with an explicit guard that rejects the equation as overflowing capacity instead of indexing past the end.
- **range**: Signed big values use sign-magnitude, and subtraction compares magnitudes first so no limb goes negative.
- **other**: Capacity must hold roughly 1200 decimal digits (total multiplicity 283 of factors up to 12944), so about 350 limbs of base 10000 are declared as a documented resource limit with a visible rejection on overflow.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, big numbers, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one verdict line per formula with Put_Line.

Assessed on 2026-10-15 against page revision 415258 of the [task](https://rosettacode.org/wiki/Check_Machin-like_formulas) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
