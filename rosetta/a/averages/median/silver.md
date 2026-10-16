# Averages/Median

**Candidate: proofs likely to discharge automatically.** All loops are for loops over the array's own range and all indexes and float sums are bounded by declared types, so every check follows from declarations; only float formatting and float range reasoning need some care.

Position 1037 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

Embed the ten example values in a constrained array of a bounded float subtype, sort a copy with nested for-loop selection sort using an index-typed min_idx, then pick the middle element or average the two middle elements using static index arithmetic on the fixed length. Print the result as text via a float-to-text operation and Put_Line; the empty case is excluded by the fixed non-zero length. About 35 lines.

## Proof obligations to watch

- **floating point**: The sum of the two middle values cannot overflow because the element subtype is a bounded float range such as -1.0E6 .. 1.0E6, so the addition is discharged from the type bounds.
- **index**: Loop-carried min_idx stays in the array index subtype, and i+1 is safe because the inner range is guarded by i being at most 10, so the swap indexes discharge from types.

## Language surface recorded by this assessment

Floating point, ranged subtypes, arrays, for loops, integers, integer division, floating-point images, procedures and Put without a newline.

## External effects

- **console output** (allowed): The median value is printed with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 411600 of the [task](https://rosettacode.org/wiki/Averages/Median) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
