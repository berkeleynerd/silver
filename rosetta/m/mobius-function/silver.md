# Möbius function

**Candidate: proofs likely to discharge automatically.** Trial division with a for loop inside a procedure avoids function termination checks, and every value is bounded by declared subtypes, so all checks follow from types and loop ranges.

Position 882 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

A procedure Mobius (N : in Positive_Small; Result : out Mu_Range) uses a Value variable typed 0..199 and a for loop over trial divisors P in 2..199, dividing out each P and setting Result to 0 on a repeated factor or negating it otherwise. The main procedure loops N in 1..99 (or 1..199), calls Mobius, and prints each value as a fixed-width cell with Put using if/elsif on -1, 0, 1, emitting Put_Line after every tenth term for a grid. Divisors are always at least 2 so mod and division are guarded by the loop range. About 45 lines.

## Proof obligations to watch

- **range**: Value / P must stay within a 0..199 subtype after the first iteration; it does because Value is typed with that range and division by a positive P cannot increase it.
- **overflow**: Negating a Result typed -1..1 is always in range, and a zero Result stays zero, so no loop-carried invariant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the grid of Möbius values to standard output.

Assessed on 2026-10-15 against page revision 412927 of the [task](https://rosettacode.org/wiki/M%C3%B6bius_function) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
