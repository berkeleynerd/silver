# Sturmian word

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded integer arithmetic with ranges set by declared limits, and the only loop-carried hazards (buffer position, search bounds) are covered by types and explicit guards, so no annotation is needed, but the nonlinear square-root search needs careful range shaping.

Position 566 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the data (m=13, n=21, and a=5, b=1, m=-1, n=2 with k=32) as constants of declared range subtypes; a procedure computes floor(k*x) exactly, using a bounded binary-search integer square root of b^2*k^2*a for the quadratic case and plain integer division for the rational case. A for loop over k appends '0' or "10" into a fixed-size Character buffer, guarding capacity before each append, and stopping when k*m is divisible by n for the rational case; x>1 is handled by swapping m and n and inverting the characters. The buffer slice is printed with Put_Line. About 95 lines.

## Proof obligations to watch

- **overflow**: b*b*k*k*a and mid*mid are computed in a 64-bit range type whose declared bounds on a, b, m, n and k (k at most 32) keep every product within range, so guards at entry suffice.
- **range**: Floor division of a possibly negative numerator (m is negative for the golden ratio) is made safe by adding a bounded non-negative offset before dividing, with a visible rejection if the numerator is out of range.
- **termination**: The integer square root uses a binary search while loop inside a procedure, which gets no termination check, and the other loops are for loops.
- **index**: The output buffer index is a loop-carried value that is guarded by a capacity check before each append of one or two characters, since no invariant can be written.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The Sturmian words for the embedded rational 13/21 and for the inverse golden ratio are printed with Put_Line.

Assessed on 2026-10-15 against page revision 392581 of the [task](https://rosettacode.org/wiki/Sturmian_word) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
