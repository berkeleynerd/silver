# Kolakoski sequence

**Candidate: proofs plausibly discharge automatically.** Everything is a bounded array walk whose indexes can be guarded immediately before use, so no annotation is needed, but several loop-carried indexes (i, k, run count) need careful guard placement.

Position 414 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Fixed-capacity array of 30 values of a 0..3 subtype holds the sequence, and a 4-element cycle array plus a cycle length holds each generator list. A procedure generates via a while loop with explicit guards on write index i and read index k (append the next cycle item, then repeat the last item s(k)-1 times, stopping at the target length). A second procedure counts runs into an RLE array and compares all but the last RLE entry to the sequence, and a driver procedure runs the four embedded cases and prints each with Put_Line using integer images. About 110 lines.

## Proof obligations to watch

- **index**: The write index i and read index k are loop-carried, so each is guarded (i <= Length, k <= Length) immediately before every array access, with exits or skips on failure.
- **overflow**: Counters and indexes are ranged to the fixed capacity (30) and increments are guarded, so no overflow check depends on an invariant.
- **range**: Cycle elements are a subtype 0..3 and run counts are bounded by the capacity, so stores into ranged arrays are guarded by explicit comparisons.
- **termination**: Loops live in procedures (while loops get no termination check) and the fixed-bound for loops terminate by themselves; the cycle position is computed with a guarded wraparound rather than mod on an unbounded value.
- **length**: Output lines are built in bounded buffers sized for 30 elements of at most one digit plus separators, with an explicit capacity guard before each append.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, procedures, functions, for loops, while loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each generated sequence and its Yes/No RLE check result.

Assessed on 2026-10-15 against page revision 415005 of the [task](https://rosettacode.org/wiki/Kolakoski_sequence) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
