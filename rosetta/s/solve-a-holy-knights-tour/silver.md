# Solve a Holy Knight's tour

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared 1..8 coordinate types, a fixed 64-entry stack and guards placed before each board access, and iterative backtracking in a procedure avoids both recursion and variants, though many loop-carried values need careful guarding.

Position 1194 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed the 8x8 example as a constant array of small integers (blocked, free, start) and copy it into a visited-step board; run a complete depth-first search with an explicit fixed-size stack of (square, next-move-index) entries in a while loop inside a procedure, trying the eight knight offsets with bounds and free-square guards. On finding a tour of all free squares, print the board row by row into fixed-width text lines with Put_Line, and print a specified "no tour" message if the stack empties. About 130 lines.

## Proof obligations to watch

- **index**: Candidate squares come from adding knight offsets to loop-carried coordinates, so each candidate is range-checked against the 1..8 board bounds by an explicit guard immediately before indexing the board.
- **index**: The explicit backtracking stack is indexed by a depth counter that changes in a while loop, so the loop guards depth against the stack bounds and the 64-square capacity before each push or pop.
- **overflow**: Step numbers and move counters are held in small declared ranges and incremented only after a guard shows they are below their upper bound, so no loop-carried overflow arises.
- **termination**: The search loop is a while loop inside a procedure, which gets no termination check, so the proof does not require a variant.
- **length**: Rendering each board row into a fixed-width text buffer needs computed offsets and integer images, which are discharged by fixed cell widths and guards on buffer position.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, enumerations, arrays, multidimensional arrays, string building, 'Image of scalars, case statements, for loops, while loops, procedures, Put without a newline and characters.

## External effects

- **console output** (allowed): The program prints the start configuration and the solved tour grid with Put_Line.

Assessed on 2026-10-15 against page revision 414479 of the [task](https://rosettacode.org/wiki/Solve_a_Holy_Knight's_tour) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
