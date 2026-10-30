# Validate International Securities Identification Number

**Candidate: proofs likely to discharge automatically.** Every check follows from character-range guards, a length guard before indexing, and a sum that stays in a 0..9 subtype, with only for loops and no recursion, so no annotation is needed; the main gaps are Silver surface (functions, loops, character and string indexing, unconstrained String parameters).

Position 972 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

A function Is_Valid_ISIN takes an unconstrained String, returns False unless its length is 12, the first two characters are A-Z, characters 3-11 are A-Z or 0-9 and the last is 0-9, then runs a Luhn check in a for loop over the reverse string range. Each character is expanded into one digit (0-9) or two base-10 digits (letters, via /10 and mod 10) fed from the right into a digit-processing step that alternates doubling with a Boolean flag and keeps the running sum reduced mod 10. Main embeds the seven test strings (including the 13-character duplication case, rejected by the length guard) as constants and prints an explicit valid or not valid line for each using if statements. About 75 lines.

## Proof obligations to watch

- **overflow**: The Luhn sum is loop-carried, so it is kept reduced mod 10 in a subtype 0..9 after every digit and each doubled digit is folded to 0..9 by a guard, making every addition bounded by types alone.
- **index**: Indexing S(S'First+11) and the reverse scan over S'Range are safe because a guard on S'Length = 12 precedes any access and the loop ranges over the string's own bounds.
- **range**: Letter values come from Character'Pos(C) - Character'Pos('A') + 10 and are computed only after a C in 'A'..'Z' comparison guard, so the 10..35 range is evident and the two digits come from /10 and mod 10.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, for loops, procedures, functions, unconstrained arrays, string indexing and arrays.

## External effects

- **console output** (allowed): Prints a valid or not valid verdict line for each embedded test ISIN.

Assessed on 2026-10-15 against page revision 413957 of the [task](https://rosettacode.org/wiki/Validate_International_Securities_Identification_Number) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
