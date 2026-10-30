# Recursive descent parser generator

**Candidate: proofs plausibly discharge automatically.** Every check can be made to follow from declared capacities and guards placed just before indexing, appending and incrementing, and recursion lives only in procedures with an explicit depth limit, but the many loop-carried cursors in two text-processing programs make discharge depend on careful shape, so the outlook is plausible.

Position 1555 in the [progression](../../progression.md#stage-34), in stage 34.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The generator is a Main procedure that reads a preprocessed grammar file into a bounded buffer, scans it with guarded while loops into fixed arrays of rule records (terminals, nonterminals, alternatives, repetition marks), and prints one Ada procedure per rule plus a fixed lexer and a temporary-naming emitter, rejecting malformed or oversize grammars with a message. The generated parser embeds the example expression, lexes it into a token array, and calls mutually recursive procedures carrying a depth parameter checked against a fixed limit; each binary step emits a line such as _0001 = one + two built from 'Image of a bounded temporary counter. About 420 lines.

## Proof obligations to watch

- **index**: Cursor positions into the grammar text, the expression and the output line buffers are loop-carried in while loops, so each read or append needs a bound guard just before it that leads to a visible rejection of oversize input.
- **range**: Counters for rules, alternatives, symbols and temporaries must be kept in declared ranges with capacity guards before each increment, rejecting grammars or expressions that exceed the documented limits.
- **length**: Emitted lines of generated source and three-address code are built in bounded buffers, so every concatenation needs a remaining-capacity check before it is performed.
- **stack**: The generated parser's mutually recursive rule procedures nest as deep as the input's parentheses, so a depth counter passed down and checked against a fixed limit must reject deeper input to make stack use a fixed premise.
- **initialization**: Token and symbol-table records filled in parsing loops must be fully initialized by default or aggregate so flow analysis sees every read component defined.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, unconstrained arrays, string indexing, string building, 'Image of scalars, case statements, for loops, while loops, procedures, functions, recursive procedures and file input.

## External effects

- **files** (allowed): The generator reads the grammar description from a named grammar file, as the task describes.
- **console output** (allowed): The generator prints the generated Ada parser source, and the generated parser prints the three-address code lines.

Assessed on 2026-10-15 against page revision 414438 of the [task](https://rosettacode.org/wiki/Recursive_descent_parser_generator) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
