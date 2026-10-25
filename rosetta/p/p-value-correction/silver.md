# P-value correction

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size array loops over embedded data with for loops in procedures, so index and termination checks are routine, but floating-point range bounds and the Hommel index arithmetic need careful guards, and fixed-decimal formatting of floats needs a custom routine, making discharge plausible rather than likely.

Position 1198 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Embed the 50 p-values in a constant Float array subtype-restricted to 0.0..1.0, and implement each method (Bonferroni, Holm, Hochberg, Benjamini-Hochberg, Benjamini-Yekutieli, Hommel, Sidak) as a procedure working on fixed-size arrays with an index permutation sorted by bubble sort. Ratcheting running min/max is done in for loops with a clamp to 1.0, and results are printed in rows of five with a hand-built fixed-decimal formatter that scales to integers and emits digits into a bounded string. Input validity is checked up front with an explicit rejection message, and the unknown-method case is a case-statement branch printing the help text. About 260 lines.

## Proof obligations to watch

- **floating point**: Products, quotients and the Sidak power on Float values need no-overflow and finite-value proofs, discharged by declaring p-values as a Float subtype range 0.0 to 1.0, embedding validated data, and clamping with explicit min guards.
- **overflow**: Multipliers like N/(N-i) and the harmonic sum are computed from a fixed N of 50 with guards before each division, so the bounded operands keep results far below Float limits.
- **index**: Sorting by index permutation (bubble sort in a procedure with for loops over the array's own range) and mapping back through the order array need index values typed as a range subtype so every access is in bounds.
- **termination**: All loops are for loops or live in procedures, so no variant is needed, and the Hommel nested loops run over fixed ranges.
- **range**: Hommel index arithmetic such as N-J+1 and the running minimum updates must stay within the subtype 1..50, which follows from loop ranges on J and explicit guards but needs careful shape.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, floating point, arrays, for loops, while loops, procedures, functions, 'Image of scalars, floating-point images, Put without a newline, string building, enumerations and case statements.

## External effects

- **console output** (allowed): Prints the adjusted p-values for each correction method as text lines.

Assessed on 2026-10-15 against page revision 414377 of the [task](https://rosettacode.org/wiki/P-value_correction) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
