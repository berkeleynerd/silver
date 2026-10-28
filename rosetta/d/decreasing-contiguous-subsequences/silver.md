# Decreasing contiguous subsequences

**Candidate: proofs likely to discharge automatically.** The task is plain integer array scanning with no recursion, floating point or heap, and the percentage tests are rewritten as bounded integer comparisons, so every check follows from types and short guards.

Position 84 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Embed the 901-value sequence as a constant array of a ranged subtype (1..1000) indexed 0..900, scan it with one for loop that tracks the start of the current non-increasing run and, when a run ends, compares (first-last)*100 against 4, 8, 12, 16 and 25 times first using integers only (no floating point), incrementing one of six counters in a Count-typed array. Each increment is guarded by a check against the counter's upper bound with Reject as the visible outcome, and the six group counts are printed with Put_Line using 'Image text. About 110 lines.

## Proof obligations to watch

- **overflow**: Loop-carried counters are known only by their type range after the first iteration, so each increment is preceded by a guard against the type's upper bound that rejects visibly, and the products (first-last)*100 stay small because the value subtype is bounded at 1000.
- **index**: The run-start and loop indexes stay inside the array's own range because the for loop runs over the array range and the run start is typed with that same index subtype.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The six per-group subsequence counts are printed as text lines.

Assessed on 2026-10-15 against page revision 405625 of the [task](https://rosettacode.org/wiki/Decreasing_contiguous_subsequences) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
