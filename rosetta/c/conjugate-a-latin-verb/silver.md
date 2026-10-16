# Conjugate a Latin verb

**Candidate: proofs likely to discharge automatically.** All work is bounded string assembly over fixed-size buffers with for loops and constant ending tables, so every index and length check follows from static bounds and a single guard before the copy.

Position 539 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Embed four example infinitives (amare, monere, regere, audire) in a constant array of fixed-length strings with recorded lengths, plus constant arrays of six present-tense endings per conjugation. A procedure takes a conjugation number and an infinitive, checks the length exceeds the 3-character suffix, copies the stem into a bounded buffer, and a for loop over 1..6 appends each ending and prints the line. A too-short verb prints a specified rejection message instead of conjugating. About 90 lines.

## Proof obligations to watch

- **index**: Stem slicing and bounded-buffer appends are guarded by the verb length checks and by a buffer sized for the longest stem plus the longest ending.
- **length**: Assembling stem plus ending into a fixed buffer needs a length guard before each copy, which the program supplies via a bounded stem length and a Last counter.

## Language surface recorded by this assessment

Ranged subtypes, arrays, for loops, procedures, string indexing, string building, characters, integers and Put without a newline.

## External effects

- **console output** (allowed): Prints the six conjugated forms of each example verb, one per line.

Assessed on 2026-10-15 against page revision 412723 of the [task](https://rosettacode.org/wiki/Conjugate_a_Latin_verb) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
