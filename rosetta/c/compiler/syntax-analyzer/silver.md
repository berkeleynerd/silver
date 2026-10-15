# Compiler/syntax analyzer

**Candidate: proofs plausibly discharge automatically.** All checks follow from fixed-capacity arrays, ranged indices and capacity guards, but the explicit-stack parser replacing recursion is a large loop-heavy program whose index and loop-carried bounds need careful guarding, so it is plausible rather than likely.

Position 1263 in the [progression](../../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

Read the lexer output from stdin into a bounded token table of records holding an enumeration kind and fixed-length text, then parse with a single while loop in a procedure that uses an explicit bounded stack of parse states and an operator stack for precedence climbing, building the binary tree in a fixed-capacity node array with integer child indices (0 for null). Print the flattened tree by a second loop with an explicit stack of node indices, and reject malformed tokens, unexpected tokens or any exceeded capacity with a specified message and Reject. About 480 lines.

## Proof obligations to watch

- **termination**: The recursive descent and precedence climbing are replaced by one while loop inside a procedure driven by an explicit bounded stack of pending states, and procedures get no termination check.
- **stack**: Nesting depth of parentheses, blocks and operators is limited by a fixed-size stack array, and exceeding it rejects the input visibly, so no recursion depth depends on input.
- **index**: Every write to the token table, node table, stack or line buffer is guarded by a capacity test just before the access, and over-capacity input is rejected with a message.
- **length**: Identifier and string token text is copied into fixed-length buffers with a guard that rejects over-long tokens, and the AST dump walks the node array with an explicit stack of the same bounded kind.
- **overflow**: Integer literals stay as text and are never converted to numbers, so no arithmetic can overflow, while line and node counters are ranged subtypes bounded by their capacities.
- **initialization**: Token and node arrays are fully initialized by aggregate before use, and record fields are set before any read.

## Language surface beyond today's Silver

Ranged subtypes, Boolean objects, characters, enumerations, arrays, records, string indexing, string building, text parsing, case statements, for loops, while loops, procedures, functions and standard input.

## External effects

- **standard input** (allowed): The lexer's token listing is read line by line from standard input.
- **console output** (allowed): The flattened AST and any rejection message are written to standard output.

Assessed on 2026-10-15 against page revision 412718 of the [task](https://rosettacode.org/wiki/Compiler/syntax_analyzer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
