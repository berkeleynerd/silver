# Damm algorithm

**Candidate: proofs likely to discharge automatically.** Every check follows from the 0..9 subtype of both the state and the table entries plus a per-character digit guard, so no loop invariant is needed; the only new surface is a 2D constant table, string indexing and a for loop in a procedure.

Position 968 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Define subtype Digit is Integer range 0 .. 9 and a constant 10x10 Digit table holding the Damm quasigroup, then a procedure Check(Input : String) that loops over Input'Range with a state of type Digit, rejecting any non-digit character with a visible "invalid" outcome and otherwise doing State := Table(State, Character'Pos(C) - Character'Pos('0')). The main procedure calls Check on the four embedded examples, printing the text with Put and the Boolean result (State = 0) as TRUE or FALSE through an if statement. About 45 lines.

## Proof obligations to watch

- **index**: Character-to-digit conversion and the table lookup are guarded by a per-character check that the character lies in '0'..'9', and the running state is a 0..9 subtype, so the two-dimensional index checks follow from types.
- **range**: Assigning the table entry to the 0..9 state variable needs no loop invariant because the table element type is the same 0..9 subtype.

## Language surface beyond today's Silver

Ranged subtypes, characters, multidimensional arrays, arrays, unconstrained arrays, string indexing, for loops, procedures, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded example number with its validation result.

Assessed on 2026-10-15 against page revision 415390 of the [task](https://rosettacode.org/wiki/Damm_algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
