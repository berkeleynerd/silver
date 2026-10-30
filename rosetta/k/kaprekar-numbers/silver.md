# Kaprekar numbers

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded by the declared ranges (squares below 10**8), and both loops are for loops over static ranges, so every check discharges without invariants and nothing needs termination proof. The optional million-number count and base 17 parts are left out.

Position 121 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A constant array holds the powers of ten 10 through 10**8, and a for loop over N in 1 .. 9_999 computes Sq = N*N, with N = 1 treated as Kaprekar directly. An inner for loop over the table splits Sq into Sq / P and Sq mod P, and a split is accepted only when the right part is greater than zero, the left part is greater than zero and the two parts sum to N, which also covers the zeros-only rule. Each hit is printed via Integer'Image, a Count variable is incremented, and a final Put_Line prints the total; no while loops or recursion are used. About 35 lines.

## Proof obligations to watch

- **overflow**: N is a subtype 1 .. 9_999 so N*N is at most about 10**8 and fits in a 32-bit Integer, and the count is bounded by the loop range, so each check follows from types.
- **index**: The powers-of-ten table is indexed only by a for-loop variable over the table's own range, so no guard is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each Kaprekar number below 10,000 and the total count with Put_Line.

Assessed on 2026-10-15 against page revision 414284 of the [task](https://rosettacode.org/wiki/Kaprekar_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
