# Wordle comparison

**Candidate: proofs likely to discharge automatically.** Every index is a for-loop variable over the arrays' own constrained range and the loops carry only Boolean flags and enumeration values, so all checks follow from types and no invariant or variant is needed. The fixed 5-letter bound is a documented resource limit and the task's same-length assumption is met by the Word subtype.

Position 1163 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Define a constrained subtype Word as String (1 .. 5) and a Color enumeration (Grey, Yellow, Green), then a procedure Score that takes answer and guess Words and fills an out array of Color plus a local array of Boolean flagging answer letters already consumed. Pass one marks greens with a for loop over the shared index range, and pass two uses a nested for loop over answer positions to mark each remaining guess letter yellow against the first unused equal answer letter, otherwise grey. Main embeds the ALLOW/LOLLY test and a few further 5-letter pairs as constants and prints each result with Put and a case statement per letter. About 70 lines.

## Language surface recorded by this assessment

Ranged subtypes, characters, arrays, string indexing, Boolean objects, for loops, procedures, case statements, Put without a newline and enumerations.

## External effects

- **console output** (allowed): Prints each answer/guess pair and its per-letter green, yellow or grey marking.

Assessed on 2026-10-15 against page revision 414588 of the [task](https://rosettacode.org/wiki/Wordle_comparison) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
