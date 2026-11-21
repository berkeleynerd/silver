# Tree from nesting levels

**Candidate: proofs plausibly discharge automatically.** All checks reduce to bounded subtypes and capacity guards placed right before each buffer write, and no annotation is needed, but the loop-carried depth and buffer position need careful guard shape.

Position 1095 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

Each embedded input is a constant array of a small Positive-range subtype with a length, and one procedure walks it with a for loop, tracking current depth in a bounded subtype. Before each element it emits ']' while depth exceeds the level and '[' while depth is below, plus separators, appending characters into a fixed-capacity String buffer behind an explicit capacity guard that rejects on overflow, then prints the buffer slice with Put_Line. The output is the nested-list text, which meets the task's displayed results; the tree is not kept as a data structure. About 95 lines.

## Proof obligations to watch

- **index**: The output buffer position is loop-carried, so each character append is preceded by a guard on remaining capacity, with overflow producing a visible rejection message.
- **range**: The nesting depth variable is loop-carried and typed as a bounded subtype, with increments and decrements guarded by comparisons against the target level so the type range suffices.
- **overflow**: Level values come from a subtype bounded to a small range in embedded data, so image and increment arithmetic stays within range.

## Language surface recorded by this assessment

Integers, ranged subtypes, arrays, for loops, while loops, procedures, characters, string indexing, string building, 'Image of scalars, Put without a newline and unconstrained arrays.

## External effects

- **console output** (allowed): Prints the nested-list text for each of the seven example inputs.

Assessed on 2026-10-15 against page revision 413093 of the [task](https://rosettacode.org/wiki/Tree_from_nesting_levels) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
