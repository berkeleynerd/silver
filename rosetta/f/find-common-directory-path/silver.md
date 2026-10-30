# Find common directory path

**Candidate: proofs likely to discharge automatically.** All indexes and lengths are bounded by constant string lengths and for-loop ranges, so every check follows from types and guards without invariants. The separator is a Character constant and the whole computation can sit in the main procedure or a plain procedure with no recursion.

Position 498 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The three embedded paths are String constants of fixed bounds, and the program keeps a running common prefix length in a bounded Natural variable. For each further path, a for loop up to the minimum of the prefix length and that path's length compares characters, recording the position of the last separator seen while the characters match and the whole component ends at a following separator or the end of both strings. The final result is the prefix up to the recorded boundary, copied into a fixed-length buffer and printed with Put_Line. About 45 lines.

## Proof obligations to watch

- **index**: Each comparison position is guarded by a bound against both path lengths and a for loop over the shortest length, so String indexing and the final slice copy discharge from the guards.
- **length**: The result goes into a fixed buffer of the maximum path length with a length counter whose type range is that bound, so the copy cannot overflow.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The common path is printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415478 of the [task](https://rosettacode.org/wiki/Find_common_directory_path) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
