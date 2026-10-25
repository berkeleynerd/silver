# Compiler/code generator

**Candidate: proofs plausibly discharge automatically.** Every check can follow from ranged index subtypes plus capacity and digit-overflow guards placed just before each push, append or multiply. Nothing needs an annotation, but the many loop-carried counters and explicit stacks make discharge depend on careful program shape, so the outlook is plausible rather than likely.

Position 1253 in the [progression](../../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program reads the flattened AST from standard input into a fixed-size node pool of records (kind enumeration, left and right Node_Index links, value buffer). It builds the tree without recursion by keeping an explicit stack of parent slots still waiting for children. It then generates code with an explicit work stack of phase-tagged items into a bounded array of instruction records, backpatching jz/jmp targets and computing byte addresses as 1 or 5 bytes per instruction. Finally it prints the Datasize/Strings header, the string pool and the formatted listing. Unknown node names, malformed lines, early end of input, integer literals over 32 bits and exceeded capacities each lead to Reject with a message. About 450 lines.

## Proof obligations to watch

- **index**: Node, instruction, string-pool, variable and explicit-stack indices are loop-carried counters, so each push or append is preceded by a capacity guard that rejects the input, and stored child links use a ranged Node_Index subtype so indexing through them follows from the type.
- **overflow**: Integer literals are parsed digit by digit with a guard against the 32-bit limit before each multiply-add, and code addresses and jump offsets are sums and differences of capacity-bounded positions, so their ranges follow from declared subtypes.
- **length**: Tokenizing lines that respect double quotes and copying identifiers and strings into fixed buffers needs explicit length guards before each slice copy and each assembled output line.
- **other**: Replacing recursive AST loading and code generation with explicit stacks of pending-child slots and phase-tagged work items for If and While must still produce exactly the reference byte offsets and backpatched jumps, which is a correctness burden rather than a proof one.
- **termination**: The line-reading, tree-building, generation and listing loops are while loops kept inside procedures, and the pool lookups in functions use for loops, so no variant is needed.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions and standard input.

## External effects

- **standard input** (allowed): The task requires reading the flattened AST text produced by the syntax analyzer, which the program reads line by line from standard input.
- **console output** (allowed): The header, string pool and virtual assembly listing are written to standard output.

Assessed on 2026-10-15 against page revision 412566 of the [task](https://rosettacode.org/wiki/Compiler/code_generator) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
