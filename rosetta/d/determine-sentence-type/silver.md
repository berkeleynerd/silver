# Determine sentence type

**Candidate: proofs likely to discharge automatically.** Everything is bounded string indexing within S'Range plus a case on a Character, so all checks follow from types and the for-loop range, and no annotation or recursion is needed.

Position 771 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The four sentences are embedded as String constants, and a procedure Classify (S : String) takes each one, rejecting an empty string with a visible message and otherwise scanning backward with a for-reverse loop over S'Range for the last of '?', '.' or '!' (neutral if none), then prints the letter, a colon and the sentence. The extra multi-sentence mode is optional and omitted, so the classification is a single-pass search with no loop-carried state beyond a Character result. About 55 lines.

## Proof obligations to watch

- **index**: The last-character and last-punctuation scan index only within the string's own range, guarded by a Length-greater-than-zero test, with a for loop in reverse over S'Range.

## Language surface beyond today's Silver

String indexing, characters, case statements, procedures, string building, Put without a newline, arrays, for loops, integers and ranged subtypes.

## External effects

- **console output** (allowed): Prints one classified line per embedded sentence.

Assessed on 2026-10-15 against page revision 415399 of the [task](https://rosettacode.org/wiki/Determine_sentence_type) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
