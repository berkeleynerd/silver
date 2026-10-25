# Roots of unity

**Candidate: proofs plausibly discharge automatically.** Every check follows from loop ranges and declared Float subtypes, but it depends on a library whose Sin and Cos contracts bound the results and on careful float-to-text formatting.

Position 1050 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Nested for loops over N in 2 .. 10 and K in 0 .. N-1 compute the angle as a Float ratio K/N with a ranged Float subtype, take Cos and Sin of it with an admitted elementary-functions library, and print the sign and five-decimal magnitudes via a small procedure that rounds into an integer and splits it into integer and fraction digits. All data is embedded, with no input. About 60 lines.

## Proof obligations to watch

- **floating point**: Sin and Cos from an admitted elementary-functions library need bounded Float arguments and Cycle > 0.0, which the loop-range-typed N and K and a ranged Float subtype provide.
- **range**: Rounding abs(value) * 100000.0 to an integer for five-decimal printing needs a Float subtype bounded to [-1.0, 1.0] on the results, which depends on the library contract bounding Sin and Cos.
- **division**: K / N is safe because N comes from a for loop over 2 .. 10 so it is never zero.
- **overflow**: Float products stay tiny because all operands are in small declared ranges, so provers discharge them with range guards.

## Language surface recorded by this assessment

Integers, ranged subtypes, floating point, for loops, procedures, floating-point images, 'Image of scalars, Put without a newline, integer division and string building.

## External effects

- **console output** (allowed): Prints each root of unity as text lines for N from 2 to 10.

Assessed on 2026-10-15 against page revision 413886 of the [task](https://rosettacode.org/wiki/Roots_of_unity) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
