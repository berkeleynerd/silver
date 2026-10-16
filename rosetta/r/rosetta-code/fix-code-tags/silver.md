# Rosetta Code/Fix code tags

**Candidate: proofs plausibly discharge automatically.** The task is bounded string scanning and rewriting over embedded data, so all checks come from buffer-capacity and index guards before each access, though several loop-carried positions need careful guarding without invariants.

Position 1031 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

Embed the three example texts as an array of fixed-length line constants with a per-line length. A procedure scans each line character by character into a bounded output buffer, recognizing "<lang>", "<lang NAME>" and "</lang>" and emitting the syntaxhighlight forms, then prints the buffer with Put_Line. Lines longer than the limit or tag expansions that exceed the buffer are rejected with a visible message. About 170 lines.

## Proof obligations to watch

- **index**: Scanning for the closing '>' and slicing the tag name uses loop-carried positions that are discharged by comparing them to Line'First and Line'Last just before each access.
- **length**: Each rewritten tag is longer than the original, so a guard before every append checks remaining buffer capacity and reports an overflow outcome instead of truncating.
- **overflow**: The output length and scan position are loop-carried but are held in bounded subtypes with guards before each increment.
- **termination**: All scanning is done with for loops or with while loops inside procedures, so no function needs a variant.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, string building, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The fixed example texts are rewritten and printed line by line.

Assessed on 2026-10-15 against page revision 415225 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Fix_code_tags) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
