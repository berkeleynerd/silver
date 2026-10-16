# Compiler/Preprocessor

**Candidate: proofs plausibly discharge automatically.** All checks reduce to bounded buffer indexing and length guards placed before each append, and recursion is avoided by an explicit include stack and fixed capacities, so nothing needs an annotation; the heavy loop-carried cursor state and string building make discharge depend on careful program shape.

Position 1461 in the [progression](../../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Lines are held in fixed-capacity character buffers with explicit lengths, macros live in a bounded table of records (name, parameter list, body), and includes are handled by an explicit stack of at most six open files driven from a while loop in a procedure. Each line is classified as an include, a define or ordinary text; ordinary text is scanned character by character for a hash-delimited usage, which is parsed, looked up, and expanded by a single substitution pass into a bounded output buffer, with unmatched text copied through unchanged. Every capacity, depth, redefinition and file-open failure is an explicit rejection with a specified message and exit status. About 420 lines.

## Proof obligations to watch

- **index**: Every scan position into a bounded line buffer is guarded by a comparison against the current line length just before use, and macro and stack tables are indexed by counters typed to their capacity.
- **length**: Expanded lines are appended into fixed-capacity buffers only after a guard checks the remaining room, and overflow is rejected with a visible error rather than truncated.
- **range**: Loop-carried scan cursors and counters are subtypes bounded by the buffer capacity and are advanced only under guards, since there is no invariant to carry the bound.
- **termination**: All scanning and expansion loops live in procedures (no termination check), and include nesting uses an explicit five-entry file stack instead of recursion.
- **overflow**: Substitution can grow a line, so output length is checked against capacity before each append and macro expansion is performed in a single non-nested pass over the definition.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, text parsing, for loops, while loops, procedures, functions, further arguments, standard input, file input, file output, Put without a newline and exit status.

## External effects

- **arguments** (allowed): Reads the optional debug flag, input file name and output file name from the command line.
- **standard input** (allowed): Reads source lines from standard input when no input file is named.
- **files** (allowed): Reads the source file and each included file, and optionally writes the output file.
- **console output** (allowed): Writes the processed text to standard output when no output file is named, and reports rejected input.
- **exit status** (allowed): Signals failure for a missing include, an include nesting deeper than five, an illegal macro redefinition or an over-capacity input.

Assessed on 2026-10-15 against page revision 414124 of the [task](https://rosettacode.org/wiki/Compiler/Preprocessor) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
