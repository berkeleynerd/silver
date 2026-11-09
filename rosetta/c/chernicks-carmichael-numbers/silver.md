# Chernick's Carmichael numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from range types and guards before arithmetic, and the loops sit in procedures so no variant is required, but the loop-carried candidate and trial-division arithmetic need careful bounding, so discharge is plausible rather than certain.

Position 259 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure Is_Prime_Proc(P, Result) does trial division with a while loop (d <= P / d, d increasing by 2), and a procedure Is_Chernick(N, M, Result) checks the factors 6m+1, 12m+1 and 2^k*9m+1 for k = 2..n-1, computing each factor in a bounded 64-bit range type. The main loop runs n = 3..9, steps m in multiples of 2^(n-4) (or 1) up to a documented cap, and prints m and the factor list via 'Image, or a stated not-found message if the cap is hit. About 90 lines.

## Proof obligations to watch

- **overflow**: Factors 2^k*9m+1 are computed from a candidate m that is loop-carried, so m is declared in a range type capped well below 2^63/1152 and the search ends with a visible not-found outcome when the cap is reached.
- **overflow**: Trial division avoids d*d by testing d <= p / d, which is safe in range-bounded 64-bit arithmetic, though the provers must handle the division.
- **termination**: The unbounded-looking search and the primality loop are while loops placed in procedures, which get no termination check, whereas a primality function with a while loop would fail one.
- **other**: The full product for n = 9 exceeds 64 bits, so the program prints the factorized form (as the task allows) rather than needing big numbers.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints m and the factorized form of a(n) for n = 3..9 as text lines.

Assessed on 2026-10-15 against page revision 415328 of the [task](https://rosettacode.org/wiki/Chernick's_Carmichael_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
