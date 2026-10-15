# Count the coins

**Candidate: proofs plausibly discharge automatically.** Every check is a static bound or a guard just before the operation, but the loop-carried Counter additions need explicit overflow guards, so discharge depends on program shape. The 64-bit range holds the optional answer, so no big-number support is needed and nothing needs an annotation.

Position 908 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A ranged Counter type (0 .. 2**63-1) holds a ways-array Cnt over 0 .. 100_000 with Cnt(0)=1, and a constant coin table of 100, 50, 25, 10, 5, 1 is processed by a procedure taking the goal and the number of leading coins to use. Nested for loops over coins and amounts add Cnt(A - Coin) into Cnt(A) under a Coin <= A guard and an explicit overflow guard that rejects. Main calls it for goal 100 with the last four coins and goal 100_000 with all six, and prints each result via 'Image. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried sum Cnt(A) + Cnt(A-Coin) is bounded only by the Counter type, so the program tests Cnt(A) <= Counter'Last - Cnt(A-Coin) just before the addition and otherwise rejects visibly, while the real maximum 13398445413854501 is well inside a 2**63-1 range.
- **index**: Index A - Coin is safe because the guard Coin <= A and the positive Coin constant lie just before the access, with A ranging over the array's own range.
- **range**: Goal and coin count are fixed constants within the 0 .. 100_000 array bound and the 6-element coin table, so every subscript follows from static bounds.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and conditional expressions.

## External effects

- **console output** (allowed): Prints the two counts (242 and 13398445413854501) with Put_Line.

Assessed on 2026-10-15 against page revision 413676 of the [task](https://rosettacode.org/wiki/Count_the_coins) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
