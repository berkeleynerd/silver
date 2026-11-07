# Modular exponentiation

**Candidate: proofs plausibly discharge automatically.** All checks derive from digit and carry subtypes and array-range for loops, but nested carry arithmetic and nonlinear digit products need careful range shaping, and the modulus is fixed at 10^40 as a documented limit, so discharge is plausible rather than certain.

Position 555 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Numbers are fixed arrays of decimal digits of subtype 0..9: a reduced to its low 40 digits, b kept as 70 digits, and the modulus 10^40 is implicit because truncating an 80-digit product to its low 40 digits is the reduction. A procedure Mul does schoolbook multiplication with a bounded carry, and a fixed 240-iteration for loop does square-and-multiply, testing b's last digit for parity and then halving b by digit-wise long division. The 40 result digits are converted to Characters into a 40-character String and printed with Put_Line. About 90 lines.

## Proof obligations to watch

- **overflow**: Schoolbook multiplication carries through nested loops, discharged by a carry subtype 0..99 and digit subtype 0..9 so every intermediate is at most 189 from types alone.
- **index**: Product digit index i+j stays at most 78 in an 80-digit array because both loop ranges are the 40-digit array's own range.
- **range**: Each digit and carry assignment after a division or mod by 10 must be proven in its subtype, which needs the solvers to handle small nonlinear bounds.
- **termination**: The exponent is consumed by a for loop of fixed 240 halvings in a procedure, avoiding any while loop or variant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, arrays, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the 40 result digits with Put_Line.

Assessed on 2026-10-15 against page revision 413792 of the [task](https://rosettacode.org/wiki/Modular_exponentiation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
