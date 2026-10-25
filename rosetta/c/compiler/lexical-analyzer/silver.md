# Compiler/lexical analyzer

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded buffers, subtype-ranged counters and an explicit guard before each lookahead, and the scanner is a procedure so termination is not checked, but the many loop-carried positions, counters and buffers need careful guard placement. Nothing requires an annotation, and the exception-based error reporting of the existing solution is replaced by specified diagnostics.

Position 1562 in the [progression](../../../progression.md#stage-35), in stage 35.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Read the whole source into a fixed-capacity Character array with a length, rejecting over-capacity input, then scan it in a procedure with a while loop and a position index, tracking line and column in bounded subtypes. A case statement on the current character classifies tokens, with guarded one-character lookahead for two-character operators, comments, identifiers, integers, character and string literals, and keywords recognized by comparing the token buffer. Each token is written as a line with Put and scalar image, and the eight lexical errors are reported through a specified message and nonzero exit status, never an exception. About 260 lines.

## Proof obligations to watch

- **index**: A scan position is carried through a while loop in a procedure, so each lookahead and buffer access is guarded by an explicit position-less-than-length test just before use.
- **overflow**: Line, column, token length and integer-literal value counters are loop-carried, so they use bounded subtypes with guards, and over-long input or integer literals beyond the limit are rejected with a specified diagnostic.
- **length**: Input buffer, token text buffer and string values have fixed capacities, and input exceeding the capacity is rejected visibly rather than truncated.
- **termination**: The scanner is a procedure with a while loop, so no termination check applies, and the position advances on every state transition.
- **initialization**: The buffers and the output token fields are fully initialized by declaration, and every case branch sets them before use.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, enumerations, arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, records, Put without a newline, standard input, file input, exit status, standard error and membership tests.

## External effects

- **standard input** (allowed): Source text is read from standard input.
- **files** (allowed): The task allows reading the source from a named file given as the first argument.
- **console output** (allowed): Token lines with line, column, name and value are written to standard output, and diagnostics are reported with a specified message.
- **arguments** (allowed): Optional first argument selects the input file.
- **exit status** (allowed): Lexical errors end the run with a nonzero status after a diagnostic.

Assessed on 2026-10-15 against page revision 412716 of the [task](https://rosettacode.org/wiki/Compiler/lexical_analyzer) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
