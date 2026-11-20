# Apply a callback to an array

**Candidate: proofs likely to discharge automatically.** A candidate with an actual scalar-function call per array element admitted. This corrects the earlier procedure-standing-in-for-a-callback account; no first-class callback capability was needed for the measured approach. Execution and final application evidence remain unmeasured. The original surface mapping is retained for separate coverage reconciliation; these observations add no delivered sample or supported task mapping in this batch.

Position 104 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

The planning candidate defines an actual admitted Main-local scalar function and calls it for each element of a fixed initialized Integer array, using a whole scalar assignment for each call result before output. Element and function formal ranges bound the squaring. The task asks to apply a function to each element; an access-to-subprogram callback or array parameter is not required. About 30 lines.

## Proof obligations to watch

- **overflow**: Squaring is safe because the element subtype is declared as a small range (e.g. -1000 .. 1000) so the product fits in Integer.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline, procedures and string building.

## External effects

- **console output** (allowed): Prints each squared array element as text.

Initially assessed on 2026-10-15 against page revision 411495 of the [task](https://rosettacode.org/wiki/Apply_a_callback_to_an_array) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-18 by Codex through targeted source review; see the [review record](../../../docs/bounded-string-building-samples.md).
