# Singly-linked list/Element removal

**Candidate: proofs likely to discharge automatically.** Every check follows from ranged link and index types and null-link guards placed before each dereference, with bounded for loops and procedures needing no termination proof or invariants. The only new output needs are integer-to-text conversion and building a line from it.

Position 98 in the [progression](../../../progression.md#stage-7), in stage 7.

## Approach

The list is a fixed-capacity array of nodes (Data and Next index, with 0 as the null link) plus Head, Free-slot flags and a Count, all declared with ranged subtypes. Insert (for three embedded values) and Remove are procedures that walk the links with a for loop bounded by the capacity, tracking Prev and Cur and guarding Cur /= 0 before each dereference. Remove unlinks the matching node, marks it free, and reports a visible Found/Not-found outcome (removing the middle and an absent value are both demonstrated), and a Print procedure walks the list with a bounded for loop and emits each value with 'Image. About 70 lines.

## Proof obligations to watch

- **index**: Following a link into the node array is guarded by a Cur /= 0 test just before each access, and the link type's range 0..Capacity makes the converted index valid.
- **range**: Count is decremented only inside the branch where the element was found, so its type range 0..Capacity cannot be violated, and the printing loop is a for loop bounded by Capacity so no loop-carried invariant is needed.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, for loops, procedures, 'Image of scalars and string building.

## External effects

- **console output** (allowed): The program prints the list contents before and after the removal with Put_Line.

Assessed on 2026-10-15 against page revision 410689 of the [task](https://rosettacode.org/wiki/Singly-linked_list/Element_removal) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
