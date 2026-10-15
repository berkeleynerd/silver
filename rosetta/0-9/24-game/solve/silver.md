# 24 game/Solve

**Candidate: proofs plausibly discharge automatically.** All loops are bounded for loops in procedures and the rational arithmetic can be kept in small ranged types with guards, so no annotation is needed, though the overflow and range guards across many nested combinations call for careful program shape.

Position 850 in the [progression](../../../progression.md#stage-14), in stage 14.

## Approach

Embed a few example digit quadruples and, for each, enumerate the 24 orderings through four nested for loops with distinctness checks, then 64 operator triples and the five bracketings, evaluating each exactly as a rational record (numerator, positive denominator) in bounded subtypes with cross-multiplication for the comparison to 24, and a Valid flag cleared on a zero divisor or a magnitude beyond the bound. On a hit it builds the expression text in a fixed-length buffer from digit and operator characters and prints it with Put_Line, using a Found flag to skip further work; otherwise it prints a no-solution message. About 170 lines.

## Proof obligations to watch

- **overflow**: Rational numerators and denominators are held in ranged subtypes and every combining step is guarded by a magnitude bound (never triggered for digits 1 to 9) so products fit in 64 bits.
- **division**: A guard rejects a zero divisor numerator before dividing, so that expression is simply invalid as in the game rules.
- **range**: Each result is checked against the subtype bounds before conversion, since loop-carried values carry only type ranges.
- **index**: Permutation indexes and output buffer positions come from for loops over fixed ranges and constant offsets, so they discharge from static bounds.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string building, case statements, for loops, procedures and functions.

## External effects

- **console output** (allowed): Prints each example digit set with its found expression or a no-solution message.

Assessed on 2026-10-15 against page revision 414627 of the [task](https://rosettacode.org/wiki/24_game/Solve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
