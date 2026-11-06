# Least common multiple

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic with bounded subtypes, and the only non-routine items are the nonzero-gcd divisor and the product bound, both handled by a guard and a range choice; the while loop sits in a procedure so no termination check applies. It is plausible rather than likely because the gcd's nonzero-ness is not inferable without an invariant and must be guarded.

Position 214 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

Declare a bounded integer subtype and a procedure Gcd that runs Euclid's algorithm with a while loop on in-subtype variables, returning the result in an out parameter. A procedure Lcm returns 0 if either input is zero, otherwise takes absolute values, guards the gcd being nonzero, and computes abs(A)*(abs(B)/G) in the bounded range. The main procedure runs the three embedded example pairs and prints each result with Put_Line and 'Image. About 45 lines.

## Proof obligations to watch

- **overflow**: abs(A)*(abs(B)/G) can overflow, so inputs are declared as a bounded subtype (for example -10**6 .. 10**6) so the product fits in Integer and GNATprove discharges it from type ranges.
- **division**: The divisor G is the Euclid result for nonzero inputs, but without a loop invariant GNATprove cannot show G is nonzero, so the program must guard G /= 0 before dividing and reject otherwise.
- **termination**: The Euclid while loop must be inside a procedure (not a function) so no variant is needed, with the result returned via an out parameter.
- **range**: Loop-carried M and N are known only by their subtype after the first iteration, so declaring them in the bounded subtype keeps mod and assignments in range.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, procedures, while loops, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the LCM results for the embedded example pairs.

Assessed on 2026-10-15 against page revision 412881 of the [task](https://rosettacode.org/wiki/Least_common_multiple) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
