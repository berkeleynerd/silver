# JSON

**Candidate: proofs plausibly discharge automatically.** Nothing requires an annotation because parsing and serialization can be written as iterative loops in procedures with explicit-stack nesting and guards before every index, though the many loop-carried cursors and table links make discharge depend on careful program shape.

Position 1203 in the [progression](../../progression.md#stage-20), in stage 20.

## Approach

The program embeds the example JSON text as a String constant and parses it with an iterative, explicit-stack procedure into a fixed-capacity node table (a record array holding kind, string span, integer value and first-child and next-sibling links), rejecting malformed input or capacity overflow. It then builds a second tree for the Linux object with an array of parents, and serializes both trees by an iterative traversal into a bounded character buffer written out with Put_Line. Every cursor, node count and depth is guarded before use, and integers are converted to text with 'Image. About 220 lines.

## Proof obligations to watch

- **index**: The parser cursor and the node, child and output-buffer positions are loop-carried, so each use is preceded by an explicit bounds guard that rejects the input or stops with a visible overflow outcome.
- **overflow**: Integer values are accumulated digit by digit in a bounded range type with a guard before each multiply-add that rejects numbers beyond the limit.
- **stack**: Nesting is handled with a fixed-depth explicit stack array instead of recursion, and input deeper than the limit is rejected.
- **initialization**: Node tables and buffers are fully initialized by aggregates so flow analysis in loops stays routine.
- **termination**: All parsing and serializing loops live in procedures, which get no termination check, and each advances the cursor.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The program prints the serialized JSON text, or a rejection message, with Put_Line.

Assessed on 2026-10-15 against page revision 412864 of the [task](https://rosettacode.org/wiki/JSON) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
