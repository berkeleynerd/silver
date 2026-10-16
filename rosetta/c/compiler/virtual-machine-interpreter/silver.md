# Compiler/virtual machine interpreter

**Candidate: proofs plausibly discharge automatically.** No Oracle rule is broken and no annotation is needed because every stack, index, arithmetic and parsing check can be guarded just before use with a visible fault outcome, but the many loop-carried values (sp, pc, accumulators) and the wide-type overflow handling make careful program shape necessary.

Position 1570 in the [progression](../../../progression.md#stage-36), in stage 36.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The listing is read from stdin line by line into fixed-capacity tables: a string pool of bounded buffers with lengths, and parallel code arrays of opcode, operand and address, with the data area and a 32-bit-ranged word stack as constrained arrays. A hand-written scanner parses the header, quoted string literals with the escapes backslash-n and double backslash, and each instruction line, rejecting anything malformed; then a while loop in a procedure dispatches by case on the opcode, guarding stack depth, indexes, division and 32-bit overflow before each operation and ending in a specified fault outcome when a guard fails. Output goes through Put of characters, a hand-built decimal conversion for prti, and pooled strings for prts. About 380 lines.

## Proof obligations to watch

- **index**: Stack pointer, data index, string index and pc are loop-carried, so each use is preceded by an explicit bounds guard that ends the run with a rejecting fault outcome.
- **overflow**: 32-bit signed arithmetic on stack words is held in a range-limited subtype, and add, sub, mul and neg compute in a wider 64-bit type and fault with a visible outcome if the result leaves the 32-bit range.
- **division**: div and mod test for a zero divisor and for the minus-2^31 by minus-1 case just before the operation and fault visibly.
- **range**: Jump targets and operand values parsed from text are range-checked while parsing and again before pc is assigned, and parsing digit accumulators are guarded against exceeding the limit on each digit.
- **length**: String-pool entries and input lines live in fixed-capacity buffers with explicit lengths, and over-long lines or escape expansions are rejected at append time.
- **termination**: All loops are in procedures, which get no termination check, so the interpreter loop needs no variant, though a guest program that loops forever simply runs forever by specification.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline, standard error, exit status and standard input.

## External effects

- **standard input** (allowed): Reads the assembly listing (header, string pool, instruction lines) line by line from standard input.
- **console output** (allowed): prtc, prti and prts write characters, integers and pooled strings to standard output without line terminators.
- **exit status** (allowed): Malformed listings, limit overruns and VM faults must end with a specified rejecting exit status.

Assessed on 2026-10-15 against page revision 414125 of the [task](https://rosettacode.org/wiki/Compiler/virtual_machine_interpreter) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
