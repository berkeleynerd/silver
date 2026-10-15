# Left factorials

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic over fixed-capacity limb arrays in procedures with for loops, so checks follow from subtype ranges and capacity guards, but the carry loops over roughly 9000 limbs and nonlinear limb products need careful typing to discharge without invariants.

Position 1383 in the [progression](../../progression.md#stage-26), in stage 26.

## Approach

Represent big numbers as a record of a fixed array of base-10000 limbs (about 9100 limbs) plus a bounded Natural length; procedures Multiply_Small and Add_Big update the factorial accumulator and the running sum in a for loop over k, with capacity guards that reject on overflow. Printing converts limbs to decimal text in a bounded buffer for the values up to !110, and digit counts are computed from the top limb and limb count, emitted at the required thousand steps while the sum is carried through a single pass to 10000. About 150 lines.

## Proof obligations to watch

- **overflow**: Limb arithmetic limb*K+carry is nonlinear but bounded by range subtypes (limb 0..9999, K at most 10000, carry at most 10000), so it fits in 32-bit Integer without an invariant.
- **index**: The limb count is a loop-carried value, so each increment is guarded by a visible capacity check that rejects (reports overflow) instead of writing beyond the fixed 9100-limb array.
- **range**: Carry and limb values assigned in loops are kept within their subtype ranges by mod and / by the base, whose results the provers bound from the operand ranges.
- **termination**: All loops live in procedures (for loops over limb ranges, plus a while loop for digit counting), so no variant is needed.
- **stack**: Two fixed arrays of about 9100 integers each are local objects whose size is static and modest.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, records, string building, 'Image of scalars, for loops, while loops, procedures, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Prints the left factorials for 0..10 and 20..110 by tens and the digit counts for 1000..10000 by thousands.

Assessed on 2026-10-15 against page revision 414305 of the [task](https://rosettacode.org/wiki/Left_factorials) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
