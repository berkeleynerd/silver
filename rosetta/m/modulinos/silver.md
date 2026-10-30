# Modulinos

**Candidate: proofs likely to discharge automatically.** Ada already separates a reusable library package from the main subprogram chosen at bind time, so the modulino idea needs no introspection of the script name; the program has only a constant-returning function and one image conversion, so every check is trivial.

Position 1456 in the [progression](../../progression.md#stage-27), in stage 27.

## Approach

A library package Life declares a function Meaning_Of_Life that returns the Integer constant 42, so other programs can with the package without running anything. A separate parameterless Main procedure, which the binder picks as the entry point only when this program is built to run directly, calls the function and prints the result with Silver_IO.Put_Line and Integer'Image. There are no loops, guards or input to validate. About 20 lines.

## Language surface recorded by this assessment

Packages, functions, integers and 'Image of scalars.

## External effects

- **console output** (allowed): The main procedure prints the line produced from the library function's result, for example "Main: The meaning of life is 42".

Assessed on 2026-10-15 against page revision 405829 of the [task](https://rosettacode.org/wiki/Modulinos) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
