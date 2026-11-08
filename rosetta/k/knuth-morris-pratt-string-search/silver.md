# Knuth-Morris-Pratt string search

**Candidate: proofs plausibly discharge automatically.** The task is only a pointer to the algorithm, which is plain index arithmetic on bounded arrays in procedures, so no annotation is needed. The risk lies in loop-carried indices (lon, i, j) without invariants, which explicit guards and bounded subtypes should let the provers discharge.

Position 562 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the example texts and patterns as String constants, copy each into a bounded Character array with a length, and implement the failure-table construction and the search as procedures using while loops over bounded index subtypes with explicit guards before every table and pattern access. Matches are collected into a fixed-capacity index array with a count, with a visible guard if the capacity is reached, and then printed with Put and Integer'Image in the "Found 'p' in 'textN' at indices [ ... ]" layout. About 110 lines.

## Proof obligations to watch

- **index**: The failure-table index t(lon-1) and pattern(lon) use a loop-carried lon with no invariant, so lon is declared in a bounded subtype and each use is preceded by an explicit lon /= 0 or lon < length guard.
- **overflow**: The increments of idx, lon, i and j are loop-carried, so each is typed with a range one above the maximum text or pattern length and guarded before incrementing, with the guard's outcome visible.
- **range**: Table entries and match positions are stored into subtypes bounded by the maximum pattern and text lengths, which holds by type but must be stated so the assignments discharge.
- **length**: Inputs of different lengths live in fixed-capacity buffers with a separate length variable, and the embedded data must fit the declared capacity (about 220 characters).

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, for loops, while loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints each text, then the pattern and the list of match indices, to standard output.

Assessed on 2026-10-15 against page revision 379605 of the [task](https://rosettacode.org/wiki/Knuth-Morris-Pratt_string_search) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
