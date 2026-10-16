# Imaginary base numbers

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded-integer work in a procedure with fixed-count for loops, so every check follows from subtype ranges and a few input guards, though the carry and weight arithmetic need careful range shaping.

Position 841 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the 1..16 and negated integer and imaginary test values, represent each Gaussian integer as two bounded Integer subtypes, and encode it into a fixed array of twelve base-2i digits (0..3) using a for loop that repeatedly takes a mod -4 remainder with carry correction on the real and imaginary parts at alternating positions. A guard rejects values outside the range or with a nonzero residual after the digits are used up, then a decoding procedure sums digit times (2i)**k using a rotating weight, and the strings are built in a bounded buffer and printed with Put_Line. The fractional stretch goal is covered by allowing an odd imaginary part to produce a single digit after the point. About 130 lines.

## Proof obligations to watch

- **overflow**: Real and imaginary parts are subtypes bounded to about plus or minus 1000, so the carry adjustment and the powers-of-2i weights (at most 2**12 times digit 3) stay within Integer, but the nonlinear multiplications need those type bounds for the provers.
- **range**: The digit is the result of a mod-4 adjustment into 0..3 and is converted to a Character by 'Pos arithmetic, which the provers can discharge only with a guard or the declared digit subtype.
- **index**: Digit positions are written by a for loop over a fixed number of positions (12) so the index always lies in the array bounds and no while loop with a computed index is needed.
- **termination**: Using for loops with a fixed digit count avoids any variant, and the conversion is a procedure, so no termination check arises.
- **other**: Inputs outside the supported range or not representable in the fixed digit count must be rejected visibly with a printed message, which is a specified outcome and not a silent narrowing.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, for loops, procedures, functions, string building, string indexing, 'Image of scalars and case statements.

## External effects

- **console output** (allowed): The conversion tables and round-trip results are printed as text lines.

Assessed on 2026-10-15 against page revision 412118 of the [task](https://rosettacode.org/wiki/Imaginary_base_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
