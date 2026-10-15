# Selection bias in clinical sciences

**Candidate: proofs plausibly discharge automatically.** All loops are bounded for loops over fixed arrays and every value is range-typed or guarded, so checks follow from types and guards, but the scaled nonlinear H arithmetic and loop-carried counters need careful shaping.

Position 1313 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

Fixed 1000 subjects and 180 days are held in parallel constrained arrays (cumulative dose, had-infection flag, category enumeration), driven by a deterministic modular-type linear congruential generator with per-day probabilities as integer thresholds (1/1000 infection, 5/1000 start, 25/100 continue, dose 3, 6 or 9 via mod 3). Nested for loops update subjects daily, a procedure prints monthly group counts and infection counts as the stretch output, and the Kruskal H is computed with integer arithmetic scaled by 1000 using closed-form rank sums for the two-valued outcome with tie correction, printed via 'Image, with guarded divisions for empty groups. About 150 lines.

## Proof obligations to watch

- **overflow**: Cumulative dose is a loop-carried value that is saturated by an explicit guard (any dose of 100 or more already means REGULAR), so the addition cannot overflow its subtype.
- **overflow**: Rank sums squared and scaled for the integer Kruskal H reach about 1e12 and are computed in 64-bit integers with operand types bounded by the 1000-subject and 180-day limits.
- **division**: Group sizes and the H denominator can be zero, so each division is preceded by an explicit guard that prints a stated 'group empty' outcome instead of a number.
- **overflow**: The pseudo-random generator uses a modular type so wraparound is by definition and the draws are reduced by mod into small ranged subtypes.
- **index**: All loops run over the arrays' own ranges and the category index is an enumeration, so indexing is routine, but the per-group counters carried through loops need range-typed bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, Boolean objects, enumerations, arrays, for loops, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints periodic group counts, infection percentages and the final H statistic.

Assessed on 2026-10-15 against page revision 400980 of the [task](https://rosettacode.org/wiki/Selection_bias_in_clinical_sciences) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
