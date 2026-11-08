# Binary search

**Candidate: proofs plausibly discharge automatically.** Everything follows from small declared ranges and a guard before the array access, but the loop-carried Low/High bounds mean the in-range index fact must come from an explicit guard rather than an invariant, so success depends on careful shape; no annotations are needed.

Position 218 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

An embedded constant sorted Integer array (for example 2 4 6 8 9) is searched iteratively by a procedure with out parameters Found and Position, using Low and High as a ranged subtype 0..N+1 and a while Low <= High loop with Mid = Low + (High - Low) / 2 and a guard on Mid before indexing. A main loop over an embedded array of search values calls the procedure and prints "contains X at I" or "does not contain X" through Put_Line with 'Image concatenation into a bounded String; the recursive variant and insertion-point variants are optional and omitted. About 45 lines.

## Proof obligations to watch

- **index**: Low and High are loop-carried so the prover knows only their type range 0..N+1, and Array(Mid) discharges only because an explicit guard just before the access sends out-of-range Mid to a visible not-found outcome (a guard that is dead in practice but not provable as dead without an invariant).
- **overflow**: Low, High and Mid are declared as a small ranged subtype (0..N+1) so Low + High and Mid - 1 cannot overflow, and Mid is computed as Low + (High - Low) / 2.
- **termination**: The while loop lives in a procedure, which gets no termination check, so no variant is required.
- **length**: Result text built with 'Image and concatenation must fit a fixed-size bounded String buffer sized for the longest line.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints a found or not-found line for each embedded search value.

Assessed on 2026-10-15 against page revision 415450 of the [task](https://rosettacode.org/wiki/Binary_search) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
