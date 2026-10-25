# Abelian sandpile model

**Candidate: proofs plausibly discharge automatically.** Every index and increment can be guarded just before use because cell values are only known by type after the first iteration, so discharge depends on careful guard placement but needs no annotation.

Position 1423 in the [progression](../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

A fixed 11 by 11 array of a ranged cell subtype holds the grid, with the task's example piles (4, 6, 16) placed in the centre and settled one after another by a procedure. The procedure loops with a while loop until no cell holds 4 or more, toppling each such cell by subtracting 4 and adding 1 to each in-bounds neighbour behind an index guard and a capacity guard that rejects on overflow. The settled grid is printed as digit rows and written to a PPM file. About 85 lines.

## Proof obligations to watch

- **overflow**: After the first loop iteration each cell is known only by its subtype range, so every neighbour increment needs a guard just before it (reject if the cell is at its maximum), which never fires for the embedded examples but keeps the result unaltered.
- **index**: Grid indexes X-1, X+1, Y-1 and Y+1 are each guarded by comparison against the array bounds immediately before use, which discharges them.
- **termination**: The settle loop is a while loop in a procedure, which gets no termination check, and a finite grid with edge loss does settle in practice.
- **length**: Output rows and PPM lines are built in fixed-size bounded buffers sized to the grid width, so concatenation lengths are static.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, multidimensional arrays, arrays, for loops, while loops, procedures, 'Image of scalars, string building, file output and Put without a newline.

## External effects

- **console output** (allowed): Print the settled grid as rows of digits for the small task examples.
- **files** (allowed): Write a PPM image file of the settled grid, as the task recommends an image format.

Assessed on 2026-10-15 against page revision 415045 of the [task](https://rosettacode.org/wiki/Abelian_sandpile_model) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
