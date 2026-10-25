# Currency

**Candidate: proofs likely to discharge automatically.** All values are constant-bounded integers in straight-line code, so overflow checks follow from the type ranges once the tax multiplication is split to stay within 64 bits. Needed beyond today's Silver are integer arithmetic, scalar image and bounded string building for the output.

Position 131 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Amounts are held as exact integer cents in a 64-bit signed range type, with embedded constants for quantity, unit price in cents and the tax rate in basis points of a hundredth. Straight-line code computes the subtotal, then the tax as quotient*765 plus the half-up rounded remainder*765/10000, then the total, with no loops. A small procedure prints dollars, a decimal point and a zero-padded two-digit cents field using Image and bounded concatenation. About 45 lines.

## Proof obligations to watch

- **overflow**: Multiplying the 2.2e18-cent total by 765 would exceed 64 bits, so the program splits the total into quotient and remainder by 10000 and multiplies the quotient and the small remainder separately, keeping every product within a 64-bit cents type.
- **range**: Image of a cents amount must be padded to two digits, which the program does with a guarded if on the remainder from mod 100 before concatenating bounded strings.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, 'Image of scalars, string building, procedures and Put without a newline.

## External effects

- **console output** (allowed): The three results (before tax, tax, total) are printed as lines with a decimal point.

Assessed on 2026-10-15 against page revision 414933 of the [task](https://rosettacode.org/wiki/Currency) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
