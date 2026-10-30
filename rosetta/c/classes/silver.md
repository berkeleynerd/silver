# Classes

**Candidate: proofs likely to discharge automatically.** The task needs only a record, a function, a procedure and a bounded integer, all of which are checked from declared ranges and one guard before the multiplication. No loops, recursion or annotations are involved.

Position 577 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

A record type with one component of a bounded integer subtype defaulting to -12 serves as the class, with a Set function as the conversion constructor and a Double procedure as the method. Main declares a default instance, doubles it, replaces it with Set (2007), and prints each state with scalar image text. Double guards the component against half the subtype range and prints a visible rejection otherwise. About 45 lines.

## Proof obligations to watch

- **overflow**: Doubling the component is preceded by an explicit range guard that rejects out-of-range values with a printed message, so the multiplication and the subtype range check discharge.

## Language surface recorded by this assessment

Integers, ranged subtypes, records, procedures, functions, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the instance's value after construction, after doubling and after Set.

Assessed on 2026-10-15 against page revision 412706 of the [task](https://rosettacode.org/wiki/Classes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
