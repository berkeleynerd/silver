# Pythagoras tree

**Candidate: proofs plausibly discharge automatically.** The task needs only integer vector arithmetic over a fixed binary tree of 255 squares, which can be built iteratively into an array and output as text or a character grid, so proofs depend on bounded coordinate ranges and index guards rather than annotations. The original SDL window and recursion are replaced by text output and an iterative loop.

Position 615 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Use integer coordinates (base square side 128 times a scale) and store each square as a record of its base-edge vector in a fixed array of 255 entries filled level by level in a procedure, computing children with the vector formulas from the task (apex M from the edge vector, no trigonometry). Then render the squares' outlines as text lines of integer coordinates, or rasterize onto a bounded character grid, using for loops with guards on each coordinate before indexing or printing. About 90 lines.

## Proof obligations to watch

- **overflow**: Coordinates are integers in a declared range that stays bounded at depth 7 because square sizes shrink geometrically, and the loop-carried values are guarded or typed to that range.
- **termination**: Recursion is replaced by an iterative level-by-level pass in a procedure over a fixed-size array of squares (2**8 - 1 entries), so no function variant is needed.
- **index**: Child indices are computed as 2*i and 2*i+1 for i within the level bounds, which needs an explicit guard against the array capacity before each store.
- **range**: Halving the side length with integer vectors only works if the base side is a multiple of 2**7, which the embedded constants satisfy but the prover must see through loop-carried values via type ranges or guards.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, records, for loops, while loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The tree is emitted as text art or an SVG-like text listing of line segments on standard output.

Assessed on 2026-10-15 against page revision 414980 of the [task](https://rosettacode.org/wiki/Pythagoras_tree) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
