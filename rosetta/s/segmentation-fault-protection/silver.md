# Segmentation fault protection

**Candidate: proofs likely to discharge automatically.** The task asks to showcase segfault protection, which Silver provides by proving index checks, so a guarded array access with a visible rejection outcome meets it without any crash. Every check follows from the static array bounds and a guard immediately before the index.

Position 50 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Declare a constant six-element Integer array over the range 1..6, then read element 4 directly and print it. For the task's index 500, test the index against 'First and 'Last in an if statement before indexing, and print an explicit "index 500 rejected: out of bounds" line otherwise. This demonstrates the language's protection, since an unguarded out-of-range access would not be admitted by the prover. About 25 lines.

## Language surface recorded by this assessment

Integers, arrays, ranged subtypes and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the valid element and the rejection message for the out-of-range index with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 380002 of the [task](https://rosettacode.org/wiki/Segmentation_fault_protection) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
