# Primes which contain only one odd digit

**Candidate: proofs likely to discharge automatically.** All loops are for loops with static bounds, so there are no termination or invariant needs, and arithmetic is bounded by declared ranges. The only non-routine parts are the nonlinear D*D, handled by loop-index bounds, and number-to-text formatting.

Position 533 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Two pure functions use only for loops: Is_Prime does trial division by D in 2..1000 with an early exit when D*D exceeds the candidate, and Odd_Digit_Count peels 7 decimal digits with mod and / on a Natural copy. The main procedure loops candidates 2..999 printing matches in rows of 9 using bounded fixed-length image buffers with padding, then loops 2..999_999 accumulating a count in a subtype bounded by 1_000_000 and prints it with a message. About 70 lines.

## Proof obligations to watch

- **overflow**: D*D in the trial-division test is safe because D is a for-loop index bounded by 2..1000 and the candidate is a subtype bounded by 1_000_000, so Integer arithmetic cannot overflow.
- **range**: The digit extraction repeats X := X / 10 a fixed 7 times inside a for loop, so no loop-carried value needs an invariant; the odd-digit counter is bounded by 7 via its subtype range and the loop count.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, procedures, 'Image of scalars, string indexing, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 45 primes, their count, and the count below 1,000,000 to standard output.

Assessed on 2026-10-15 against page revision 405983 of the [task](https://rosettacode.org/wiki/Primes_which_contain_only_one_odd_digit) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
