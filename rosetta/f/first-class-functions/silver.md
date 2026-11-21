# First-class functions

**Candidate: proofs plausibly discharge automatically.** Every numeric check follows from guards placed just before Arcsin, Arccos, \"**\" and the cube, and from the elementary-function postconditions. The outlook is plausible rather than likely because the program relies on SPARK's access-to-subprogram and generic-instantiation support, with float guards in every wrapper.

Position 1564 in the [progression](../../progression.md#stage-36), in stage 36.

## Approach

Each \"function of a real\" is a not-null access-to-function from Float to a (Valid, Value) result record. Two constant arrays hold Sin/Cos/Cube wrappers (A) and guarded Arcsin/Arccos/cube-root wrappers (B), with the built-in Elementary_Functions doing the trig work. A for loop over the array range instantiates a generic Compose with A(I) and B(I) inside a declare block, applies the new function to 0.5 and prints the result and its error, or a rejection message if a stage reports Valid = False. About 85 lines.

## Proof obligations to watch

- **other**: Storing Arcsin, Arccos and the cube root behind a not-null access-to-function type with no Pre needs user-defined wrapper functions, because the library preconditions on Arcsin, Arccos and "**" cannot be implied by an unannotated access type. Each wrapper checks its argument's domain and returns a (Valid, Value) record, so an out-of-domain argument gives a visible rejection.
- **floating point**: Cube overflow is discharged by a guard (abs X <= 1.0E10, else Valid = False), and the difference abs (Result - X) is safe because every Value is bounded by the library postconditions or the guard.
- **range**: The cube root calls "**" (Left, 1.0/3.0) only on a strictly positive Left, handling zero and negative values in separate if branches, so its library precondition holds.
- **termination**: The generic Compose function calls F and G through access values, and its termination check relies on GNATprove treating the loop-free, non-recursive designated functions as terminating.

## Language surface recorded by this assessment

Floating point, floating-point images, records, Boolean objects, functions, access types, generics, arrays, for loops, block statements and 'Image of scalars.

## External effects

- **console output** (allowed): Prints, for each function pair, the test value, the composed result and its difference from the original.

Assessed on 2026-10-15 against page revision 414945 of the [task](https://rosettacode.org/wiki/First-class_functions) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
