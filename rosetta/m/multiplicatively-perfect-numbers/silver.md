# Multiplicatively perfect numbers

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges and the only loop-carried value, the product, is range-typed and guarded before each multiplication, so every check follows from types and guards.

Position 139 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Two nested for loops: n from 2 to 499 and m from 2 to n-1, keeping a product in a subtype 1..1000 and a Boolean flag set to false once a divisor would push the product above n; a number qualifies when the flag holds and the product equals n, and 1 is omitted as the task allows. Each multiplication is preceded by an explicit guard (pro <= n / m) so no overflow or range check depends on a loop invariant, and results are printed with Integer'Image through Put_Line. The stretch counts to 500,000 are left out as optional. About 30 lines.

## Proof obligations to watch

- **overflow**: The running product of proper divisors is a ranged subtype and is multiplied only after a guard that it stays at most n (checked as pro <= n / m), so the bound holds without an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and Boolean objects.

## External effects

- **console output** (allowed): Prints each multiplicatively perfect number below 500, one per line.

Assessed on 2026-10-15 against page revision 399450 of the [task](https://rosettacode.org/wiki/Multiplicatively_perfect_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
