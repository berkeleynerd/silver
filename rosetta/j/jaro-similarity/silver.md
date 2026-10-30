# Jaro similarity

**Candidate: proofs plausibly discharge automatically.** All checks follow from for-loop ranges over array indices, clamped window bounds and small-range integers, and the floating point of the original is replaced by scaled integer arithmetic, but the loop-carried match count and clamped indices require careful guards.

Position 1005 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A procedure takes two String parameters (length capped by a documented bound), marks matched positions in two Boolean arrays using nested for loops with exit and clamped window bounds, then copies matched characters in order into two compact Character arrays and counts mismatches with a for loop, avoiding the pointer-chasing while loop. The score is computed in integer arithmetic as a fixed-point value scaled by 100000 (using 2m minus transpositions over 2m), then printed as digits via integer image with Put and Put_Line for the four pairs including the DWAYNE/DUANE example. Empty strings, m = 0 and strings over the cap are each handled by explicit guards with a visible outcome. About 95 lines.

## Proof obligations to watch

- **index**: Match-window bounds are computed from L, string lengths and the window size, so the program clamps them with explicit min/max guards before the inner for loop over Right.
- **range**: The loop-carried match count is only known by its subtype after the first iteration, so a guard (count below capacity) precedes each increment and each compact-array store, which never triggers since matches cannot exceed the string length.
- **overflow**: Scaled score arithmetic multiplies lengths, match counts and 100000 in bounded subtypes, which fits in 64 bits for strings capped at a small documented length.
- **division**: Divisions by match count and string lengths are each preceded by a guard on m = 0 and on empty strings, with m = 0 giving the specified score 0.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, 'Image of scalars, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each pair's similarity score as text lines.

Assessed on 2026-10-15 against page revision 414276 of the [task](https://rosettacode.org/wiki/Jaro_similarity) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
