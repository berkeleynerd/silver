# Shift list elements to left by 3

**Candidate: proofs likely to discharge automatically.** The two copy loops rotate the nine task values left by three positions: destination indices 1 through 6 read source indices 4 through 9, and destination indices 7 through 9 read source indices 1 through 3. Both index intervals stay within 1 through 9, all components are explicitly initialized, and writes preserve other cells. The exact source and manifest match this narrow approach; broader arrays remain unsupported. The assurance and validation status is recorded separately in docs/fixed-integer-arrays.md; this static assessment establishes no native or universal validation evidence.

Position 38 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Declare an explicitly initialized constant source array containing 1 through 9 and a mutable result array initialized to zero. Copy source indices 4 through 9 into result indices 1 through 6, then source indices 1 through 3 into result indices 7 through 9; print both arrays with Integer Image and Put. This is samples/rosetta_shift_list_left_3.adb, with no named types, array attributes, user subprograms or modulo. About 21 lines.

## Language surface recorded by this assessment

Fixed-size Integer arrays, immutable Integer arithmetic, Integer range for loops, Integer image and Put without a newline.

## External effects

- **console output** (allowed): Prints the list before and after the shift to standard output.

Initially assessed on 2026-10-15 against page revision 406577 of the [task](https://rosettacode.org/wiki/Shift_list_elements_to_left_by_3) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-27 by Codex through targeted source review; see the [review record](../../assessment-arrays-20261027.md).
