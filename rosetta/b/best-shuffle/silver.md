# Best shuffle

**Candidate: proofs plausibly discharge automatically.** Every check follows from for-loop ranges over a fixed-capacity buffer, with only the loop-carried score needing a guard, and no recursion, annotations or exceptions are required. The greedy swap is deterministic and acceptable under the task, so the outlook is plausible rather than likely because of the guarded accumulator and string assembly.

Position 541 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Each embedded test string is copied into a fixed-capacity Character array with a length; a deterministic double for loop swaps positions I and J when both characters would land in a differing spot, as in the existing greedy swap, over the array's own index range. A second for loop counts unchanged positions into a ranged score, and the result line is built with concatenation and the score's Image, then printed with Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The score counter is loop-carried, so its increment is guarded by a comparison against the fixed maximum length, which never fires for valid data.
- **index**: Swap indexes come from nested for loops over the buffer's own range, so every index check follows from the loop bounds.
- **length**: The output line is concatenated from bounded pieces whose maximum lengths are statically below the buffer capacity, with the Image of a small ranged score.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, 'Image of scalars, arrays, for loops and procedures.

## External effects

- **console output** (allowed): Prints one line per test case in the form original, shuffled, (score).

Assessed on 2026-10-15 against page revision 414073 of the [task](https://rosettacode.org/wiki/Best_shuffle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
