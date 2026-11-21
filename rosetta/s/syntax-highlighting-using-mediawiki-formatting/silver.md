# Syntax highlighting using Mediawiki formatting

**Candidate: proofs plausibly discharge automatically.** Every check is a bounded-index or bounded-length operation guardable just before use, and all unbounded loops can sit in procedures, so no annotations are needed, though many loop-carried positions need careful guards. No Oracle rule is violated since the task is pure text transformation.

Position 1240 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The program reads each stdin line into a bounded buffer with a length, then a procedure scans it with a while loop, emitting comments (starting with --) in italic markup, identifiers as bold when they match an embedded table of upper-case Ada keywords, and translating the four special characters to entities. Output is built in a bounded buffer prefixed with a space, with lines exceeding the input or output capacity rejected with a specified message. Keyword lookup is a for loop over a constant array of bounded-string records, compared case-insensitively after upcasing the word. About 170 lines.

## Proof obligations to watch

- **index**: Scan positions in the while loops are loop-carried, so each Line(Pos) access is preceded by an explicit Pos <= Length guard.
- **length**: Output-buffer growth from entity expansion (up to 6x per character) is guarded by a capacity check that rejects over-long lines with a visible message rather than truncating.
- **termination**: All while loops live in procedures, which get no termination check, and the keyword search uses a for loop in a function.
- **overflow**: Position and length counters are subtypes bounded by the fixed line capacity, so increments are safe given the loop guards.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, case statements, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **standard input** (allowed): Source lines are read from standard input and processed until end of input.
- **console output** (allowed): Each highlighted line is written to standard output with a leading space.

Assessed on 2026-10-15 against page revision 413939 of the [task](https://rosettacode.org/wiki/Syntax_highlighting_using_Mediawiki_formatting) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
