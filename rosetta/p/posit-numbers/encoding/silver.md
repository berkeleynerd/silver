# Posit numbers/encoding

**Candidate: proofs plausibly discharge automatically.** Encoding a single fixed constant into an 8-bit posit needs only bounded integer loops over at most 8 bits, so every check follows from range types and loop bounds, though the scaled-integer shifting needs careful sizing to keep overflow checks provable without invariants.

Position 221 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

Embed pi as a scaled integer constant and a fixed 8-bit, es=2 format, then derive the regime by a bounded loop dividing by useed (16), the exponent by comparing against powers of two, and the fraction bits by a bounded for loop that doubles the remainder and extracts one bit per iteration, with round-to-nearest-even done by integer comparison. All state lives in range-typed integers, the loops run at most 8 iterations, and the result is printed with 'Image in Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The scaled-integer mantissa is repeatedly doubled and divided in loops, so it is declared in a range type (for example up to 2**40) and a guard or reduction keeps each doubling within that range.
- **range**: The accumulated bit pattern is loop-carried and is kept inside a Natural subtype bounded by 255, with each shift preceded by a guard on the number of bits already emitted.
- **floating point**: Avoided by representing pi as a fixed-point integer constant (3141592653589793 scaled by 10**15), so no floating-point reasoning is needed and rounding is exact integer arithmetic.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, for loops, while loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the resulting posit pattern as an unsigned integer (77).

Assessed on 2026-10-15 against page revision 390251 of the [task](https://rosettacode.org/wiki/Posit_numbers/encoding) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
