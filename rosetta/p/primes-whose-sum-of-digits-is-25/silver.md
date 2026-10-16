# Primes whose sum of digits is 25

**Candidate: proofs likely to discharge automatically.** Every operand is bounded by a ranged subtype and every loop is a static-bound for loop, so overflow, division and termination checks follow from types alone with no annotations.

Position 327 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Declare subtype Candidate is Integer range 1..4999; a function Digit_Sum extracts digits with a fixed four-iteration for loop using mod and /, and Is_Prime trial-divides with a for loop over 2..70 guarded by D*D <= N. The main loop runs I over Candidate, prints each prime whose digit sum is 25 through Put of its image, and keeps a Natural counter bounded by 4999 for a final count line. The optional stretch goal beyond 10^24 is omitted. About 45 lines.

## Proof obligations to watch

- **overflow**: The digit sum and the prime-test product are bounded because N is a subtype of 1..4999 and the divisor loop runs over a fixed range 2..70.
- **termination**: Only for loops with static bounds are used inside functions, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each qualifying prime and the final count.

Assessed on 2026-10-15 against page revision 409858 of the [task](https://rosettacode.org/wiki/Primes_whose_sum_of_digits_is_25) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
