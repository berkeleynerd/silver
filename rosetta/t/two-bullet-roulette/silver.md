# Two bullet roulette

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged subtypes, fixed array bounds and a bounded counter, and the only loops are for loops plus a small while loop in a procedure. The only care needed is keeping the LCG arithmetic within 64-bit range, which types and mod make routine.

Position 370 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

The cylinder is a six-element Boolean array rotated by one position per step with a mod-6 copy; a deterministic LCG with a ranged state supplies the spin of 1 to 6 rotations. Four procedures (or one procedure taking a scenario number) unload, load, spin and fire in each scenario's order for 100000 trials, counting deaths in a bounded counter. Results are turned into a whole or one-decimal percentage with integer division and printed through a bounded text buffer. About 110 lines.

## Proof obligations to watch

- **overflow**: The LCG step multiplies a state bounded by a ranged subtype by a small constant so the product fits in 64-bit Integer, and the result is reduced with mod, and the trial and death counters are bounded by the fixed trial count.
- **index**: Cylinder positions are a 0..5 subtype and rotation uses mod 6 arithmetic, so every array index is within range by type.
- **termination**: The load while loop skips occupied chambers and lives in a procedure, which gets no termination check, and a guard on the bullet count keeps it from spinning on a full cylinder.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the four scenario labels with their death percentages.

Assessed on 2026-10-15 against page revision 413950 of the [task](https://rosettacode.org/wiki/Two_bullet_roulette) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
