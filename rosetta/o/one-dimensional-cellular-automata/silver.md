# One-dimensional cellular automata

**Candidate: proofs likely to discharge automatically.** Every index and length is determined by static array bounds and for-loop ranges over them, with Boolean-only cell arithmetic, so all checks follow from types and no annotation or while loop is needed.

Position 509 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Use a constrained Boolean array of 20 cells initialised from the task's example aggregate, with a Step procedure that copies the old generation into a second array and computes each new cell from its left and right neighbours (off-end cells treated as dead via explicit boundary cases for the first and last cell). A for loop over generations 0..9 builds each output line in a fixed-length String buffer (prefix, generation digit, then '#' or '_' per cell) and prints it, then calls Step. All loops are for loops over static ranges, so no loop-carried value needs an invariant. About 45 lines.

## Proof obligations to watch

- **index**: Neighbour access Culture(I+1) and Culture(I-1) is guarded by looping I over 2..19 and handling cells 1 and 20 separately, so all indexes are statically within 1..20.
- **length**: The output line buffer has fixed length sized for the 'Generation N ' prefix plus 20 cells, and each slice assignment uses constant-bounded indexes so lengths match.

## Language surface recorded by this assessment

Boolean objects, characters, ranged subtypes, arrays, for loops, procedures, 'Image of scalars, string building, string indexing, integers and Put without a newline.

## External effects

- **console output** (allowed): Prints ten generation lines of the automaton to standard output.

Assessed on 2026-10-15 against page revision 414900 of the [task](https://rosettacode.org/wiki/One-dimensional_cellular_automata) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
