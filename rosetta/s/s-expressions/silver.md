# S-expressions

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded array and subtype indices with guards before each access, and nothing needs recursion, heap or an annotation because the nested structure is flattened into a depth-tagged node array; the loop-carried scanner positions and counters need careful guarding, hence plausible rather than likely.

Position 638 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

The program embeds the task's example as a constant String, scans it with a while loop in a procedure, and builds the tree into a fixed-capacity array of node records (kind: list-open, list-close, symbol, quoted string, integer, float; start and stop positions in the input; depth), using a bounded depth counter to match parentheses. Atoms are classified by character scanning (digits, optional sign, one dot) so that integers and floats are recognized without float conversion, and the writer walks the node array in order, putting 3*depth spaces and then the token text, with unbalanced parentheses, unterminated quotes and capacity overflow producing a specified rejection message. About 170 lines.

## Proof obligations to watch

- **index**: The scanner's position, the node count and the stack depth are loop-carried in while loops, so each is guarded just before every array or String access and a failed guard routes to a visible rejection.
- **range**: Node and stack indices live in bounded subtypes, with explicit capacity checks before each increment so overflow rejects the input instead of failing.
- **termination**: The scanner and parser are while loops inside procedures, which get no termination check, and the writer uses a for loop over the node pool.
- **initialization**: The node and stack arrays must be fully initialized at declaration so flow analysis passes across the loop-carried updates.
- **length**: Printing a token slice and the indent padding use fixed bounds, with token length and nesting depth capped so that the indent width cannot exceed its buffer.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The writer prints the pretty-printed S-expression (and a rejection message for malformed input) to standard output.

Assessed on 2026-10-15 against page revision 412032 of the [task](https://rosettacode.org/wiki/S-expressions) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
