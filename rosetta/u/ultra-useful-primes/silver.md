# Ultra useful primes

**Candidate: proofs plausibly discharge automatically.** Everything is bounded fixed-capacity big-number arithmetic in procedures with limb types that bound all intermediate values, so no annotation is needed, but the multi-precision multiplication, folding reduction and fixed-base Miller-Rabin demand careful program shape for the provers.

Position 1396 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent numbers as fixed arrays of 16-bit limbs (64 limbs for the 1024-bit case, 128 for products) in 64-bit integers, and for each n from 1 to 10 search odd k upward, testing 2^(2^n) - k with a Miller-Rabin test using a few fixed small bases and modular exponentiation done by square-and-multiply with folding reduction. Control flow is for loops over array ranges inside procedures, with a capped k search and a printed failure message if the cap is hit, and the ten results are printed with Put and Integer'Image. About 260 lines.

## Proof obligations to watch

- **overflow**: Limb products and column sums are carried through loops, so limbs are subtypes of 0..65535 held in 64-bit integers and each partial sum is reduced by carry propagation within a bound that the types alone establish.
- **index**: Schoolbook multiplication and folding reduction index limb positions i+j and shifted offsets, which discharge only if loops run over the arrays' own ranges and each computed index is guarded just before use.
- **termination**: The search for k and the Miller-Rabin square loop are while loops, so they are placed in procedures (no termination check) and bounded by a explicit cap on k that yields a visible failure outcome.
- **range**: Reduction modulo 2^N - k uses folding (2^N is congruent to k) instead of long division, but the repeated fold count is a loop-carried quantity that needs a fixed iteration count rather than an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, big numbers, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the first ten sequence elements on one line.

Assessed on 2026-10-15 against page revision 413953 of the [task](https://rosettacode.org/wiki/Ultra_useful_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
