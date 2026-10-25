# Quaternion

**Candidate: proofs plausibly discharge automatically.** Everything is straight-line, loop-free float arithmetic on small embedded constants, so no loop invariants or termination variants are needed; the only non-routine work is bounding float operands and having an admitted Sqrt and float formatting. The tight data bounds make range guards easy, but floating-point proof and library availability keep it at plausible.

Position 1075 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Define a bounded Float subtype and a Quaternion record of four such components, with pure functions for norm, negation, conjugate, real addition, quaternion addition, real scaling and Hamilton multiplication, each applied to the embedded example data. Main (a procedure) checks that operand magnitudes keep every result inside the bound before calling them, prints each result as text, and prints both q1*q2 and q2*q1 plus a Boolean comparison showing they differ. About 90 lines.

## Proof obligations to watch

- **floating point**: Float products and sums of four terms cannot overflow only if components are held in a bounded subtype (for example plus or minus 1.0E6), which the program declares and enforces with a visible rejection guard on inputs.
- **range**: Results assigned back to the bounded component subtype need a range guard before assignment (rejecting with a printed message), since GNATprove cannot carry bounds through chained operations without annotations.
- **floating point**: The norm needs Sqrt on a non-negative argument, which holds because the sum of squares of bounded values is non-negative, relying on the admitted elementary-function library's verified contract.
- **other**: Float text formatting needs an admitted image operation with bounded output length, since Float'Image is not provable in an unannotated program.

## Language surface recorded by this assessment

Floating point, ranged subtypes, records, functions, procedures, floating-point images, string building, Put without a newline and Boolean objects.

## External effects

- **console output** (allowed): The program prints each quaternion, the norms and the two products to standard output.

Assessed on 2026-10-15 against page revision 415032 of the [task](https://rosettacode.org/wiki/Quaternion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
