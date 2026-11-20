# Carmichael 3 strong pseudoprimes

**Candidate: proofs plausibly discharge automatically.** Every check follows from loop-index ranges and small declared subtypes, with only nonlinear products and quotients needing interval propagation, and all loops are for loops so no variant is needed.

Position 380 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Use a ranged integer type (0 .. 2**40) and a function Is_Prime doing for-loop trial division, then nested for loops over P1 in 2..61 (prime only), H3 in 1..P1 and D in 1..H3+P1-1 following the pseudocode. Each candidate P2 and P3 is computed from bounded operands, tested with Is_Prime and the mod condition, and qualifying triples are printed with Put_Line using 'Image concatenation into bounded strings. About 70 lines.

## Proof obligations to watch

- **overflow**: The products (H3+P1)*(P1-1), P1*P2 and P1*P2*P3 are nonlinear but every operand has a small subtype range (P1 up to 61, P2 up to 7261, P3 up to about 443000), so interval reasoning keeps them below 2**40.
- **range**: Assigning P2 and P3 into ranged subtypes needs the provers to bound quotients using D>=1 and H3>=1, which follows from the loop-index ranges but depends on careful typing.
- **division**: The divisors D, H3 and P1-1 are nonzero because loop indexes start at 1 and P1 is at least 2.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each Carmichael triple and product line by line.

Assessed on 2026-10-15 against page revision 413660 of the [task](https://rosettacode.org/wiki/Carmichael_3_strong_pseudoprimes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
