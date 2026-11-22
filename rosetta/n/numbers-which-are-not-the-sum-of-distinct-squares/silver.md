# Numbers which are not the sum of distinct squares

**Candidate: proofs likely to discharge automatically.** Everything is bounded for loops over small ranged subtypes with a Boolean array, so each index and arithmetic check follows from types and the loop range; the only subtlety is documenting the fixed limit, which Oracle rule 7 allows.

Position 121 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Keep a Boolean array Reachable (0 .. Limit) with Reachable (0) true, where Limit is a documented fixed bound comfortably above 128 (the largest non-representable number), and run a 0/1 subset-sum pass over the squares K*K for K in 1 .. Root, with S iterating in reverse from Limit down to K*K and setting Reachable (S) when Reachable (S - K*K) holds. A final for loop prints every positive index that is still false, with a running count in a subtype-bounded counter, then prints the count. All loops are for loops, so no variants are needed, and the Limit is justified by a documented argument that every value from 129 up is a sum of distinct squares (verified for a run of consecutive values and extended by induction), so the output is complete. About 40 lines.

## Proof obligations to watch

- **index**: The reachable-sum update reads Reachable (S - K*K) inside a reverse for loop over S in K*K .. Limit, and an explicit guard on S >= K*K just before the access keeps the index in range without an invariant.
- **overflow**: K*K and S - K*K are bounded by declared subtypes (K at most the square root of Limit, S at most Limit), so the arithmetic cannot overflow or leave the index range.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and procedures.

## External effects

- **console output** (allowed): Prints each non-representable positive integer and a final count with Put_Line.

Assessed on 2026-10-15 against page revision 413809 of the [task](https://rosettacode.org/wiki/Numbers_which_are_not_the_sum_of_distinct_squares) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
