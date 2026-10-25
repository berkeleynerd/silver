# Smith numbers

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in a procedure with nested for and while loops, so no recursion or termination proof is needed, but loop-carried accumulators and the shrinking quotient need careful range subtypes and guards because no invariants can be written.

Position 215 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A main procedure loops with a for loop over n in 4..9999, computes the digit sum of n with a bounded for loop of five iterations, then factors n by trial division using a for loop over divisors 2..n with an inner while loop that divides out each divisor and adds the factor's digit sum, counting factors. A number is printed with Put_Line of its image when it has more than one prime factor and the two digit sums match, with all accumulators in ranged subtypes and guarded before each addition. About 45 lines.

## Proof obligations to watch

- **overflow**: The factor-digit-sum accumulator is loop-carried, so the program declares it with a bounded range subtype and guards each addition (the true total stays under a few hundred) before adding.
- **range**: The remaining quotient and trial divisor are loop-carried, so they are held in ranged subtypes of 1..9999 and 2..10000 with guards before each division and increment so no range check depends on an invariant.
- **division**: The divisor comes from a for-loop range starting at 2 and the digit divisor is the literal 10, so division by zero is excluded by static bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each Smith number below 10000 to standard output.

Assessed on 2026-10-15 against page revision 414475 of the [task](https://rosettacode.org/wiki/Smith_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
