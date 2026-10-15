# I'm a software engineer, get me out of here

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded index subtypes, for loops and explicit range guards, with no recursion or function loops, but the loop-carried distances, bounded route-string building and nonlinear jump arithmetic need careful program shape.

Position 869 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

The map is embedded as 23 String constants decoded into a 0..22 by 0..22 array of digit subtype 0..9 (outside-disc cells marked blocked), with all-pairs data in distance and next-hop arrays over cell indices. Part 1 runs a unit-cost breadth-first search (Dijkstra with equal weights) from HQ in a procedure using a fixed ring queue and predecessor array, printing all shortest routes to zero cells; Part 2 runs a triple for-loop Floyd with a sentinel Infinity and saturation guard, then reconstructs routes with a bounded while loop and finds the longest shortest route and unreachable or farthest cells by scans. About 260 lines.

## Proof obligations to watch

- **overflow**: Floyd relaxation sums two distances held in a subtype capped at an Infinity sentinel and only relaxes when both are below it, so the sum fits in Integer and any improved value is below the cap.
- **index**: Cell lookups use row and column subtypes 0..22, with explicit guards that x + n*dx and y + n*dy lie in 0..22 before indexing, which is nonlinear but bounded by the digit range 0..9.
- **termination**: Dijkstra with unit steps is done as a breadth-first search in a procedure over a fixed-capacity queue sized to the 529 cells, and path reconstruction follows predecessors with a step counter capped at the cell count, so no loop needs a variant.
- **range**: The Floyd triple loop (about 12 million iterations over 23x23 cells squared) is for loops over array index ranges with loop-carried distance and next-hop arrays whose element subtypes keep every store in range.
- **length**: Route text is built in a bounded buffer sized for the longest route, with a guard before each append that rejects or truncates visibly when capacity would be exceeded.
- **initialization**: All distance, predecessor and next-hop arrays are filled by aggregate or full for loops before use, so flow analysis can see them initialized.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the shortest routes, the Floyd routes, the longest shortest route and the unreachable and farthest cells.

Assessed on 2026-10-15 against page revision 414000 of the [task](https://rosettacode.org/wiki/I'm_a_software_engineer,_get_me_out_of_here) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
