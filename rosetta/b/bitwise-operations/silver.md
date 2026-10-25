# Bitwise operations

**Candidate: proofs likely to discharge automatically.** Modular operations never raise overflow checks and the shift amount is guarded, so every check is straight-line and follows from types; the only new needs are modular types, 'Image and bounded text building.

Position 1259 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Declare 8-bit modular constants A, B and a shift amount N as embedded example data, and print AND, OR, XOR, NOT, shifts and rotates using the standard Interfaces operations with 'Image concatenated into Put_Line strings. An if on N being below 8 guards the shift and rotate section, with a printed rejection message otherwise; no loops are needed. About 28 lines.

## Language surface recorded by this assessment

Modular types, ranged subtypes, integers, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Each operation's result is printed with Put_Line.

Assessed on 2026-10-15 against page revision 414791 of the [task](https://rosettacode.org/wiki/Bitwise_operations) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
