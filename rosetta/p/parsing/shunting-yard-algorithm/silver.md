# Parsing/Shunting-yard algorithm

**Candidate: proofs plausibly discharge automatically.** Every check is an index or length bound on small ranged counters that an explicit guard before each push, pop or append makes provable, and the while loops live in procedures so no variant is needed.

Position 572 in the [progression](../../../progression.md#stage-11), in stage 11.

## Approach

The infix input is an embedded String constant scanned by a for loop over its index range, with single-character tokens classified by comparisons (operator, parenthesis, operand). The operator stack is a fixed-capacity Character array with a ranged top counter and the RPN output is a fixed-capacity Character buffer with a length counter, both manipulated in procedures with while loops that pop by precedence and associativity. Each token prints a trace line of stack and output via Put_Line, with mismatched parentheses and capacity overflow producing a visible rejection message. About 120 lines.

## Proof obligations to watch

- **index**: Stack-top and output-length indexes are loop-carried, so each read or write is preceded by an explicit guard (top > 0, length below capacity) that rejects with a visible message otherwise.
- **range**: Counters are declared as ranged subtypes bounded by the fixed capacities so increments are guarded by capacity checks rather than invariants.
- **length**: Trace lines are assembled in fixed-capacity buffers with a length guard before each append, and overflow leads to a specified rejection.
- **termination**: The popping loops are while loops inside a procedure, which get no termination check, and the token scan is a for loop over the constant string's range.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints the input, a per-token trace of the operator stack and RPN output, and the final RPN string.

Assessed on 2026-10-15 against page revision 414381 of the [task](https://rosettacode.org/wiki/Parsing/Shunting-yard_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
