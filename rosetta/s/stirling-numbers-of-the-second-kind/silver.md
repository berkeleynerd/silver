# Stirling numbers of the second kind

**Candidate: proofs plausibly discharge automatically.** All indexes come from for-loop ranges over a fixed 13x13 table and the largest entry (1379400) is small, so the only non-routine checks are the loop-carried overflow guard and padded-text formatting, none needing an annotation.

Position 676 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Hold S2 in a 13 by 13 array of a ranged subtype, set the diagonal to 1, then fill rows with nested for loops using S2(n+1,k) = k*S2(n,k) + S2(n,k-1) computed in Long_Long_Integer and guarded against the element limit with a visible rejection. Print each row with Put of right-justified 'Image text and Put_Line at row end. The optional n==100 big-number maximum is omitted. About 55 lines.

## Proof obligations to watch

- **overflow**: The recurrence k*S(n,k)+S(n,k-1) works on table entries known only by their type after the first loop iteration, so the sum is computed in a wider type and an explicit guard against a stated limit rejects before storing, which keeps the stored values in range.
- **index**: Indexes n+1 and k-1 are safe because the for-loop ranges (n in 0..11, k in 1..12) are written to stay inside the 0..12 array bounds.
- **length**: Padded output lines are built in a fixed-size buffer whose size must be shown sufficient for 13 columns of width 12 plus the row label, with each image's width guarded before copying.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars, Put without a newline and string building.

## External effects

- **console output** (allowed): The triangle of S2(n, k) for n and k up to 12 is printed as text rows.

Assessed on 2026-10-15 against page revision 412168 of the [task](https://rosettacode.org/wiki/Stirling_numbers_of_the_second_kind) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
