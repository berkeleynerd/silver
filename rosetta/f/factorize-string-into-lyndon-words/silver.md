# Factorize string into Lyndon words

**Candidate: proofs plausibly discharge automatically.** Duval's algorithm is plain iteration over a fixed-length String inside a procedure, so no termination check applies, and the index checks can be discharged by redundant explicit guards plus ranged subtypes, though loop-carried indices need careful shaping.

Position 541 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The Thue-Morse string is embedded as a 128-character String constant, and Duval's algorithm runs in a procedure with index variables i, j, k of a wide ranged Integer subtype. The outer and inner while loops use guard conditions that keep every index inside 1 .. n before each character comparison, and each factor slice is guarded by a bounds check before Put_Line prints it. Nothing is read, so there is no input to validate and the only external effect is console output. About 45 lines.

## Proof obligations to watch

- **index**: Duval's carried indices i, j, k have no invariant, so each use of s(k) and s(j) is protected by explicit loop-condition guards (j <= n and then k >= 1 and then k <= n) that are redundant for the algorithm and so do not change behavior.
- **range**: The updates i := i + (j - k) and k := k + 1 are carried through loops, so they are declared over a wide Integer subtype and guarded just before the update; the guards never trigger for the fixed 128-character input.
- **overflow**: Integer additions on indices are bounded by the wide subtype ranges and the fixed string length, so they discharge from types and guards.
- **length**: Printing the slice s(i .. i + (j - k) - 1) needs a guard that the slice lies within 1 .. n, otherwise a visible reject outcome is taken.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, while loops and procedures.

## External effects

- **console output** (allowed): Each Lyndon factor is printed on its own line with Put_Line.

Assessed on 2026-10-15 against page revision 412106 of the [task](https://rosettacode.org/wiki/Factorize_string_into_Lyndon_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
