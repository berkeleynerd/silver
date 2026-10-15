# Topological sort

**Candidate: proofs likely to discharge automatically.** All data is embedded and the graph is tiny and fixed, so every index and range check follows from loop ranges over the arrays and a guard on the placed count, and no recursion or while loop is required.

Position 807 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The 15 library names (including ieee and std, which appear only as dependencies) are node indices of a ranged subtype, with a case-statement procedure printing each name and a Boolean matrix of dependencies filled by an Add_Dep procedure with self-dependencies skipped. A Kahn-style procedure runs a bounded for loop of passes, each scanning for-loop over nodes for an unplaced node whose dependencies are all placed, appending it to a fixed-size order array only when the count is below capacity; if a pass places nothing it reports the graph as un-orderable. The main procedure sorts the given data and prints the order with Put, then adds dw04 to dw01's dependencies and prints the cycle message. About 130 lines.

## Proof obligations to watch

- **index**: The placed-count is a range-typed loop-carried value, so the program guards that it is below the node count before writing the next order slot.
- **initialization**: Order, Placed and the dependency matrix are fully initialized by aggregates (others => False or 0) before any read.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, case statements, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The compile order, or a message that the dependencies are un-orderable, is printed to standard output.

Assessed on 2026-10-15 against page revision 414550 of the [task](https://rosettacode.org/wiki/Topological_sort) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
