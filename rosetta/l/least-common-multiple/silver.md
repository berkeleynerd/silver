# Least common multiple

**Candidate: proofs likely to discharge automatically.** Two active Euclidean steps at least halve the nonnegative second operand; twenty suffice for magnitudes <= 1000. Thus the divisor is the exact GCD and is zero only for two zero inputs. The guarded quotient of the absolute product implements every sign and zero case without truncating a required computation. The required 12/18 example gives 36, with twelve demonstrated controls. No while loop, out parameter or additional procedure is used. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 84 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_least_common_multiple.adb: an earlier GCD function normalizes signed arguments in -1000..1000 and runs twenty guarded Euclidean updates. LCM on the same full domain computes the product magnitude, assigns the GCD call to a local and divides only under Divisor > 0, retaining zero otherwise. Its result range is 0..1000000. Main indexes two fixed constant arrays and assigns each LCM call before output. About 61 lines.

## Proof obligations to watch

- **division**: B > 0 guards every modulo operation; Divisor > 0 guards the LCM quotient. The GCD argument establishes that retaining zero loses no required case.
- **range**: Sign normalization stays in 0..1000, the signed product stays in -1000000..1000000, and the magnitude and quotient fit 0..1000000.
- **termination**: Counted loops terminate by construction; the separate two-step halving argument establishes that twenty Euclidean updates suffice on the entire declared domain.

## Language surface recorded by this assessment

Named Integer subtypes, bounded components and scalar signatures, small nonrecursive scalar functions, bounded mutable Integer objects, Integer range for loops, interval-checked Integer division, scalar guard refinement, fixed-size Integer arrays and Integer image.

## External effects

- **console output** (allowed): Prints twelve LCM pairs covering 12 and 18, signs, zero and declared bounds.

Initially assessed on 2026-10-15 against page revision 412881 of the [task](https://rosettacode.org/wiki/Least_common_multiple) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
