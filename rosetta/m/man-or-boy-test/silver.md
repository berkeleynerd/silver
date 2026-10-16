# Man or boy test

**Candidate: proofs plausibly discharge automatically.** The program has no true closures or recursion, so the Oracle is not violated, but its iterative defunctionalised evaluator carries many loop-carried indices and values that each need hand-placed guards, making automatic discharge plausible but not routine. Fixed capacity (about 800 frames, depth about 1000) covers k = 10 where A is called 722 times, and larger k would be rejected visibly.

Position 843 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Model each Algol activation record as an entry in a fixed-size array of records (k copy, five argument-thunk references, each a small tagged choice of constant 1/0/-1 or a B-closure bound to a frame index), standing in for the heap and closures. A procedure runs an explicit-stack state machine in a bounded while loop that evaluates A and B without recursion, guarding frame allocation, stack depth, step budget and sum ranges with explicit tests that Reject on exceed. Main embeds k = 10 and prints the result with Put_Line. About 130 lines.

## Proof obligations to watch

- **index**: Frame pool and explicit-stack indices are loop-carried in a while loop with no invariant, so each use is guarded by a capacity test just before it and exceeding capacity takes a visible Reject path.
- **overflow**: Accumulated values are subtype-bounded and each addition is guarded by a range test just before it, with an out-of-range sum rejected visibly.
- **termination**: The driver is a while loop inside a procedure, which gets no termination check, and a step-budget counter bounds work and rejects when exhausted.
- **stack**: The Algol recursion is replaced by an explicit fixed-capacity stack and a frame pool so no input-dependent recursion depth exists.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, case statements and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the computed value for k = 10 (-67) with Put_Line.

Assessed on 2026-10-15 against page revision 412910 of the [task](https://rosettacode.org/wiki/Man_or_boy_test) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
