# Euler's identity

**Candidate: proofs plausibly discharge automatically.** The task needs only straight-line floating-point arithmetic on constant operands with bounded types, so no annotations are required, but the proofs depend on admitted elementary functions with verified contracts and on float formatting.

Position 1032 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Define a small record type for a complex number with Long_Float parts bounded by a declared subtype, and compute e^(i*pi) as Exp(0)*(Cos(Pi) + i*Sin(Pi)) using constants with no loops or recursion. Add 1.0 to the real part, then print both parts and the magnitude of the residual, which is about 1.2E-16, as approximately zero with the error shown. All data is embedded and there is no input. About 35 lines.

## Proof obligations to watch

- **floating point**: Cos, Sin and Exp on a constant Pi argument must be admitted library operations with verified contracts, otherwise a Taylor series on a range-bounded Long_Float subtype with a fixed term count is the fallback, and its bounds must make every product and sum provably finite.
- **overflow**: Complex multiplication and addition of values in a declared small float subtype stay far below the type limit, so the float overflow checks follow from the type range.
- **length**: Float-to-text formatting must go into a fixed-capacity buffer through an admitted float-image operation whose length bound is verified.

## Language surface recorded by this assessment

Floating point, records, floating-point images, functions, procedures, Put without a newline, string building and ranged subtypes.

## External effects

- **console output** (allowed): Prints the real and imaginary parts of e^(i*pi)+1 and the error magnitude.

Assessed on 2026-10-15 against page revision 411960 of the [task](https://rosettacode.org/wiki/Euler's_identity) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
