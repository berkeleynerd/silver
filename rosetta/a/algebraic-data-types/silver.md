# Algebraic data types

**Candidate: proofs plausibly discharge automatically.** Recursion and pointers in the original are replaceable by an index-based array tree with an explicit bounded path stack, so every check follows from ranged link types and guards placed before pushes and allocation, though the rebalancing loops need careful shape.

Position 1184 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

Represent the tree as a fixed-capacity array of node records (color enumeration, value, left and right links as a ranged subtype where 0 is the shared empty node) plus a node count. Insertion is an iterative procedure that descends from the root recording the path in a bounded stack, attaches a red leaf, then walks back up applying the four Okasaki balance cases as rotations and recolors, and finally blackens the root; the example inserts 1 to 16 and prints the tree with an explicit-stack reverse in-order traversal using indentation. About 150 lines.

## Proof obligations to watch

- **index**: Node links are a ranged subtype 0..Capacity with 0 as the shared empty node, so array accesses on loop-carried links are safe by type, and a full pool is checked by a guard that rejects the insert.
- **index**: The root-to-node path stack used for iterative rebalancing has fixed depth, so each push is guarded by a depth check that rejects the insertion visibly rather than altering the tree.
- **overflow**: Indentation widths and value arithmetic stay in bounded ranges, with value comparisons needing no arithmetic.
- **termination**: The descent and rebalance loops are while loops inside a procedure, which gets no termination check.
- **length**: The indented output line buffer has a fixed length and a guard on depth before building each line.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, enumerations, arrays, records, for loops, while loops, procedures, case statements, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the resulting red-black tree as indented text lines.

Assessed on 2026-10-15 against page revision 412642 of the [task](https://rosettacode.org/wiki/Algebraic_data_types) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
