# Experimental Verification of the NKTg Law in Earth Orbit Based on NASA’s 2025 Earth Dataset

**Candidate: proofs plausibly discharge automatically.** The task is fixed embedded data pushed through a few multiplications and one division in a for loop, with no recursion, while loops or input, so checks follow from float subtype ranges. The only non-routine parts are float overflow bounds up to 1e40 and hand-written scientific-notation formatting.

Position 1001 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the five simulated records (date text, x, v, m) and the five NASA velocities as constant arrays of range-bounded float subtypes, then a for loop over the array's own range computes p, NKTg1, NKTg2 and the relative error percent through small side-effect-free functions. A procedure formats each value as mantissa and decimal exponent text in a bounded buffer and prints one line per date, with the NASA velocity guaranteed nonzero by its subtype range. About 110 lines.

## Proof obligations to watch

- **floating point**: Products like x*p reach 1e40 and the percent error divides by v_NASA, so the program declares range-constrained float subtypes (for example v between 1.0 and 1.0e5, m up to 1.0e25) so the provers can bound every product and see the divisor is nonzero.
- **overflow**: Float overflow checks on m*v, x*p and dm/dt*p discharge because the embedded constants sit inside the declared subtype ranges and the result subtype is wide enough, though the provers need the range bounds stated through the types.
- **range**: Converting a float to scientific-notation text needs exponent and mantissa extraction, which is done with guarded comparison loops over bounded decades, and this is the least routine part.

## Language surface recorded by this assessment

Floating point, floating-point images, ranged subtypes, arrays, records, for loops, functions, procedures, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints a header and one result row per 2025 date to standard output.

Assessed on 2026-10-15 against page revision 409786 of the [task](https://rosettacode.org/wiki/Experimental_Verification_of_the_NKTg_Law_in_Earth_Orbit_Based_on_NASA%E2%80%99s_2025_Earth_Dataset) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
