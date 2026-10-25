# Ramanujan's constant

**Candidate: proofs plausibly discharge automatically.** The task is pure integer big-number arithmetic with fixed bounds and console output, so it needs no annotations, but proofs over looped limb arithmetic depend on careful typing and guards, hence plausible rather than likely.

Position 1384 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent fixed-point numbers as a fixed-capacity array of decimal limbs scaled by 10**60, embed pi as a constant string of digits, and compute sqrt(n) by digit-by-digit or Newton integer square root with for loops over a fixed iteration count. Compute exp via a Taylor series with a fixed, statically bounded number of terms (using add, multiply and divide-by-small-integer procedures), then print the integer and 32 fractional digits for 163 and the other Heegner numbers (19, 43, 67, 163) with text formatting. About 170 lines.

## Proof obligations to watch

- **overflow**: Fixed-point big-number multiply, add and carry propagation run in loops with loop-carried digit values, so each digit type must be bounded (digits 0..9, carries in a wide range) and guarded just before use.
- **index**: Limb-array indexing in schoolbook multiply and shifts uses for-loop indexes plus computed offsets that need guards or capacity checks before each access.
- **termination**: Integer square root and Taylor-series loops are written as for loops over fixed counts, or as while loops only inside procedures, so no variant is needed.
- **range**: Number of Taylor terms and the digit width of 1e18-sized values must be statically bounded constants sized for e^(pi*sqrt(163)), about 18 integer digits plus roughly 50 fractional digits.
- **division**: Division of a digit array by the term index k is guarded because k comes from a for loop starting at 1.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, big numbers and Put without a newline.

## External effects

- **console output** (allowed): Prints the 32-digit constant and the four Heegner-number results to standard output.

Assessed on 2026-10-15 against page revision 413874 of the [task](https://rosettacode.org/wiki/Ramanujan's_constant) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
