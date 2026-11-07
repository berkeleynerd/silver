# Largest difference between adjacent primes

**Candidate: proofs plausibly discharge automatically.** Every loop is a for loop over static ranges with array indices bounded by declared subtypes, so the only non-routine obligation is the bounded nonlinear product I * J in the sieve. No annotations or termination variants are needed, and there are no conflicts.

Position 161 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Use a constant-bounded Boolean array Composite (0 .. 999_999) as a sieve of Eratosthenes with nested for loops (outer I in 2 .. 999, inner J in 2 .. 999_999 / I, guarded by not Composite (I)), then one for loop over 3 .. 999_999 tracking the previous prime and the best gap and its endpoints in range-typed variables. Finish with a single Put_Line of the concatenated integer images, so no while loops, recursion or heap are needed. About 40 lines.

## Proof obligations to watch

- **index**: The sieve marks Composite (I * J) with J in 2 .. 1_000_000 / I, so the index bound needs a nonlinear product fact that the provers should discharge from the loop ranges but which is not purely static.
- **overflow**: I * J and the gap subtraction stay within Integer because I is at most 1000, J is at most 1_000_000 / I, and the last-prime value is always a declared-range index.
- **length**: The result line concatenates the 'Image text of four integers, whose maximum lengths follow from the declared integer subtype ranges and fit a fixed-size buffer.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the single result line with the largest gap and the two primes.

Assessed on 2026-10-15 against page revision 397119 of the [task](https://rosettacode.org/wiki/Largest_difference_between_adjacent_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
