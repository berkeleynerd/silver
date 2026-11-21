# Entropy

**Candidate: proofs plausibly discharge automatically.** Every index, division and logarithm argument is bounded by types, static string length or an adjacent guard, so no annotation is needed, but the loop-carried float accumulator and the dependence on an admitted logarithm and float-formatting library with contracts make discharge depend on careful shape.

Position 957 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

The program embeds the string "1223334444" as a constant, keeps a 256-entry array of bounded counts indexed by Character, and fills it with a for loop over the string's range using a guarded increment that rejects on overflow. A second for loop over all Characters skips zero counts, computes p as Float(count)/Float(N) with N guarded positive, and subtracts p*log2(p) from a Float accumulator, then prints the result with a fixed-decimals float-to-text operation via Put_Line. About 40 lines.

## Proof obligations to watch

- **overflow**: The per-character count increment is loop-carried so the prover knows only its type, and the program declares counts as a subtype bounded above the string length and guards each increment with a visible rejection outcome.
- **floating point**: Each probability is count divided by a positive length so it lies in (0,1], and the logarithm is called only when the count is positive, but proving the float range of the loop-carried entropy sum relies on the sum's type bounds or per-term guards rather than an invariant.
- **division**: The divisor is the string length, which is a static positive constant and is also guarded by an explicit non-zero test before the division.
- **other**: The log2 value is computed as Log(p) divided by a constant Log(2.0) from an admitted elementary-function library whose contract must supply the positive-argument and finite-result facts.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, for loops, floating point, floating-point images, Put without a newline and procedures.

## External effects

- **console output** (allowed): The program prints the computed entropy of the embedded string to standard output.

Assessed on 2026-10-15 against page revision 411700 of the [task](https://rosettacode.org/wiki/Entropy) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
