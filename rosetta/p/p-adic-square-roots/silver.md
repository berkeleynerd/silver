# P-Adic square roots

**Candidate: proofs plausibly discharge automatically.** Every check can be bounded by types and pre-operation guards using exact integer arithmetic instead of floats, but the many loop-carried values in the Hensel lift and Lagrange reduction need careful guards, so it is plausible rather than likely.

Position 633 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed the example (a, b, p, k) cases in a constant array of records, with a digit array of bounded subtype values and a fixed maximum precision; find the root mod p by a for loop, lift digit by digit in a for loop with a guard stopping on overflow of p^k, and compute the complement and the squared expansion with carry loops. Reconstruct the rational with Lagrange reduction in a bounded while loop inside a procedure using integer norms, then cross-multiply to check against a/b and print the digits via Integer'Image-style conversion and string building. About 230 lines.

## Proof obligations to watch

- **overflow**: Evaluating b*x^2-a, the p^k powers, the digit-weighted sum and the squaring convolution are loop-carried, so each is computed in 64-bit with an explicit guard that stops the expansion (the task's own cut-off) when the next product would exceed a bound.
- **range**: Lagrange reduction and the Hensel lift reassign bounded subtype values from loop-carried results, so every update is preceded by a range guard that ends the loop with a visible 'reconstruction failed' outcome.
- **division**: Divisions by p, b and the modular inverse are protected by subtypes excluding zero and guards on the prime and denominator, with b=0 rejected visibly.
- **termination**: The valuation-stripping and Lagrange loops are while loops, so they live only in procedures, and each is also bounded by a fixed iteration counter.
- **index**: Digit arrays use a fixed offset range and every index is derived from for-loop variables or guarded against the array bounds.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, string building, 'Image of scalars, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints each radicand, the digit expansions, the reconstructed rational and a pass or fail verdict.

Assessed on 2026-10-15 against page revision 414376 of the [task](https://rosettacode.org/wiki/P-Adic_square_roots) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
