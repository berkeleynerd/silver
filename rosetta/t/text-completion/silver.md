# Text completion

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop over fixed bounds with range-typed table cells, and the only division is guarded by a validated non-zero length, so all checks follow from types and guards without annotations. The embedded dictionary replaces the large word file, a documented resource limit, and a plain edit-distance similarity satisfies the task's "any algorithm" allowance.

Position 681 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed a small fixed dictionary of lowercase words in a constant array of fixed-capacity padded buffers with stored lengths. Validate the first argument (length 1 to 16, lowercase letters only) and reject otherwise. For each dictionary word, a procedure fills a two-dimensional Levenshtein table using for loops, converts the distance to a percentage similarity, and prints words at or above a threshold with the percentage. About 130 lines.

## Proof obligations to watch

- **overflow**: The Levenshtein table cells are a subtype capped at the maximum word length and are filled with for loops over fixed bounds, so minimum-plus-one never exceeds the subtype.
- **index**: All table and string indexes come from for loops over the arrays' own ranges, or from word lengths already validated against the fixed capacity.
- **division**: The percentage divides by the longer word length, which is guarded to be at least 1 because an empty argument is rejected before use.
- **range**: Percentage is computed as (longer - distance) * 100 / longer where distance never exceeds longer, which a guard before the subtraction makes explicit.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, 'Image of scalars, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the input word and each candidate with its similarity percentage.
- **arguments** (allowed): The word to complete is taken from the first command-line argument, with Input_Is_Valid and Reject for bad input.

Assessed on 2026-10-15 against page revision 354267 of the [task](https://rosettacode.org/wiki/Text_completion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
