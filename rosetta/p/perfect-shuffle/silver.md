# Perfect shuffle

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges, for-loop indexes and one guard on the loop-carried counter, and the open-ended loop lives in a procedure so no variant is needed.

Position 211 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Represent the deck as a fixed-capacity array of 10_000 integers indexed 0..9_999 with a Size subtype of even values passed as a ranged parameter, and a Count_Shuffles procedure that fills an identity deck, repeatedly interleaves the two halves into a second array using a for loop, copies it back, and compares to the identity with a for loop setting a Boolean. The outer repeat loop is a while loop inside a procedure (no termination check) with the counter guarded by a cap that rejects visibly, and Main calls a Report procedure for each of the seven embedded sizes, printing the count with 'Image and Put_Line. About 55 lines.

## Proof obligations to watch

- **overflow**: The loop-carried shuffle counter is guarded against a fixed cap (e.g. 10_000) before each increment, with a visible rejection outcome if reached, so the increment check discharges.
- **index**: The interleave indices 2*I and 2*I+1 are bounded because I ranges over 0..Half-1 with Half a subtype capped at 5000 and the deck array sized 0..9999, which the provers can show from ranges alone.
- **initialization**: Whole fixed-capacity deck arrays are initialized with an aggregate before any prefix is used, so flow analysis passes.
- **stack**: Three 10_000-element Integer arrays on the stack are a fixed-size environmental premise rather than input-dependent depth.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one line per test deck size giving the shuffle count.

Assessed on 2026-10-15 against page revision 413845 of the [task](https://rosettacode.org/wiki/Perfect_shuffle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
