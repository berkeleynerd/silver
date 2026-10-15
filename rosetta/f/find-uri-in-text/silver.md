# Find URI in text

**Candidate: proofs plausibly discharge automatically.** Every check is an index into a fixed constant text or small result table, guardable by explicit comparisons before each access, and the loops sit in procedures so no variants are needed; the nonroutine parts are only the loop-carried positions and the paren-balance counter, which need careful guarding but no annotation.

Position 839 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

The sample text is an embedded constant String (ASCII, with the non-ASCII character replaced or treated as an ordinary non-delimiter byte) scanned left to right by a procedure with a while loop. At each position a scheme (letters followed by ':' and then '//' or a recognised scheme like mailto/news/tel) is detected, the URI is extended over legal URI characters, and trailing delimiter punctuation and unbalanced closing parentheses are trimmed with a bounded counter; start/end pairs go into a fixed-size array and are printed with Put_Line over slices. About 130 lines.

## Proof obligations to watch

- **index**: Scanning positions are loop-carried, so each String access is guarded by an explicit bounds comparison just before use and a scheme-start lookahead is checked against the text length.
- **termination**: The scanner is a procedure with while loops (no termination check) that always advances the position by at least one, and any helper functions use only for loops.
- **range**: Start and end positions of each found URI are held in subtypes of the text index range and are only assigned from guarded positions, with trailing-punctuation trimming guarded by a start-less-than-end test.
- **length**: Found URIs are stored as start/end index pairs in a fixed-capacity array, and a full table is handled by a visible stop that prints a truncation message rather than dropping results silently.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, case statements, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Prints each URI found in the embedded sample text, one per line.

Assessed on 2026-10-15 against page revision 405888 of the [task](https://rosettacode.org/wiki/Find_URI_in_text) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
