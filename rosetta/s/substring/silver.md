# Substring

**Candidate: proofs likely to discharge automatically.** All five cases use a short constant string with static bounds, for loops over the array's own range and guards placed just before each slice, so every index and overflow check follows from types and guards. No loop invariant, recursion or while loop is needed.

Position 966 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the string "abcdefgh" as a constant with constants N and M, and print the first three cases as slices with static, guarded bounds. For the known-character and known-substring cases, use a for loop over the string's own index range that records the first match, then print the slice after a guard that clips to the string end and prints a visible 'not found' line when no match exists. The substring comparison compares slices Str(I..I+Len-1) only for I in a range that keeps the upper bound inside the string. About 45 lines.

## Proof obligations to watch

- **index**: Slice bounds computed from a found position and M are discharged by explicit guards just before each slice, with the loop-carried found position typed as a bounded subtype or recomputed under a guard.
- **overflow**: Position plus M arithmetic stays far below Integer'Last because Str has a static length of 8 and M is a small constant.

## Language surface recorded by this assessment

Integers, characters, string indexing, unconstrained arrays, for loops, Boolean objects and integer division.

## External effects

- **console output** (allowed): Each of the five substrings is printed with Put_Line.

Assessed on 2026-10-15 against page revision 414526 of the [task](https://rosettacode.org/wiki/Substring) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
