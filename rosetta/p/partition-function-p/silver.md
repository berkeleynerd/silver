# Partition function P

**Candidate: proofs likely to discharge automatically.** Every check follows from static loop ranges, a guard on the pentagonal offset just before each array index, and an overflow guard just before each accumulation that leads to a visible capacity message, so nothing needs an invariant. The documented 64-bit limit (about n = 400) is a permitted resource bound because the task requires only a function and its values; P(666) and the timed P(6666) bonus would need fixed-capacity big numbers.

Position 147 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A procedure fills a local array P(0..Max_N) of Long_Long_Integer, initialized with an aggregate, using Euler's pentagonal recurrence: an outer for loop over I and an inner for loop over K in 1..Max_K (statically large enough) that computes the generalized pentagonal offsets K*(3K-1)/2 and K*(3K+1)/2. Each term is used only under an if guard that the offset is at most I, and each add or subtract is preceded by a guard that the running sum stays within Long_Long_Integer; if that guard fails, an out Boolean reports that the documented capacity was exceeded, and Main prints a capacity message for that n instead of a value. Main calls the procedure for the embedded values 0..12 plus a larger in-capacity n, and prints each result with Put_Line and 'Image. About 55 lines.

## Proof obligations to watch

- **overflow**: The loop-carried running sum P(I) has no known bound after the first iteration, so each addition or subtraction of P(I-J) is preceded by a comparison against Long_Long_Integer'Last or 'First that reports exceeding capacity instead of overflowing.
- **index**: The index I-J stays within 0..I because the pentagonal offset J is tested to be at most I just before use, and I comes from a for loop over the array's own range.
- **overflow**: The nonlinear offset K*(3K-1)/2 cannot overflow because K comes from a for loop over a small static range, so the product is statically bounded.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures and 'Image of scalars.

## External effects

- **console output** (allowed): Prints P(n) for the embedded values of n, or a capacity message when a value exceeds the 64-bit limit.

Assessed on 2026-10-15 against page revision 413835 of the [task](https://rosettacode.org/wiki/Partition_function_P) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
