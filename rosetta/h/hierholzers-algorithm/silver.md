# Hierholzer's algorithm

**Candidate: proofs plausibly discharge automatically.** Everything is fixed-capacity arrays with ranged subtypes and explicit guards inside a procedure, so no termination check or annotation is needed, but loop-carried stack tops and counts require careful guard placement.

Position 709 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Embed the two OCaml example graphs as constrained 2D edge arrays of ranged-subtype vertices plus a per-vertex count array, and run Hierholzer's with two fixed-capacity array stacks inside one procedure using a while loop. Each push is guarded by a capacity check that prints a rejection, and each edge removal shifts the list left under a count-positive guard. The circuit is printed by popping the circuit stack with Put and Integer'Image, called once per example graph. About 110 lines.

## Proof obligations to watch

- **index**: Stack tops are loop-carried so each push is guarded by an explicit top-below-capacity test that rejects with a visible message, and each pop or peek is guarded by a nonempty test.
- **range**: Per-vertex edge counts are declared with a bounded subtype and each decrement is guarded by a count-greater-than-zero test just before it, so no invariant is needed.
- **index**: The edge-shift loop reads edges(i+1) with i at most count-1, which follows from count's subtype bound because the loop bounds are read once from a ranged variable.
- **other**: The reject guard on stack capacity changes behavior only for graphs exceeding the documented limit, which is a visible specified outcome.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, multidimensional arrays, for loops, while loops, procedures, Put without a newline, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints each Eulerian circuit as a line of vertices separated by arrows.

Assessed on 2026-10-15 against page revision 415449 of the [task](https://rosettacode.org/wiki/Hierholzer's_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
