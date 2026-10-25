# Boyer-Moore string search

**Candidate: proofs plausibly discharge automatically.** Every index and shift is bounded by array types and explicit guards before use, and the loops sit in procedures, so no annotation is needed, though loop-carried positions need careful bounded subtypes.

Position 1007 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the texts and needles as String constants and write one procedure that builds a bad-character shift table (array of 256 bounded shifts) from the needle, then scans the haystack right-to-left at each alignment with a while loop and guarded indexes. Matches are recorded in a fixed-length marker String of the haystack's length, set to '^' over each match, and the procedure prints the needle, haystack and marker line, or a not-found line when there is no match. About 90 lines.

## Proof obligations to watch

- **index**: The shift-table lookup indexes by Character'Pos into a 256-entry array, which is safe by type, and the haystack index start+j is guarded by start + needle length <= haystack length before each comparison.
- **overflow**: Start position and shift values are loop-carried, so they are held in bounded subtypes and each advance is guarded against the haystack length before the add.
- **termination**: The scanning while loop lives in a procedure, which gets no termination check, and each iteration advances start by at least one.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints needle, haystack and a marker line for each search case.

Assessed on 2026-10-15 against page revision 412683 of the [task](https://rosettacode.org/wiki/Boyer-Moore_string_search) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
