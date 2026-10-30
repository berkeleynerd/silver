# Smallest power of 6 whose decimal expansion contains n

**Candidate: proofs plausibly discharge automatically.** The task needs big numbers (6^m exceeds 64 bits), but a fixed-capacity digit array with narrow subtypes lets every check follow from types and one count guard, so no annotation is needed. Discharge depends on careful shape of the carry loop and pattern search, hence plausible rather than likely.

Position 1362 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent the current power of 6 as a fixed 80-element array of decimal digits (least significant first) with a digit count, and for each exponent from 0 to 100 multiply in place by 6 with a carry loop, guarding the count before appending a digit. For each n in 0..21, a procedure scans exponents in order, checking whether the one- or two-digit pattern of n occurs among the digits using bounded for-loop comparisons, and prints the exponent and the power built from the digits. If no exponent up to the limit matches, it prints a specified not-found line. About 90 lines.

## Proof obligations to watch

- **overflow**: The digit-times-6-plus-carry step is bounded because digits are a 0..9 subtype and the carry a 0..5 subtype, so the provers see a result of at most 59 without needing an invariant.
- **index**: The digit count is a loop-carried value, so each write into the fixed 80-digit array is preceded by an explicit guard on the count, with a specified overflow outcome that rejects instead of truncating.
- **range**: Re-narrowing the carry and digit values from the quotient and remainder of a division by 10 requires the type bounds on the operands, which hold, but it depends on careful subtype declarations.
- **termination**: All loops are for loops or live in procedures, so no variant is needed, and the exponent limit of 100 keeps the power within 80 digits.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, records, 'Image of scalars, string building, for loops, while loops, big numbers, Boolean objects, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per n from 0 to 21 giving the exponent and the power.

Assessed on 2026-10-15 against page revision 409956 of the [task](https://rosettacode.org/wiki/Smallest_power_of_6_whose_decimal_expansion_contains_n) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
