# Jaccard index

**Candidate: proofs plausibly discharge automatically.** All checks follow from fixed array bounds, for-loop ranges over them and a zero-union guard, and the exact-decimal output via scaled integers avoids floating point; the only non-routine point is the loop-carried intersection counter, which a visible guard keeps in range.

Position 698 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Each of the six sets is a row in a constant 6x5 Integer table with a parallel array of element counts (A has 0), and the sets contain distinct values so the union size is |A|+|B|-|A∩B|. Nested for loops over the index ranges count the intersection with a guarded increment, a function returns the index as a scaled integer (guarding union=0 to give 1), and a procedure prints "J(X,Y) = J(Y,X) = d.ddddddd" using integer division and mod for the seven decimal digits and Character'Val for the set letters, for X<=Y over A..F. About 90 lines.

## Proof obligations to watch

- **overflow**: The intersection count is a loop-carried accumulator, so each increment sits behind an explicit guard (count below the set capacity) or uses a subtype bounded well below Integer'Last.
- **division**: The union size is tested for zero before dividing, returning 1 for the empty/empty pairing exactly as the task's expected output shows.
- **range**: Set sizes, element indexes and the scaled-decimal quotient (numerator at most 10 times 10**7) stay within declared subtypes, and the decimal digits are emitted by a fixed-count for loop.
- **length**: Each output line is built in a fixed-capacity buffer sized for the longest line (e.g. J(B,C) = J(C,B) = 0.4285714) so concatenations cannot exceed it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, multidimensional arrays, for loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the 21 pairing lines to standard output.

Assessed on 2026-10-15 against page revision 408908 of the [task](https://rosettacode.org/wiki/Jaccard_index) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
