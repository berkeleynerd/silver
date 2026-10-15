# Least m such that n! + m is prime

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation, since every loop value sits in a bounded limb subtype or behind a guard, but the fixed-capacity big-number arithmetic carried through many nested loops makes discharge depend on careful program shape.

Position 1410 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Represent numbers as a record of a fixed-capacity array of 16-bit limbs (about 40 limbs, enough for 106!, ~565 bits, plus a documented rejecting capacity limit) with a length, and build procedures for compare, add, subtract, multiply by small, modular add, double-and-add mulmod and modpow. Loop n from 0 upward updating the factorial in place, search m from n+1 upward with a trial-small-prime filter then fixed-base Miller-Rabin as procedure while loops, store the 50 terms in an array and print them in rows with Put, then report the first m above 1000 and its position (106 factorial gives position 107 counting from 1) via scalar image conversion; stretch thresholds are optional. About 320 lines.

## Proof obligations to watch

- **overflow**: Limb products and carries in the fixed-capacity big-number add, subtract and multiply-by-small routines are bounded by limb subtypes held in 64-bit intermediates, and the factorial step rejects visibly if the final carry would exceed capacity.
- **index**: Limb loops run over the array's own range, but shifted or carried positions need explicit guards just before the index to discharge.
- **termination**: The Miller-Rabin exponent-halving and candidate-search loops are while loops, so they live in procedures (no termination check), with the m search capped by a documented bound and a specified failure message.
- **other**: Modular multiplication must use double-and-add with modular add rather than long division to avoid Knuth-D index arithmetic, costing run time but keeping every loop-carried value type-bounded.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, big numbers, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the 50 terms and the first m greater than 1000 with its position as text lines.

Assessed on 2026-10-15 against page revision 413762 of the [task](https://rosettacode.org/wiki/Least_m_such_that_n!_%2B_m_is_prime) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
