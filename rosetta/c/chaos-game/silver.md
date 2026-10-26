# Chaos game

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, constant array bounds and for loops, with a bounded-seed deterministic generator replacing system randomness, so proofs should discharge without annotations.

Position 757 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The program keeps a fixed-size grid of characters (for example 32 rows by 64 columns, initially blanks) and the three triangle corners as constants, with the point coordinates and a deterministic generator state held in ranged subtypes. A for loop over a fixed iteration count advances the generator, picks a corner by its value mod 3, moves the point to the integer midpoint, and marks the cell; a final for loop prints each row with Put_Line. All indices are subtype-bounded by the grid's own ranges, so no guards beyond the types are needed. About 45 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator state lives in a bounded integer subtype small enough that seed*multiplier+increment cannot overflow, with a mod reducing it back into range.
- **range**: The midpoint (X + Vx) / 2 of two in-range coordinates stays in range, which linear arithmetic with division by a constant lets the prover show without a loop invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, string indexing, for loops, procedures and case statements.

## External effects

- **console output** (allowed): The Sierpinski triangle is printed as lines of text art through Put_Line.

Assessed on 2026-10-15 against page revision 415358 of the [task](https://rosettacode.org/wiki/Chaos_game) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
