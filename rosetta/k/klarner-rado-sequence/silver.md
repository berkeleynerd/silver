# Klarner-Rado sequence

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged types and explicit guards on the loop-carried pointers and counters, and the for loop needs no variant, but the several loop-carried values and the capacity choice make discharge depend on careful program shape.

Position 103 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A fixed-capacity Boolean array of about one million entries marks sequence members, filled in one ascending for loop over i with two lagging pointers p2 and p3 and next-target counters (2*p2+1 and 3*p3+1), with no sorting. Each loop-carried value is a ranged integer guarded before it indexes the array or is incremented. A counter prints terms 1 to 100 in rows of 20 using Put and records the 1000th and 10000th terms, with a specified message if the array limit is reached first. About 70 lines.

## Proof obligations to watch

- **index**: The lagging pointers p2 and p3 index the Boolean array but are loop-carried, so each use is preceded by an explicit guard against the array bound.
- **overflow**: The pointers, the next-target counters and the term count are loop-carried with no invariant, so they are ranged integers well above the limit and increments are guarded.
- **range**: If the 10000th term exceeded the fixed array limit the program would print a specified rejection message, so the limit must be sized large enough to avoid that.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 100 terms in rows of 20 and the 1000th and 10000th terms to standard output.

Assessed on 2026-10-15 against page revision 414286 of the [task](https://rosettacode.org/wiki/Klarner-Rado_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
