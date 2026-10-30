# RSA code

**Candidate: proofs plausibly discharge automatically.** Everything fits in fixed-capacity limb arrays with for-loop indexes and shift-and-add arithmetic needing no division by large values, so no annotation is required, but loop-carried big-number arithmetic needs careful guarded program shape.

Position 1390 in the [progression](../../progression.md#stage-24), in stage 24.

## Approach

Represent big numbers as fixed-capacity arrays of limbs (about 160 to 320 bits) with n, e and d embedded as limb constants, and implement add, compare, subtract, double and mod-n reduction as procedures. Compute modular multiplication by bitwise shift-and-add with conditional subtraction of n, and modular exponentiation by a for loop over the exponent's fixed bit positions with square-and-multiply. Encode the 12-character message "Rosetta Code" as a base-256 number below n, encrypt and decrypt it, then print the decimal values (by repeated small division in a for loop) and the recovered text. About 230 lines.

## Proof obligations to watch

- **overflow**: Limb add, subtract and shift steps in the big-number modular arithmetic carry values through loops, so each limb is typed with a range wide enough (for example 32-bit limbs in a 64-bit range) that intermediate sums cannot overflow.
- **index**: Limb and digit indexes in fixed-capacity arrays are loop-carried, so every access uses for-loop indexes over the array's own range or a guard just before the access.
- **range**: Modular multiplication is done by shift-and-add (double, compare, conditionally subtract n) so no division or 286-bit product is needed, but the operand being below n is a loop-carried fact that must be re-guarded at each step rather than invariant-supplied.
- **termination**: Loops that convert to decimal or find the top limb are while loops, so they live in procedures or are rewritten as for loops over the fixed capacity.
- **length**: Decimal and decoded-text output buffers are fixed-size with a documented maximum and a specified rejection outcome if the number does not fit.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, for loops, while loops, procedures, functions, big numbers and Put without a newline.

## External effects

- **console output** (allowed): The program prints the plaintext, its numeric encoding, the ciphertext and the decrypted text.

Assessed on 2026-10-15 against page revision 413872 of the [task](https://rosettacode.org/wiki/RSA_code) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
