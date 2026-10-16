# Monads/Maybe monad

**Candidate: proofs likely to discharge automatically.** The task is a simple bind/unit composition over a small bounded integer record applied to four embedded values, so every check follows from subtype ranges and a Valid-flag guard before each operation.

Position 604 in the [progression](../../../progression.md#stage-12), in stage 12.

## Approach

Define a record Maybe_Int (Valid : Boolean; Value : Small_Int) with Unit and a Bind function that takes the Maybe plus a named step function and applies it only when Valid; because Ada has no closures, Bind is realised through a small Step enumeration or a case dispatch in a function without function pointers. Two steps, Decrement (valid only when Value is above zero) and Triple (bounded by the subtype), are composed via Bind over an embedded array of inputs 3, 4, 0, 5, and a for loop prints each input and result, with "none" for an invalid Maybe, using bounded string building from 'Image. About 70 lines.

## Proof obligations to watch

- **overflow**: Triple multiplies by 3 and Decrement subtracts 1, so the Integer ranges of the embedded values are bounded by a declared subtype and discharge from types alone.
- **discriminant**: Maybe is a plain record with a Boolean Valid flag and a bounded value, avoiding discriminants, so no discriminant check arises.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, records, arrays, for loops, functions, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each input value and its composed result line.

Assessed on 2026-10-15 against page revision 414805 of the [task](https://rosettacode.org/wiki/Monads/Maybe_monad) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
