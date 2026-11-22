# Decreasing contiguous subsequences

**Candidate: proofs likely to discharge automatically.** The full required 901-value candidate admitted and ran, producing bins 7, 6, 4, 2, 2, 0 from a 3855-byte source. Preserve this measured complete-sequence scope; it is inherited planning evidence and adds no promised sample or final delivery checkpoint result. The original surface mapping is retained for separate coverage reconciliation; these observations add no delivered sample or supported task mapping in this batch.

Position 116 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

The measured 3855-byte candidate embeds all 901 required values in a fixed initialized Integer array and scans maximal non-increasing subsequences with counted loops and bounded scalar state. Integer comparisons classify percentage decreases without floating point, guarded counters accumulate the six bins, and Integer Image output prints the counts. The complete candidate admitted and executed with observed bins 7, 6, 4, 2, 2, 0. About 110 lines.

## Proof obligations to watch

- **overflow**: Loop-carried counters are known only by their type range after the first iteration, so each increment is preceded by a guard against the type's upper bound that rejects visibly, and the products (first-last)*100 stay small because the value subtype is bounded at 1000.
- **index**: The run-start and loop indexes stay inside the array's own range because the for loop runs over the array range and the run start is typed with that same index subtype.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The six per-group subsequence counts are printed as text lines.

Initially assessed on 2026-10-15 against page revision 405625 of the [task](https://rosettacode.org/wiki/Decreasing_contiguous_subsequences) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
