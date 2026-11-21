# String length

**Candidate: proofs plausibly discharge automatically.** Counting UTF-8 lead bytes with a for loop over the string's own range uses only types and a single counter guard, so the proofs should discharge without annotations; the grapheme count is optional and omitted.

Position 543 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The example strings (such as "møøse" and the non-BMP Unicode example) are embedded as constant Strings holding their UTF-8 bytes as Latin-1 characters, so the byte length is S'Length. The code point length is found by a for loop over S'Range that counts every byte except UTF-8 continuation bytes (Character'Pos between 128 and 191), guarding the counter before incrementing. Both lengths are printed with Put_Line using Natural'Image concatenated into short bounded strings. About 35 lines.

## Proof obligations to watch

- **overflow**: The loop-carried code point counter has no invariant, so an explicit guard Count < Natural'Last before each increment is needed, with a visible Reject outcome if it fails.
- **range**: Character'Pos of each indexed byte is bounded by the Character type and the loop index runs over the string's own range, so these checks are routine.
- **length**: Building the output line from the 'Image of the lengths needs a bounded buffer sized for the largest Natural, which must be checked against the buffer capacity.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the byte length and the code point length of the embedded example strings.

Assessed on 2026-10-15 against page revision 415012 of the [task](https://rosettacode.org/wiki/String_length) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
