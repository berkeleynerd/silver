# Almkvist-Giullera formula for pi

**Candidate: proofs plausibly discharge automatically.** Everything follows from fixed-capacity limb arrays, bounded for loops and small-multiplier ranged types, but the multi-limb carry chains, big-by-big multiplication and digit-by-digit square root need careful shaping so every check discharges without invariants.

Position 1395 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent big non-negative integers as fixed-length arrays of base-10^9 limbs in a record or paired array and carry length bounds, with procedures for multiply-by-small, divide-by-small, add, subtract, compare and big-by-big multiply. The integer terms come from the exact ratio recurrence (multiply by six consecutive factors, then divide by (n+1) six times) times the quadratic polynomial, printed by converting limbs to digit characters; pi is computed as a scaled fixed-point sum of terms, then 1/S and its square root found digit by digit with bounded for loops, and the 70 digits printed after the decimal point. About 260 lines.

## Proof obligations to watch

- **overflow**: Limb arithmetic (limb times small multiplier plus carry) is bounded by declaring limbs as a ranged base-10^k subtype with small multipliers under a few hundred, so the products fit in 64-bit Long_Long_Integer without invariants.
- **index**: Fixed-capacity digit arrays are traversed with for loops over the array's own range, and carry out of the top limb is guarded with a visible overflow rejection.
- **overflow**: The integer terms reach about 4.7e43 and pi needs roughly 85 working digits, so capacities of about 20 limbs (terms) and 30 limbs (pi) are sized explicitly with headroom.
- **termination**: The square root and division are done digit-by-digit with for loops over fixed digit counts inside procedures, avoiding Newton iteration whose while loop would need a variant.
- **range**: Each digit search (trial digit 0..9 by repeated compare-and-subtract) is a bounded for loop, so no loop-carried value escapes its subtype.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, for loops, while loops, procedures, big numbers, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints ten integer terms and the 70-digit pi value as text lines.

Assessed on 2026-10-15 against page revision 413633 of the [task](https://rosettacode.org/wiki/Almkvist-Giullera_formula_for_pi) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
