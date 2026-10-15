# Function composition

**Candidate: proofs likely to discharge automatically.** In Ada, composing functions with generic formal subprograms needs no closures or access values, and GNATprove analyzes each instance with checks that follow from the declared ranges, so every check should discharge without annotations. The functions are non-recursive and use only for loops, so the termination checks are trivial.

Position 1523 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

A generic function Compose takes formal types A, B and C and formal functions G : A -> B and F : B -> C, and its body returns F (G (X)), so each instantiation (for example `function Double_Then_Increment is new Compose (...)`) is the composed function as a new named function. Main instantiates it with two simple integer functions over declared ranges, then uses a for loop over a small static range to print each argument and its composed result with 'Image. There are no guards because the ranges keep every intermediate value in its type. About 35 lines.

## Proof obligations to watch

- **overflow**: The sample functions (for example G(X) = 2 * X and F(Y) = Y + 1) take arguments of declared range types chosen so each result type's range statically contains every possible result, so the arithmetic checks discharge from the types alone.

## Language surface beyond today's Silver

Integers, ranged subtypes, functions, generics, 'Image of scalars and for loops.

## External effects

- **console output** (allowed): The program prints the result of applying the composed function to sample arguments with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 412810 of the [task](https://rosettacode.org/wiki/Function_composition) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
