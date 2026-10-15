# 4-rings or 4-squares puzzle

**Candidate: proofs likely to discharge automatically.** Every check follows from the 0..9 digit subtype, bounded sums and a guard on the counter, with only for loops in a procedure, so no annotation is needed.

Position 97 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A Digit subtype 0..9 and a bounded Count subtype are used by a procedure Four_Rings (Low, High, Unique, Show) containing seven nested for loops over Low..High. Ring sums of Digit values are computed in an integer range wide enough to hold them, compared for equality, and uniqueness is checked with explicit pairwise inequality tests rather than an array. Matching solutions are printed with Put_Line over concatenated 'Image strings and a final count line is printed for each of the three required parameter sets. About 70 lines.

## Proof obligations to watch

- **overflow**: The loop-carried solution counter is declared in a bounded range subtype and incremented only under a guard just before the increment, since 10_000_000 combinations is the true maximum so no result changes.
- **length**: Concatenating the 'Image of ranged digit subtypes and of the bounded counter gives statically bounded string lengths, so the result length check discharges.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the unique solutions and the solution counts for the three parameter sets.

Assessed on 2026-10-15 against page revision 414038 of the [task](https://rosettacode.org/wiki/4-rings_or_4-squares_puzzle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
