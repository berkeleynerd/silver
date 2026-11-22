# Print itself

**Candidate: proofs likely to discharge automatically.** Every index comes from a for loop over the constant's own range and there are no accumulators, so all checks follow from types and static bounds. The task needs only console output, and a self-embedding quine satisfies it without file access or any annotation.

Position 484 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Write a classic quine instead of opening the source file: a constant String holds the program text with a marker where the text itself is embedded, and a few Put calls emit the part before the marker, then the constant re-quoted with each double quote doubled, then the part after the marker. The re-quoting is a for loop over the constant's own index range that tests each Character and calls Put with a one-character slice, so no loop-carried state exists. About 25 lines.

## Language surface recorded by this assessment

Characters, string indexing, for loops, Put without a newline and procedures.

## External effects

- **console output** (allowed): The program writes its own source text to standard output.

Assessed on 2026-10-15 against page revision 412328 of the [task](https://rosettacode.org/wiki/Print_itself) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
