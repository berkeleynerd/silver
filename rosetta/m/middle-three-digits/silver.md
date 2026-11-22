# Middle three digits

**Candidate: proofs likely to discharge automatically.** All arithmetic is on values bounded by Integer and loop counts are fixed at most 10, so overflow, index and range checks follow from types and one guard, and the error case is a visible Boolean outcome rather than an exception.

Position 457 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The 17 test values are embedded in a constant Integer array and a for loop over its range calls a procedure that takes the value and returns a Boolean Ok flag plus a 3-character String out parameter. The procedure rejects Integer'First, takes the absolute value, counts digits with a bounded for loop of divisions by 10, fails when the count is under 3 or even, and otherwise computes (N / 10**k) mod 1000 with k=(count-3)/2 using a bounded power loop and fills the buffer with zero-padded digit characters. The caller prints the Integer'Image of the value and either the three digits or the fixed error text. About 70 lines.

## Proof obligations to watch

- **overflow**: Negating the input is guarded by rejecting Integer'First (or typing the embedded inputs in a narrower subtype), and digit-count and power-of-ten loops are for loops bounded to 10 iterations on a value kept within a declared range.
- **index**: The three-character result buffer is filled by a for loop over its own range, and the digit characters come from Character'Val of a value in 48..57 established by mod 10.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, procedures, string building, 'Image of scalars, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): Prints each tested value with its middle three digits or an error message line.

Assessed on 2026-10-15 against page revision 413553 of the [task](https://rosettacode.org/wiki/Middle_three_digits) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
