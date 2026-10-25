# Anaprimes

**Candidate: proofs plausibly discharge automatically.** Everything uses fixed-bound arrays and guarded loop-carried values with no recursion or heap, so no annotation is needed, but several accumulators each need a careful guard.

Position 825 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed a Boolean sieve over 2..999999 built with a while loop in a procedure (marking from I*I by repeated addition, guarded before each index). For each digit length 3 to 6, loop over the primes in range, extract digits into a ten-entry count array, build the sorted-digit number as a group key (guarded against growth), and keep per-key count, minimum and maximum in three fixed arrays. Then print the largest count and the min and max of every group that reaches it, using 'Image and bounded concatenation. About 130 lines.

## Proof obligations to watch

- **overflow**: Sieve marking index and the sorted-digit key are loop-carried, so each is guarded just before use (M <= limit, key <= 99999 before multiplying by 10); the guards never trigger for valid values.
- **range**: Digit counts and group counters are loop-carried and need guards before increment because no invariant can bound them.
- **index**: Array indexes by sieve position and by group key rely on subtype ranges and the guard immediately before each access.
- **termination**: The sieve's while loop and any digit-extraction loop stay in procedures, which get no termination check.
- **stack**: Three million-entry arrays are fixed-size but large, so they depend on the environmental memory premise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and case statements.

## External effects

- **console output** (allowed): Prints the largest group's size and its minimum and maximum members for each digit length.

Assessed on 2026-10-15 against page revision 415451 of the [task](https://rosettacode.org/wiki/Anaprimes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
