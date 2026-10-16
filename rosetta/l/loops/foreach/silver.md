# Loops/Foreach

**Candidate: proofs likely to discharge automatically.** Every check follows from the array's declared bounds and a for loop over its own range, and nothing is carried between iterations. The only new surface is arrays, for loops, and integer-to-text conversion.

Position 49 in the [progression](../../../progression.md#stage-4), in stage 4, which adds arrays.

## Approach

Embed the collection as a constant array of Integer indexed 1..5 with an aggregate, then iterate with a for loop over the array's own index range, printing each element as text via 'Image. Each element goes out on its own line with Put_Line, or via Put with spaces if line-less output is added, and no guards are needed because the loop index is the array's range. About 14 lines.

## Language surface recorded by this assessment

Integers, arrays, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints each element of the collection to standard output.

Assessed on 2026-10-15 against page revision 415246 of the [task](https://rosettacode.org/wiki/Loops/Foreach) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
