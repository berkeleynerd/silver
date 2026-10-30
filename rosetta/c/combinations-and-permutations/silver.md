# Combinations and permutations

**Candidate: proofs plausibly discharge automatically.** Everything stays within declared ranges or guards placed before each operation, with no annotation needed, but the float mantissa/exponent normalisation and the guarded loop-carried integer arithmetic make discharge depend on careful program shape.

Position 1097 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Exact values use a 61 by 61 Pascal triangle of a 63-bit range subtype for combinations and a guarded running product for permutations 1 to 12, printed through bounded text building of the integer image. The approximate part keeps each result as a scaled mantissa in a float subtype plus a decimal exponent, multiplying by (n-i) and dividing by i in for loops with a renormalisation step, and prints mantissa and exponent as text. Samples are embedded constants; no input is read. About 150 lines.

## Proof obligations to watch

- **overflow**: Exact products and Pascal sums are loop-carried, so each multiplication or addition is preceded by a guard against a 63-bit limit that reports the sample as out of range, and the chosen samples (P up to 12, C(60,k)) fit.
- **floating point**: Approximate P(n,k) up to n=15000 and C up to 1000 are kept as a mantissa bounded in a constrained float subtype plus an integer decimal exponent, renormalised by a guarded loop after every multiply so no float overflow check can fail.
- **range**: The exponent counter and renormalisation loop are loop-carried, so the exponent type is a wide declared range and the loop bound is guarded explicitly.
- **index**: Pascal table indices come from for-loop ranges over the array's own bounds, but the C(n-1,k-1) lookups need guards for k=0.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, floating point, floating-point images, 'Image of scalars, string building, arrays, multidimensional arrays, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the sample permutation and combination tables, exact and approximate, as lines of text.

Assessed on 2026-10-15 against page revision 414120 of the [task](https://rosettacode.org/wiki/Combinations_and_permutations) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
