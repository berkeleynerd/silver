# Count how many vowels and consonants occur in a string

**Candidate: proofs likely to discharge automatically.** Every check follows from the for-loop index range over the string, a counter subtype bounded by the documented maximum length, and a length guard on the input, with no loop invariants needed.

Position 760 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Take the first argument via First_Or_Default, reject it if it exceeds a documented maximum length, then a for loop over the string's own index range classifies each character with a case statement on letters (A, E, I, O, U and lowercase as vowels, other letters as consonants), incrementing two counters typed to the length bound. Print the quoted string and the counts using integer 'Image into a bounded line. About 45 lines.

## Proof obligations to watch

- **overflow**: Counters are Natural subtypes bounded by the string's fixed maximum length, so a range subtype capped at that length (or a guard before the increment) discharges the increment checks.
- **length**: The input is rejected if longer than a documented bound (e.g. 1024), so the output buffer is sized from the bound and concatenation lengths are statically known.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, 'Image of scalars, for loops, case statements, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the string and the vowel and consonant counts.
- **arguments** (allowed): The string to analyze is taken from the first command-line argument, with invalid input rejected.

Assessed on 2026-10-15 against page revision 413614 of the [task](https://rosettacode.org/wiki/Count_how_many_vowels_and_consonants_occur_in_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
