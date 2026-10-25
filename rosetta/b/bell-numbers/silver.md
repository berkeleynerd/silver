# Bell numbers

**Candidate: proofs plausibly discharge automatically.** All values stay far below 2**61 so a guard before each addition discharges overflow and range checks with only for loops and fixed array bounds, though loop-carried array contents need that guard to be placed carefully.

Position 676 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Use a constrained 2D array (rows 1..15, columns 1..15) of a bounded integer subtype, set the first element to 1, and for each later row copy the previous row's last entry into column 1 and fill each next column with the left neighbour plus the above-left entry inside for loops. A guard rejects any sum exceeding the subtype bound, then the program prints the first column of each row with 'Image and the first ten rows with Put. The optional 50th element is omitted since it needs big numbers, and the 15 numbers (up to the 15th row's last entry, 1382958545) fit easily. About 45 lines.

## Proof obligations to watch

- **overflow**: Triangle elements are a subtype bounded well below the 64-bit limit so a sum of two elements cannot overflow, and an explicit guard rejects any sum above the subtype bound before storing it.
- **range**: The stored sum is range-checked against the element subtype, which the guard before the assignment discharges even though loop-carried array contents are known only by type.
- **index**: Indexes come from for loops over the array's own bounds, with the previous row and next column computed from loop variables that are provably within range.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, 'Image of scalars, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the first 15 Bell numbers and the first ten Bell triangle rows as text.

Assessed on 2026-10-15 against page revision 415345 of the [task](https://rosettacode.org/wiki/Bell_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
