# Pascal's triangle/Puzzle

**Candidate: proofs likely to discharge automatically.** Every value is a bounded sum of for-loop indexes with declared ranges, the only loop-carried state is a Boolean flag, and no annotation, recursion or while loop is needed, so all checks follow from types and ranges.

Position 97 in the [progression](../../../progression.md#stage-5), in stage 5.

## Approach

Brute-force search with nested for loops over X and Z in a small declared range (for example -200 .. 200), computing Y = X + Z and each brick as a direct expression of X, Y and Z held in plain Integer locals, with no arrays so no loop-carried unbounded values. When the left-edge brick equals 40 and the top equals 151, a Found Boolean is set and the pyramid rows are printed with Put and Integer'Image, and if no pair matches a "no solution" line is printed. About 45 lines.

## Proof obligations to watch

- **overflow**: X and Z are for-loop indexes over a small declared range and every brick is a short sum computed directly from them in one expression, so no overflow check can fail.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the solved pyramid, one row per line, or a no-solution message.

Assessed on 2026-10-15 against page revision 414384 of the [task](https://rosettacode.org/wiki/Pascal's_triangle/Puzzle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
