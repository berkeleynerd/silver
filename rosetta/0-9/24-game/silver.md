# 24 game

**Candidate: proofs plausibly discharge automatically.** All checks come from ranged types, fixed-capacity stacks and guards before each operation, with loops kept as for loops in procedures so no variant is needed, but the rational arithmetic and stack bookkeeping need careful guard placement.

Position 1241 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program generates four digits with a deterministic linear congruential generator, prints them, prints a prompt, and reads one line into a bounded buffer. A single for loop over the line validates characters (digits matched once each against the generated digits, operators and parentheses allowed, multi-digit numbers rejected) and evaluates the expression by an iterative shunting-yard with fixed-capacity operand and operator stacks of exact rationals held as numerator and denominator records. Every stack push, arithmetic step and division is guarded and any failure prints a specified rejection message, with the final test being numerator equals 24 times denominator. About 230 lines.

## Proof obligations to watch

- **overflow**: Rational numerators and denominators are held in ranged integers and each add, subtract and multiply is preceded by a magnitude guard that rejects the expression with a visible message, which never fires for four single-digit operands.
- **division**: Division by a zero-valued rational is guarded just before the operation and rejected with a message, and the equality test with 24 is done by cross-multiplication so no real division is needed.
- **index**: The operand and operator stacks have fixed capacity and every push is guarded by a count check that rejects the expression, while the input line is a bounded buffer scanned by a for loop over its own range.
- **termination**: The tokenizer and shunting-yard evaluator are written as for loops inside procedures, so no function contains an unbounded while loop and no variant is needed.
- **overflow**: The pseudo-random generator uses a linear congruential step on a range-bounded state with mod, so the product is bounded by the declared range and cannot overflow.
- **initialization**: Stacks, counters and the digit-used flags are fully initialized by aggregates before the loops that read them.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Displays the four digits, the prompt, and the result or rejection message.
- **standard input** (allowed): Reads the player's expression as one line of input, with a specified outcome for end-of-input or over-long lines.

Assessed on 2026-10-15 against page revision 415249 of the [task](https://rosettacode.org/wiki/24_game) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
