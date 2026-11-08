# Sign of an integer (signum)

**Candidate: proofs likely to discharge automatically.** The three branches partition the full Integer domain without negating X, so both signed endpoints are handled. All required examples are present. This Integer representation has no distinct signed zero, so the representation-dependent signed-zero clause does not apply. Fixed Integer arrays and constant element iteration suffice; no case statement or broad array/function identifier is required. The [reconciliation](../../../rosetta/assessment-scalar-function-batch-20261108.md) preserves the original assessment attribution and links the separately reviewed Linux application evidence; final combined integration and independent delivery status remain in the batch delivery record.

Position 58 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_signum.adb: Signum(X : in Integer) returns the named Integer subtype -1..1. An initialized local is assigned -1 for X < 0, 1 for X > 0 and 0 otherwise, then returned once. Main iterates the five-value constant Integer array, assigns each function result and prints it with Integer Image. About 26 lines.

## Language surface recorded by this assessment

Named Integer subtypes and bounded components, small nonrecursive scalar functions, bounded mutable Integer objects, fixed-size Integer arrays, constant Integer-array iteration and Integer image.

## External effects

- **console output** (allowed): Prints signum results for -10, 42, 0 and both Integer endpoints with Put_Line.

Initially assessed on 2026-10-15 against page revision 413025 of the [task](https://rosettacode.org/wiki/Sign_of_an_integer_%28signum%29) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-08 by Codex through targeted source review; see the [review record](../../assessment-scalar-function-batch-20261108.md).
