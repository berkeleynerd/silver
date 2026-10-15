# Parsing/RPN to infix conversion

**Candidate: proofs plausibly discharge automatically.** Every index and length check follows from bounded subtypes and explicit capacity guards in procedures, and the only loops are a scanner while loop in a procedure and for loops printing the stack, so no annotations are needed, but many loop-carried lengths make the shape delicate.

Position 1031 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

The program embeds the two RPN strings as constants and, in a procedure, scans each with a while loop, pushing operands and combining the top two entries of a fixed-depth stack of records (a fixed-capacity character buffer, its length and a precedence) on each operator. Operator handling uses a case statement with precedence and associativity rules to decide parenthesization, appending pieces to the buffer only after capacity guards, and rejecting stack underflow, unknown tokens or overflow with a printed message. After every token the stack is printed with Put_Line and Put, and the final single entry is printed as the infix expression. About 170 lines.

## Proof obligations to watch

- **index**: Stack push/pop and buffer appends index fixed arrays, so each is preceded by an explicit capacity or non-empty guard that leads to a visible Rejected message.
- **overflow**: Expression lengths and stack depth are loop-carried counters typed with bounded subtypes, and every append is guarded by a remaining-capacity test, so additions cannot exceed the subtype range.
- **length**: Slice copies between expression buffers need the guard to show source length plus separators and parentheses fit in the fixed capacity, which is nonlinear-free but needs careful ordering of guards.
- **termination**: The token scanner uses a while loop with a pointer advanced each iteration, which is acceptable only because it lives in a procedure; it must not be placed in a function.
- **initialization**: Stack entries and buffers are fully initialized by declaration aggregates, so flow analysis is routine.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string building, case statements, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints each input RPN string, the stack contents after every token, and the final infix result.

Assessed on 2026-10-15 against page revision 412957 of the [task](https://rosettacode.org/wiki/Parsing/RPN_to_infix_conversion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
