# Input/Output for pairs of numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded integer subtypes and guards before each buffer access and digit accumulation, but the hand-written parser with loop-carried values needs careful guard placement, and Silver needs stdin line reading plus text parsing first.

Position 1357 in the [progression](../../../progression.md#stage-25), in stage 25.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A procedure reads the first line into a bounded line buffer and parses it as a count constrained to a declared maximum, rejecting anything else. A for loop over that count reads each line, a guarded scanner skips spaces and parses two optionally signed decimal integers within a bounded range, rejects trailing junk or missing fields, then prints the sum with scalar image text through Put_Line. Missing lines (end of input) and out-of-range values lead to a specified Reject outcome. About 90 lines.

## Proof obligations to watch

- **overflow**: Parsed integers are accepted only within a declared range of plus or minus 10**9, so the sum of a pair always fits Integer, and digit accumulation is guarded before each multiply-add.
- **index**: The line parser's while loop carries a position, so each character access is guarded by an explicit position-within-length test just before use.
- **termination**: Parsing loops live in procedures, which get no termination check, and the pair loop is a for loop over the parsed count.
- **length**: Line buffers are fixed-capacity with a stated maximum, and over-long lines are rejected rather than truncated.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, characters, for loops, while loops, procedures, string indexing, string building, 'Image of scalars, text parsing, standard input, conditional expressions and exit status.

## External effects

- **standard input** (allowed): Reads the count line and then one line per pair from standard input.
- **console output** (allowed): Writes each pair's sum on its own line to standard output.
- **exit status** (allowed): Malformed or out-of-range input is rejected with a nonzero exit status.

Assessed on 2026-10-15 against page revision 409215 of the [task](https://rosettacode.org/wiki/Input/Output_for_pairs_of_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
