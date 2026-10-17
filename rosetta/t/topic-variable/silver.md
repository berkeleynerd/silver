# Topic variable

**Candidate: proofs likely to discharge automatically.** The task only needs a small bounded-integer demonstration with a for loop and integer-to-text output, all of whose checks follow from declared ranges and for-loop bounds. No annotation, recursion or nonlinear loop-carried value is involved.

Position 36 in the [progression](../../progression.md#stage-2), in stage 2, which adds for loops, integers, ranged subtypes and 'Image of scalars.

## Approach

Ada has no topic variable, so the program declares a short-named variable It of a bounded integer subtype (0 .. 1000), assigns 3, and prints It, It*It and an integer square root found by a for loop over 0 .. 31 that keeps the largest R with R*R <= It. A second, inner use is skipped, and the output explains in text that Ada scoping is lexical with no implicit topic. All arithmetic is bounded by the subtype range, so no guards beyond the loop bound are needed. About 22 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, 'Image of scalars and for loops.

## External effects

- **console output** (allowed): Prints the topic value, its square and its integer square root with Put_Line.

Assessed on 2026-10-15 against page revision 405498 of the [task](https://rosettacode.org/wiki/Topic_variable) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
