# 99 bottles of beer

**Candidate: proofs likely to discharge automatically.** Every check comes from the loop index's static range 1 .. 99, so X - 1 and the bounded concatenation cannot overflow, and there are no loop-carried values, recursion or functions needing variants.

Position 60 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

A main procedure loops with a for loop in reverse over a ranged subtype 1 .. 99 and prints each verse with Put_Line, building each count line by concatenating the integer image with fixed text in a bounded string. The next count is computed as X - 1, which stays in 0 .. 98 because X is the loop index of a static range, and a blank line separates verses. The singular "1 bottle" is optional and is left out, or handled by a plain if on X = 1. About 22 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, for loops, 'Image of scalars, string building, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints the full lyrics line by line to standard output.

Assessed on 2026-10-15 against page revision 415384 of the [task](https://rosettacode.org/wiki/99_bottles_of_beer) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
