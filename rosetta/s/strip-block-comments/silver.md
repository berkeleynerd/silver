# Strip block comments

**Candidate: proofs likely to discharge automatically.** Every check is an index or counter bound that follows from the for-loop range, one lookahead guard and one capacity guard, with no loop-carried arithmetic beyond a guarded counter, so the proofs should discharge without annotations. The program needs only a few Character and String indexing constructs beyond today's Silver.

Position 519 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

The sample program text is embedded as a constant String built by concatenating line literals with Character'Val (10) line feeds, and a single for loop over its indexes copies characters into a fixed output buffer while tracking Inside_Comment and a Skip_Next flag. On "/*" outside a comment it enters the comment and skips the next character, on "*/" inside a comment it leaves it and skips the next character (so the "/*/" case stays inside the comment), and line feeds inside comments are kept to preserve line structure as in the sample output. The buffer slice up to the counter is printed with Put_Line, and the delimiters are constants (the caller-specified delimiter extra credit is left out). About 55 lines.

## Proof obligations to watch

- **index**: Reading the character after the current one is guarded by a test that the current index is below Text'Last, and the loop index runs over Text'Range.
- **range**: The output length counter is a subtype bounded by Text'Length and is incremented only after a guard that it is below that bound, with Reject as the visible outcome otherwise.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, string indexing, string building, for loops and Boolean objects.

## External effects

- **console output** (allowed): The stripped text is written to standard output with Put_Line.

Assessed on 2026-10-15 against page revision 414668 of the [task](https://rosettacode.org/wiki/Strip_block_comments) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
