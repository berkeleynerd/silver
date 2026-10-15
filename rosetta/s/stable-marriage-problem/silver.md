# Stable marriage problem

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size arrays and enumerations with index checks that follow from types and sentinel guards, and the only loop-carried state (proposal counters, free flags) is range-typed, so no annotation is needed. Plausible rather than likely because of the nested-array aggregates, the sentinel handling and the 'Image-based output strings.

Position 1553 in the [progression](../../progression.md#stage-34), in stage 34.

## Approach

Guys and girls are enumerations with a sentinel value plus subtypes excluding it, and the ten-by-ten preference tables are constant arrays of arrays embedded as aggregates. A procedure precomputes rank tables with for loops, then runs Gale-Shapley with a while loop over free men, guarding the proposal counter and the sentinel before each index. A stability-check procedure uses nested for loops over men and women comparing ranks, and the main procedure prints the engagements, then swaps each pair of partners, rechecks and restores them. About 170 lines.

## Proof obligations to watch

- **index**: Partner entries are Guy_X including a no_guy sentinel, so every use as an index into the preference tables sits behind an explicit /= no_guy guard, and rank tables are filled by for loops over the arrays' own ranges.
- **overflow**: The per-man proposal counter is a 0..10 range type incremented only after a guard that it is below 10, so the increment and the following Rank index both follow from the type and the guard.
- **termination**: The Gale-Shapley while loop lives in a procedure, which gets no termination check, so no variant is needed, though the loop-carried free and engaged flags are only typed, not bounded, so progress is never proved.
- **length**: Output lines concatenate names from 'Image of enumerations whose maximum lengths are statically bounded, so the concatenation length checks need the bounded-concatenation support to discharge.

## Language surface beyond today's Silver

Enumerations, ranged subtypes, arrays, multidimensional arrays, Boolean objects, 'Image of scalars, string building, for loops, while loops, procedures, functions and membership tests.

## External effects

- **console output** (allowed): Prints each engagement and the stable or unstable verdict for the Gale-Shapley result and for every pairwise exchange.

Assessed on 2026-10-15 against page revision 414019 of the [task](https://rosettacode.org/wiki/Stable_marriage_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
