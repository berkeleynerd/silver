# Permutations with repetitions

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges, for-loop indexes over the array range and guards before increments, and the loop is in a procedure so no termination check applies.

Position 437 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Fixed N=2 positions and K=3 values with a counter array of a 1..K subtype acting as an odometer, so each permutation is generated on demand without storing the sequence. A procedure loops with a Boolean Done flag, prints the current tuple as a bounded String, hands it to a deciding check that may stop early, then increments the odometer from the last position with a carry guarded by explicit tests. Output goes through Put_Line of a fixed-length string built from the symbol table. About 45 lines.

## Proof obligations to watch

- **index**: The odometer counter array is indexed by a for-loop variable over the array's own range and each digit is range-typed 1..K, so index and range checks follow from types.
- **overflow**: The digit increment is guarded by a test that the digit is below K before adding one, so no range check can fail.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, for loops, while loops, procedures, functions, Put without a newline, string building and integer division.

## External effects

- **console output** (allowed): Each generated permutation is printed as a line of text.

Assessed on 2026-10-15 against page revision 411047 of the [task](https://rosettacode.org/wiki/Permutations_with_repetitions) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
