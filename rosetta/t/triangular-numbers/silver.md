# Triangular numbers

**Candidate: proofs plausibly discharge automatically.** The tables are simple bounded integer prefix sums that discharge with range guards, but the real-valued roots need floating-point arithmetic and formatting that depend on careful range guarding, so the outlook is plausible rather than likely.

Position 1098 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Keep a 31-element array of a 64-bit range subtype; build triangular, tetrahedral, pentatopic and then up to 12-simplex numbers by repeated in-place prefix sums with a guard before each addition, printing six per line. For the roots, embed the four integers as constants and compute each triangular and pentatopic root with a guarded floating-point square root and the tetrahedral root with a bounded fixed-iteration Newton loop, printing with a text-building float formatter. About 110 lines.

## Proof obligations to watch

- **overflow**: The running-sum tables reuse one array of a 64-bit range subtype, and each addition is preceded by an explicit guard that rejects values beyond a documented cap, which the 5.6e9 maximum never reaches.
- **floating point**: Square roots and the cube-root formula need operands guarded to non-negative bounded ranges, and the cube root is computed by a bounded Newton or bisection loop in a procedure rather than a fractional power.
- **termination**: Root-finding iterations use for loops with a fixed iteration count or while loops inside procedures only, so no function needs a variant.
- **range**: Converting the large integers and float results to text needs explicit range guards before 'Image or a hand-written digit-building routine.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, floating point, floating-point images, arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the four 30-term tables and the three roots for each of the four integers.

Assessed on 2026-10-15 against page revision 414554 of the [task](https://rosettacode.org/wiki/Triangular_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
