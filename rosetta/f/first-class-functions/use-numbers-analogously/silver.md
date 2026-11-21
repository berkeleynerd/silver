# First-class functions/Use numbers analogously

**Candidate: proofs plausibly discharge automatically.** Generic instantiation meets the "returns a function" requirement without closures or access types, and every check is float arithmetic on constants or on bounded subtypes. The one non-routine part is choosing a bounded float subtype so that the provers can rule out overflow in the product of three values.

Position 1529 in the [progression](../../../progression.md#stage-31), in stage 31.

## Approach

Two constant arrays of a bounded Float subtype hold x, y and z = x + y, and their inverses xi, yi and zi = 1.0 / (x + y). A generic function Multiplier with formal objects n1 and n2 returns n1 * n2 * m, which is Ada's way to make a function from two numbers. A for loop over the array range opens a declare block that instantiates Multiplier with the i-th number and its inverse, calls the instance with 1.0 and prints the result with Float'Image. About 32 lines.

## Proof obligations to watch

- **floating point**: The overflow check on n1 * n2 * m discharges if the generic formals and parameter use a bounded floating-point subtype such as range -1000.0 .. 1000.0, so the product stays far below Float'Last.
- **division**: zi = 1.0 / (x + y) uses constant operands 2.0 and 4.0, so the provers can see that the divisor is 6.0 and nonzero.
- **range**: Inverses and literals assigned into the bounded subtype must be shown to lie within its range, which is simple constant float arithmetic for the provers.

## Language surface recorded by this assessment

Floating point, floating-point images, arrays, for loops, block statements, generics and functions.

## External effects

- **console output** (allowed): Prints the product from each multiplier and inverse pair, which should show as one.

Assessed on 2026-10-15 against page revision 414212 of the [task](https://rosettacode.org/wiki/First-class_functions/Use_numbers_analogously) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
