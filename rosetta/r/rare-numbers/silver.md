# Rare numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges and guards just before each operation, but the reversal accumulator and square-root search are loop-carried nonlinear arithmetic needing careful range-bounded types, and running to 2e9 is slow though not a proof issue.

Position 400 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A procedure loops a candidate n over a declared 64-bit range from 10 up to a documented limit (about 2.1e9), computing the digit reversal in a for loop over at most 10 digits, then keeps n only if n>r and both n+r and n-r pass a binary-search integer square root test. Found numbers are counted in a small bounded counter, printed with Put_Line using 'Image, and the loop stops after five (or eight) are found, or reports the limit reached. About 90 lines.

## Proof obligations to watch

- **overflow**: The reversal accumulator r*10+d is loop-carried and knows only its type range, so r is a 64-bit subtype bounded to 10 digits and the update is guarded or reduced so the multiply cannot overflow, with the 10-digit limit being a documented resource bound.
- **overflow**: The perfect-square test needs an integer square root; a binary search over a subtype bounded by 2**32 keeps mid*mid within 64 bits without an invariant.
- **termination**: The unbounded-looking search and binary-search while loops must live in procedures, since functions would need variants; the outer search is bounded by a range-typed counter with an explicit stop at the limit.
- **range**: Values around 2.04e9 exceed 32-bit Integer, so a 64-bit declared range is needed and n+1 must be guarded at the upper limit with a visible outcome.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each rare number found, one per line.

Assessed on 2026-10-15 against page revision 414431 of the [task](https://rosettacode.org/wiki/Rare_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
