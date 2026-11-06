# Reverse a string

**Candidate: proofs likely to discharge automatically.** Both subscript intervals stay inside 1..6, and each swap reads the RHS before the write. The temporary preserves the byte overwritten by the first write and the earlier String copy preserves the original. The exact program passed the complete Linux manifest-driven regression check; complete native and actual-source assurance is recorded in docs/bounded-string-characters.md.

Position 24 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The driver samples/rosetta_reverse_a_string.adb embeds silver in a mutable String and retains an immutable original snapshot. For Index in 1..3 it saves Text(Index) in a Character temporary, replaces that element with Text(7-Index), and restores the saved byte at the mirrored position. It prints silver -> revlis. This performs the required reversal in place; optional Unicode combining-character handling is excluded. About 14 lines.

## Language surface recorded by this assessment

Bounded String indexing and Character operations and Integer range for loops.

## External effects

- **console output** (allowed): Prints the computed result or verdict with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 415531 of the [task](https://rosettacode.org/wiki/Reverse_a_string) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-04 by Codex through targeted source review; see the [review record](../../assessment-bounded-string-characters-20261031.md).
