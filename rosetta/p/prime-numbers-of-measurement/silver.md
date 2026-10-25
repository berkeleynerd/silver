# Prime numbers of measurement

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic with for-loop indices and guarded sums inside a procedure, so checks should discharge by types and guards, though the loop-carried sum and the search limit need careful shape.

Position 220 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Keep a 1000-element array of Positive values and a count; for each candidate in a bounded for loop (limit 100000), a nested pair of loops over start and end indices accumulates contiguous sums with an early exit when the sum reaches or exceeds the candidate, and the candidate is appended only if no sum equals it and the array is not full. After the scan, a for loop prints the first 100 elements ten per line using Image into a fixed-length row buffer, then prints the 1000th element; if fewer than 1000 elements were found within the limit the program prints a specified error message instead. About 55 lines.

## Proof obligations to watch

- **overflow**: The running contiguous sum is a loop-carried value, so it is declared in a bounded range and a guard just before each addition exits the inner loop once the sum exceeds the candidate.
- **index**: Array indices come from for-loop ranges bounded by a count that is guarded against reaching the array capacity of 1000 before each store.
- **termination**: All looping lives in the Main procedure, which gets no termination check, and the candidate scan is a for loop with a fixed upper limit.
- **range**: Stored elements are candidates from a bounded for loop and the count is guarded, so no subtype range check on the array contents or count can fail.
- **length**: Each output row is built in a fixed-size buffer using a guarded position, so concatenation lengths stay within the buffer.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the first 100 elements in rows of ten and the 1000th element.

Assessed on 2026-10-15 against page revision 401424 of the [task](https://rosettacode.org/wiki/Prime_numbers_of_measurement) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
