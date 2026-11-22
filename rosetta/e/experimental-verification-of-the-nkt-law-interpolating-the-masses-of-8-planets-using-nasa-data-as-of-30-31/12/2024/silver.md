# Experimental Verification of the NKT Law: Interpolating the Masses of 8 Planets Using NASA Data as of 30–31/12/2024

**Candidate: proofs plausibly discharge automatically.** Everything is a fixed 8-element for loop over embedded constants with only multiply, divide and subtract on bounded floats, so no annotations are needed, but the floating-point range and division-by-zero checks plus float-to-text output depend on careful bounded subtypes and guards.

Position 978 in the [progression](../../../../progression.md#stage-16), in stage 16.

## Approach

Embed the eight planets' names, x, v, NKTg1 and NASA mass as constant arrays of a bounded Long_Float subtype (or a record array), and loop with a for loop over the array's own range. Each iteration guards that x*v is nonzero and in range, computes m = NKTg1/(x*v) and Δm = |m_NASA − m|, then prints the name, values and an 'approximately zero' verdict from a relative-tolerance comparison against the NASA mass, with a visible rejection line otherwise. About 70 lines.

## Proof obligations to watch

- **floating point**: The products x*v and quotient NKTg1/(x*v) must not overflow or produce infinities, which the program discharges by declaring a bounded Long_Float subtype for all quantities and having the provers bound each operand from the constants' static ranges.
- **division**: The divisor x*v must be provably nonzero, which a guard just before the division enforces, with a visible 'invalid data' outcome in the output if it fails.
- **overflow**: NKTg1 reaches 2e37 and masses reach 1.9e27, so the range subtype must be wide enough for these yet narrow enough that the quotient and difference stay finite, which needs careful choice of bounds.
- **range**: Converting floating values to text through 'Image and bounded buffers needs a bounded string length, which fixed-size buffers and the float subtype range make checkable.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, arrays, records, for loops, procedures, functions, integers, Boolean objects, conditional expressions, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints a table of planet names, interpolated masses, NASA masses and Δm with a pass/fail remark.

Assessed on 2026-10-15 against page revision 398670 of the [task](https://rosettacode.org/wiki/Experimental_Verification_of_the_NKT_Law:_Interpolating_the_Masses_of_8_Planets_Using_NASA_Data_as_of_30%E2%80%9331/12/2024) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
