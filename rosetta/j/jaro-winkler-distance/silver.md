# Jaro-Winkler distance

**Candidate: proofs plausibly discharge automatically.** All checks follow from ranged subtypes, for-loop index ranges and guards placed before indexing and division, with no annotation needed, but several loop-carried counters and the scaled-integer arithmetic need careful shaping. Using scaled integers instead of floats and an embedded dictionary keeps it within automatically provable style.

Position 637 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed a small constant dictionary (about 20 words) and the nine misspelled words as arrays of records holding a fixed-capacity character buffer plus a length; a procedure computes Jaro similarity using Boolean match-flag arrays, a for loop over the first string with a clamped window, and a guarded while loop for transpositions, then applies the Winkler prefix bonus (up to 4) in scaled integers. Main loops over each misspelled word and dictionary word, keeps entries whose distance is below a threshold in a bounded result array, orders them with a bounded insertion sort, and prints the top few with the distance formatted as 0.dddd via integer division and mod. About 150 lines.

## Proof obligations to watch

- **index**: Match-window bounds and the transposition pointer k are loop-carried, so each is clamped by an explicit guard to 1 .. length just before use.
- **overflow**: Match and transposition counters and scaled-integer products are held in small ranged subtypes (lengths up to 16, scale 10000) so every product and sum stays within Integer.
- **division**: Divisions by the string lengths and by the match count are each guarded by a preceding length or matches > 0 test with a defined outcome.
- **termination**: The transposition scan uses a while loop with an explicit bound guard (k <= length) inside a procedure, so no termination check or variant is needed.
- **floating point**: Avoided by computing the similarity as scaled integer rational arithmetic with 4 decimal digits, so output is formatted from integers rather than a Double.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints each misspelled word with its close dictionary alternatives and their distances.

Assessed on 2026-10-15 against page revision 414277 of the [task](https://rosettacode.org/wiki/Jaro-Winkler_distance) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
