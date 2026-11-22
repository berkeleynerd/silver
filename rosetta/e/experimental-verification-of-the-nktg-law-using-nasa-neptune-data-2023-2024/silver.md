# Experimental Verification of the NKTg Law Using NASA Neptune Data (2023–2024)

**Candidate: proofs plausibly discharge automatically.** The task is fixed embedded data with straight-line floating-point arithmetic in for loops, so all checks follow from ranged float subtypes and constant divisors. The risk is moderate because the program needs floating-point types, sqrt and float formatting, which Silver does not yet have, and the provers must bound products of roughly 1e37.

Position 993 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the five 2023 and five simulated 2024 records (date text, x, v, m) as constant arrays of ranged Long_Float values and iterate with for loops over the array range. A pure function computes p, NKTg1, NKTg2 and the sqrt-combined NKTg, and a procedure prints each row plus the relative mass error against the constant NASA mass, using an admitted float-to-text routine for formatting. All values are fixed constants, so no input validation or runtime-dependent guards are needed. About 90 lines.

## Proof obligations to watch

- **floating point**: x*p reaches about 1e37 and its square about 1e74, so declared ranged Long_Float subtypes for position, velocity, mass and momentum keep every product far below the format limit and let the provers discharge the overflow checks.
- **floating point**: sqrt needs a non-negative argument, which holds because the argument is a sum of two squares that the prover can show is at least zero.
- **division**: The relative error divides by the NASA mass, which is a positive constant of 1.0243e26, so the nonzero check is static.
- **range**: Mass simulation m_prev + dm_dt*dt stays inside the mass subtype only because the loop is unrolled over the five embedded dates or each step is computed from an embedded value rather than carried through the loop.

## Language surface recorded by this assessment

Floating point, ranged subtypes, arrays, records, for loops, procedures, functions, floating-point images, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints NKTg values and the relative mass error for each 2024 date to standard output.

Assessed on 2026-10-15 against page revision 401698 of the [task](https://rosettacode.org/wiki/Experimental_Verification_of_the_NKTg_Law_Using_NASA_Neptune_Data_%282023%E2%80%932024%29) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
