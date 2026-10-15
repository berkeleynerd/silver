# Haversine formula

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged float subtypes, library contracts and guards before Sqrt and ArcSin, with no loops or recursion, but the floating-point reasoning and the dependence on an admitted elementary-functions library make discharge depend on careful program shape rather than being routine.

Position 1048 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The program declares a ranged Float subtype for latitudes and longitudes in degrees, embeds the BNA and LAX coordinates as constants, converts them to radians, and computes the haversine term with a function using the admitted Sin, Cos, Sqrt and ArcSin operations. Guards clamp the Sqrt and ArcSin operands into their valid domains, and the resulting distance is scaled to an integer and printed as text with three decimals through Put_Line. About 45 lines.

## Proof obligations to watch

- **floating point**: Sin, Cos, ArcSin and Sqrt must come from an admitted elementary-functions library with verified contracts, and the provers must bound the products of ranged-subtype operands using those contracts.
- **range**: Rounding could push the ArcSin operand fractionally above 1.0, so an explicit guard clamps it to 1.0 before the call, which is a visible and numerically harmless outcome.
- **range**: Sqrt needs a nonnegative operand, which follows from a sum of squares and a product of cosines of latitudes held in a subtype limited to -90.0 .. 90.0 degrees, but a guard against negative rounding results is added to be safe.
- **overflow**: Converting the kilometer result to scaled integer digits for printing is safe because the distance is bounded by 2.0 * 6372.8 * Pi/2 and a guard precedes the conversion.

## Language surface beyond today's Silver

Floating point, ranged subtypes, functions, floating-point images, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the BNA to LAX great-circle distance in kilometers.

Assessed on 2026-10-15 against page revision 415515 of the [task](https://rosettacode.org/wiki/Haversine_formula) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
