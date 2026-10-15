# Binary digits

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every arithmetic result is bounded by the subtype, so overflow, range and index checks follow from types and the loop index, with no loop invariant needed. Only the slice bounds need a small guard, which the loop index and the zero branch provide.

Position 958 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

A procedure Show takes a value of a subtype Natural range 0 .. 2**31-1, fills a fixed 31-character buffer by a reverse for loop, taking N mod 2 as the digit character and halving N each iteration. It then finds the first '1' with a second for loop, and prints either that slice or the single string "0" when the value is zero. Main calls Show on the embedded values 5, 50 and 9000 (plus 0 optionally). About 35 lines.

## Proof obligations to watch

- **range**: Character'Val(48 + N mod 2) is routine because N mod 2 is provably 0 or 1, so the position stays in 48..49.
- **index**: Slicing from the first '1' position to the buffer end needs a guard that the position lies in the buffer, supplied by the for-loop index range and an explicit zero-value branch.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, string indexing, string building, unconstrained arrays, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each binary string followed by a newline using Put_Line.

Assessed on 2026-10-15 against page revision 415551 of the [task](https://rosettacode.org/wiki/Binary_digits) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
