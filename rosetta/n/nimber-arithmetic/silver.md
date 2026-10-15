# Nimber arithmetic

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded 16-bit modular xor and shifts with array indexes from ranged subtypes, so checks are routine except for the careful table fill order that replaces the recursion without needing a variant.

Position 1305 in the [progression](../../progression.md#stage-23), in stage 23.

## Approach

Use a 16-bit modular type for nimbers, nim-addition as xor, and nim-multiplication as the xor over set bit pairs of a precomputed 16x16 table of products of powers of two, filled in procedure loops in an order where dependencies are already available. Output rows are built in bounded String buffers with right-aligned 'Image values and printed with Put_Line, then the 21508 and 42689 sum (62149) and product (35202) are printed. About 110 lines.

## Proof obligations to watch

- **termination**: The recursive nim-product is replaced by a bottom-up fill of a 16x16 table of products of powers of two, using only for loops and a bounded while loop inside a procedure, so no termination check arises.
- **index**: Table indexes are bit positions of ranged subtype 0..15 and results are 16-bit modular values, so bit-pair loops index the table within its own range.
- **range**: The fill order must make every referenced entry already computed, and the entries for (i-h, j-h) combined with the constant 3*2^(h-1) need indices kept in 0..15, which requires guards on the shifted exponents.
- **overflow**: All nim values below 65536 stay in a 16-bit modular type where xor and shifts cannot overflow, and ordinary products only occur for disjoint power-of-two pairs, giving 2^(i+j) with i+j at most 30 so a 32-bit modular type is needed for them or the pair is skipped by a guard.

## Language surface beyond today's Silver

Modular types, ranged subtypes, arrays, multidimensional arrays, for loops, while loops, procedures, functions, integers, integer division, 'Image of scalars, string building, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the 16x16 nim-addition and nim-multiplication tables and the two five-digit results with Put_Line.

Assessed on 2026-10-15 against page revision 394866 of the [task](https://rosettacode.org/wiki/Nimber_arithmetic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
