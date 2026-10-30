# Cheryl's birthday

**Candidate: proofs likely to discharge automatically.** Everything is a fixed ten-element array scanned by for loops over its own index range, so index and range checks follow from types; only counters need a Boolean flag or a guard to avoid overflow, so no annotation is required.

Position 1158 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The ten dates sit in constant arrays of month (an enumeration) and day (a 1..31 subtype) beside a Boolean Active array, all indexed 1..10. Three elimination passes use nested for loops over the array's own range: drop months that contain a day occurring only once, then drop active dates whose day is shared among active dates, then drop active dates whose month is shared among active dates. The remaining date is printed with Put_Line using 'Image of the month and day. About 70 lines.

## Proof obligations to watch

- **overflow**: Candidate counters carried through loops are replaced by Boolean found-another flags or a counter in a 0..10 subtype guarded by a test just before each increment, so no invariant is needed.
- **length**: Concatenating the month image and day image for output is bounded by the enumeration and day subtype ranges, which should let the string length check discharge from types alone.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, enumerations, arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the remaining-candidate counts and the deduced birthday with Put_Line.

Assessed on 2026-10-15 against page revision 411949 of the [task](https://rosettacode.org/wiki/Cheryl's_birthday) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
