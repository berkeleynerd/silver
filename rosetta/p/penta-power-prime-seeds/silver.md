# Penta-power prime seeds

**Candidate: proofs plausibly discharge automatically.** Every check follows from types and bounded for loops, but the 25-digit primality test needs fixed-capacity big-number arithmetic carried through nested loops, so discharge depends on careful program shape and the solver handling limb arithmetic, with no annotation required.

Position 1396 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Use a fixed-size Boolean sieve (bounded to the search limit of about 1.6 million, which covers the first thirty seeds) to test n+2 and 2n+1 quickly, then test n^2+n+1, n^3+n+1 and n^4+n+1 with a deterministic Miller-Rabin over a fixed-capacity limb-array number type with bounded add, compare and double-and-add modular multiply. A procedure with a while loop walks odd n, counts hits until thirty, and prints each with Put_Line using bounded string building of the integer image; the over-ten-million stretch is left out since it needs a 21-million sieve. About 260 lines.

## Proof obligations to watch

- **overflow**: n^4+n+1 for n up to about 1.6 million reaches 5e24, so it is carried in a fixed-capacity multi-limb number whose limb products use a wider type or split halves, with every carry bounded by the limb type range.
- **termination**: The search loop and the modular exponentiation loops are in procedures (no termination check), and every function uses only for loops over fixed bounds.
- **range**: The Miller-Rabin modular multiplication is done by bounded double-and-add over a fixed number of bits, so each intermediate stays below twice the modulus and fits the fixed capacity without an invariant.
- **index**: Limb loops iterate over the array's own range and the sieve index is guarded by an explicit bound check that rejects with a visible outcome.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, Boolean objects, arrays, for loops, while loops, procedures, functions, big numbers, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 30 seeds as text lines.

Assessed on 2026-10-15 against page revision 413843 of the [task](https://rosettacode.org/wiki/Penta-power_prime_seeds) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
