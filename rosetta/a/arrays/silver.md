# Arrays

**Candidate: proofs likely to discharge automatically.** Every index is a constant in range or a for-loop index over the array's own range, and the push is guarded by an explicit capacity check with a visible outcome, so all checks follow from types and guards.

Position 1159 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The program declares a fixed-length Integer array 1..10, assigns it with an aggregate (others => 0) and individual elements, retrieves elements by constant indices and by a for loop over the array's own range, and prints them with Put_Line and 'Image. A second small fixed-capacity array with a Count variable shows push by guarding Count against the capacity, printing a visible rejection message when full. Values are kept small (Integer subtype ranges) so sums cannot overflow. About 45 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, enumerations, arrays, for loops, 'Image of scalars, Put without a newline, Boolean objects and procedures.

## External effects

- **console output** (allowed): Prints retrieved array elements and the sum to show the arrays work.

Assessed on 2026-10-15 against page revision 411498 of the [task](https://rosettacode.org/wiki/Arrays) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
