# Loops/Wrong ranges

**Candidate: proofs likely to discharge automatically.** Every check follows from the bounded Value subtype and the explicit guards before the single addition, and invalid ranges get a visible error message rather than a changed result. The only loop is a while loop inside a procedure, so no variant is needed.

Position 604 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Declare a bounded subtype Value (for example -1000 .. 1000) and a constant array of nine records holding start, stop, step and a comment, then a for loop over the array's own range calls a procedure Print_Range. Print_Range prints an explicit error line for stop < start or step <= 0, and otherwise runs a while loop that prints Num, exits when Stop - Num < Step, and else adds Step, all with Put and 'Image output. About 70 lines.

## Proof obligations to watch

- **overflow**: The loop-carried Num is declared in a bounded subtype and the increment is guarded by exiting when Stop - Num < Step, so Num + Step provably stays at most Stop.
- **termination**: The while loop sits in a procedure, which gets no termination check, and Step is guarded to be positive so the loop also does terminate.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, records, arrays, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each test's comment, parameters and resulting range or error message to standard output.

Assessed on 2026-10-15 against page revision 413767 of the [task](https://rosettacode.org/wiki/Loops/Wrong_ranges) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
