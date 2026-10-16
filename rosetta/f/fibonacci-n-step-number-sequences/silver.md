# Fibonacci n-step number sequences

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static or parameter-bounded ranges inside procedures, and the only loop-carried value is the window sum, which the wider accumulator type and a visible guard before storage make safe without an invariant. No recursion, heap or annotations are needed, so only careful shape around the sum and text buffer matters.

Position 454 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Sequences are held in a fixed-capacity array of bounded-subtype integers, with the start values embedded as constants and the order N given by the number of start values. A procedure Generate fills terms N+1..Length using a for loop with an inner for loop summing the previous N terms in a wider accumulator, guards the sum against the element limit and sets a failure flag if exceeded. A printing procedure converts each term to text with 'Image into a bounded buffer and emits one Put_Line per sequence for Fibonacci, tribonacci, tetranacci and Lucas. About 70 lines.

## Proof obligations to watch

- **overflow**: The window sum is accumulated in a loop over up to ten elements, so it is computed in a 64-bit type from elements bounded by a declared subtype range, and a guard before storing the result rejects any value above the limit visibly rather than clamping.
- **range**: Storing the sum into a bounded element subtype is preceded by an explicit comparison against the limit, so the range check follows from the guard.
- **index**: Reads of element K-I use for-loop ranges with I in 1..N and K starting at N+1, so the index follows from loop bounds and the array's declared range.
- **length**: The text line is built in a fixed-capacity buffer sized for the maximum number of terms times the maximum digit width, with a guard on the write position before each append.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building, Put without a newline, Boolean objects and characters.

## External effects

- **console output** (allowed): Prints each named sequence's first ten or more members to standard output.

Assessed on 2026-10-15 against page revision 413368 of the [task](https://rosettacode.org/wiki/Fibonacci_n-step_number_sequences) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
