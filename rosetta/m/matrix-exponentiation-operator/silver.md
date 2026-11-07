# Matrix-exponentiation operator

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges and for-loop bounds, but overflow across repeated multiplication needs careful range design and guards, so success depends on program shape.

Position 705 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Define a constrained 2x2 array type of a ranged integer subtype with "*" and "**" operators, where "**" multiplies by repeated for-loop iteration over a bounded exponent range. Demonstrate M**0 through M**10 on embedded example data against explicit products, with sums computed in a wider integer type under magnitude guards, and print rows with Image and Put. About 90 lines.

## Proof obligations to watch

- **overflow**: Matrix products are carried through repeated multiplication, so the program checks element magnitudes (bounded by 10^9) in a wider integer type before each multiply and rejects with a visible outcome if a result would exceed the bound.
- **range**: Storing each product back into the bounded element subtype needs a magnitude test just before the assignment.
- **other**: A function-based ** operator cannot report overflow, so the operator is applied only after a guard in a procedure shows the demonstrated powers stay within the element bound.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints each matrix and power result as text lines.

Assessed on 2026-10-15 against page revision 414333 of the [task](https://rosettacode.org/wiki/Matrix-exponentiation_operator) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
