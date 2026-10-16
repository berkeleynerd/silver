# Unique characters

**Candidate: proofs likely to discharge automatically.** Every index is a Character-typed array index or a for-loop index over a string's own range, and the only loop-carried value (the counter) is bounded by its type plus a saturating guard, so nothing needs an annotation. Silver mainly lacks arrays, Character indexing, procedures with String parameters, for loops and Put.

Position 955 in the [progression](../../progression.md#stage-17), in stage 17, which adds unconstrained arrays.

## Approach

Hold a constrained array of small-range counters indexed by Character, initialized to zero, and a procedure Count taking an unconstrained String that loops over its own 'Range and increments each character's counter only when it is below 2 (saturating). Call Count on the three embedded strings, then loop over every Character in order and Put the character and a space for each counter equal to 1, ending with a line terminator. About 32 lines.

## Proof obligations to watch

- **overflow**: The per-character counter is incremented in a loop with no invariant, so it is only incremented under a guard (count below 2) or its type is bounded, which keeps the 'exactly once' result unchanged because counts of 2 or more are all equivalent.

## Language surface recorded by this assessment

Characters, ranged subtypes, arrays, unconstrained arrays, string indexing, for loops, procedures, integers, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Prints the unique characters, separated by spaces, to standard output.

Assessed on 2026-10-15 against page revision 409273 of the [task](https://rosettacode.org/wiki/Unique_characters) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
