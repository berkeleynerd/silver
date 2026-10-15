# Functional coverage tree

**Candidate: proofs plausibly discharge automatically.** Everything is bounded for-loop work over fixed arrays with ranged integers and no recursion, so checks follow from types and a single division guard, but string building and nonlinear weighted sums need careful range shaping.

Position 640 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Store the tree in preorder as parallel constant arrays of padded fixed-length names, depth, parent index, weight (default 1) and leaf coverage scaled to millionths, with fixed-point scaled integers instead of floating point. A reverse for loop over nodes computes each parent's weighted average from accumulated weighted sums, guarding a zero weight sum, and a forward for loop builds each output line in a bounded buffer with indentation, weight and a six-digit decimal coverage before Put_Line. The delta extra credit is omitted as optional. About 170 lines.

## Proof obligations to watch

- **overflow**: Weighted sums of scaled integer coverage times weight are bounded by declared ranges (coverage 0..1_000_000, weight 0..100, under 64 nodes) so no overflow follows from types alone.
- **division**: The weighted average divides by the sum of child weights, so a guard on a nonzero sum precedes the division and a zero sum keeps the leaf coverage.
- **index**: Parent indexes are a ranged subtype of node numbers and bottom-up accumulation runs a reverse for loop over the array's own range, but each parent must be guarded to precede its child.
- **length**: Output lines are built in a fixed-capacity buffer with a position guarded before each character write, and indentation depth is bounded by a declared range.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, arrays, records, for loops, procedures, string indexing, string building, 'Image of scalars, characters and Put without a newline.

## External effects

- **console output** (allowed): The program prints the indented hierarchy with weight and coverage columns and the top-level coverage.

Assessed on 2026-10-15 against page revision 414226 of the [task](https://rosettacode.org/wiki/Functional_coverage_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
