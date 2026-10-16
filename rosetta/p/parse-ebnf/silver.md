# Parse EBNF

**Candidate: proofs plausibly discharge automatically.** The task is faithful with bounded arrays and explicit stacks in procedures, so every check is a guarded index or counter, but the size and number of loop-carried indices make discharge depend on careful program shape, and nothing needs an annotation.

Position 1209 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Embed the EBNF grammars and test sentences as String constants, tokenize each into a bounded token array, then parse it with an iterative precedence-driven procedure using an explicit operator stack into a fixed-size array pool of rule nodes (kind, child and next indices). Match the sentence against the node pool with a backtracking interpreter that keeps an explicit choice stack, a step budget and capacity guards, then print the accept or reject verdict and a simple tree line per node. About 450 lines.

## Proof obligations to watch

- **index**: The tokenizer position, the token table, the rule-node pool and the explicit matching stack are loop-carried indices that each need a guard against their fixed capacity, with overflow producing a visible rejection such as grammar too large.
- **termination**: Grammar parsing and matching are done in procedures using explicit stacks instead of recursion, so no termination check applies, and a fixed step budget gives a visible reject outcome for left-recursive grammars.
- **stack**: Nested brackets and recursive grammar rules would need recursion, so the program uses a bounded explicit stack with a documented depth limit instead of recursive procedures.
- **overflow**: Node and position counters are subtypes bounded by the pool and input capacity, so increments are guarded before use.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, string indexing, string building, case statements, for loops, while loops, procedures, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): Prints per-test accept/reject verdicts and optionally a textual syntax tree.

Assessed on 2026-10-15 against page revision 413514 of the [task](https://rosettacode.org/wiki/Parse_EBNF) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
