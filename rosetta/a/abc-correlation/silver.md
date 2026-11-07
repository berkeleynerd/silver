# ABC correlation

**Candidate: proofs likely to discharge automatically.** The program is one for loop over a length-bounded argument with three guarded counters and an equality test, so every check follows from types and guards placed just before the operation.

Position 487 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Take the first command-line argument as a bounded String (validated to a documented maximum length, with Reject otherwise), then run one for loop over its own index range, testing each Character against 'a', 'b' and 'c' and bumping three counters held in a ranged subtype. Each increment is guarded by a check against the maximum, with Reject as the visible outcome, and the program prints true if the three counts are equal and false otherwise. About 35 lines.

## Proof obligations to watch

- **overflow**: The three counters are loop-carried, so GNATprove knows only their subtype range after the first iteration; the program discharges this with a guard before each increment that rejects when a counter is at its maximum, which the length-bounded input never triggers.
- **index**: Indexing the argument string is safe because the loop runs over the string's own index range.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing and for loops.

## External effects

- **arguments** (allowed): The input string is read from the first command-line argument.
- **console output** (allowed): The program prints true or false with Put_Line.

Assessed on 2026-10-15 against page revision 413626 of the [task](https://rosettacode.org/wiki/ABC_correlation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
