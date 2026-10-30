# The sieve of Sundaram

**Candidate: proofs plausibly discharge automatically.** Every check follows from constant bounds, for-loop indexes and one guard on the culling index, with nothing needing an invariant, though the large array and loop-carried indices need careful shaping. The remaining uncertainty is stack size for the big array and the nonlinear start-index arithmetic.

Position 220 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A constant-size Boolean array of 7.8 million entries marks composites: a for loop over i in 1..L computes p = 2i+1 and start 2i(i+1), then a while loop culls j with step p under a j <= K - p guard. A second for loop over the array counts unmarked entries with a count < limit guard, prints the first 100 primes ten per row with Put, and records the 100th and millionth primes for output. About 55 lines.

## Proof obligations to watch

- **overflow**: The culling index j is loop-carried in a while loop, so the program guards j against K - p before each increment and exits otherwise, which also keeps the array index in range.
- **overflow**: The prime counter is loop-carried, so it is incremented only under an explicit count < capacity guard; the p*p start value uses a for-loop index bounded by a constant so it cannot overflow.
- **stack**: A Boolean array of about 7.8 million entries in Main may exceed the stack, which GNATprove does not check, so it rests on the fixed environmental memory premise.
- **termination**: The while culling loop sits in the main procedure, which gets no termination check, and its guard step of p >= 3 makes it terminate anyway.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 100 Sundaram primes in rows of ten plus the 100th and millionth primes.

Assessed on 2026-10-15 against page revision 412171 of the [task](https://rosettacode.org/wiki/The_sieve_of_Sundaram) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
