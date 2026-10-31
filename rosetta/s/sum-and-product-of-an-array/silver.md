# Sum and product of an array

**Candidate: proofs likely to discharge automatically.** The bounded component subtype supplies the operand range for guarded sum and product updates. The embedded ten-element example is computed by iteration over the actual array, with standard Integer Image output.

Position 44 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main embeds the constant vector 1 through 10 in an anonymous fixed array whose component subtype is Integer range 1..10. One foreach loop updates guarded Integer sum and product accumulators, then prints 55 and 3628800. Constant thresholds follow from the component upper bound, so no division, Boolean object, procedure or array attribute is needed. About 23 lines.

## Proof obligations to watch

- **overflow**: The component subtype 1..10 bounds each operand. Guards Sum <= 2147483637 and Product <= 214748364 precede addition and multiplication; the alternative arms print explicit overflow messages. Neither guard fails for the embedded vector 1 through 10.

## Language surface recorded by this assessment

Bounded mutable Integer objects, fixed-size Integer arrays, constant Integer-array iteration, Integer image, scalar guard refinement and named Integer subtypes and bounded components.

## External effects

- **console output** (allowed): Prints the sum and product with Silver_IO.Put_Line.

Initially assessed on 2026-10-15 against page revision 413444 of the [task](https://rosettacode.org/wiki/Sum_and_product_of_an_array) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-10-29 by Codex through targeted source review; see the [review record](../../assessment-named-integer-subtypes-20261029.md).
