# Parsing/RPN calculator algorithm

**Candidate: proofs plausibly discharge automatically.** Every check is a bounded-integer operation on array-stack values that can be guarded just before use with a visible rejection, and no annotation is needed, but many loop-carried values (stack contents, depth, cursor, scaled results) each need their own guard, so discharge depends on careful program shape.

Position 844 in the [progression](../../../progression.md#stage-13), in stage 13.

## Approach

The expression is an embedded String constant scanned by a cursor in a procedure with while loops, classifying each token as a number, one of + - * / ^, or invalid. Values are scaled integers (five decimal places) held in a fixed-capacity array stack with a depth counter; operators pop two values after a depth guard, apply the operation with range and zero guards, and push the result, while exponentiation is repeated multiplication with a bounded non-negative exponent. After each token a procedure prints the stack row by converting each scaled value to text through 'Image pieces, and any malformed token, stack error, overflow or division by zero produces a specified rejection message. About 170 lines.

## Proof obligations to watch

- **overflow**: Scaled-integer add, subtract, multiply and power act on loop-carried stack values bounded only by type range, so each operation is guarded by a range check on its operands that rejects the input on failure.
- **index**: Stack depth and token cursor are loop-carried, so a guard before each push and pop rejects stack overflow or underflow, and the cursor is checked against the string's bounds before every read.
- **division**: The divisor is tested for zero just before dividing, with a specified rejection outcome.
- **range**: Rendering each scaled value as a fixed five-decimal string in a bounded buffer needs digit-count guards because the value's magnitude is known only from its type.
- **termination**: Tokenizer and exponent loops are while loops inside procedures, which get no termination check, so none is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the token table of stack snapshots and the final result to standard output.

Assessed on 2026-10-15 against page revision 415019 of the [task](https://rosettacode.org/wiki/Parsing/RPN_calculator_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
