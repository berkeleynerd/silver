# Distribution of 0 digits in factorial series

**Candidate: proofs plausibly discharge automatically.** Everything is bounded-range integer and float arithmetic in for/while loops inside a procedure, with a fixed-capacity digit array whose growth is guarded, so no annotation is needed, but loop-carried carry, length and float sum need careful typing and guards.

Position 1069 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Store n! as a fixed-capacity array of decimal digits (least significant first, capacity about 35700) with a length variable, and for each f from 2 to 10000 multiply in place by f with a carry loop that extends the length under an explicit capacity guard. After each step count zero digits with a for loop over 1..Len, add zeros/Len to a range-bounded float total, and at f = 100, 1000 and 10000 print total/f via Float image concatenated into Put_Line. The stretch search is omitted as optional. About 80 lines.

## Proof obligations to watch

- **overflow**: The carry in the digit-multiply loop is loop-carried, so it is declared with a range far above 9*10000 plus the carry bound, making t/10 provably within the carry type with no invariant.
- **index**: Growing the digit count in the carry-propagation while loop is guarded by an explicit 'if Len < Capacity' check that rejects (Reject) on overflow, and Capacity is sized above the 35660 digits of 10000!.
- **floating point**: The running sum of ratios is a loop-carried float, so it is a bounded float subtype and each addition is guarded against exceeding that bound, while the digit count divisor is a positive ranged integer.
- **range**: Zero-digit and digit counters are ranged integers capped at Capacity, which the for-loop over the array range keeps within bounds.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, floating point, arrays, for loops, while loops, 'Image of scalars, floating-point images and string building.

## External effects

- **console output** (allowed): Prints the mean zero-digit proportion for N = 100, 1000 and 10000 with Put_Line.

Assessed on 2026-10-15 against page revision 414161 of the [task](https://rosettacode.org/wiki/Distribution_of_0_digits_in_factorial_series) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
