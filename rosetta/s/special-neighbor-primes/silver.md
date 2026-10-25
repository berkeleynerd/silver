# Special neighbor primes

**Candidate: proofs likely to discharge automatically.** All indices, sums and mod divisors are bounded by declared subtypes and for-loop ranges, with no while loops, recursion or loop-carried unbounded values, so every check follows from types and static bounds.

Position 144 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Fill a Boolean array Is_Prime indexed 0..200 using nested for loops with trial division by d in 2..14 (mod on loop indexes of a bounded subtype), then walk n in 2..99 with a variable holding the previous prime found, and for each consecutive prime pair test Is_Prime(p1+p2-1), where the sum is at most 185 and so within the array. Qualifying lines are printed through Put_Line of concatenated 'Image strings with fixed bounded lengths. About 45 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each qualifying neighbor-prime pair and its p1+p2-1 prime to standard output.

Assessed on 2026-10-15 against page revision 397687 of the [task](https://rosettacode.org/wiki/Special_neighbor_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
