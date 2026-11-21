# Arithmetic evaluation

**Candidate: proofs plausibly discharge automatically.** A shunting-yard parser with explicit stacks plus postorder array evaluation avoids recursion, heap use and while loops in functions. Every check rests on a guard placed just before the operation or on 64-bit arithmetic over 32-bit-ranged operands, but there are many loop-carried stack tops and counters and one nonlinear multiply, so discharge depends on careful program shape.

Position 1135 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

The AST is a fixed-capacity array of node records (an operator Character, a literal value, and Left/Right child indices). A shunting-yard parser in a procedure scans the String parameter with a for loop and uses bounded operator and operand stacks, so it needs no recursion and always creates children before their parents. Evaluation then walks the node array in index order in a for loop, filling a value array, and guards turn every malformed, too-large, over-capacity, overflowing or divide-by-zero expression into a printed error. About 170 lines.

## Proof obligations to watch

- **overflow**: Number literals accumulate only after a guard against the maximum value, and each binary operation is computed in a 64-bit type from 32-bit-ranged operands, then range-checked, with any out-of-range result reported as an overflow error.
- **division**: A divisor-is-zero test placed just before the division reports an error, and a symmetric value range rules out the minimum divided by -1 case.
- **index**: The operator-stack, operand-stack and node-count tops are loop-carried, so each push is guarded by Top < Capacity (otherwise the expression is too complex and is rejected) and each pop by Top > 0 (otherwise it is a syntax error).
- **range**: Digit values come from Character'Pos after a '0'..'9' comparison guard, and child indices stored in nodes are checked to be nonzero before they index the value array.
- **initialization**: The node, stack and value arrays are initialized whole with aggregates at declaration, so no element read depends on loop-established facts.
- **termination**: The while loop that reduces operators while they have higher precedence lives in a procedure, so it gets no termination check, and the precedence helper function has no loops.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, unconstrained arrays, text parsing, 'Image of scalars, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): Each embedded expression is printed with its evaluated value or a specified error message.

Assessed on 2026-10-15 against page revision 414925 of the [task](https://rosettacode.org/wiki/Arithmetic_evaluation) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
