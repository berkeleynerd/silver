# Biorhythms

**Candidate: proofs likely to discharge automatically.** All arithmetic is integer over small declared ranges, mod results index tables of matching size, and there are no loops or recursion, so every check follows from types and one date-order guard. Floating point is avoided by tabulating the sine percentages, which keeps the output faithful to the task's example values.

Position 366 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the birth and target dates as constants of ranged year, month and day subtypes, convert each to a day number with integer-only civil-calendar arithmetic, and reject the pair with a message if the target precedes the birth. Take the difference mod 23, 28 and 33, look up each sine value in a constant integer-percent table sized to the cycle, so no floating point or Sin is needed, and derive the trend text from the position with if statements. Build each output line by concatenating fixed text with 'Image of the day and the percent into a bounded buffer. About 110 lines.

## Proof obligations to watch

- **overflow**: The day-number computation uses year, month and day subtypes with small ranges so every intermediate product and sum fits in Integer without any loop-carried value.
- **index**: Each cycle position comes from mod 23, 28 or 33 into a subtype equal to the table's index range, so table lookups are statically in bounds.
- **range**: The target date must not precede the birth date, so the program checks this just before subtracting and prints a specified rejection message otherwise.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, functions, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the day count and the three biorhythm values with descriptions via Put_Line.

Assessed on 2026-10-15 against page revision 415038 of the [task](https://rosettacode.org/wiki/Biorhythms) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
