# Proper divisors

**Candidate: proofs likely to discharge automatically.** Only bounded for loops, mod and division by a nonzero loop index, and a range-limited counter are involved, so every check follows from types and a guard just before the increment.

Position 144 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A single Main procedure uses a Positive range subtype 1 .. 20_000 for N and a for loop over D in 1 .. N/2 testing N mod D = 0, first printing divisors with Put for N in 1 .. 10, then counting divisors for every N in 1 .. 20_000 and tracking the best N and count. The count increment is guarded by a bound check, and all arithmetic stays within declared ranges; output uses 'Image text pieces joined with concatenation into Put and Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The loop-carried divisor count and best-so-far values are declared with a range of 0 .. 20_000 and the increment is guarded by a comparison against that bound, so the addition cannot overflow without an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, 'Image of scalars, string building, Put without a newline, for loops and procedures.

## External effects

- **console output** (allowed): Prints the divisor lists for 1 to 10 and the final maximum-count line.

Assessed on 2026-10-15 against page revision 413861 of the [task](https://rosettacode.org/wiki/Proper_divisors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
