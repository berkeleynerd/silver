# Odd and square numbers

**Candidate: proofs likely to discharge automatically.** The loop bounds are static and the largest square is 961, so overflow and range checks follow from types and the for range, and mod by the literal 2 cannot divide by zero. No loop-carried value exists and no annotation is needed.

Position 108 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

A for loop runs I over the declared range 11 .. 31 (the smallest and largest odd I with 99 < I*I < 1000), and an if statement tests I mod 2 /= 0. The square is computed into a variable of a range subtype, and its 'Image text is written with Put, with a final Put_Line of an empty string to end the line. About 16 lines.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the odd squares between 100 and 999 on one line.

Assessed on 2026-10-15 against page revision 414368 of the [task](https://rosettacode.org/wiki/Odd_and_square_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
