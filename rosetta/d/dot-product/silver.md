# Dot product

**Candidate: proofs likely to discharge automatically.** The constrained callable driver preserves the required dot-product function and equal vector lengths by nominal type identity. All products and partial sums fit for every declared input, independently of Main's aggregates. Expected stdout is Dot product: 3 followed by LF. The feature routes passed in managed run 20261121T125607-826b7d51ebf2; complete #410 assurance, final regressions and independent delivery review remain pending, so the new construct remains unsupported.

Position 1568 in the [progression](../../progression.md#stage-38), in stage 38, which adds named constrained Integer-array inputs and static bounds queries.

## Approach

The prepared samples/rosetta_dot_product.adb defines a named constrained Vector (1 .. 3) of Component (-10 .. 10) and a function Dot with two read-only Vector inputs and Product (-300 .. 300) result. Its terminal expression sums all three corresponding products using First, First+1 and Last queries. Main calls Dot with [1, 3, -5] and [4, -2, -1] through named associations and prints the resulting 3 with Integer'Image. The fixed length is faithful because arbitrary length is optional in the task. About 25 lines.

## Proof obligations to watch

- **overflow**: Each declared component is -10 .. 10, so each corresponding product is -100 .. 100, their first sum is -200 .. 200 and their complete sum is -300 .. 300 for every pair of formal inputs.
- **index**: Both inputs have the same named Vector identity and fixed bounds 1 .. 3. First, First+1 and Last are therefore valid component indexes for every formal value.

## Language surface recorded by this assessment

Named constrained Integer-array inputs and static bounds queries, named Integer subtypes, bounded components and scalar signatures, bounded mutable Integer objects, Integer image, small nonrecursive scalar functions and named scalar arguments.

## External effects

- **console output** (allowed): Prints the dot product result 3 via Put_Line.

Initially assessed on 2026-10-15 against page revision 413360 of the [task](https://rosettacode.org/wiki/Dot_product) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-21 by Codex through targeted source review; see the [review record](../../assessment-named-array-parameters-20261121.md).
