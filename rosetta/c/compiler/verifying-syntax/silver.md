# Compiler/Verifying syntax

**Candidate: proofs plausibly discharge automatically.** The recursive-descent grammar can be recast as an iterative bounded-stack automaton, so every check follows from array bounds and guards just before indexing, with no annotation needed. The outlook is plausible rather than likely because of the tokenizer's loop-carried position, the bounded-depth stack, and the needed file-reading library.

Position 1337 in the [progression](../../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program reads each line of the input file into a bounded String buffer, then scans it with a while loop in a procedure that classifies tokens (identifier, integer, keyword or, and, not, true, false, operators, parentheses) by Character comparisons. Grammar checking is an iterative pushdown state machine: an enumeration state expects an operand or an operator, a fixed-capacity array indexed by paren depth records whether a comparison has been used in the current level, and "not" is only admitted at the start of a comparison operand. Over-long lines or over-deep nesting are rejected with a specified "false" message, and every failure prints "false" plus the position and reason. About 170 lines.

## Proof obligations to watch

- **index**: The scanner advances a position through a bounded line buffer, so each character access is guarded by a position <= length test just before use.
- **termination**: Scanning loops are while loops inside procedures, which get no termination check, and each iteration advances the position.
- **overflow**: The paren-depth counter and position index are bounded by guards, and exceeding the documented maximum nesting or line length yields a specified "false" rejection message.
- **stack**: The grammar's nesting is handled by an explicit fixed-size array of per-depth flags in an iterative state machine instead of recursion, so no input-dependent stack depth arises.
- **length**: Building the error message with the numeric position uses bounded concatenation in a buffer sized for the maximum line length plus the position digits.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, file input and Put without a newline.

## External effects

- **files** (allowed): The task reads the token stream from a file, so the program needs a named-file line reader with a specified failure outcome.
- **console output** (allowed): It prints "true", or "false" followed by an error message.
- **arguments** (allowed): The input file name comes from the first command-line argument via Silver_Arguments.

Assessed on 2026-10-15 against page revision 412719 of the [task](https://rosettacode.org/wiki/Compiler/Verifying_syntax) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
