# Reverse words in a string

**Candidate: proofs likely to discharge automatically.** All checks are array indexes and a bounded length counter protected by guards placed just before each use inside for loops in Main, so no invariant or variant is needed and the outlook is likely.

Position 971 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

The ten poem lines are embedded as an array of 40-character space-padded String constants, and for each line a reverse for loop over its index range detects word starts (a non-space whose predecessor is a space or the first position) and then copies that word forward with an inner for loop and a Boolean in-word flag into a 40-character buffer, inserting single separating spaces. Every buffer write is guarded by a capacity check with a visible rejection outcome, and the line is printed as the buffer slice 1 .. Out_Len, which is empty for blank lines. About 55 lines.

## Proof obligations to watch

- **index**: Reads of Line (I - 1) are guarded by I > Line'First with and then, and writes to Buffer (Out_Len + 1) are guarded by Out_Len < Buffer'Last immediately before the write.
- **range**: The loop-carried output length Out_Len is a Natural range 0 .. 40 that is only incremented under the Out_Len < 40 guard, whose else branch prints a visible over-capacity message that cannot occur because the output never exceeds the 40-character input.

## Language surface recorded by this assessment

Integers, Boolean objects, characters, arrays, for loops, string indexing, string building and unconstrained arrays.

## External effects

- **console output** (allowed): Each of the ten reversed lines is printed with Silver_IO.Put_Line, one per line in order.

Assessed on 2026-10-15 against page revision 415404 of the [task](https://rosettacode.org/wiki/Reverse_words_in_a_string) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
