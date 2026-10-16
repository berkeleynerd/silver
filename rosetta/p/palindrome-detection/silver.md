# Palindrome detection

**Candidate: proofs likely to discharge automatically.** The only loop is a for loop, which terminates by itself, and every index is bounded by the loop range and the string's own bounds, so no annotation is needed.

Position 961 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

A pure function Palindrome (Text : String) return Boolean runs a for loop from 0 to Text'Length / 2 - 1, compares the Character at Text'First + Offset with the one at Text'Last - Offset, and returns False on the first mismatch, otherwise True. Main embeds a few sample strings (palindromes, non-palindromes and the empty string) and prints a verdict line for each with Put_Line. The extra-credit parts (Unicode, inexact matching) are left out. About 35 lines.

## Proof obligations to watch

- **index**: Text (Text'First + Offset) and Text (Text'Last - Offset) stay in Text'Range because Offset is below Text'Length / 2, which the provers derive from the for-loop bounds with linear arithmetic only.
- **overflow**: Text'First + Offset never exceeds Text'Last and Text'Last - Offset never drops below Text'First, so the sums stay within Integer; the empty string gives the empty range 0 .. -1 and the loop never runs.

## Language surface recorded by this assessment

Functions, Boolean objects, unconstrained arrays, string indexing, for loops, integers, integer division and characters.

## External effects

- **console output** (allowed): Put_Line prints a verdict for each embedded sample string.

Assessed on 2026-10-15 against page revision 415537 of the [task](https://rosettacode.org/wiki/Palindrome_detection) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
