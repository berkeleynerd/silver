# Apply a callback to an array

**Candidate: proofs likely to discharge automatically.** All checks follow from the declared element range and for-loop indexes over the array's own range, so the squares cannot overflow and no annotation is needed.

Position 73 in the [progression](../../progression.md#stage-4), in stage 4.

## Approach

Declare a ranged integer subtype and a constrained array type of 10 elements, embed the sample data as an aggregate, and use a procedure Apply_Square that loops over the array's own range, squaring each element into a second array or printing it via a nested Display procedure called directly (no access-to-subprogram callback, a named procedure standing in for the callback). Each result is printed with Put_Line of a bounded concatenation of "array(" , the index image, ") = " and the value image. About 30 lines.

## Proof obligations to watch

- **overflow**: Squaring is safe because the element subtype is declared as a small range (e.g. -1000 .. 1000) so the product fits in Integer.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, 'Image of scalars, Put without a newline, procedures and string building.

## External effects

- **console output** (allowed): Prints each squared array element as text.

Assessed on 2026-10-15 against page revision 411495 of the [task](https://rosettacode.org/wiki/Apply_a_callback_to_an_array) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
