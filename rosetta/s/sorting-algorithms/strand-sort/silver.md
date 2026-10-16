# Sorting algorithms/Strand sort

**Candidate: proofs plausibly discharge automatically.** Everything uses fixed capacity arrays and bounded subtypes with procedures only, so no variants are needed, but several loop-carried cursors in the extraction and merge need explicit guards for the provers to discharge index and range checks.

Position 565 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

Embed the 15 sample integers in a constant array of a bounded subtype, then in a procedure repeatedly sweep with a Used flag array to extract an ascending strand into a fixed-capacity array, and merge it with the fixed-capacity result array into a new array using guarded cursors. The outer loop is a for loop over at most 15 passes (or a while loop in the procedure), and the sorted result is printed through a bounded String buffer with Put_Line before and after. About 95 lines.

## Proof obligations to watch

- **index**: Strand length, result length and merge cursors are loop-carried, so each increment and array access is guarded by an explicit comparison against the fixed capacity just before use.
- **overflow**: Counters are subtypes of 0..15 or 0..16 and every increment is guarded, since no invariant can carry the bound across iterations.
- **range**: Element values are a bounded subtype (-100..100) so comparisons and the Image conversion never overflow.
- **length**: Output line text is built in a fixed-size String buffer sized for 15 elements of at most 5 characters each, with a guarded write position.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, 'Image of scalars, Put without a newline, string building and string indexing.

## External effects

- **console output** (allowed): The unsorted and sorted arrays are printed to standard output.

Assessed on 2026-10-15 against page revision 414847 of the [task](https://rosettacode.org/wiki/Sorting_algorithms/Strand_sort) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
