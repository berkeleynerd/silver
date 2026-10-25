# Periodic table

**Candidate: proofs likely to discharge automatically.** All values are bounded by the 1..118 subtype and small constant tables, so index, range and overflow checks follow from types and the for loop needs no invariant, giving a likely automatic proof.

Position 140 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Declare a subtype Atomic_Number is Integer range 1 .. 118 and constant arrays of segment start numbers and offsets, then a procedure Show (N : Atomic_Number) finds the segment with a bounded for loop over the 8 entries and computes row = (N + offset) / 18 + 1 and column = (N + offset) mod 18 + 1 on small bounded values. Main iterates over an embedded constant array of the example atomic numbers and prints each result with Put, 'Image and Put_Line. About 45 lines.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, procedures, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the row and column for each embedded test atomic number.

Assessed on 2026-10-15 against page revision 414394 of the [task](https://rosettacode.org/wiki/Periodic_table) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
