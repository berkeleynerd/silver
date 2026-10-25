# Suffixation of decimal numbers

**Candidate: proofs plausibly discharge automatically.** Exact decimal-digit arrays avoid floating point and make every check follow from array bounds, ranged digit types and guards, though the loop-carried carry and index logic in division and rounding needs careful shaping; nothing requires an annotation or recursion.

Position 1404 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Each embedded test number is parsed in a procedure into a sign, a fixed-capacity decimal digit array (about 160 digits) and a decimal exponent, skipping commas and handling the point and e-exponent, with invalid text rejected visibly. Metric suffixes only move the decimal point by multiples of three (googol at 1e100), while binary suffixes divide the digit array by 1024 repeatedly using a short-division loop, selecting the largest suffix not exceeding the value by array comparison. The result is rounded to the requested digits with carry propagation, then rendered into a bounded string buffer and printed with identifying text via Put_Line and Put. About 320 lines.

## Proof obligations to watch

- **index**: Digit-array shifts, decimal-point placement and rounding carry propagate through loops, so each index is guarded by explicit bounds tests or for loops over the array's own range.
- **overflow**: Long division of the digit array by 1000 or 1024 keeps remainders below 1024 so carry*10+digit stays within a declared Integer range, but this needs a ranged remainder type or guard since loop-carried values lose their facts.
- **length**: Output text is assembled in a fixed-capacity buffer sized for the longest result (sign, about 130 digits, suffix), with explicit capacity guards before every append.
- **range**: Parsed exponent and digit counts are accumulated with saturation guards that reject values beyond fixed limits, giving a visible 'invalid input' outcome rather than silent clamping.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, for loops, while loops, procedures, functions, big numbers and Put without a newline.

## External effects

- **console output** (allowed): The program prints each test case's original number, digit count, suffix type and the suffixed result.

Assessed on 2026-10-15 against page revision 413934 of the [task](https://rosettacode.org/wiki/Suffixation_of_decimal_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
