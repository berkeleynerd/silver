# Monty Hall problem

**Candidate: proofs likely to discharge automatically.** Everything is bounded for loops over fixed ranges with a modular-type generator, so every check follows from types, static bounds and a type with headroom for the counters; no annotations or recursion are needed.

Position 1272 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

A deterministic modular-type LCG yields door indices via mod 3; a procedure plays one game given a strategy flag by choosing a car door and a pick, finding Monty's door with a for loop over three doors, and optionally switching to the remaining door. Two for loops of 10000 games count wins per strategy, then the program prints counts and integer percentages using scalar images and concatenation. About 90 lines.

## Proof obligations to watch

- **overflow**: The linear congruential generator uses a modular type so wraparound is defined and no overflow check exists.
- **range**: Door values come from a mod 3 reduction converted to a 1..3 subtype, so the conversion is in range by construction.
- **overflow**: Win counters only have their type range inside the loop, so they use an integer type with headroom far above the fixed game count of 10000.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, enumerations, arrays, for loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the stay and switch win counts and percentages as text lines.

Assessed on 2026-10-15 against page revision 414971 of the [task](https://rosettacode.org/wiki/Monty_Hall_problem) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
