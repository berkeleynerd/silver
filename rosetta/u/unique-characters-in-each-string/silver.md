# Unique characters in each string

**Candidate: proofs likely to discharge automatically.** Every check follows from the Character-indexed array type, a capped counter guarded just before the increment, and for loops over the arrays' own ranges, so no annotation is needed. The only missing pieces are arrays, Character indexing, for loops, procedures and unterminated character output.

Position 975 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the three strings as constants and keep a Count array indexed by Character with a small range subtype (0..2) per string, filled by a procedure that loops over the string's own 'Range and increments only when the count is below 2. Then loop over every Character in order (which is alphabetical order) and print it followed by a space when all three counts equal exactly 1. All loops are for loops and nothing is recursive or heap allocated. About 45 lines.

## Proof obligations to watch

- **overflow**: The per-character count is capped at 2 by a guard just before the increment, so the increment cannot overflow its small range subtype.
- **index**: Counts are indexed by Character over an array whose index type is Character and the string is walked with for loops over its own 'Range, so every index check follows from types.

## Language surface beyond today's Silver

Characters, ranged subtypes, arrays, unconstrained arrays, string indexing, for loops, procedures, integers, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints the characters unique in every string, space separated, on standard output.

Assessed on 2026-10-15 against page revision 406638 of the [task](https://rosettacode.org/wiki/Unique_characters_in_each_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
