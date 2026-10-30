# Perceptron

**Candidate: proofs plausibly discharge automatically.** Everything uses bounded integers, constant-size arrays and for loops inside procedures, so checks follow from types and a few visible guards, but loop-carried weight updates require careful bound guards and scaled-integer arithmetic in place of floating point.

Position 463 in the [progression](../../progression.md#stage-9), in stage 9.

## Approach

The program uses fixed-point-style scaled integers instead of floating point: a three-element weight array (x, y, bias), a deterministic LCG for initial weights and 2000 training points held in constant-size arrays, and labels computed from the line y = 2x + 1. A for loop trains once over each sample, with a guard that skips an update if a weight would leave its bounded subtype, then a second pair of nested for loops classifies each cell of a small grid and builds each row in a fixed-length String printed with Put_Line. Ground-truth line membership is marked in the text image, and the program also prints the count of misclassified training points. About 110 lines.

## Proof obligations to watch

- **overflow**: Integer weights updated across 2000 training iterations are loop-carried, so each update is guarded by a visible weight-magnitude bound that stops training for that weight (a documented resource limit) rather than relying on an invariant.
- **overflow**: The linear congruential generator multiplies a state bounded by its subtype with a constant, which fits in 64 bits and follows from the subtype range alone.
- **range**: Scaled integer arithmetic replaces floating point, with every product of weight, coordinate and error falling inside declared subtype bounds that the provers handle as bounded nonlinear multiplication.
- **index**: Grid cell and training-sample indices come from for-loop ranges over the arrays' own bounds, so they discharge routinely.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, for loops, procedures, functions, string building, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): The trained classifier's result is shown as a text-art grid of '+' and '-' cells printed to standard output.

Assessed on 2026-10-15 against page revision 414388 of the [task](https://rosettacode.org/wiki/Perceptron) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
