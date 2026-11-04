# Soundex

**Candidate: proofs likely to discharge automatically.** Everything is a bounded for loop over fixed-size strings with output-position guards and character-class case mapping, so all checks follow from types and local guards and no annotation is needed. The code-run rule Ashcraft/Tymczak needs only a small previous-code state variable of a small enumeration or digit subtype.

Position 786 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed the sample names as String constants and encode each in a procedure writing into a fixed 4-character output buffer: the first letter is upper-cased, then a for loop over the name's range maps each letter to a code digit (or vowel, H/W-separator, or ignored class) via a case statement, tracking the previous code and whether the last separator was a vowel or H/W. A digit is appended only when the output position is at most 4, differs from the previous code (reset after a vowel but not after H or W), and the buffer is zero-padded. Names are printed with Put_Line, using a bounded concatenation of name, " = ", and code. About 90 lines.

## Proof obligations to watch

- **index**: The scan index and output position are loop-carried, so the program uses a for loop over the name's own range and guards the output position (opos <= 4) just before each store, with the lookahead index checked against the bounds.
- **range**: Soundex digits are derived from a case statement over upper-cased letters mapped to a small digit subtype, so conversions are bounded by the type and an explicit non-letter guard that skips such characters.

## Language surface recorded by this assessment

Ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures, functions, Boolean objects, integers, case statements and Put without a newline.

## External effects

- **console output** (allowed): Prints each embedded sample name with its four-character Soundex code, one per line.

Assessed on 2026-10-15 against page revision 413922 of the [task](https://rosettacode.org/wiki/Soundex) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
