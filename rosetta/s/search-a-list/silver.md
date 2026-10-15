# Search a list

**Excluded from Silver: local exceptions.** Static array bounds and an ascending for loop make the search safe and preserve the first-match requirement; the required raise can be local, so the exclusion is Silver local-exception scope rather than an Oracle conflict.

## Approach

Main holds a bounded constant array of equal-length strings and scans it in increasing index order, printing the first matching index and returning immediately. If no element matches, Main explicitly raises a declared exception and handles it locally with a not-found message; no exception crosses a call. About 25 lines.

## Language surface beyond today's Silver

Arrays, integers, for loops, 'Image of scalars and local exceptions.

## External effects

- **console output** (allowed): Prints the smallest matching index or the locally handled missing-needle outcome.

Initially assessed on 2026-10-15 against page revision 411635 of the [task](https://rosettacode.org/wiki/Search_a_list) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-15 by Codex through targeted source review; see the [review record](../../review-343c2f8.md).
