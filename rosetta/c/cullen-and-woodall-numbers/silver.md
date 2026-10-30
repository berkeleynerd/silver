# Cullen and Woodall numbers

**Candidate: proofs likely to discharge automatically.** Every value is computed fresh from a loop index whose range is declared, so overflow and range checks follow from types and static bounds, needing no invariants. Only the plain Put and 'Image surface are new.

Position 1496 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

A main procedure with two for loops over a subtype N_Range is 1 .. 20, each computing N * 2**N + 1 (or - 1) in Integer and printing the value with 'Image and Put, with a space separator and a final Put_Line for the line break. No state is carried between iterations, and the 20-term count is a fixed documented limit. The optional Cullen and Woodall prime stretch is left out because it needs thousand-digit primality testing. About 22 lines.

## Proof obligations to watch

- **overflow**: n * 2**n + 1 with n declared in 1 .. 20 stays below 2**25, so it fits Integer; the prover needs the bounded exponent and product, which the loop range supplies without any loop-carried value.

## Language surface recorded by this assessment

Integers, exponentiation, ranged subtypes, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the two lists of 20 numbers to standard output.

Assessed on 2026-10-15 against page revision 415370 of the [task](https://rosettacode.org/wiki/Cullen_and_Woodall_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
