# Phrase reversals

**Candidate: proofs likely to discharge automatically.** Fixed-size strings and for loops over the phrase's own range make the index checks follow from bounds and guards, and the word-splitting loop lives in a procedure so no variant is needed.

Position 523 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed the 28-character phrase as a constant String, and build each result in a fixed-length String variable of the same length filled by for loops with index arithmetic such as Phrase'Last - I + Phrase'First. Word-wise reversal and word-order reversal use a procedure with a while loop that finds each word's start and end using explicit bounds guards, then copies characters into the result at computed offsets; the lines are printed with Put_Line and concatenation. About 55 lines.

## Proof obligations to watch

- **index**: Word-boundary scanning uses loop-carried start and end positions, discharged by guarding each index against the fixed phrase bounds immediately before every access.
- **termination**: The word-splitting while loop sits in a procedure, which gets no termination check, and for loops terminate by construction.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, string indexing, string building, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Prints the original phrase and the three reversal results as lines.

Assessed on 2026-10-15 against page revision 413848 of the [task](https://rosettacode.org/wiki/Phrase_reversals) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
