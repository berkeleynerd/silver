# Sierpinski triangle

**Candidate: proofs likely to discharge automatically.** Every index and update depends only on for-loop ranges and Boolean values, so the checks follow from types and loop bounds and need no invariant, and the loops and output sit in a procedure so there are no termination checks. The task has no input or recursion, so there is no unbounded depth or heap use.

Position 478 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Order 4 is a fixed constant (16 rows). A Boolean array of 16 holds one row of Pascal's triangle mod 2 and is updated in place with a reverse for loop using inequality as XOR. For each row, a 31-character String of spaces gets '*' at position 16 - R + 2*C for each C in 0 .. R where the row bit is set, and the row is output with Put_Line. About 30 lines.

## Proof obligations to watch

- **index**: The star position 16 - R + 2*C in the 31-character line is linear in two for-loop variables with C in 0 .. R and R in 0 .. 15, so it stays within 1 .. 31 and the provers discharge it without an invariant.
- **index**: Updating the Pascal row in place with Row (C - 1) uses a reverse for loop over C in 1 .. 15, so C - 1 is always in range, and the Boolean row values carry no loop-carried range risk.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building and for loops.

## External effects

- **console output** (allowed): Each of the 16 triangle rows is written as one line of text.

Assessed on 2026-10-15 against page revision 414880 of the [task](https://rosettacode.org/wiki/Sierpinski_triangle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
