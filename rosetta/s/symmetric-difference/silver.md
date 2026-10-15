# Symmetric difference

**Candidate: proofs likely to discharge automatically.** Every check is an index over the array's own enumeration range or a Boolean operation, with only for loops and no loop-carried arithmetic, so everything discharges from types alone. The work for Silver is the surface of enumerations, Boolean arrays with aggregates, procedures, Put and enumeration 'Image.

Position 1158 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Represent each set as a Boolean array indexed by an enumeration of the five names, initialised with aggregates, and compute the symmetric difference and the two individual differences with element-wise xor, and and not. A procedure prints a set by iterating over the array's own range with a for loop, using a Boolean first-flag to place commas and Person'Image for the names. Duplicates are inherently collapsed because membership is one flag per person. About 40 lines.

## Language surface beyond today's Silver

Enumerations, arrays, Boolean objects, for loops, procedures, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the three result sets (A xor B, A - B, B - A) to standard output.

Assessed on 2026-10-15 against page revision 414539 of the [task](https://rosettacode.org/wiki/Symmetric_difference) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
