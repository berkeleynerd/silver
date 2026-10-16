# Compiler/AST interpreter

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation because recursion is replaced by explicit stacks in procedures and all arithmetic, indexes and buffers are bounded by types and guards, but the many guarded loop-carried indexes and the text parsing make discharge depend on careful program shape.

Position 1259 in the [progression](../../../progression.md#stage-21), in stage 21.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program reads the AST lines from stdin into a fixed-capacity array of node records (kind enumeration, left and right indexes, value) using a loader that parses with an explicit stack instead of recursion, then interprets it with an iterative explicit-stack evaluator in a procedure over a bounded variable table and string pool. Every arithmetic result, index and capacity is guarded and violations reject the input with a specified message; output goes through Put-style procedures and integer text conversion. About 350 lines.

## Proof obligations to watch

- **overflow**: Interpreted +, -, * and negation run on a wide ranged type and a guard rejects any result outside the interpreter's value range, so the check discharges and overflow has a visible outcome.
- **division**: A guard rejects a zero divisor before / and mod, and truncation toward zero matches Ada's native semantics.
- **index**: Node, string-pool, variable and stack indexes are range-typed and every load or push is guarded against the fixed capacities, with overflow rejecting the input.
- **termination**: Recursion is replaced by an explicit work stack inside procedures with while loops, which get no termination check, and a non-terminating guest program simply runs forever, which is not a proved property.
- **length**: Input lines, identifiers and string literals are copied into fixed-size bounded buffers with length guards that reject over-long tokens.
- **initialization**: All node, variable and pool arrays are initialized by whole-array aggregates or for loops before use.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, Put without a newline and standard input.

## External effects

- **standard input** (allowed): The AST text produced by the syntax analyzer is read line by line from standard input.
- **console output** (allowed): The interpreted program prints characters, integers and strings without line terminators.

Assessed on 2026-10-15 against page revision 412098 of the [task](https://rosettacode.org/wiki/Compiler/AST_interpreter) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
