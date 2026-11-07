# Smallest square that begins with n

**Candidate: proofs likely to discharge automatically.** Everything is small bounded integer arithmetic inside nested fixed-range for loops with no recursion or annotations, so all range and overflow checks follow from subtype bounds.

Position 147 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

For each n in 1 .. 49 a for loop over roots 1 .. 1000 computes the square and tests whether it begins with n by dividing a copy by 10 a fixed 7 times and comparing to n at each step, recording the first match with a Boolean found flag. Results are printed by Put_Line using 'Image text concatenated into a bounded line; the bound of 1000 is large enough since the largest required root is 213, and a not-found outcome would print an explicit message. About 45 lines.

## Proof obligations to watch

- **overflow**: The root is a subtype with range 1 .. 1000 so its square is at most 1_000_000 and every product and quotient is bounded by types alone.
- **termination**: All loops are for loops over fixed ranges (the prefix test divides by 10 a fixed 7 times), so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): Prints one line per n giving the prefix, the smallest square and its root.

Assessed on 2026-10-15 against page revision 410071 of the [task](https://rosettacode.org/wiki/Smallest_square_that_begins_with_n) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
