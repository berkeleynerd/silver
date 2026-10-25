# Sum and product of an array

**Candidate: proofs plausibly discharge automatically.** Indexing is safe because the loops run over the array's own range, but the loop-carried sum and product need explicit overflow guards with visible failure output since no invariant can be written. This is routine guarded arithmetic with no annotation needed.

Position 164 in the [progression](../../progression.md#stage-6), in stage 6.

## Approach

An embedded constant array of ten Integers (1 to 10) is traversed by for loops over its own range, accumulating the sum and product in Integer variables. Before each addition and multiplication a guard checks that the result stays in Integer range; on failure a Boolean flag is set and the program prints an explicit overflow message instead of a result. Otherwise it prints both values with Integer'Image concatenated into text. About 45 lines.

## Proof obligations to watch

- **overflow**: Sum and product are loop-carried Integer values with no invariant, so each addition and multiplication is preceded by a guard comparing the accumulator with Integer'Last or Integer'First divided by the element, and an overflow sets a flag that selects a visible 'overflow' output instead of a wrong result.
- **division**: The guard divides by the element, so it is placed under a test that the element is nonzero (zero is handled separately because it leaves the product at zero).
- **length**: The output string is formed by concatenating literals with Integer'Image results, whose bounded length the prover must see against the declared String size.

## Language surface recorded by this assessment

Integers, integer division, arrays, for loops, 'Image of scalars and Boolean objects.

## External effects

- **console output** (allowed): Prints the sum and product with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413444 of the [task](https://rosettacode.org/wiki/Sum_and_product_of_an_array) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
