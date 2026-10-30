# Penholodigital squares

**Candidate: proofs plausibly discharge automatically.** All checks follow from declared integer ranges, a base subtype bounding digit indexes, and fixed-bound for loops, but the loop-carried counters and the base-digit formatting need careful shaping without invariants.

Position 459 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

For each base from 9 to 12 a for loop scans n over a fixed range bracketing sqrt(base^(base-2)) to sqrt(base^(base-1)) (or simply 1..900_000), squares it in a 64-bit integer type, and a procedure with a Boolean seen array extracts base digits by a fixed 12-iteration for loop, rejecting zero digits, repeats and wrong digit counts. Matches are formatted into a bounded Character buffer in the base and printed with Put_Line along with the per-base count, and the optional stretch bases 13 and up are omitted. About 110 lines.

## Proof obligations to watch

- **overflow**: n*n for n up to 900000 stays below 10**12, which fits a 64-bit integer type, and the loop range is declared so the prover sees the bound from the types.
- **index**: Digits come from mod by a base subtype of 9..12, so the digit is in 0..11 and indexes a Boolean array of 0..15 without a guard.
- **termination**: Digit extraction uses a for loop of 12 fixed iterations that stops acting when the value reaches zero, so no while loop or variant is needed in a function.
- **overflow**: The distinct-digit counter is a loop-carried value, so it uses a bounded subtype with a guard before each increment.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string building, 'Image of scalars, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the count and each square with its root in the base for bases 9 to 12.

Assessed on 2026-10-15 against page revision 413842 of the [task](https://rosettacode.org/wiki/Penholodigital_squares) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
