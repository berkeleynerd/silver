# Fibonacci heap

**Candidate: proofs plausibly discharge automatically.** Index-based linked structures in a fixed pool keep every check within subtype ranges and null guards, and iterative cascading cut and consolidation avoid recursion, though rank and degree-table bounds need careful guards with a rejecting outcome and a fixed pool capacity.

Position 640 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Nodes live in a fixed-capacity pool of parallel arrays or a record array (key, parent, child, left, right, rank, mark, in-use) addressed by a 0..N index subtype with 0 as null, so pointer-style circular doubly-linked lists need no access types. Insert, Union (list splice with a new-pool-slot discipline, rejecting when capacity would be exceeded), Minimum, ExtractMin with a degree-table consolidation loop, DecreaseKey with cut and cascading cut as an iterative while loop, and Delete (decrease to the minimum key then ExtractMin) are procedures with explicit guards; the demo embeds the example data and prints the forest with an iterative indented dump. About 260 lines.

## Proof obligations to watch

- **index**: All links are a subtype 0..Capacity (0 meaning null) and every dereference is guarded by a non-null test, so array index checks follow from the subtype range.
- **range**: Rank increments during consolidation and child-count updates need an explicit guard against the degree-table bound with a visible Reject outcome, since only an invariant could show the rank stays below log of the node count.
- **overflow**: Keys are a bounded integer subtype and DecreaseKey only compares and assigns, so no arithmetic can overflow, and node-count arithmetic is capped by the fixed capacity.
- **termination**: Circular-list walks and consolidation loops are written as while loops inside procedures (no termination check), or as for loops bounded by the node capacity, with no recursion.
- **initialization**: The node pool and degree table are fully initialized by whole-array aggregates or initialization loops before use, and out parameters are assigned on every path.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, arrays, records, for loops, while loops, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The demo prints each heap operation's result and a text rendering of the heap forest.

Assessed on 2026-10-15 against page revision 413484 of the [task](https://rosettacode.org/wiki/Fibonacci_heap) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
