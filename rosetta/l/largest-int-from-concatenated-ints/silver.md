# Largest int from concatenated ints

**Candidate: proofs likely to discharge automatically.** All checks follow from the Item subtype bound and for-loop ranges with no loop-carried accumulators, and there are no while loops or recursion, so no annotation is needed. Arithmetic comparison of cross-concatenations avoids building strings and keeps overflow trivially bounded.

Position 980 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Elements are a subtype Item range 1 .. 999 stored in a fixed array of 8, with the count held in a constant per set. A pure function Scale maps a value to 10, 100 or 1000 by if/elsif, and Before(X,Y) compares X*Scale(Y)+Y against Y*Scale(X)+X in Integer; a procedure runs a nested for-loop bubble sort swapping adjacent elements when Before holds, then prints each element via Image minus its leading space using Put and ends with an empty line. Both test sets are embedded and each is handled by one call to a shared procedure. About 60 lines.

## Proof obligations to watch

- **overflow**: Cross-concatenation values X*Scale(Y)+Y stay below 10**6 because elements are a subtype capped at 999 and Scale is 10, 100 or 1000, so the bounds follow from types alone.
- **index**: Bubble-sort swaps index A(J) and A(J+1) with J ranging 1 .. N-1 over a fixed-size array, and the Image slice starts at S'First+1 of a nonempty result, both following from loop ranges and types.

## Language surface beyond today's Silver

Integers, ranged subtypes, arrays, for loops, procedures, functions, Boolean objects, 'Image of scalars, string indexing, unconstrained arrays and Put without a newline.

## External effects

- **console output** (allowed): Prints the largest concatenated integer for each of the two test sets.

Assessed on 2026-10-15 against page revision 414302 of the [task](https://rosettacode.org/wiki/Largest_int_from_concatenated_ints) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
