# Extended Straddling Checkerboard

**Candidate: proofs plausibly discharge automatically.** Nothing needs an annotation because all work is in procedures over bounded buffers with explicit capacity and lookahead guards, but the loop-carried output and input cursors in the encoder and decoder require careful guard placement.

Position 865 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Embed the test message as a constant String, uppercase it by character, and keep the checkerboard as constant arrays of Character and of two-digit codes, plus a small constant array of the dictionary words ACK, REQ, MSG, RV, GRD, SND and SUPP. A procedure encodes by scanning words with an index and a figure-mode Boolean, emitting shift codes, doubled digits, dictionary codes or CODE followed by three digits into a bounded buffer. A second procedure decodes with a while loop and guarded lookahead, and any unrecognized character or buffer overflow prints a specified rejection message and stops. About 230 lines.

## Proof obligations to watch

- **index**: Every write into the fixed-capacity encoded and decoded buffers is guarded by a capacity test that rejects overflow with a visible message, and decode lookaheads of 1 to 3 characters are each guarded by a remaining-length test.
- **length**: The output length is a loop-carried counter whose only known bound after the first iteration is its subtype range, so each append is preceded by an explicit guard against that capacity.
- **range**: Character-to-digit and digit-to-table-index conversions occur only after a test that the character is a digit or letter, so the results stay inside the table subtypes.
- **termination**: Decode's cursor-advancing loop is a while loop, which is acceptable only because it lives in a procedure and so gets no termination check.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, functions and case statements.

## External effects

- **console output** (allowed): Prints the original message, the encoded digit string and the decoded text with Put_Line.

Assessed on 2026-10-15 against page revision 383625 of the [task](https://rosettacode.org/wiki/Extended_Straddling_Checkerboard) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
