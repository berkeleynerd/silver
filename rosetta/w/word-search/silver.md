# Word search

**Candidate: proofs plausibly discharge automatically.** Every access is a bounded grid cell or fixed-capacity buffer slot that can be guarded just before use, and no recursion, heap or annotation is needed. The risk is the nonlinear generator and the loop-carried placement cursors, so careful guard placement is needed but no invariant.

Position 1194 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program embeds about 40 lowercase words of 3 to 9 letters taken from unixdict as records holding a fixed buffer and a length, keeps the grid as a 10 by 10 Character array, and draws positions and directions from a deterministic modular pseudo-random generator. A procedure with bounded while loops tries random start, direction and word candidates, tests that the word fits and agrees with the cells it crosses before writing, and records each placement; once 25 or more words are placed and exactly 11 cells are empty, a for loop fills them with ROSETTACODE in row-major order. It then prints the grid and the word list with coordinates, and prints a failure message if the attempt budget runs out. About 190 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator multiplies a seed bounded to a ranged subtype by a constant inside a 64-bit type, so the product is bounded by the declared range and cannot overflow.
- **index**: Each word cell is addressed as start plus step times direction, so a fit test on the start, direction and word length must run just before the writes, with coordinates in a 1..10 subtype, because no loop invariant can carry the bound.
- **range**: The write cursor into the 11-letter message and the placed-word count are loop-carried and are each guarded by an explicit test against their capacity before use.
- **termination**: The retry and placement loops are while loops in procedures, which get no termination check, and each is also bounded by an explicit attempt counter so the program ends with a specified outcome.
- **other**: Packing at least 25 words and leaving exactly 11 free cells depends on the deterministic search succeeding, so the program must reject or report failure in a visible way after its attempt budget is spent rather than shrinking the requirements.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the 10 by 10 grid and the list of hidden words with their start and end coordinates.

Assessed on 2026-10-15 against page revision 414865 of the [task](https://rosettacode.org/wiki/Word_search) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
