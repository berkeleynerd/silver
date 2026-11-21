# Horner's rule for polynomial evaluation

**Candidate: proofs likely to discharge automatically.** The constrained routine accepts coefficients in increasing-power order and x as the task requires. Full-domain bounds justify every performed multiply-add; reverse Range iteration justifies every index. Independent sequences are 0,6,14,49,128 at x=3 and 0,6,56,567 then refusal at x=10. Expected lines are At 3: 128 and At 10: capacity exceeded. Complete Linux native/Lean/actual-source assurance, final regression coverage and scoped independent reviews are recorded in the [delivery record](../../../rosetta/assessment-named-array-parameters-20261121.md#delivery) and its linked evidence. The precise named-integer-array-parameters construct is supported; broad arrays, writable arrays and unconstrained arrays remain unsupported.

Position 88 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

The delivered samples/rosetta_horner_polynomial.adb declares a named Polynomial (0 .. 3) of Coefficient (-20 .. 20). Procedure Horner takes that read-only array with scalar X (-10 .. 10), a scalar result (-1000 .. 1000) and a Boolean success output. It traverses the coefficient Range in reverse, implementing Horner's recurrence only after a fresh -98 .. 98 accumulator guard. Refusal persists and returns zero with Succeeded=False; Main suppresses the numeric result and prints capacity exceeded. The embedded coefficients [-19, 7, -4, 6] give 128 at x=3; x=10 visibly exercises refusal. Both mixed and positional calls use existing scalar output/copy-back rules. About 55 lines.

## Proof obligations to watch

- **overflow**: Before every performed step the executable accumulator guard gives -98 .. 98, the full argument domain is -10 .. 10 and every coefficient is -20 .. 20. The product is therefore -980 .. 980 and the multiply-add fits -1000 .. 1000.
- **index**: The reverse counted loop uses Coefficients'Range (0 .. 3), so every component read is in bounds for every formal value. No predicate relation is retained in the Boolean success flag.

## Language surface recorded by this assessment

Named constrained Integer-array inputs and static bounds queries, named Integer subtypes, bounded components and scalar signatures, bounded mutable Integer objects, Integer image, small nonrecursive scalar procedures, scalar Boolean objects and expressions, scalar guard refinement, Integer range for loops and named scalar arguments.

## External effects

- **console output** (allowed): The program prints the evaluated polynomial value (128) with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 411617 of the [task](https://rosettacode.org/wiki/Horner's_rule_for_polynomial_evaluation) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-21 by Codex through targeted source review; see the [review record](../../assessment-named-array-parameters-20261121.md).
