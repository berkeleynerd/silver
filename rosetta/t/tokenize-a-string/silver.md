# Tokenize a string

**Candidate: proofs likely to discharge automatically.** Every index and counter check follows from ranged subtypes, for loops over the input's own range and a capacity guard just before each store, so no invariant or variant is needed. The program needs only Put and a few basic Ada features, and its token arrays are fixed-size.

Position 491 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the 23-character input as a String constant and declare two bounded arrays holding each token's start and stop positions as a ranged subtype of the input's index range. One for loop over the input indices records a token boundary at each comma and at the end, with an explicit capacity guard on the token count. A second for loop over the stored tokens prints each token's characters with Put (using one-character slices) followed by a period. About 35 lines.

## Proof obligations to watch

- **index**: Token start and stop positions stored in arrays are loop-carried, so they are declared with a subtype of the input's index range and the count is guarded against the array capacity before each store.
- **overflow**: The token counter is a small ranged subtype that is incremented only after a guard confirms it is below its maximum.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, string indexing, for loops and Put without a newline.

## External effects

- **console output** (allowed): The words are printed separated by periods, without line terminators between them.

Assessed on 2026-10-15 against page revision 415381 of the [task](https://rosettacode.org/wiki/Tokenize_a_string) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
