# Knapsack problem/Bounded

**Candidate: proofs likely to discharge automatically.** This is a bounded dynamic-programming program built from fixed-size for loops over static ranges, ranged subtypes and a W <= J guard before each table index, so no annotation is needed. The only added work is the multi-dimensional table, records and number formatting for output.

Position 666 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Embed the 22 items as constant parallel arrays (or a record array) of ranged subtypes, build a (0..22, 0..400) value table with nested for loops in a procedure, then trace back with a reverse for loop, guarding W <= Cap before every table index. Print each chosen item with its count, weight and value using padded names and Image-based number formatting, then the totals line; no loop-carried value is used unbounded because all are ranged subtypes. About 110 lines.

## Proof obligations to watch

- **index**: The table index Cap - W is guarded by W <= Cap just before use, and the table and loop ranges are static, so the checks discharge.
- **overflow**: Values are bounded by subtype ranges (max total value 1500 across 22 items), so table sums and Count*Value products fit declared ranges with a guard against the cap.
- **range**: The trace-back subtracts Weight from Cap, which discharges only because Weight is guarded by W <= Cap before assignment and Cap is a ranged subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, multidimensional arrays, records, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the chosen items with counts, weights, values and the totals line.

Assessed on 2026-10-15 against page revision 414288 of the [task](https://rosettacode.org/wiki/Knapsack_problem/Bounded) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
