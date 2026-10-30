# Erdős-primes

**Candidate: proofs plausibly discharge automatically.** All data is fixed-size with static bounds and the only loop-carried arithmetic is the factorial product, which a simple guard against the small limit keeps within range, so no annotation is needed but the nonlinear sieve index and product need careful shape.

Position 215 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A Boolean array 0 .. 2499 is filled by a sieve of Eratosthenes using for loops, then for each prime P below 2500 a while loop in the main procedure walks the factorials 1!, 2!, 3!, ... while Fact < P and stops with a not-Erdős result as soon as P - Fact is prime. Qualifying primes are stored in a fixed 64-entry array with a guarded counter, then printed ten per line using 'Image text built in a bounded buffer with Put and New_Line, followed by the count; the 1,000,000 stretch goal is left out as optional. About 55 lines.

## Proof obligations to watch

- **overflow**: The factorial product Fact * J is loop-carried, so it is guarded by testing Fact < I (I under 2500) and keeping J in a small declared range before multiplying, so the product stays within Integer.
- **index**: The sieve marks C(M * P) inside a for loop over M in 2 .. Limit / P, and the nonlinear bound M * P <= Limit needs the prover to handle division, otherwise a guard before the store is added.
- **index**: Lookups of C(I - Fact) are guarded by Fact < I, which gives an index of at least 1, and the result array of 25 entries is guarded by a count check before each store.
- **termination**: All while loops live in the main procedure body, which gets no termination check, and the sieve uses for loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the count and the list of Erdős primes below 2500 to standard output.

Assessed on 2026-10-15 against page revision 414184 of the [task](https://rosettacode.org/wiki/Erd%C5%91s-primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
