# Extract file extension

**Candidate: proofs likely to discharge automatically.** Every check follows from the for-loop index over the parameter's own range, so slicing and indexing discharge without invariants, and for loops need no variant in a function. The only novelty for Silver is unconstrained String parameters, returns and slices, plus Character comparisons.

Position 1546 in the [progression](../../progression.md#stage-33), in stage 33.

## Approach

A function Extension (S : String) return String walks S backward with a for loop over reverse S'Range, tracking only the index of the loop variable: alphanumeric characters (tested by Character range comparisons) continue the scan, a '.' with at least one alphanumeric after it returns S (I .. S'Last), and any other character, or reaching the start, returns an empty string. Main holds the six task test strings as String constants and prints each input and its extension with Put_Line, with no loop-carried state other than the loop index. About 70 lines.

## Proof obligations to watch

- **index**: The backward scan uses a reverse for loop over the parameter's own S'Range and slices S (I .. S'Last) only with I taken from that loop, so empty and one-character inputs are covered without invariants.
- **range**: The Character comparisons for letters and digits are plain range tests on loop-indexed characters, and the result slice bounds come straight from the loop index, so nothing is computed across iterations.

## Language surface beyond today's Silver

Characters, Boolean objects, functions, procedures, unconstrained arrays, string indexing, string building, for loops, while loops, integers, ranged subtypes and membership tests.

## External effects

- **console output** (allowed): Each embedded test path and its extracted extension are printed with Put_Line.

Assessed on 2026-10-15 against page revision 406546 of the [task](https://rosettacode.org/wiki/Extract_file_extension) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
