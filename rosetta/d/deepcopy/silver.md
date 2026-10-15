# Deepcopy

**Candidate: proofs likely to discharge automatically.** Ada array and record assignment is already a deep copy, and index-based links keep cycles without access types. Every check follows from ranged index subtypes and static bounds, so proof should discharge without annotations.

Position 1165 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The program models a heterogeneous, cyclic graph as a fixed array of node records. Each record holds a kind enumeration, an integer value, a fixed-length label and a Next link typed as a ranged node index, with the links forming a cycle 1->2->3->1. Assigning the whole array gives a deep copy. The program then changes the copy and prints both versions with 'Image, following each cycle a fixed number of times in a for loop to show that the copy has the same shape but separate data. It also prints a note that the method is limited to cycles expressed as indices rather than pointers. About 60 lines.

## Proof obligations to watch

- **index**: Cycle links are stored as a Node_Index subtype over the array's own bounds, so following a link with a fixed-count for loop always indexes within range.

## Language surface beyond today's Silver

Integers, ranged subtypes, enumerations, arrays, records, 'Image of scalars and for loops.

## External effects

- **console output** (allowed): Prints the original and copied structures before and after changing the copy, plus a note on the method's limitations.

Assessed on 2026-10-15 against page revision 413169 of the [task](https://rosettacode.org/wiki/Deepcopy) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
