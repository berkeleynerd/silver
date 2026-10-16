# Fivenum

**Candidate: proofs plausibly discharge automatically.** Every check reduces to array indices guarded by Count and bounded float values, and the sort uses only for loops over static ranges, so no invariant is needed, but float arithmetic and float formatting make it depend on careful shape.

Position 1188 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The three embedded data sets are fixed-capacity arrays of a bounded Float subtype with a Count, sorted in a copy by nested for-loop exchange sort, then a procedure computes minimum, lower hinge, median, upper hinge and maximum by a guarded Median helper over index ranges. Empty input is rejected with a specified outcome and the five results are stored in an array indexed by an enumeration, then printed through a library float formatter with Put. About 110 lines.

## Proof obligations to watch

- **floating point**: Values live in a bounded float subtype so the sum of two elements before halving cannot overflow, and the comparisons and swaps in the sort do no arithmetic.
- **index**: Median takes an array plus integer low and high bounds, and an explicit guard on 1 <= Low <= High <= Count precedes every indexed read, with the midpoint computed from those guarded bounds.
- **range**: Hinge bounds are derived from the count by integer division, and the program guards Count >= 1 first so Count / 2 and Count / 2 - 1 stay within the index subtype.
- **overflow**: Sorting with nested for loops over fixed index ranges needs no loop-carried index arithmetic, so only the bounded midpoint sums matter.
- **other**: Float formatting needs an admitted library routine with specified output, since 'Image text is not the fixed decimal layout the task shows.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, floating point, floating-point images, arrays, enumerations, for loops, procedures, functions, Boolean objects and Put without a newline.

## External effects

- **console output** (allowed): Prints each five-number summary line to standard output.

Assessed on 2026-10-15 against page revision 414213 of the [task](https://rosettacode.org/wiki/Fivenum) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
