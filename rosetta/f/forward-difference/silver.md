# Forward difference

**Candidate: proofs plausibly discharge automatically.** All loops are for loops over static or subtype-bounded ranges and no recursion or floating point is needed, but because pass-to-pass growth of loop-carried values cannot be bounded without an invariant, each subtraction needs a range guard with a visible rejection outcome, so discharge depends on careful program shape.

Position 915 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Embed the ten sample values in a fixed-capacity array of a wide ranged integer type, and a procedure applies one in-place forward-difference pass over the first Len elements using a for loop, then decrements Len, with the order applied by an outer for loop in the main procedure. A guard before each subtraction rejects results outside the element range, and the order loop stops at an empty list, which is printed as an empty-list message. Results for orders 0, 1, 2, 9 and 10 are printed via a procedure that loops over the live elements writing 'Image text with separators. About 70 lines.

## Proof obligations to watch

- **overflow**: Each pass subtracts loop-carried array elements, so the program declares a 64-bit element type and guards each difference against the element range, printing a specified rejection message rather than altering the result.
- **range**: Storing a difference back into the bounded element type is checked by an explicit guard just before the assignment, since no invariant can bound growth across passes.
- **index**: The inner loop runs over a range derived from the current length minus one, and indexes I and I+1 stay within the fixed-capacity array because the length variable is typed with the array's index range.
- **length**: The current list length is a subtype-bounded variable that decreases by one per pass, with the order-zero and order-exceeds-length cases handled by explicit guards printing the empty list.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, Put without a newline and conditional expressions.

## External effects

- **console output** (allowed): Each resulting difference list is printed to standard output.

Assessed on 2026-10-15 against page revision 411754 of the [task](https://rosettacode.org/wiki/Forward_difference) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
