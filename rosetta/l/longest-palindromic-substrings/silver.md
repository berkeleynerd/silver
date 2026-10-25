# Longest palindromic substrings

**Candidate: proofs likely to discharge automatically.** Every loop is a for loop and all indexes derive from S'Range and the loop bounds, so the checks follow from types and loop ranges with no invariants or recursion; the only care needed is bounded subtypes for the loop-carried best start and length.

Position 755 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed a constant sample String and use three nested for loops over its own range: candidate start I, end J, and an inner for loop over K comparing S(I+K) with S(J-K), clearing a Boolean flag on mismatch. When a palindrome is longer than the best so far, record its start and length in bounded subtype variables, then print the slice with Put_Line, with a guarded branch for an empty string. About 35 lines.

## Proof obligations to watch

- **index**: S(I+K) and S(J-K) are discharged because K runs over 0 .. (J-I)/2 inside I .. J, which are loop ranges over S'Range, so both indexes stay within I .. J.
- **range**: The best-start and best-length variables are carried through loops, so they are declared as subtypes bounded by the string's range and length and assigned only from loop indexes, making the slice S(Best_Start .. Best_Start + Best_Len - 1) provably in bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, string indexing, for loops and case statements.

## External effects

- **console output** (allowed): Prints the longest palindromic substring of the embedded sample string with Put_Line.

Assessed on 2026-10-15 against page revision 407287 of the [task](https://rosettacode.org/wiki/Longest_palindromic_substrings) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
