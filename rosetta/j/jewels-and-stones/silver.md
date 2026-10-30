# Jewels and stones

**Candidate: proofs plausibly discharge automatically.** All checks come from for-loop ranges over the strings' own indexes plus a bounded counter, so no annotation is needed, but the loop-carried counter requires a careful type and guard choice.

Position 987 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A function Count takes unconstrained String parameters, loops over each stone index with a nested for loop over the jewels, increments a bounded counter when characters match (counting each stone at most once with an exit), and returns it. Main embeds the example data (the task's aAAbbbb/aA case and a zero case), and prints each result via Count'Image through Put_Line. About 30 lines.

## Proof obligations to watch

- **overflow**: The loop-carried counter is known only by its type after the first iteration, so it is declared as a ranged subtype whose upper bound exceeds the documented string-length limit and the increment is guarded, which GNATprove can discharge only if the subtype and limit are chosen so the guard never needs to change the result.
- **index**: Both loops iterate over each string's own 'Range, so indexing checks follow directly from the loop bounds.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, for loops, functions, unconstrained arrays and 'Image of scalars.

## External effects

- **console output** (allowed): Prints each example's count with Put_Line.

Assessed on 2026-10-15 against page revision 412860 of the [task](https://rosettacode.org/wiki/Jewels_and_stones) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
