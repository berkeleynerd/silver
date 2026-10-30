# Cut a rectangle

**Candidate: proofs plausibly discharge automatically.** The task is a bounded backtracking count that converts to an iterative procedure with fixed arrays, so all checks follow from ranged types and guards just before each access, though loop-carried indexes and the counter need careful guards. No annotation is required and the only effect is console output.

Position 828 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Embed a fixed list of rectangle sizes up to 10x10 and, for each, run an iterative self-avoiding-path depth-first search from the center point to the boundary using a visited grid (with its 180-degree mirror marked) and an explicit stack of position and next-direction arrays. Each boundary hit adds to a bounded counter, the symmetric-case rules (odd sides, width 1 or 2, square doubling, transposed pass) are plain if statements, and results are printed with 'Image. Every grid and stack access is preceded by a coordinate or capacity guard. About 130 lines.

## Proof obligations to watch

- **index**: Grid and stack indexes are loop-carried, so each neighbor step is guarded by an explicit coordinate bounds test and each push by a stack-capacity test just before the access, with overflow of the stack rejected visibly.
- **overflow**: The cut counter is a loop-carried accumulator that is incremented in a loop, so it uses a 64-bit range type and a guard against its documented limit, with a visible rejection when exceeded.
- **termination**: The depth-first search runs as a while loop inside a procedure, which gets no termination check, and no function contains a loop.
- **stack**: The recursive search is replaced by an explicit fixed-capacity stack sized to the grid cell count, so no recursion depth depends on input.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, multidimensional arrays, records, for loops, while loops, procedures, functions, case statements, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the number of cuts for each rectangle size to standard output.

Assessed on 2026-10-15 against page revision 414143 of the [task](https://rosettacode.org/wiki/Cut_a_rectangle) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
