# Averages/Mean time of day

**Candidate: proofs plausibly discharge automatically.** All integer and string checks follow from subtypes and constants, but the proof hinges on floating-point trig sums and a rounding conversion being provably bounded, which needs careful guards and admitted Elementary_Functions contracts and no annotations.

Position 866 in the [progression](../../../progression.md#stage-14), in stage 14.

## Approach

The four sample times are embedded as an array of seconds-of-day in a 0..86399 subtype, and a for loop over the array sums Cos and Sin of each angle (seconds scaled by 2*pi/86400) in float accumulators. A guard checks whether both sums are effectively zero and prints a visible 'undefined' message, otherwise Arctan(Y, X) is normalised to a non-negative angle, converted to rounded whole seconds clamped into the subtype, and formatted into an 8-character String with digit characters and colons before Put_Line. About 75 lines.

## Proof obligations to watch

- **floating point**: The Sin and Cos sums over four angles must be proven finite and bounded, which depends on the admitted Elementary_Functions contracts bounding each result to -1.0..1.0, otherwise float overflow checks may stay unproved.
- **range**: Arctan with both sums near zero must be guarded by an explicit visible outcome such as printing that the mean is undefined, and the angle normalised to 0..86400 before converting to a seconds subtype, with the rounded value guarded against reaching 86400.
- **overflow**: Seconds are held in a 0..86399 subtype and hour, minute and second digits come from division by constants, so the integer arithmetic is bounded by types.
- **index**: Output characters are written to fixed positions 1..8 of an 8-character String from digit values in 0..9, so indexing and Character'Val range checks follow from the types.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, floating point, arrays, for loops, procedures, string building and string indexing.

## External effects

- **console output** (allowed): The program prints the mean time as HH:MM:SS with Put_Line.

Assessed on 2026-10-15 against page revision 414065 of the [task](https://rosettacode.org/wiki/Averages/Mean_time_of_day) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
