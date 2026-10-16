# Product of divisors

**Candidate: proofs likely to discharge automatically.** All divisions have nonzero literal-bounded divisors and loop indexes come from for ranges, and the single loop-carried multiplication is covered by an explicit guard before use, so no annotation is needed.

Position 117 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

An outer for loop runs N over 1..50, with a product variable of a wide ranged integer subtype starting at N, and an inner for loop over 2..N/2 multiplies in each I where N mod I = 0, guarded before the multiplication against exceeding the type bound (Reject otherwise). Each result is printed with Put_Line as N'Image and the product image concatenated; the largest value (254803968) is far below the bound so the guard never triggers. About 25 lines.

## Proof obligations to watch

- **overflow**: The loop-carried product P is only known by its type range, so a guard (reject if P exceeds the type's upper bound divided by I) is placed just before the multiplication, and for 1..50 it never fires.
- **range**: Image of the product and N is concatenated into a bounded output line whose length follows from the declared subtype ranges, with a fixed-size line bound.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints one line per integer from 1 to 50 giving its divisor product.

Assessed on 2026-10-15 against page revision 405049 of the [task](https://rosettacode.org/wiki/Product_of_divisors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
