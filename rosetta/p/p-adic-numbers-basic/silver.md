# P-Adic numbers, basic

**Candidate: proofs plausibly discharge automatically.** The task is integer-only modular arithmetic over small fixed-size digit arrays, so every check can follow from subtype ranges and explicit guards with visible failure outcomes, but several loop-carried values (remainder, digit sum, denominator count) need careful guarding.

Position 632 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed the example rational pairs, primes and precisions in a constant array of records, represent a p-adic as a fixed-capacity digit array plus a valuation, and implement conversion, carry addition, complement and the repeated-self-addition rational reconstruction as procedures with guarded while and for loops. Inputs outside the supported bounds (zero denominator, p out of range, magnitudes above the limit, no modular inverse) and overflow in the weighted digit sum print a specified failure line instead of a result; digits and rationals are formatted into bounded strings with 'Image and printed with Put_Line. About 230 lines.

## Proof obligations to watch

- **overflow**: The remainder update a - d*b and the Horner digit sum are loop-carried values known only by type range, so each step is guarded explicitly with a visible 'overflow/fail' outcome (as the original already prints 'crat: fail') over bounded Long_Long_Integer operands.
- **division**: mod and division by p or b are discharged by subtypes constraining p to 2..32749 and by rejecting b = 0 and denominators without an inverse before the loop.
- **index**: Digit arrays have a fixed offset range and every digit index i is guarded against the array bounds before use, with the precision-limit exit already in the algorithm.
- **termination**: The valuation-stripping and long-division loops are while loops inside procedures (no termination check), and the denominator-counting loop is a bounded for loop.
- **range**: Valuation shifts and the carry-add loops index with v and k whose bounds are set from guarded subtype values, and the sum's lower index is clamped to the array range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each rational with its prime and precision, the digit expansions, the sum, and the reconstructed rational.

Assessed on 2026-10-15 against page revision 414375 of the [task](https://rosettacode.org/wiki/P-Adic_numbers,_basic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
