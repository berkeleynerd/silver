# Experimental Verification of the NKTg Law Using NASA Mercury Data in 2025

**Candidate: proofs plausibly discharge automatically.** All data are static and positive-ranged, so overflow and division checks follow from the subtypes and for-loop indexes over the array's own range, and nothing needs an annotation. The remaining uncertainty is the float provers on the product chain and the as-yet-absent float formatting library.

Position 1057 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Embed the 2024 reference record and the five 2025 NASA rows as constant arrays of a record of Long_Float subtype-constrained fields, compute NKTg1 once, then a for loop over the array's own range computes v = NKTg1/(x*m), relative error, p and NKTg2 with dm/dt = -0.5. Each row is formatted through a bounded float-image routine and printed with Put_Line, with no loop-carried state apart from the output line. About 70 lines.

## Proof obligations to watch

- **floating point**: The product x*m*v is about 8.9e38, which overflows 32-bit Float, so it must use Long_Float with range-constrained subtypes for x, m and v so the provers can bound every product and quotient below overflow.
- **division**: The divisions by x*m and by the NASA velocity are discharged because the subtypes' lower bounds are strictly positive and the data are embedded constants.
- **range**: Formatting each Long_Float result as scientific-notation text needs a bounded image routine or scaling to integers with guarded conversion, which depends on an admitted library operation that does not exist yet.
- **floating point**: Reproducing the printed rounded values relies on float-image output that is deterministic across targets, which is an environmental premise rather than a proof matter.

## Language surface recorded by this assessment

Floating point, ranged subtypes, arrays, records, for loops, floating-point images, string building, integers, Boolean objects and procedures.

## External effects

- **console output** (allowed): The program prints the NKTg1 constant and a per-date table of interpolated velocity, NASA velocity, relative error and NKTg2.

Assessed on 2026-10-15 against page revision 398822 of the [task](https://rosettacode.org/wiki/Experimental_Verification_of_the_NKTg_Law_Using_NASA_Mercury_Data_in_2025) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
