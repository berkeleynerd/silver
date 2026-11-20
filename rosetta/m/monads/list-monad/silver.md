# Monads/List monad

**Candidate: proofs likely to discharge automatically.** All values are small ranged integers and every loop is a for loop over a constant range, so overflow, index and range checks follow from types and the capacity guard.

Position 94 in the [progression](../../../progression.md#stage-3), in stage 3.

## Approach

A fixed-capacity list is a constrained array of a small ranged integer subtype with an element count, holding the embedded input 3, 4, 5. Bind is a procedure that for-loops over the input elements, applies the increment step and then the doubling step, and writes each result into an output array, with a guard that the count stays within capacity. The result is printed with Put calls for brackets, separators and each value's image. About 35 lines.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints the resulting list such as [8, 10, 12] to standard output.

Assessed on 2026-10-15 against page revision 414345 of the [task](https://rosettacode.org/wiki/Monads/List_monad) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
