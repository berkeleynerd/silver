# Special pythagorean triplet

**Candidate: proofs likely to discharge automatically.** Every operand is bounded by for-loop ranges, so all arithmetic checks follow from types and static bounds, and for loops need no variants or invariants.

Position 87 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Two nested for loops run a over 1..333 and b over a+1..500, compute c as 1000-a-b, and test a*a+b*b = c*c with Integer arithmetic. A Boolean Found and an Integer Product are updated on the first match (guarded by not Found), and after the loops the program prints Integer'Image of Product, or a specified not-found message if none exists. About 30 lines.

## Proof obligations to watch

- **overflow**: a*a+b*b, c*c and a*b*c are bounded by loop ranges (a<=333, b<=500, c<=1000, product under 1.7e8), so they fit Integer without any invariant.
- **range**: c is computed as 1000-a-b inside loops with static bounds, so it lies in 167..998 and fits a subtype 1..1000 by interval reasoning.

## Language surface beyond today's Silver

Integers, ranged subtypes, for loops, 'Image of scalars and Boolean objects.

## External effects

- **console output** (allowed): Prints the product of the triplet (and optionally the triplet) with Put_Line.

Assessed on 2026-10-15 against page revision 403490 of the [task](https://rosettacode.org/wiki/Special_pythagorean_triplet) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
