# Wordiff

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed-capacity buffers, for-loop scans and length guards placed before indexing, and the game loop lives in a procedure so no termination annotation is needed; the main work is careful guarding of the one-edit comparison and the bounded history. The timing stretch goals are optional and omitted, and the embedded dictionary replaces file reading.

Position 1239 in the [progression](../../progression.md#stage-20), in stage 20.

## Failure paths to test

- **standard input**: end of input before the expected data, a line longer than the buffer, and bytes outside the accepted set.

## Approach

The dictionary is an embedded constant array of bounded word records (a character buffer plus length) holding a modest word list, with a fixed-capacity history array of used words and two player-name buffers. A procedure reads names and then loops per turn: read a line, validate length and characters, check dictionary membership and history by for-loop scans, and check one-edit difference (substitution, insertion or deletion) with index-guarded comparisons. Any failed check ends the game with a printed outcome naming the losing player, and the initial 3 or 4 letter word is picked using a small deterministic generator reduced by mod. About 170 lines.

## Proof obligations to watch

- **index**: Comparing words character by character across lengths differing by one needs every index guarded by a length test just before use, which is expressible with explicit guards.
- **length**: Input lines and names are copied into fixed-capacity buffers with a stored length, and over-long or empty lines are rejected with a visible message.
- **range**: The deterministic generator is seeded from a constant and reduced with mod by the dictionary size so the chosen index stays in range.
- **termination**: The turn loop is a while loop inside a procedure and the scans are for loops, so no variant is needed.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops, procedures, functions, Put without a newline and standard input.

## External effects

- **console output** (allowed): Prompts, the first word and the loss message are written to the console.
- **standard input** (allowed): Player names and each turn's word are read as lines from standard input.

Assessed on 2026-10-15 against page revision 414587 of the [task](https://rosettacode.org/wiki/Wordiff) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
