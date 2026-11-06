# Sequence: smallest number with exactly n divisors

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and every check follows from subtype ranges and guards placed just before the operation, so the proofs should discharge with no annotations.

Position 145 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

A Natural array Term(1..15) starts at zero; an outer for loop over candidates 1..4096 counts divisors with an inner for loop over 1..candidate using mod, then stores the candidate in Term(count) when count is in 1..15 and that slot is still zero. Afterwards a for loop over 1..15 prints each term with Integer'Image concatenated into a bounded String line by Put_Line, and any term left at zero produces a visible Reject because 4096 covers the largest required term (a_13 = 4096). About 45 lines.

## Proof obligations to watch

- **overflow**: The divisor counter is a loop-carried value that only an invariant would bound by the candidate, so it is declared in a subtype 0..4096 and incremented only under an explicit count < 4096 guard, which never changes the true result because a number up to 4096 has at most 4096 divisors.
- **index**: The table is indexed by the divisor count, so each store is guarded by count in 1..15 just before use, which discharges the index check.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the first 15 terms of the sequence via Put_Line.

Assessed on 2026-10-15 against page revision 414461 of the [task](https://rosettacode.org/wiki/Sequence:_smallest_number_with_exactly_n_divisors) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
