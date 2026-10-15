# UPC

**Candidate: proofs likely to discharge automatically.** Every index is fixed-offset on constrained 95-character strings inside for loops, the checksum accumulator is bounded by mod 10, and no recursion, while loop or variant is needed, so all checks follow from types and static bounds.

Position 810 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the ten 95-character scans as constants in an array of constrained Strings, and hold the left and right 7-character digit patterns in constant arrays indexed by a 0..9 subtype. A procedure Decode checks the start, middle and end markers, then loops over the 12 digits taking fixed-offset 7-character slices and matching each against the pattern table with an inner for loop, setting a found flag. If any marker or digit fails it retries once on a reversed copy built with a for loop; otherwise it applies the mod-10 checksum, and prints the result, a reversed note, or an invalid message with the line number.

 About 150 lines.

## Proof obligations to watch

- **overflow**: The checksum accumulator is kept in a 0..9 subtype by taking mod 10 after each weighted add, so the loop-carried addition cannot overflow without an invariant.
- **index**: Slice bounds are computed from the for-loop variable over fixed 1..6 ranges on constrained 95-character strings, so each start and end index is statically within 1..95.
- **range**: Digit characters come from a lookup that returns a value in 0..9 or a not-found flag, with the guard tested just before the Character'Val conversion.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, for loops, procedures, functions and case statements.

## External effects

- **console output** (allowed): Each of the ten embedded scans prints its decoded 12-digit number, a reversed marker, or an invalid message.

Assessed on 2026-10-15 against page revision 414559 of the [task](https://rosettacode.org/wiki/UPC) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
