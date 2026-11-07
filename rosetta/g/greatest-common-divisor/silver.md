# Greatest common divisor

**Candidate: proofs likely to discharge automatically.** For nonnegative magnitudes at most 1000, two Euclidean updates at least halve the second operand; 20 updates suffice since 2**10 exceeds 1000. Cases include ordinary, zero, both-zero, signed and coprime pairs, including (610, 987). This bounded demonstration does not claim an unrestricted GCD API. The exact source passed admission, complete required application/library proof audit, build and manifest execution in integration run 20261107T164659-9f6192441d21; the linked assessment records the evidence scope. The linked delivery record carries the independent closing review status.

Position 62 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main reads eight embedded pairs from fixed Input_Value arrays bounded -1000 .. 1000, normalizes each scalar copy by guarded unary negation, then performs up to 20 Euclidean updates under B > 0. Each update sets Remainder := (A mod B), A := B and B := Remainder. It prints the original pair and A. The source explicitly adopts gcd (0, 0) = 0. About 35 lines.

## Proof obligations to watch

- **division**: B > 0 narrows the modulo divisor to 1 .. 1000, giving remainder 0 .. 999 even under conservative declared-range body reads.
- **range**: The -1000 .. 1000 input range makes sign normalization safe, and each Euclidean assignment fits its declared scalar range.
- **termination**: All loops are counted; sufficiency of the fixed 20-update bound for the declared magnitudes is a separate algorithm argument, not merely loop termination.

## Language surface recorded by this assessment

Integer range for loops, immutable Integer arithmetic, Integer image, bounded mutable Integer objects, interval-checked Integer division, scalar guard refinement, fixed-size Integer arrays and named Integer subtypes and bounded components.

## External effects

- **console output** (allowed): Prints eight labelled GCD results: 6, 42, 42, 0, 6, 1, 1 and 1 for the source pairs.

Initially assessed on 2026-10-15 against page revision 415534 of the [task](https://rosettacode.org/wiki/Greatest_common_divisor) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-sample-expansion-20261107.md).
