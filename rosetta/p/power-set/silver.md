# Power set

**Candidate: proofs likely to discharge automatically.** All loops are for loops over static ranges, the mask copy stays within 0..15 by its subtype and division by the literal 2 cannot fail, so every check follows from types and bounds. Output is by Put and Put_Line in the Main procedure, so no function termination or contract is needed.

Position 488 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The set {1,2,3,4} is an embedded constant String "1234", and an outer for loop counts a ranged subtype 0..15 as a bitmask over the subsets. For each mask an inner for loop over the String's own index range tests the current bit with mod 2, prints the element with a comma separator when a Boolean first flag says so, and halves a local copy of the mask. The empty set is printed as {} for mask 0, which also covers the extra-credit edge case of an empty subset. About 30 lines.

## Language surface beyond today's Silver

Ranged subtypes, integers, integer division, Boolean objects, string indexing, for loops and Put without a newline.

## External effects

- **console output** (allowed): Each subset is printed as a braced list on one line.

Assessed on 2026-10-15 against page revision 414662 of the [task](https://rosettacode.org/wiki/Power_set) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
