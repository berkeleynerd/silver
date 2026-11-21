# Higher-order functions

**Candidate: proofs likely to discharge automatically.** The program has no loops, recursion or heap use, and its only arithmetic is a multiplication that the parameter's declared range bounds, so every check follows from types and should discharge automatically. One open question is whether a generic formal subprogram counts as faithfully passing a function as an argument. If a run-time access-to-subprogram value is required instead, SPARK still supports that without annotations, but access-types would join the surface.

Position 1514 in the [progression](../../progression.md#stage-30), in stage 30.

## Approach

Main declares a small ranged subtype, a plain function Square over it, and a generic function Apply whose formal parameter is a function (with function F (X : Small) return Integer), so the function is passed as an argument at instantiation, not through an access value. Main instantiates Apply with Square, calls the instance on embedded constants, and prints the results with 'Image; there are no loops and no guards beyond the declared ranges. About 25 lines.

## Proof obligations to watch

- **overflow**: The passed function (for example Square) takes a parameter of a declared subtype such as range -1000 .. 1000, so its product is bounded by the types and cannot overflow Integer.

## Language surface recorded by this assessment

Integers, ranged subtypes, functions, generics and 'Image of scalars.

## External effects

- **console output** (allowed): Prints the result of calling the passed-in function through the higher-order function with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 415543 of the [task](https://rosettacode.org/wiki/Higher-order_functions) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
