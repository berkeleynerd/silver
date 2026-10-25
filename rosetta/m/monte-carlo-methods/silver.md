# Monte Carlo methods

**Candidate: proofs likely to discharge automatically.** Every check follows from range subtypes, a mod-bounded generator state and a guarded counter increment, with only integer arithmetic and for loops in a procedure, so no annotation is needed.

Position 1530 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

A procedure Estimate takes a sample count in a bounded range subtype and runs a for loop that draws two coordinates in 0..2**15-1 from a 31-bit linear congruential generator held in a range-typed state variable, counting points with x*x+y*y below 2**30. The estimate of pi is computed as integer fixed-point (scaled by 10**6) after the loop, then rendered with 'Image and bounded concatenation into a fixed-length String, and Main calls it for several embedded sample sizes. No floating point or recursion is used. About 70 lines.

## Proof obligations to watch

- **overflow**: The linear congruential step multiplies a state bounded by a 2**31 range subtype by a constant below 2**31, so the product stays under 2**62 and the mod result re-establishes the range on every iteration without an invariant.
- **overflow**: The Inside counter is loop-carried and an invariant is unavailable, so a visible guard (increment only while below the type's upper bound) precedes each increment, and the bound exceeds the largest sample size.
- **overflow**: The scaled estimate 4*Inside*10**6 is computed once after the loop from operands whose type ranges are small enough (sample size capped at 10**8) to fit in 64 bits.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, procedures, 'Image of scalars, string building, Put without a newline and block statements.

## External effects

- **console output** (allowed): Prints the estimate for each sample size to standard output.

Assessed on 2026-10-15 against page revision 414904 of the [task](https://rosettacode.org/wiki/Monte_Carlo_methods) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
