# Long multiplication

**Candidate: proofs likely to discharge automatically.** Fixed-capacity decimal digit arrays with for loops keep every index and arithmetic check derivable from declared ranges, so no invariant is required.

Position 442 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Represent each operand as a constant 20-element array of base-10 digits (2^64 embedded as data) and the product as a 40-element digit array initialised to zero; schoolbook long multiplication uses nested for loops with a carry per row and writes the final carry into the row's top cell. Output scans from the most significant cell with a for loop and a Boolean flag to skip leading zeros, printing each digit via Character'Val, so no while loops or recursion are needed. About 60 lines.

## Proof obligations to watch

- **index**: Result indexes i+j-1 and i+20 are bounded by for-loop ranges 1..20 over a 1..40 array, so they discharge from static bounds.
- **overflow**: The accumulator is a small ranged integer built from digit-typed operands (at most 9+81+9=99) and the carry is a 0..9 subtype, so ranges follow from types without a loop invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops and Put without a newline.

## External effects

- **console output** (allowed): Prints the decimal result of 2^64 * 2^64 to standard output.

Assessed on 2026-10-15 against page revision 414312 of the [task](https://rosettacode.org/wiki/Long_multiplication) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
