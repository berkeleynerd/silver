# Strong and weak primes

**Candidate: proofs plausibly discharge automatically.** Every check is an index or addition on values bounded by the Limit constant, and all loops live in a procedure so no variants are needed, but sieve loop-carried indexes and the large fixed array make careful guarding necessary.

Position 268 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A constant Limit just above 10,000,000 sizes a fixed Boolean sieve array that a Main-level procedure fills with nested while loops (outer bound i*i <= Limit, inner step guarded by j <= Limit). A single for loop over the array's range then tracks the previous prime and current prime, classifying the current one as strong or weak when the next prime arrives by comparing prev + next against 2*cur, and records the first 36 strong and 37 weak primes and counts below 1,000,000 and 10,000,000. Results are printed with Put and Put_Line using Integer'Image, with all loop-carried values kept in bounded Integer subtypes. About 90 lines.

## Proof obligations to watch

- **index**: The sieve's inner while loop carries a multiple index j, which is discharged by putting the 'j <= Limit' test in the loop condition immediately before each array access.
- **overflow**: Sums of neighbouring primes and the running counts stay within 32-bit Integer because values never exceed about 10,000,100, and the sieve step addition is guarded by the loop condition.
- **stack**: A Boolean sieve of several million entries (odd-only storage helps) is a large fixed object whose memory is an environmental premise that GNATprove does not check.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the two lists of first strong and weak primes and the four counts to standard output.

Assessed on 2026-10-15 against page revision 414524 of the [task](https://rosettacode.org/wiki/Strong_and_weak_primes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
