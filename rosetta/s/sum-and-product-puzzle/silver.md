# Sum and product puzzle

**Candidate: proofs likely to discharge automatically.** Every loop is a bounded for loop over declared ranges with fixed-size arrays, so index and overflow checks follow from types and one saturating-counter guard, and no variants or recursion are needed.

Position 107 in the [progression](../../progression.md#stage-5), in stage 5.

## Approach

Embed the puzzle bounds as constants and use for loops over subtypes 2..98 to build a saturating count array of product decompositions, then a Boolean array marking sums whose every decomposition has a non-unique product (fact 1). A second pass counts, per product, the decompositions whose sum satisfies fact 1 (fact 2), and a third pass counts per sum the decompositions with fact 1 and a unique fact-2 product (fact 3), printing each sum with exactly one such decomposition via Silver_IO.Put_Line and integer image text. About 70 lines.

## Proof obligations to watch

- **index**: The product X*Y indexes a count array, which discharges because X and Y are subtypes 2..98 and the array is sized 0..9604 so the bound follows from the types.
- **overflow**: Loop-carried counters are incremented only under a guard that saturates at 2, which preserves the needed distinction between zero, one and many decompositions and keeps the addition within its type.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the single solution (X, Y) and their sum and product as text lines.

Assessed on 2026-10-15 against page revision 414529 of the [task](https://rosettacode.org/wiki/Sum_and_product_puzzle) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
