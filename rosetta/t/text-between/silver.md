# Text between

**Candidate: proofs plausibly discharge automatically.** All checks reduce to index arithmetic bounded by for-loop ranges and explicit guards before the slice, with no need for invariants, so discharge is plausible but depends on careful loop-carried position handling. The task needs only strings, loops and console output, with no conflicts with the Oracle.

Position 1013 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

A procedure Between takes three unconstrained String parameters, handles the special values "start" and "end" by String equality, and otherwise searches for each delimiter with a for loop over candidate start positions that compares a delimiter-length slice, exiting at the first match and recording the position in a Boolean-flagged Natural variable. It guards against empty delimiters and against out-of-range slice bounds before printing the result slice, and a driver in Main calls it for the nine embedded examples via Put_Line. About 80 lines.

## Proof obligations to watch

- **index**: Slices of the text and delimiter comparisons need start and stop positions known to lie within the text's bounds, which the program establishes by recording positions only inside for loops over bounded ranges and re-checking them with an explicit guard before slicing.
- **overflow**: Computing the position after a delimiter (match position plus delimiter length) could overflow near Integer'Last, so the program computes it only inside the loop where the match position is bounded by Text'Last minus the delimiter length, and stores it in a wider Natural-like subtype.
- **length**: Comparing a text slice with a delimiter needs equal lengths, which holds because the search range is limited to start positions that leave room for the whole delimiter and an empty delimiter is rejected up front.
- **other**: The task promises non-empty delimiters but the prover cannot know this, so the program guards with an explicit visible rejection message for empty delimiters.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, unconstrained arrays, string indexing, string building, for loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): Each example's text, delimiters and result are printed with Put_Line.

Assessed on 2026-10-15 against page revision 410929 of the [task](https://rosettacode.org/wiki/Text_between) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
