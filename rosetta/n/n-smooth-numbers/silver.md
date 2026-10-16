# N-smooth numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged digit, carry and index subtypes plus guards, but the fixed-capacity big-number arithmetic in loops and the guarded table indices make discharge depend on careful program shape rather than being routine.

Position 1383 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Represent each number as a fixed 32-digit little-endian decimal array in a 3002-row table, computing the n-smooth sequence with the classic merge: per-prime candidate values, a minimum selection by digit-wise comparison, and guarded index advance. Candidates are produced by a procedure multiplying a row by a small prime with a ranged carry; the main procedure loops over the ten primes for the first-25 and 3000-to-3002 lists and prints digits via Put. The optional n=503..521 part is omitted, and overflow of the digit capacity yields a visible rejection message. About 150 lines.

## Proof obligations to watch

- **overflow**: Digit-by-digit multiplication by a prime up to 29 keeps digit and carry in small ranged subtypes so digit*p+carry stays below 310, and a nonzero carry out of the top digit is rejected visibly.
- **index**: Each per-prime index into the 3002-entry table is a ranged subtype and is incremented only under an explicit guard before the table lookup, since no loop invariant can bound it.
- **range**: Decimal conversion of 32-digit numbers and the 3000th 3-smooth value (about 9.4e28) need a digit capacity chosen with margin, and the table size 3002 is a fixed documented limit.
- **termination**: All loops are for loops or live in procedures (the merge loop is a for loop over table positions), so no termination check applies.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, procedures, big numbers, Put without a newline, string building, 'Image of scalars and records.

## External effects

- **console output** (allowed): Prints each list of smooth numbers on one horizontal line.

Assessed on 2026-10-15 against page revision 414354 of the [task](https://rosettacode.org/wiki/N-smooth_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
