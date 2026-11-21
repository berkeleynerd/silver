# Thiele's interpolation formula

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-size array and for-loop code that avoids recursion and needs no annotations, but proof depends on floating-point range bounds and zero-denominator guards through the nested loops, and on an admitted trig library or embedded table. This makes it plausible rather than likely.

Position 998 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed or compute a 32-entry table of x, sin, cos, tan in fixed-size Long_Float arrays, then build a 32x32 reciprocal-difference array with nested for loops, rejecting any zero denominator. The inverse is evaluated by a reverse for loop over the continued fraction in a procedure that returns a status flag, and the program prints pi and 6*asin(0.5), 3*acos(0.5) and 4*atan(1) as text. About 90 lines.

## Proof obligations to watch

- **floating point**: Reciprocal differences divide by differences of table values, so the program must guard each denominator against zero and the guards must also keep results finite, which makes the proof depend on range-bounded float subtypes.
- **overflow**: Float subtraction, division and accumulation in the continued fraction can overflow unless operands are bounded by subtypes or guards, and the loop-carried value A is only known by its type range.
- **division**: A zero denominator in rho or in the continued fraction must lead to a specified visible rejection, not a silently altered result.
- **index**: The triangular table uses computed slices and indices like N-I+1 and I-2, which discharge only if written as for loops over 2D constrained bounds with explicit guards.
- **other**: Trig functions need an admitted elementary-function library with bounded contracts, since Silver authors cannot write their own and the table could instead be embedded as literals.

## Language surface recorded by this assessment

Floating point, arrays, for loops, ranged subtypes, procedures, functions, floating-point images and Put without a newline.

## External effects

- **console output** (allowed): Prints the pi reference and the three Thiele-derived pi values.

Assessed on 2026-10-15 against page revision 413947 of the [task](https://rosettacode.org/wiki/Thiele's_interpolation_formula) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
