# Longest substrings without repeating characters

**Candidate: proofs likely to discharge automatically.** A sliding-window scan with a last-seen table needs only a for loop and loop-carried values held in bounded subtypes, so every range and index check follows from types and an up-front length guard without any annotation. No recursion, while loops or function termination checks are involved.

Position 969 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A procedure Test takes the String (embedded test data such as the empty string, xyzyabcybdfd and zzzzz are passed from Main), rejects it if longer than a documented maximum, and runs a single for loop over Item'Range with a Character-indexed array of last-seen positions of a bounded subtype. The window start is moved past the previous occurrence by an explicit if guard, and the best first index and length are updated only when the current window is strictly longer; the result is printed by slicing Item, or printing an empty line when no characters exist. About 55 lines.

## Proof obligations to watch

- **overflow**: The window start and last-seen positions live in subtypes bounded by a documented maximum length, with an explicit length guard rejecting longer inputs, so the +1 and length arithmetic stay in range.
- **index**: Indexing the per-character table by Character and slicing Item(Best_First .. Best_Last) follow from the Character-indexed array type and the loop-carried subtype ranges, with the empty case handled by a guard before slicing.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, for loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): Prints each test string and its longest repeat-free substring with Put_Line.

Assessed on 2026-10-15 against page revision 414657 of the [task](https://rosettacode.org/wiki/Longest_substrings_without_repeating_characters) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
