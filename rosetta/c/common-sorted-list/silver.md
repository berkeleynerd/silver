# Common sorted list

**Candidate: proofs likely to discharge automatically.** Every index comes from for-loop ranges over fixed-size arrays or a guard just before the use, and the dedupe-while-printing design avoids any loop-carried counter, so no annotation is needed.

Position 58 in the [progression](../../progression.md#stage-3), in stage 3.

## Approach

Embed the three example lists as constant integer arrays, copy them with for loops into one fixed 17-element array, then sort it with a for-loop bubble sort (N passes over adjacent pairs, swapping through a temporary). Print by walking the sorted array with a for loop and emitting each element only when it is the first or differs from its predecessor (guarded by an or else), using Put with Integer'Image for the brackets and separators. About 45 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the bracketed sorted unique list as text.

Assessed on 2026-10-15 against page revision 415200 of the [task](https://rosettacode.org/wiki/Common_sorted_list) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
