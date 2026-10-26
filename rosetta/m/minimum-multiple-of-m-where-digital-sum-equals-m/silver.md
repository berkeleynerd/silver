# Minimum multiple of m where digital sum equals m

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared ranges and a fixed-iteration digit loop, so checks follow from types and one guard, though the loop-carried digit-sum accumulator needs careful shaping.

Position 159 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Main loops n from 1 to 70 and for each n runs a for loop over m in 1..20_000_000 that computes the digit sum of n*m with a fixed 10-iteration for loop (digit = mod 10, then divide by 10), exiting when the sum equals n. The sum is a ranged subtype guarded before each addition, and the found m is printed with Integer'Image through Put_Line, with a visible Reject if none is found within the limit. About 45 lines.

## Proof obligations to watch

- **overflow**: The digit-sum accumulator is loop-carried so only its type range is known, so it is a subtype 0..1000 with a guard before each addition, and the guard never triggers for products under 2*10**9 since the sum stays at most 90.
- **overflow**: The product n*m is bounded by the declared ranges n in 1..70 and m in 1..20_000_000, fitting 64-bit Integer arithmetic without any invariant.
- **termination**: All loops are for loops (the m search uses exit when), so no variant is needed.
- **other**: If no m is found within the documented limit of 20 million the program rejects visibly, and the known maximum answer 12842857 fits the limit.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the 70 sequence elements, one per line.

Assessed on 2026-10-15 against page revision 413788 of the [task](https://rosettacode.org/wiki/Minimum_multiple_of_m_where_digital_sum_equals_m) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
