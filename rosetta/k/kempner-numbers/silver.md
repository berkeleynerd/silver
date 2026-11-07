# Kempner numbers

**Candidate: proofs likely to discharge automatically.** The first fifty values need only small bounded modular arithmetic inside for loops, so every check follows from declared ranges and the static loop bounds. The 64-bit stretch with prime factorization is optional and left out.

Position 875 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

For each n in 1..50 a for loop over k in 1..50 updates f := (f * k) mod n starting from f = 1 mod n and exits when f = 0, recording k as S(n); S(1) is set to 1 explicitly by the convention. Values are stored in a 50-element Integer array or printed directly with Put and Integer'Image, ten per line using a column counter. The stretch range beyond 32 bits is treated as optional and omitted, so every operand stays in small declared ranges. About 35 lines.

## Proof obligations to watch

- **overflow**: The running value f = k! mod n is kept in a subtype 0..50 and the product f*k is at most 50*50, so the multiplication is bounded by types without an invariant.
- **division**: The divisor n is the loop index of a for loop over 1..50, so it is statically nonzero.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, procedures, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the fifty Kempner numbers as five rows of ten.

Assessed on 2026-10-15 against page revision 401651 of the [task](https://rosettacode.org/wiki/Kempner_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
