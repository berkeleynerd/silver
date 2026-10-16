# Common list elements

**Candidate: proofs likely to discharge automatically.** Every index comes from for-loop ranges over the arrays themselves and the single loop-carried counter is bounded by its subtype and a guard, so all checks discharge without annotations. No while loops, recursion or functions with loops are needed.

Position 91 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

The three example lists are constant Integer arrays embedded in the program, and the result is a fixed-capacity array of 8 with a Count of type 0 .. 8. Nested for loops over each array's own range test whether each element of the first list appears in the second and third using Boolean flags set inside the inner loops. Matches are appended under a capacity guard, and the output is built with Put and the integer image, with commas between elements (the matches come out in first-list order as 3, 9, 6, which is the same set as the example's [3,6,9]). About 45 lines.

## Proof obligations to watch

- **index**: The result counter is a loop-carried value, so the program guards each append with a test of Count against the array capacity (8, equal to the length of the first list) just before the indexed store.
- **range**: Count is declared with a subtype 0 .. 8 and incremented only inside that guard, so the increment's range check follows from the guard and the type.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, 'Image of scalars, string building, Put without a newline and procedures.

## External effects

- **console output** (allowed): Prints the common elements as a bracketed list on standard output.

Assessed on 2026-10-15 against page revision 406865 of the [task](https://rosettacode.org/wiki/Common_list_elements) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
