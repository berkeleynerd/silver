# Sum to 100

**Candidate: proofs plausibly discharge automatically.** All loops are for loops or while loops inside procedures (no termination check), arrays are statically sized, and every arithmetic step is bounded by wide subtypes plus explicit guards, so nothing needs an annotation; the main burden is guarded loop-carried arithmetic and the new integer, array, string-building and Put surface.

Position 462 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

Enumerate all 2*3^8 operator choices with a counter loop, decoding the base-3 operator pattern per gap with mod and /, accumulating the current number and total in a wide integer subtype under range guards, and store each sum in a fixed array of 13122 entries. Print the expression text (built in a bounded Character buffer) when the sum is 100, then insertion-sort the array in a procedure and scan it linearly to find the sum with the most solutions among nonnegative sums, the smallest missing nonnegative sum, and the ten highest distinct sums. About 150 lines.

## Proof obligations to watch

- **overflow**: The running term and total are loop-carried, so they are held in a 64-bit type whose range dwarfs the true maximum (123456789) and each addition is preceded by an explicit range guard that rejects out-of-range values, which never fires in practice.
- **index**: The insertion sort over 13122 sums uses while loops with the index guard (j > 1) tested by and then just before each a(j-1) access, which discharges without an invariant.
- **length**: The expression text buffer is sized to the longest string (17 characters for digits plus signs plus leading minus) and the write position is guarded before each append, so no overflow of the bounded buffer occurs.
- **range**: Base-3 pattern decoding by mod and / on a loop counter bounded by a declared subtype keeps operator choices in 0..2 and the digit-to-Character conversion within 0..9.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, procedures, functions, Boolean objects, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the solutions for 100, the most frequent sum, the lowest unreachable positive sum and the ten highest sums as text lines.

Assessed on 2026-10-15 against page revision 414533 of the [task](https://rosettacode.org/wiki/Sum_to_100) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
