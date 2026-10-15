# Black box

**Candidate: proofs plausibly discharge automatically.** All indexes and positions are bounded by subtypes and guards placed before each step, and the only loop carrying state is a while loop inside a procedure, so no annotation is needed, though the loop-carried beam state needs careful guard placement.

Position 834 in the [progression](../../progression.md#stage-15), in stage 15.

## Approach

Embed the four atoms of a fixed 8 x 8 board in a Boolean array and trace a beam from each of the 32 edge entry points with a while loop inside a procedure, keeping position and direction in small ranged subtypes. Each step applies the hit, reflection and deflection rules via bounds-checked Atom_At lookups, then records H, R or a pair exit number in a fixed result array that is printed with Put_Line using scalar image and bounded concatenation. The interactive guessing, scoring and board drawing are replaced by a deterministic non-interactive run that reports every entry's outcome. About 130 lines.

## Proof obligations to watch

- **range**: The beam position and direction are loop-carried values updated in a while loop, so each step is guarded by an explicit test that the next cell is within the 0..9 border box before the position subtype is assigned.
- **index**: Atom lookups go through a function that returns False for coordinates outside 1..8 before indexing the 8 x 8 Boolean array, so no index check depends on loop-carried facts.
- **termination**: The beam-tracing loop lives in a procedure, which gets no termination check, so no variant is needed (the beam always exits in the real game).
- **overflow**: The exit-numbering counter is a small ranged integer incremented at most once per entry point, bounded by a guard against its subtype maximum.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, for loops, while loops, case statements, procedures, functions, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints the beam result (H, R or the exit number) for each of the 32 edge entry points.

Assessed on 2026-10-15 against page revision 412678 of the [task](https://rosettacode.org/wiki/Black_box) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
