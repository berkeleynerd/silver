# A\* search algorithm

**Candidate: proofs plausibly discharge automatically.** Every array index and cost sum can be bounded by subtypes and explicit guards, and the only unbounded loops live in procedures, so no annotation is needed, but many loop-carried values need careful guards.

Position 843 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

The 8x8 grid is a two-dimensional array of cell costs (1 or 100) with parallel arrays for g-score, f-score, parent row and column, and open/closed flags, all with 0..7 index subtypes. A procedure runs the A* loop: it picks the open cell with the least f by a for-loop scan, relaxes the eight neighbors after bounds guards, and stops when the goal is closed or no cell is open. The route is rebuilt backwards into a fixed 64-entry array, then printed as a text grid with X marks, the coordinate sequence and the total cost. About 170 lines.

## Proof obligations to watch

- **index**: Neighbor coordinates are computed from loop-carried positions, so each is guarded by a 0..7 bounds test before indexing the 8x8 cost and state arrays.
- **overflow**: Path costs accumulate in loops, but with a 64-cell grid and a cost of at most 100 per move, a subtype such as 0..100000 plus a guard before each addition keeps sums bounded.
- **termination**: The open-set loop is a while loop inside a procedure, which gets no termination check, and its work is bounded by an explicit iteration cap that produces a visible 'path not found' outcome.
- **index**: Open-list size and path reconstruction by parent links are loop-carried, so the open list is a fixed 64-cell array scanned with for loops, and the path walk is a capped loop that guards each parent index and path length before use.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string building, 'Image of scalars, for loops, while loops, procedures, functions, Put without a newline and case statements.

## External effects

- **console output** (allowed): Prints the text-art grid, the route coordinates and the total cost.

Assessed on 2026-10-15 against page revision 414922 of the [task](https://rosettacode.org/wiki/A%2A_search_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
