# Text processing/2

**Candidate: proofs plausibly discharge automatically.** Everything is string scanning and bounded counters over embedded data, so index and overflow checks follow from guards before each access, with no recursion, float arithmetic or annotations needed. The cost is the careful guarded token scanner with loop-carried positions, hence plausible rather than likely.

Position 1026 in the [progression](../../../progression.md#stage-17), in stage 17.

## Approach

The six sample records are embedded as string constants and each is passed to a validating procedure taking an unconstrained String, which scans whitespace-separated fields (spaces or tabs) with a guarded position index, checking a date field of the form dddd-dd-dd, then 24 pairs of a decimal-formatted value (digits, point, digits; no float conversion needed) and an integer flag whose sign and digits are parsed with a cap. Valid dates are stored in a fixed array and compared against earlier entries with a for loop to report duplicates, and a record counts as good when all 24 flags are at least 1; malformed records print a specified error message and totals are printed with scalar image. About 130 lines.

## Proof obligations to watch

- **index**: A token scanner walks a record with a loop-carried position, so every Line(Pos) access is guarded by an explicit Pos <= Line'Last test just before use.
- **overflow**: Record, flag and duplicate counters are bounded subtypes and the flag value is accumulated digit by digit with a cap guard so it cannot overflow.
- **termination**: The scanner's while loops live in procedures (no termination check), and any function uses only for loops.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Reports malformed fields, duplicated datestamps and the count of fully good records.

Assessed on 2026-10-15 against page revision 414546 of the [task](https://rosettacode.org/wiki/Text_processing/2) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
