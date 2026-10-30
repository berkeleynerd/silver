# Extra primes

**Candidate: proofs likely to discharge automatically.** Every check follows from small declared ranges and a fixed-count for loop, with no loop-carried value needing an invariant, so proofs should discharge automatically.

Position 309 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A function Is_Prime over a subtype 0 .. 9999 uses a for loop with D in 2 .. 99 and returns False when D*D <= A and A mod D = 0. The main for loop runs N over 2 .. 9999, extracts the four digits with fixed-count for-loop steps using mod 10 and /10 on a copy bounded by the subtype, checks each nonzero digit and the digit sum (at most 36) with Is_Prime, and prints qualifying N with Put_Line of its image, counting them and printing the count line at the end. About 45 lines.

## Proof obligations to watch

- **overflow**: The trial-division product D*D is bounded because D is a for-loop index in 2 .. 99 of a ranged subtype, and the counter is bounded by the 9,999 loop range.
- **termination**: Primality testing uses a for loop over 2 .. 99 inside a function, so no variant is needed, whereas a while loop in a function would need one.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, functions, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each extra prime and the final count to standard output.

Assessed on 2026-10-15 against page revision 406202 of the [task](https://rosettacode.org/wiki/Extra_primes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
