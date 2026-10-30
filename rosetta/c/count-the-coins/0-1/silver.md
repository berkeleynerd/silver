# Count the coins/0-1

**Candidate: proofs plausibly discharge automatically.** All indices and bounds come from static array ranges and for loops with no recursion or while loops, but the loop-carried counts and factorial products need explicit cap guards to discharge overflow without invariants, so it is plausible rather than likely.

Position 692 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Embed each example as a fixed-capacity coin array (16 slots) plus a count, and run a 0/1 knapsack DP in a procedure over a table ways(size, sum) with descending sum for-loops, avoiding the exponential recursion. The unordered answer is the total over sizes at the target, and the extra ordered answer is the sum of ways(size, target) times a constant factorial table, with every addition and product guarded against a cap that yields a printed overflow message. Results are printed with 'Image via Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: The loop-carried DP counts are unbounded by type after the first iteration, so each addition is guarded against a documented cap with a visible overflow outcome, and the count-times-factorial products are guarded the same way against a 64-bit range.
- **index**: The index sum minus coin value is guarded by an explicit comparison just before each table access, and the subset-size dimension is bounded by the fixed 16-coin capacity.
- **range**: The target and coin values are declared as bounded subtypes and the example data are embedded, so the DP table bounds are static.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): Prints the unordered and ordered counts for the three embedded examples.

Assessed on 2026-10-15 against page revision 397924 of the [task](https://rosettacode.org/wiki/Count_the_coins/0-1) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
