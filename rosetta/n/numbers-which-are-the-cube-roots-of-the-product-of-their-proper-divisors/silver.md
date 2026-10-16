# Numbers which are the cube roots of the product of their proper divisors

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared ranges and a fixed 512 trial-division limit, and every loop is a for loop, so checks follow from types and guards; the only care needed is saturating the loop-carried counters and bounding the text buffer.

Position 175 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A procedure Divisor_Count takes N in a ranged subtype and loops I over 1..512 with a guard I*I <= N, adding 2 per divisor pair (1 when I*I = N) with a saturating cap. The main loop is a for loop over candidates 1..300000 that counts matches (N = 1 or divisor count = 8). It prints the first 50 in rows of 10 using Image and a fixed buffer, and prints the 500th, 5,000th and 50,000th when the match counter reaches them. About 70 lines.

## Proof obligations to watch

- **overflow**: The divisor count and match count are loop-carried, so each increment sits behind a guard against a small cap (the divisor count is capped at 9, since only exactly 8 matters), and the cap does not change which numbers match.
- **range**: Candidate N is a for-loop index over a fixed range of 1..300000, and the divisor loop index runs over 1..512 with an I*I <= N guard, so I*I and N mod I stay within Integer.
- **length**: Formatted output lines are built in a fixed-size buffer sized for 10 numbers of at most 6 digits plus padding, with a guarded write position before each append.
- **other**: The program must give a visible failure outcome if fewer than 50,000 matches are found within the 300000 limit; the real 50,000th value is 223735, so this path is never taken.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 50 matching numbers and the 500th, 5,000th and 50,000th as text lines.

Assessed on 2026-10-15 against page revision 413811 of the [task](https://rosettacode.org/wiki/Numbers_which_are_the_cube_roots_of_the_product_of_their_proper_divisors) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
