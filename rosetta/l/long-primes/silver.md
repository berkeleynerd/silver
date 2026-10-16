# Long primes

**Candidate: proofs likely to discharge automatically.** Every check follows from small declared ranges (values at most 64000, products at most 640000) and for-loop bounds, with only the counter needing a visible guard, so proofs should discharge without annotations. The main burden on Silver is surface growth: arrays, subtypes, for and while loops, functions, and number-to-text output.

Position 899 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A Boolean composite array indexed 0..64000 is filled by a nested for-loop sieve, and a function computes the multiplicative order of 10 modulo p with a bounded for loop that exits when the residue is 1, with the residue and p as range-bounded subtypes. A main loop over odd primes counts those whose order equals p-1, printing those up to 500 on one line and the running count at each doubled limit (500 up to 64000), using Integer'Image for the numbers. About 90 lines.

## Proof obligations to watch

- **overflow**: The residue update r*10 mod p is safe because r and p are subtypes bounded by 64000 so r*10 fits Integer, and the result stays below p.
- **overflow**: The long-prime counter is loop-carried, so each increment sits behind an explicit guard against the capacity bound that rejects visibly if ever reached.
- **index**: Sieve marking uses j in 2 .. Max/i so i*j <= Max is a mild nonlinear fact the provers should accept, or a while loop with a guard before j+i avoids it.
- **termination**: The order search is a for loop over 1 .. p-1 with an early exit, so no variant is needed even for p = 2 or 5 where the residue never returns to 1.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the long primes up to 500 on one line and the eight counts, one per line.

Assessed on 2026-10-15 against page revision 412889 of the [task](https://rosettacode.org/wiki/Long_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
