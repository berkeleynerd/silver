# Fermat pseudoprimes

**Candidate: proofs likely to discharge automatically.** All values are bounded by 12000 so every product fits a wide integer and every loop is a for loop over a static range, so the checks follow from types and static bounds without needing invariants; the stretch to larger limits only changes the constant.

Position 353 in the [progression](../../progression.md#stage-8), in stage 8.

## Approach

Embed the limit 12000 as a constant, build a Boolean composite table by a for-loop sieve over a constrained array, then for each base 1..20 loop x from 4 to 12000 and, if x is composite, compute base^(x-1) mod x by square-and-multiply over a fixed 14-iteration for loop with residues in a 0..12000 subtype. Count matches in a bounded counter, print the first 20 via a Put procedure using integer image, and finish each line with the total via Put_Line. About 70 lines.

## Proof obligations to watch

- **overflow**: The modular multiplication of two values below 12000 is computed in a wide integer type and reduced by a guarded nonzero modulus, so the product bound follows from the subtype ranges alone.
- **range**: Loop-carried residues are stored in a subtype 0..12000 and the mod result is bounded by the modulus, which the provers must show from the guard x <= 12000 without an invariant.
- **termination**: Exponentiation is a fixed 14-step for loop over the bits of x-1 and primality uses a Boolean sieve in for loops, so no while loop or recursion is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, for loops, procedures, functions, string building, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints one line per base 1 through 20 with the first 20 pseudoprimes and the total count.

Assessed on 2026-10-15 against page revision 414202 of the [task](https://rosettacode.org/wiki/Fermat_pseudoprimes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
