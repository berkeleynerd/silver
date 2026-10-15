# Langton's ant

**Candidate: proofs likely to discharge automatically.** All checks follow from declared subtypes, the array's own index ranges and a bounds guard before each move, and the task's exception-based exit is replaced by an explicit guard, so no annotation is needed.

Position 773 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Keep a 100x100 Boolean array, ant X and Y in a 1..100 subtype, and a heading in a 0..3 subtype, with fixed dx and dy chosen by a case statement. A while loop in the Main procedure flips the cell, turns left or right by wrapping the heading with explicit if guards, computes the next position in Integer, and exits with a visible outcome when it falls outside 1..100. Afterwards a for loop over each row fills a 100-character String buffer with ' ' or '#' by index and prints it with Silver_IO.Put_Line. About 60 lines.

## Proof obligations to watch

- **index**: Ant coordinates are declared in 1..100 and the next position is computed in a wider Integer and tested against 1..100 before assignment, so every grid access is within bounds and leaving the region ends the loop as the task specifies.
- **termination**: The ant loop is a while loop in the Main procedure, which gets no termination check, so no variant is required, although halting rests on the known behavior of the automaton rather than on a proof.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, for loops, while loops and case statements.

## External effects

- **console output** (allowed): The final 100x100 grid is printed as 100 text rows with Put_Line.

Assessed on 2026-10-15 against page revision 414964 of the [task](https://rosettacode.org/wiki/Langton's_ant) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
