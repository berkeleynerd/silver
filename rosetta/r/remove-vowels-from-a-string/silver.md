# Remove vowels from a string

**Candidate: proofs likely to discharge automatically.** The task is a single for loop that filters characters into a bounded buffer, so every check follows from the array range, the Count type and one capacity guard before the append, and no invariant is needed. The only non-routine part is the loop-carried Count, which the guard makes safe.

Position 973 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Embed the two example strings as constants and use one procedure, Show_Without_Vowels (Text : String), that loops with a for loop over Text'Range and copies each non-vowel character (a case statement over the ten vowel letters) into a fixed 128-character buffer. A Count of type Natural range 0 .. 128 is guarded before each append, with Reject if the capacity would be exceeded, and then the original and the Buf (1 .. Count) slice are printed with Put_Line, with a blank line between the two examples. About 45 lines.

## Proof obligations to watch

- **index**: The write position is a loop-carried counter, so each append is guarded by a check against the buffer capacity with a visible Reject outcome, and the final slice 1 .. Count is safe because Count is typed 0 .. capacity.
- **range**: Count + 1 cannot be proved in range from the type alone after the first iteration, so the guard just before the increment supplies it.

## Language surface beyond today's Silver

Characters, string indexing, string building, unconstrained arrays, ranged subtypes, integers, for loops, case statements and procedures.

## External effects

- **console output** (allowed): Prints each original string and its vowel-free version with Put_Line, including a blank separator line.

Assessed on 2026-10-15 against page revision 409326 of the [task](https://rosettacode.org/wiki/Remove_vowels_from_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
