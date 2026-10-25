# Knight's tour

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, fixed array bounds and guards placed just before indexing, and recursion is replaced by an explicit-stack while loop in a procedure, so no annotation is needed; the nested loop-carried search state keeps it at plausible rather than likely.

Position 1121 in the [progression](../../progression.md#stage-18), in stage 18.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

The program parses a two-character square such as e4 from the first argument, rejecting anything outside a-h and 1-8 via Input_Is_Valid and Reject, then fills an 8x8 visited array of ranged integers. An iterative backtracking search in a procedure uses fixed-size arrays as an explicit stack of positions and next-move indices over eight constant knight offsets, with each candidate square guarded for range and unvisited before use. The numbered board is printed row by row using bounded text buffers built from 'Image of each visit number. About 130 lines.

## Proof obligations to watch

- **index**: Candidate neighbour coordinates are computed in a wider integer range and guarded against 1..8 immediately before indexing the 8x8 visited array, and stack depth is a fixed 64-entry array indexed by a ranged level variable that is guarded before each push.
- **overflow**: Loop-carried move counters and per-level move-choice counters are ranged subtypes (1..64, 0..8) with guards before increments, so no invariant is needed.
- **termination**: The explicit-stack backtracking search is a while loop inside a procedure, which gets no termination check, so no variant is required.
- **other**: Plain greedy Warnsdorff can fail from some start squares, so the program uses iterative backtracking over Warnsdorff-ordered moves with an explicit stack, which is faithful but adds loop-carried state that must stay within ranged types.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, Put without a newline, Boolean objects and text parsing.

## External effects

- **arguments** (allowed): The starting square in algebraic notation is read from the first command-line argument.
- **console output** (allowed): The numbered 8x8 board is printed as text lines.
- **exit status** (allowed): An invalid starting square is rejected with a specified failure outcome.

Assessed on 2026-10-15 against page revision 415067 of the [task](https://rosettacode.org/wiki/Knight's_tour) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
