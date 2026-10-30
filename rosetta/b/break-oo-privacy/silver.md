# Break OO privacy

**Candidate: proofs likely to discharge automatically.** The child-package "friend" mechanism is ordinary Ada that bypasses privacy without reflection or unchecked conversion, and every check is a static fixed-length String operation, so proofs discharge trivially.

Position 1457 in the [progression](../../progression.md#stage-27), in stage 27.

## Approach

A package declares a private record type holding a fixed-length 8-character String password with a default value, and a child package of it exposes a non-dispatching function returning that password through the parent's private view. Main declares an object, calls the child function, and prints the result inside quotes using bounded concatenation. There are no loops, no tagged types, no unchecked conversion and no input. About 35 lines.

## Language surface recorded by this assessment

Packages, records, functions and ranged subtypes.

## External effects

- **console output** (allowed): Prints the recovered password with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413152 of the [task](https://rosettacode.org/wiki/Break_OO_privacy) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
