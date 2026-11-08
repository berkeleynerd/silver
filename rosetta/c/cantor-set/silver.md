# Cantor set

**Candidate: proofs likely to discharge automatically.** All loops are for loops with static bounds and the only loop-carried value has a declared range that the update provably stays within, so every check follows from types and no annotation or recursion is needed.

Position 483 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

One 81-character String buffer is reused for five rows (levels 0 to 4). For each level and each column I, a subtype 0 .. 80 variable J starts at I-1 and, for each of the Level leading base-3 digits, a column is blanked if J / 27 equals 1, and J then becomes (J mod 27) * 3; the cell is set to '*' or ' ' and the row is printed with Put_Line. About 30 lines.

## Proof obligations to watch

- **range**: The loop-carried value J is a subtype 0 .. 80 and each update (J mod 27) * 3 is at most 78, so the range check discharges from the type and arithmetic alone.
- **index**: The row index comes from a for loop over 1 .. 81, which is the String's own range, so indexing is routine.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing and for loops.

## External effects

- **console output** (allowed): Prints the five rows of the Cantor set as text art with Put_Line.

Assessed on 2026-10-15 against page revision 415349 of the [task](https://rosettacode.org/wiki/Cantor_set) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
