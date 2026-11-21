# Knapsack problem/Unbounded

**Candidate: proofs likely to discharge automatically.** Exhaustive search over three bounded for-loop indexes with exact scaled integer arithmetic gives every check a static bound, and nothing needs a loop invariant or variant. The only new surface is integer arithmetic, ranged subtypes, for loops and integer-to-text conversion for output.

Position 110 in the [progression](../../../progression.md#stage-4), in stage 4.

## Approach

Scale the data to exact integers (weight in tenths, volume in thousandths, limits 250 and 250) and enumerate all counts with three nested for loops whose upper bounds are static constants (10 panacea, 16 ichor, 12 gold), which avoids floating point. For each combination compute value, weight and volume from the loop indexes, and when the weight and volume fit and the value strictly exceeds the best so far, record the value and the three counts in range-typed scalar variables. After the loops print the best value and each count using Integer'Image concatenation. About 45 lines.

## Proof obligations to watch

- **overflow**: The value, weight and volume sums are linear in for-loop indexes with static ranges (at most 10, 16 and 12 items), so the largest total of 88800 fits Integer and the checks discharge from the index types.

## Language surface recorded by this assessment

Integers, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the best total value and the counts of panacea, ichor and gold with Put_Line.

Assessed on 2026-10-15 against page revision 414961 of the [task](https://rosettacode.org/wiki/Knapsack_problem/Unbounded) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
