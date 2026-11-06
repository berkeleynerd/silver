# Equal prime and composite sums

**Candidate: proofs plausibly discharge automatically.** Six terms need only sums up to about 18.9 million and numbers below about 6,500, so a fixed sieve and 64-bit sums fit, and each loop-carried check is covered by an explicit capacity or cap guard without annotations. The loop-carried pointers and sums make shape matter, hence plausible rather than likely.

Position 243 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Build a Boolean sieve array over 2..20000 with nested for loops, then advance a prime pointer and a composite pointer in a while loop in the main procedure, adding the next prime to the prime sum when it is smaller and the next composite to the composite sum when it is smaller, and record each equality with its n, m and value until six terms are found. Every pointer advance and sum addition is guarded against the sieve capacity and a sum cap, with a printed outcome if a limit is reached, and results are formatted into a bounded String via digit extraction and printed with Put_Line. About 80 lines.

## Proof obligations to watch

- **overflow**: Running prime and composite sums are loop-carried 64-bit values, so each addition is preceded by a guard that the sum is below a documented cap (for example 10**12), with a visible stop message if the cap is hit.
- **index**: The scanning pointers into the sieve are loop-carried, so each advance is guarded by a comparison with the sieve's last index and the program reports the capacity limit and stops rather than reading past the array.
- **range**: Sieve marking computes multiples as I times K with K running over a for-loop range bounded by Limit/I, so the product stays within the array bounds from the loop range alone.
- **termination**: The two-pointer search is a while loop kept in the main procedure (not a function), so no variant is needed, and the sieve and digit-formatting loops are for loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints a header and one line per matching sum with its n and m indices.

Assessed on 2026-10-15 against page revision 412767 of the [task](https://rosettacode.org/wiki/Equal_prime_and_composite_sums) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
