# Real constants and functions

**Candidate: proofs plausibly discharge automatically.** The program is straight-line code calling SPARK-annotated Ada.Numerics.Elementary_Functions on literal in-domain arguments, so no loop-carried facts are needed; the only uncertainty is floating-point finiteness checks and whether the admitted library exposes the Ada.Numerics functions and Float'Image.

Position 1042 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

A parameterless Main procedure declares Float constants (Ada.Numerics.Pi, Ada.Numerics.e, and literal test values) and prints, one per line, a label plus the Float'Image of Pi, e, Sqrt, Log, Exp, abs, Float'Floor, Float'Ceiling and the ** power, all with embedded literal arguments. There are no loops or recursion; every domain precondition (non-negative sqrt argument, positive log argument, non-negative base for **) is met statically by the literals. About 30 lines.

## Proof obligations to watch

- **floating point**: Sqrt, Log, Exp and ** carry domain preconditions and finite-result checks, which the program discharges by calling them only on literal arguments inside their domains (for example Sqrt (2.0), Log (10.0), Exp (1.0), 2.0 ** 10.0).
- **range**: Floor and Ceiling results are shown as floats via Float'Floor and Float'Ceiling, avoiding any Float-to-Integer conversion range check.
- **length**: Concatenating a label with Float'Image results into Put_Line needs the bounded image length known to the prover, so each image is printed with a short label in a separate Put_Line or in a bounded buffer.

## Language surface recorded by this assessment

Floating point, floating-point images, 'Image of scalars, ranged subtypes, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each constant and function result as a line of text.

Assessed on 2026-10-15 against page revision 414436 of the [task](https://rosettacode.org/wiki/Real_constants_and_functions) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
