# Balanced brackets

**Candidate: proofs plausibly discharge automatically.** Everything is a bounded for loop or a mod-bounded index over a small fixed buffer with embedded N values, so checks come from types and local guards and no invariant is needed. The only care points are the loop-carried depth counter and the generator arithmetic, which need range-bounded types or a guard.

Position 1080 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Use a fixed 8-character String buffer filled with N opening then N closing brackets for N from 0 to 4, shuffled by a Fisher-Yates style loop driven by a small ranged linear congruential generator held in a procedure. A separate function scans the string with a for loop over its range, keeping an Open counter and returning False when a closing bracket appears at depth zero or the final depth is nonzero. Main prints each bracket string with its verdict through Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The generator state is a ranged subtype and each update is reduced by mod, so the multiply-add cannot overflow.
- **overflow**: The nesting depth counter is loop-carried and the prover knows only its type, so a guard before the increment rejects depth beyond a declared limit, which a string of at most 8 characters never reaches.
- **index**: Swap positions come from a mod of the string length plus one, guarded against a zero length, and the checker loops over the buffer's own range.
- **range**: Slicing a bounded buffer to the current length and concatenating with the verdict text needs the length provably within the buffer capacity.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, string indexing, string building, for loops, while loops, procedures, functions and unconstrained arrays.

## External effects

- **console output** (allowed): Each generated bracket string and its OK or NOT OK verdict is printed with Put_Line.

Assessed on 2026-10-15 against page revision 413613 of the [task](https://rosettacode.org/wiki/Balanced_brackets) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
