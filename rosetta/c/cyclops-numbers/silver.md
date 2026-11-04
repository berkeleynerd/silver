# Cyclops numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged integers and for-loop bounds with guards before table writes, but the nested enumeration, multiplication of bounded values and several loop-carried counters need careful program shape and a long runtime in the prover-friendly style.

Position 943 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Enumerate cyclops numbers in increasing order by half-length k (1 to 4 digits), left half and right half each ranging over k-digit values with no zero digit (tested by a for-loop digit function), composing the value as left*10^(k+1)+right with 0 as the middle. Primality is trial division in a for loop over 2..11000 with exit when f*f exceeds v; blind form is left*10^k+right and palindrome test compares right with the digit reversal of left. Four counters and 50-entry arrays record the first 50 of each class, then the first value above 10,000,000 and its index are recorded, with 0 (the first cyclops number) handled as a special initial entry and rows of ten printed via Put and Put_Line using 'Image.

Key parameters: tables are fixed arrays of 50 plus four result pairs. About 170 lines.

## Proof obligations to watch

- **overflow**: Candidate values stay below 10^9 by ranged subtypes and half-length loops capped at 4 digits, and the trial-division product f*f is bounded by the loop range 2..11000 so it fits in 32 bits.
- **termination**: Primality and digit tests use for loops with exit when inside functions, and only the top-level search loops are while loops in the Main procedure, which gets no termination check.
- **range**: Counters for the 50-entry tables and the running index (up to about 766505) are bounded by guards before each increment and by a ranged index subtype.
- **index**: Result-table writes are guarded by count < 50 just before the store, and digit extraction uses mod 10 on bounded values.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints four lists of 50 numbers plus four above-ten-million results with their indexes.

Assessed on 2026-10-15 against page revision 414145 of the [task](https://rosettacode.org/wiki/Cyclops_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
