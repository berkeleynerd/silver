# XML/Input

**Candidate: proofs plausibly discharge automatically.** The task is plain string scanning of fixed embedded data with no recursion, annotation or dynamic construct, so it fits Silver once string indexing, loops and bounded buffers exist. It is plausible rather than likely because the scanner has several loop-carried indices that each need a guard just before use.

Position 1142 in the [progression](../../../progression.md#stage-19), in stage 19.

## Approach

Embed the XML fragment as a String constant and scan it with a position index in a while loop inside a procedure. Detect a start tag named Student, locate its Name attribute, copy the quoted value into a bounded buffer while decoding numeric character references to UTF-8 bytes, then print the buffer with Put_Line. Every lookahead is preceded by a bounds guard, and a malformed or over-long name produces a specified rejection message. About 130 lines.

## Proof obligations to watch

- **index**: The scanner advances a position through the embedded XML text in a while loop inside a procedure, so every lookahead (tag name, Name=" prefix, closing quote, entity terminator) needs an explicit bounds guard just before the indexing.
- **length**: Each name is copied into a fixed-capacity buffer (for example 64 characters), so a guard must check capacity before every append and give a visible outcome such as reporting an over-long name.
- **range**: Decoding the numeric character reference &#x00C9; accumulates a code point in a bounded integer and encodes it to UTF-8 bytes, which needs digit-count and value guards so the accumulator and Character'Val arguments stay in range.
- **termination**: The loops sit in a procedure so no variant is required, but the scan must be written so the position visibly advances and no function contains a while loop.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, string indexing, string building, text parsing, while loops, for loops, procedures and arrays.

## External effects

- **console output** (allowed): Each extracted student name is printed on its own line, with non-ASCII characters emitted as UTF-8 bytes.

Assessed on 2026-10-15 against page revision 415319 of the [task](https://rosettacode.org/wiki/XML/Input) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
