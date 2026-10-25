# Van der Corput sequence

**Candidate: proofs likely to discharge automatically.** All arithmetic is bounded integer arithmetic with static ranges, no recursion or while loops in functions, and no floating point, so every check follows from types and guards just before the operations.

Position 445 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Avoid floating point by computing each term as an exact integer fraction numerator/denominator in a function with a bounded for loop that peels base-b digits of n (n in 0..10, base subtype 2..5), then print the value as a five-digit decimal using integer arithmetic ((num*100000 + den/2)/den) split into digit Characters. A procedure prints each "Base b:" line with Put for the terms and Put_Line at the end, with guards rejecting out-of-range n or base. About 60 lines.

## Proof obligations to watch

- **overflow**: The loop-carried denominator and numerator are multiplied each iteration, so they are kept in a bounded subtype and a for loop over a fixed digit count with an explicit guard before each multiply makes the check provable.
- **division**: Base is a subtype range 2..5 and the denominator is at least 1 by its subtype, so the divisions and mod operations have nonzero divisors.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, for loops, functions, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first ten sequence members for bases 2 to 5 as text lines.

Assessed on 2026-10-15 against page revision 414569 of the [task](https://rosettacode.org/wiki/Van_der_Corput_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
