# Polymorphism

**Candidate: proofs likely to discharge automatically.** Each operation only copies Integer fields and prints them with 'Image, with no arithmetic, indexing or loops, so every check is trivial. The only new ground is SPARK's support for tagged types and dispatching, which proves without annotations.

Position 1549 in the [progression](../../progression.md#stage-33), in stage 33.

## Approach

A package declares a tagged private record Point with Integer components X and Y that default to 0, along with Create functions for every default form, accessor and setter functions, and a primitive Print procedure. A child package or the same package derives Circle from Point, adding R, and overrides Print, Create and the accessors. Copy construction and assignment are Ada's predefined record assignment, and destruction is the implicit end of scope. Main builds objects with literal values and calls a class-wide Show (Item : Point'Class) procedure, which dispatches to Print, so there is no arithmetic and no guard is needed. About 110 lines.

## Language surface recorded by this assessment

Integers, records, tagged types, packages, procedures, functions and 'Image of scalars.

## External effects

- **console output** (allowed): Each Print operation writes a line describing the Point or Circle and its coordinates to standard output.

Assessed on 2026-10-15 against page revision 414408 of the [task](https://rosettacode.org/wiki/Polymorphism) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
