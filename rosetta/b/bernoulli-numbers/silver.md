# Bernoulli numbers

**Candidate: proofs plausibly discharge automatically.** The task needs only console output and bounded big-rational arithmetic with no recursion, heap use or annotations, so it is feasible once a fixed-capacity big number facility exists, but the multi-limb carry, gcd and division loops make proof discharge depend on careful program shape.

Position 1400 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent signed rationals as numerator and denominator arrays of base-10000 limbs with a length, and implement add, subtract, multiply by small integer, divide by small integer and gcd reduction as procedures with for and while loops over the fixed arrays. Run the Akiyama-Tanigawa double loop over a 61-entry array of such rationals for each n from 0 to 60, reducing after every step, then for even n and for n=1 build the line "B(n) = numerator / denominator" with aligned solidi into a fixed string buffer and print it with Put_Line. Any capacity overflow is rejected with a visible outcome rather than clamped. About 300 lines.

## Proof obligations to watch

- **overflow**: Fixed-capacity digit arrays use small limbs (for example base 10000 in 64-bit integers) so every limb product and carry is bounded by type ranges, and the digit capacity is sized above the largest intermediate Akiyama-Tanigawa value with an explicit overflow-reject path for results that do not fit.
- **index**: Schoolbook multiply, subtract, divide and gcd loops index limb arrays through for loops over the array range or with a guard just before each access, since carried positions have no invariant.
- **termination**: Gcd and normalisation use while loops, which are only safe because they live in procedures that get no termination check; functions must be limited to for loops.
- **range**: Signed rational subtraction and long division carry loop-carried quotient and remainder values that are bounded only by their declared subtypes, so each step needs explicit guards before narrowing.
- **length**: Output lines are assembled in a fixed-size buffer whose width is sized for the 43-digit numerator, with right alignment computed from digit counts under guards.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, while loops, procedures, functions, big numbers, string building, string indexing and 'Image of scalars.

## External effects

- **console output** (allowed): Prints one line per nonzero Bernoulli number B0 through B60.

Assessed on 2026-10-15 against page revision 413652 of the [task](https://rosettacode.org/wiki/Bernoulli_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
