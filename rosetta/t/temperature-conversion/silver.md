# Temperature conversion

**Candidate: proofs likely to discharge automatically.** Scaled-integer arithmetic on a ranged subtype makes every overflow and range check follow from declared types, and there are no loop-carried values beyond a short digit-writing loop over a fixed buffer, so proofs should discharge without annotations.

Position 147 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

Represent temperatures as integer hundredths (K = 2100 for the embedded example 21.00), compute C = K - 27315, R = K * 9 / 5 and F = R - 45967 with exact integer arithmetic, then print each through a procedure that formats a signed hundredths value as sign, whole part, point and two-digit fraction using abs, / 100 and mod 100 into a bounded string. The kelvin input is a ranged subtype so every intermediate stays within Integer; the task's example value is embedded rather than read. About 45 lines.

## Proof obligations to watch

- **overflow**: The kelvin value is a ranged subtype of hundredths (0 to 100_000_000), so K*9, the subtractions and the C, F and R results all fit in Integer by static range reasoning.
- **length**: The text-formatting procedure writes digits into a fixed-size buffer sized for the widest value (sign, up to 10 digits, point, two decimals), so no index or length check can fail.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, 'Image of scalars, string building and procedures.

## External effects

- **console output** (allowed): Prints the four labelled lines K, C, F and R.

Assessed on 2026-10-15 against page revision 415541 of the [task](https://rosettacode.org/wiki/Temperature_conversion) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
