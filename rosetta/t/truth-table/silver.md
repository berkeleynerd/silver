# Truth table

**Candidate: proofs plausibly discharge automatically.** Everything is bounded arrays, ranged indexes and iterative stack loops in procedures, so checks follow from types and guards before each push or pop, but many loop-carried stack pointers and positions need careful guards. No annotation is needed, though the parser's shape makes automatic discharge plausible rather than certain.

Position 1458 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

The program reads the expression from the first argument (defaulting to embedded examples), rejects it if longer than a fixed bound, and converts infix to postfix with an iterative shunting-yard in a procedure using fixed-size token and operator stack arrays guarded against overflow and underflow. It collects distinct variable letters into a bounded table (rejecting more than a fixed maximum), then loops over 2**N combinations, evaluating the postfix tokens with a bounded Boolean stack and printing each row with Put and Put_Line. Any syntax error, stack misuse or over-limit input leads to Reject with a visible message. About 230 lines.

## Proof obligations to watch

- **index**: Operator and operand stack pointers are loop-carried across the parse and evaluation loops, so each push and pop is preceded by an explicit capacity or underflow guard that rejects the input.
- **range**: The input position and output token count are loop-carried values whose bounds follow from their subtype ranges and a length guard on the input string rejecting expressions over the fixed limit.
- **overflow**: The row count 2**N is computed with N capped at a fixed variable limit (for example 8), and the combination counter is a ranged subtype so the bit tests for each row stay in range.
- **termination**: All parsing and evaluation loops live in procedures (no termination check), and the evaluator is an iterative stack machine over postfix tokens, so no function needs a variant.
- **initialization**: Stacks, token buffers and the variable table are fully initialized by aggregates before any loop reads them.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, string indexing, string building, case statements, for loops, while loops, procedures, functions, Put without a newline, further arguments and exit status.

## External effects

- **console output** (allowed): The program prints the table header, separator line and one row per input combination.
- **arguments** (allowed): The Boolean expression is taken from the first command-line argument, with embedded examples for the two- and three-variable demonstrations.
- **exit status** (allowed): A malformed or over-long expression is rejected with a specified failure outcome and nonzero status.

Assessed on 2026-10-15 against page revision 413097 of the [task](https://rosettacode.org/wiki/Truth_table) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
