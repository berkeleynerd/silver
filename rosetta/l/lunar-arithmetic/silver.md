# Lunar arithmetic

**Candidate: proofs plausibly discharge automatically.** Everything is digit-array max/min work with fixed capacity and for-loop indexes, so index and range checks follow from types and capacity guards, though the shift-and-add indexing and bounded conversions need careful guarding. No annotation is needed because the loops can be for loops or live in procedures.

Position 842 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Represent each lunar number as a fixed-capacity array of 24 decimal digits (subtype 0..9) plus no length field, with leading zeros ignored when printing; lunar add is column-wise max and lunar multiply is the sum over the multiplier digits of the digit-wise min row shifted by position, with shift guarded against capacity. Conversion from a bounded Natural to digits uses a for loop with div and mod, distinctness of evens is checked against an array of the previous results, and the stretch search is a bounded loop comparing consecutive squares digit by digit from the most significant position. All tables use embedded example data, fixed bounds and output through Put_Line and Put in a main procedure. About 150 lines.

## Proof obligations to watch

- **index**: The shifted digit index in multiplication (position plus shift) is guarded by an explicit check against the fixed capacity, and any overflow of capacity is a visible rejection rather than truncation.
- **overflow**: Values are held as fixed-capacity digit arrays with Digit subtype range 0..9, so no accumulator is loop-carried except bounded for-loop indexes and a bounded decimal conversion that is guarded by range.
- **termination**: Search loops for distinct evens and the stretch case live in the main procedure (no termination check) or are for loops with fixed upper bounds like 1 to 20000.
- **length**: Building output text from digits needs a bounded buffer sized to the maximum digit count, with its length tracked and guarded before each append.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, Put without a newline, 'Image of scalars, string building, string indexing and case statements.

## External effects

- **console output** (allowed): Prints the sums, products and the three twenty-term sequences plus the stretch answer as text lines.

Assessed on 2026-10-15 against page revision 403797 of the [task](https://rosettacode.org/wiki/Lunar_arithmetic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
