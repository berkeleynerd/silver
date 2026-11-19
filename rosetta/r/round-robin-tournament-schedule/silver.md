# Round-robin tournament schedule

**Candidate: proofs likely to discharge automatically.** All indices come from for-loop ranges over a fixed 12-element array of a bounded subtype, with no while loops, recursion or loop-carried arithmetic, so every check follows from types and static bounds.

Position 97 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Use a constrained array of 12 elements of a 1..12 subtype, filled by a for loop, then an outer for loop over rounds 1..11 that prints a header and six pairs, where the opponent of position I is position 13 - I, ordered smaller-first with an if. After each round, rotate positions 2..12 by one using a temp and a for loop over K in 2..12 shifting from K-1 or via reverse loop, keeping position 1 fixed; output text is built by bounded concatenation of fixed literals and 'Image of the integers. About 45 lines.

## Proof obligations to watch

- **index**: The opponent index 13 - I and the rotation index K - 1 are computed from for-loop bounds (1..6 and 2..12) so they stay within 1..12 by static range reasoning.
- **range**: Circle elements are of a subtype 1..12 and are only ever assigned other elements of the same subtype, so no value check depends on a loop-carried fact.

## Language surface recorded by this assessment

Ranged subtypes, arrays, for loops, 'Image of scalars and integers.

## External effects

- **console output** (allowed): Prints the 11 rounds of pairings and blank separator lines via Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414451 of the [task](https://rosettacode.org/wiki/Round-robin_tournament_schedule) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
