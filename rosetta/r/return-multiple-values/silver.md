# Return multiple values

**Candidate: proofs likely to discharge automatically.** The cached Ada solution uses a procedure with two out parameters, and the bounded driver preserves that multiple-result behavior. Independent arithmetic and Integer Image formatting match all six manifest lines. The unchanged sample passed admission, automatic obligation/report checks, compilation and execution in the retained 85-sample suite. The [delivery record](../../../docs/scalar-procedures.md#delivery-assurance-and-validation) separately records complete compiler assurance, actual-source correspondence and final regression coverage; the task review retains its own bounded scope.

Position 59 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The unchanged samples/rosetta_return_multiple_values.adb defines a Main-local Sum_And_Diff procedure with explicit in Small inputs (-100 .. 100) and out Integer Sum and Difference formals. Two source-written leading assignments compute both results; three positional calls use (5, 3), (-100, 100) and (100, 100) with distinct initialized mutable Integer output objects. Main prints each pair with Integer'Image and Silver_IO.Put_Line. About 27 lines.

## Proof obligations to watch

- **overflow**: Each Small input spans -100 .. 100, so the sum and difference lie in -200 .. 200 over all 40,401 input pairs and fit Standard.Integer. This static task argument is separate from the complete native/application assurance recorded for delivery.

## Language surface recorded by this assessment

Small nonrecursive scalar procedures, named Integer subtypes, bounded components and scalar signatures, bounded mutable Integer objects and Integer image.

## External effects

- **console output** (allowed): The program prints the two returned values with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 412999 of the [task](https://rosettacode.org/wiki/Return_multiple_values) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-15 by Codex through targeted source review; see the [review record](../../assessment-scalar-procedures-20261115.md).
