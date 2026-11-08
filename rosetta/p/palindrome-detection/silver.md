# Palindrome detection

**Candidate: proofs likely to discharge automatically.** Every read stays within its fixed String bounds. The Boolean accumulator is a stored value, and the algorithm checks actual bytes rather than comparing the input with a precomputed answer. Both positive and negative examples execute. The exact program passed the complete Linux manifest-driven regression check; complete native and actual-source assurance is recorded in docs/bounded-string-characters.md.

Position 61 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The driver samples/rosetta_palindrome_detection.adb embeds racecar and silver. It resets a Boolean flag for each String, scans the first three positions, compares each Character with its mirrored position (8-Index or 7-Index), and clears the flag on a mismatch. It prints a palindrome verdict for racecar and a non-palindrome verdict for silver. The task permits a program instead of a function; Unicode and inexact matching are optional and excluded. About 29 lines.

## Language surface recorded by this assessment

Bounded String indexing and Character operations, scalar Boolean objects and expressions and Integer range for loops.

## External effects

- **console output** (allowed): Prints the computed result or verdict with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 415537 of the [task](https://rosettacode.org/wiki/Palindrome_detection) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-04 by Codex through targeted source review; see the [review record](../../assessment-bounded-string-characters-20261031.md).
