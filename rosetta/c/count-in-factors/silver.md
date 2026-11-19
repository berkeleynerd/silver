# Count in factors

**Candidate: proofs likely to discharge automatically.** Every check follows from subtype ranges and guards just before the operations, since trial division with a bounded divisor and a halving cofactor needs no invariant, and the loops sit in procedures so no termination check applies. The only extras are Put and 'Image output, which are not yet in Silver.

Position 206 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

An outer for loop counts N over a subtype 1..10_000 (an explicit documented limit in place of the unbounded count), and a procedure factors N by trial division in a while loop with divisor D of subtype 2..101 and a remaining value R. Each prime factor is printed with Put of Integer'Image separated by " x ", with 1 shown as itself, and the while loop exits when D*D exceeds R or the guard on D fails, in which case the leftover R is itself prime. About 40 lines.

## Proof obligations to watch

- **overflow**: The trial divisor squared and the divisor increment are bounded by a subtype range and a guard before the increment, so no overflow can occur.
- **range**: The remaining cofactor is only divided by a divisor of at least 2, so it stays within its subtype after each division.
- **division**: The divisor is declared in a subtype starting at 2, so division by zero is excluded by type.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, for loops, while loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per number with its factor product to standard output.

Assessed on 2026-10-15 against page revision 411748 of the [task](https://rosettacode.org/wiki/Count_in_factors) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
