# Stirling numbers of the first kind

**Candidate: proofs plausibly discharge automatically.** Everything is a bounded nested for-loop over static ranges with a guarded recurrence, so checks should discharge, but the loop-carried array values need careful guard placement and the 'Image padding needs bounded buffers.

Position 679 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Use a 13x13 constrained array of a ranged subtype (unsigned Stirling numbers, noted in the output), zero-initialised by an aggregate, row 0 set to S1(0,0)=1, then fill rows 1..12 and columns 1..n with the recurrence in a wider type behind an explicit range guard that rejects on exceeding the subtype. Print each row with nested for loops, using 'Image to text and padding into a fixed buffer, emitted with Put and Put_Line. The optional n == 100 maximum needing big numbers is omitted. About 50 lines.

## Proof obligations to watch

- **overflow**: Table entries are loop-carried values known to GNATprove only by their type, so the recurrence is computed in a wider type and guarded against exceeding the entry subtype with a visible rejection outcome.
- **index**: Row n-1 and column k-1 are safe because the loops run n from 1 and k from 1 with row 0 set separately, so the indexes follow from the loop ranges.
- **length**: Padded output lines are built in a fixed-size buffer sized for 13 columns of width 12, with image lengths bounded by the entry subtype's range.

## Language surface recorded by this assessment

Integers, ranged subtypes, multidimensional arrays, for loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The triangle of S1(n, k) up to n = 12 is printed as text rows.

Assessed on 2026-10-15 against page revision 412167 of the [task](https://rosettacode.org/wiki/Stirling_numbers_of_the_first_kind) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
