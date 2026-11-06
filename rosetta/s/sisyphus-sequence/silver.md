# Sisyphus sequence

**Candidate: proofs plausibly discharge automatically.** All arithmetic and indexing can be made safe by explicit bound guards before each operation, and the only unbounded-looking loop is a while loop in a procedure, so no annotation is needed, though several loop-carried values each need a careful guard.

Position 279 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep a 64-bit integer term, a count of primes used, and a fixed-capacity array of discovered primes; a procedure finds the next prime by scanning odd candidates and trial-dividing by earlier stored primes inside a bounded while loop. A single for loop over the term index applies halve-if-even else add-next-prime, stores the first 100 terms, and at 1,000, 10,000, 100,000 and 1,000,000 prints the term and the largest prime used via bounded decimal-formatting into a String buffer. Guards on the term magnitude, array capacity and candidate limit reject with a specified message instead of altering results; the stretch parts are omitted as optional. About 120 lines.

## Proof obligations to watch

- **overflow**: The term is a loop-carried value, so a guard before each addition rejects with a visible outcome if it exceeds a documented bound far below 2**62, and the halving branch cannot overflow.
- **index**: The stored-prime array index is a loop-carried counter, so a guard before each store and each read checks it against the fixed capacity (sized above the number of primes the 1,000,000-term run needs) and rejects otherwise.
- **division**: Trial division by stored primes is nonlinear and loop-carried, so a guard that the divisor is at least 2 precedes each mod and the divisor range is a declared subtype.
- **termination**: The next-prime search uses a while loop, which is acceptable because it lives in a procedure, and it is bounded by a candidate-limit guard that rejects rather than looping unboundedly.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 100 terms in 10 rows of 10 and the four requested terms with their highest primes.

Assessed on 2026-10-15 against page revision 412160 of the [task](https://rosettacode.org/wiki/Sisyphus_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
