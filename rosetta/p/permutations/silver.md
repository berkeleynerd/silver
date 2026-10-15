# Permutations

**Candidate: proofs plausibly discharge automatically.** Every index and range check follows from the element subtype and guards placed in the scanning conditions, and no loop or call lives in a function, so no annotation is needed, though the guard shape of the next-permutation scans needs care.

Position 465 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed a constant N (for example 4) and represent a permutation as an array indexed 1 .. N of a ranged subtype 1 .. N, with a Next procedure implementing lexicographic next-permutation using guarded while loops and a Boolean Is_Last out parameter. The main loop prints the current permutation as a digit string built in a fixed-length String buffer via Character'Val, calls Put_Line, and repeats until Is_Last. About 70 lines.

## Proof obligations to watch

- **index**: The downward scans for the pivot and the swap partner are while loops with loop-carried indexes, so each decrement is preceded by an explicit guard (I > 1, J > I) and the indexes have the element subtype range.
- **range**: Index updates such as J + 1, K - 1 and the digit Character'Val (48 + P (I)) must fit the declared subtypes, which holds because the swap loop is guarded by J < K and element values are bounded by N.
- **termination**: All while loops sit in procedures, which get no termination check, and the generation loop is in the main procedure.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, for loops, while loops, Boolean objects, procedures and string building.

## External effects

- **console output** (allowed): Prints one line per permutation of the embedded n objects.

Assessed on 2026-10-15 against page revision 412967 of the [task](https://rosettacode.org/wiki/Permutations) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
