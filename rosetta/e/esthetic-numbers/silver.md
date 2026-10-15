# Esthetic numbers

**Candidate: proofs plausibly discharge automatically.** Every operation is bounded integer arithmetic or indexing on small fixed-size arrays and ranged subtypes, with loops that are for loops or while loops inside procedures, so checks follow from types and nearby guards; the care needed is in carrying counts and digit buffers through nested loops without invariants.

Position 926 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed a 16-character digit constant, loop bases 2 to 16 with a for loop, and scan candidates 1 to 10_000 (enough to reach index 6*base in every base, e.g. 5461 for base 2) with a ranged count that stops printing once it passes 6*base. A procedure peels digits with n mod base into a fixed 16-slot array, then compares adjacent digit values with explicit difference guards to decide esthetic-ness, and printing converts the stored digits to characters with Put. A second for loop prints base-10 esthetic numbers from 1000 to 9999; the 1.0e8 to 1.3e8 stretch is left out as optional. About 90 lines.

## Proof obligations to watch

- **overflow**: Counters and the scanned value are bounded by ranged subtypes (candidates 1 .. 10_000, counts 0 .. 100), so increments are guarded by the loop range and a count cap test.
- **index**: Digit extraction uses n mod base with base a 2 .. 16 subtype indexing a 16-character constant, and the digit buffer has fixed capacity 16 with a guard before each write, so indexes follow from types and guards.
- **termination**: The digit-peeling loop is a while loop kept in a procedure (no termination check), or replaced by a fixed 14-iteration for loop, so no variant is needed.
- **division**: Division and mod use a base held in a subtype that excludes 0 and 1, so no division check can fail.
- **length**: Reversed digit text is built in a bounded buffer with explicit length tracked and guarded, so no length check on assignment can fail.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, for loops, while loops, procedures, string building, string indexing, 'Image of scalars, Put without a newline, arrays and conditional expressions.

## External effects

- **console output** (allowed): Prints each base's esthetic numbers as digit text and the base-10 list from 1000 to 9999.

Assessed on 2026-10-15 against page revision 414186 of the [task](https://rosettacode.org/wiki/Esthetic_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
