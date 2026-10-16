# Loop over multiple arrays simultaneously

**Candidate: proofs likely to discharge automatically.** The for loop runs over the arrays' own index range with static bounds, and the digit is a bounded value in 1..3, so no check needs a loop invariant or annotation.

Position 438 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Declare a subtype Index of Positive range 1 .. 3 and three constant arrays indexed by it, holding Characters 'a','b','c', 'A','B','C' and Integers 1,2,3. A for loop over Index'Range builds each three-character line from the two Characters and the digit character via Character'Val of 48 plus the Integer, then prints it with Put_Line. The different-length case is handled by sizing all arrays to the same index subtype, so the lengths are equal by construction. About 22 lines.

## Language surface beyond today's Silver

Characters, integers, arrays, ranged subtypes, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the three lines aA1, bB2, cC3 to standard output.

Assessed on 2026-10-15 against page revision 411568 of the [task](https://rosettacode.org/wiki/Loop_over_multiple_arrays_simultaneously) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
