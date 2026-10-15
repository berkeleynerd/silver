# Prime reciprocal sum

**Candidate: proofs plausibly discharge automatically.** No annotation is needed because all arithmetic is fixed-capacity digit-array loops in procedures with types and guards bounding each step, but the amount of bignum division and modular exponentiation makes discharge depend on careful program shape rather than being routine.

Position 1416 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Represent numbers as a record of a bounded digit array plus a length in a fixed capacity (about 160 decimal digits), keeping the sum as a numerator/denominator pair of such numbers. A procedure loop computes the smallest candidate prime from ceil(den/(den-num)) rounded up to odd, steps by 2 under a Miller-Rabin test using bignum multiply, divide-with-remainder and modular exponentiation, then updates the fraction and prints the term, abbreviating anything over 40 digits. Every digit index and carry is guarded by capacity checks, with an overflow outcome that rejects visibly instead of altering results. About 420 lines.

## Proof obligations to watch

- **overflow**: Fixed-capacity digit-array add, multiply and long division carry values through loops, so each digit step is kept in a small subtype whose product-plus-carry fits Integer, which the types alone bound.
- **index**: Schoolbook multiplication and division index digit arrays by computed positions, so every index is guarded by an explicit capacity check just before use, with overflow past the capacity reported as a visible limit-reached outcome.
- **termination**: The prime search and Miller-Rabin loops are while loops, so they live only in procedures (no termination check) and the digit loops are for loops; no function contains a while loop or recursion.
- **other**: Computing ceil(1/(1-sum)) needs big-by-big division and modular exponentiation for primality, which is nonlinear loop-carried arithmetic that stays within provable ranges only through per-step guards and a fixed digit capacity sized for 10 terms (about 160 digits).
- **other**: Primality is probabilistic Miller-Rabin with fixed bases, which the output must declare.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Prints each term, abbreviated to first 20 digits, last 20 digits and digit count when over 40 digits.

Assessed on 2026-10-15 against page revision 413856 of the [task](https://rosettacode.org/wiki/Prime_reciprocal_sum) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
