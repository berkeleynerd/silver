# Function definition

**Candidate: proofs likely to discharge automatically.** A single non-recursive function over bounded ranged types has a product check that follows from declared ranges alone, so proof is routine; the only new surface is functions, ranged types and integer image output.

Position 293 in the [progression](../../progression.md#stage-8), in stage 8, which adds functions.

## Approach

Declare a small input subtype and a wider result range type, define a function Multiply (A, B : Input) return Result as A * B using a conversion, and call it from Main on embedded constants. Main prints the result through Silver_IO.Put_Line using integer 'Image. No loops or recursion are involved, and the type bounds make the overflow check static. About 22 lines.

## Proof obligations to watch

- **overflow**: The Multiply function takes arguments of a small ranged subtype (for example -1000 .. 1000) and returns a wider ranged type, so the product provably fits without any guard.

## Language surface recorded by this assessment

Integers, ranged subtypes, functions, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the product of example arguments to show the function's result.

Assessed on 2026-10-15 against page revision 415026 of the [task](https://rosettacode.org/wiki/Function_definition) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
