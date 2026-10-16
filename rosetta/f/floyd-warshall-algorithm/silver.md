# Floyd-Warshall algorithm

**Candidate: proofs plausibly discharge automatically.** Everything is integer arithmetic over bounded ranges in fixed-size arrays with for loops, so overflow, range and index checks follow from types and sentinel guards placed just before each use, though the loop-carried distances need carefully shaped guards. Floating-point infinity from the existing solution is replaced by a finite integer sentinel, which keeps the task faithful because the example weights are integers.

Position 719 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the 4-vertex example as a constant edge table loaded into a 2D Distance array (subtype range with a large finite sentinel for no edge) and a 2D Next array of vertex indices with 0 as nil; run triple for loops over the vertex range, skipping the update when either leg is the sentinel and rejecting if a sum falls below the lower bound. Print each ordered pair with its distance via Integer'Image and reconstruct the path by following Next in a bounded loop with a nil guard, using Put for pieces and Put_Line for line ends. About 110 lines.

## Proof obligations to watch

- **overflow**: Integer weights use a bounded Distance subtype with a large finite sentinel for no edge, and the sum of two entries is computed only when neither is the sentinel, so the sum is bounded by the type ranges.
- **range**: A sum below the Distance lower bound (possible only with a negative cycle, which the task lets us assume away) is detected by an explicit guard that rejects, since the provers cannot know the absence of negative cycles.
- **index**: Next-hop lookups during path printing are guarded by a nonzero check and a step counter bounded by the vertex count, because the loop-carried vertex has only its type range as a fact.
- **length**: Output lines are assembled from fixed-width digit strings and ' -> ' pieces, or printed piecewise with Put, so no computed-length buffer can overflow.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the pair, distance and path table lines to standard output.

Assessed on 2026-10-15 against page revision 415485 of the [task](https://rosettacode.org/wiki/Floyd-Warshall_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
