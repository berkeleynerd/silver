# Arbitrary-precision integers (included)

**Candidate: proofs plausibly discharge automatically.** Fixed-capacity limb arithmetic has every check bounded by subtype ranges or a capacity guard, but carries through nested loops and nonlinear products make discharge depend on careful program shape rather than being routine.

Position 1378 in the [progression](../../progression.md#stage-25), in stage 25.

## Approach

Represent the number as a fixed-capacity little-endian array of base-10^9 limbs with a count, start at 1, and repeatedly multiply in place by 5 raised to at most 13 per pass until 5^262144 (4**(3**2) is the constant 262144) is reached, guarding the limb count against capacity before appending a carry limb. Then count digits from the top limb's digit length plus 9 per remaining limb, and build the first 20 and last 20 digits into a bounded String buffer by formatting limbs with a small digit-extraction loop, and print the three lines with Put_Line. About 110 lines.

## Proof obligations to watch

- **overflow**: Limb times multiplier plus carry stays under 2^63 because limbs are a subtype below 10^9, the multiplier is a constant at most 5^13 and the carry is a bounded subtype, so the bound follows from types alone.
- **index**: Limb count grows in the loop, so a guard just before each append rejects with a visible message if the fixed capacity of about 20400 limbs would be exceeded, and the computed size of 183231 digits fits within it.
- **range**: Converting the product quotient and remainder back to the limb and carry subtypes needs the prover to bound nonlinear products, which holds because every operand's type range is tight.
- **termination**: All loops (multiply passes, digit counting, text extraction) are for loops or sit in procedures, so no variant is required.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, big numbers, 'Image of scalars, string building and string indexing.

## External effects

- **console output** (allowed): Prints the first 20 digits, last 20 digits and the digit count with Put_Line.

Assessed on 2026-10-15 against page revision 414059 of the [task](https://rosettacode.org/wiki/Arbitrary-precision_integers_%28included%29) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
