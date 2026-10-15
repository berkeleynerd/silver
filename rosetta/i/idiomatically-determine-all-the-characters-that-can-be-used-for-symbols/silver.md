# Idiomatically determine all the characters that can be used for symbols

**Candidate: proofs likely to discharge automatically.** All checks come from the for-loop index range, the declared count range and a capacity guard before each append, with no while loops or recursion, so proofs should discharge automatically. The set of identifier characters is the fixed Ada rule applied to every Character value, which is a faithful, bounded program.

Position 970 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A procedure loops with a for loop over every value of the Character type and classifies each one with plain comparisons (letters a-z and A-Z, digits 0-9, underscore) for the three sets (first, middle, last position). Each matching character is appended to a 64-character String buffer behind a guard on a bounded count, and the buffer slice is then printed with Silver_IO.Put_Line under a label that names the character set (ASCII/Latin-1 as the platform's Character type). About 45 lines.

## Proof obligations to watch

- **index**: The write position in the fixed 64-character buffer is a loop-carried count, so each append is guarded by testing the count against the capacity just before the store and the increment.
- **range**: The slice Buffer (1 .. Count) is safe because Count is declared Natural range 0 .. 64 and the buffer covers 1 .. 64.

## Language surface beyond today's Silver

Integers, characters, ranged subtypes, for loops, string indexing, string building, unconstrained arrays and procedures.

## External effects

- **console output** (allowed): Prints the sets of characters valid in identifiers with Put_Line.

Assessed on 2026-10-15 against page revision 413749 of the [task](https://rosettacode.org/wiki/Idiomatically_determine_all_the_characters_that_can_be_used_for_symbols) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
