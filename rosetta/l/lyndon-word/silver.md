# Lyndon word

**Candidate: proofs plausibly discharge automatically.** Duval's algorithm needs only bounded arrays, a small alphabet and loop-carried lengths, all of which can be given range types and explicit guards, so no annotation is needed. It is plausible rather than likely because the loop-carried length, the mod index and the successor step depend on careful guard placement.

Position 1007 in the [progression](../../progression.md#stage-18), in stage 18.

## Approach

Store the current word in a fixed-capacity Character array with a bounded length variable, using the embedded alphabet '0'..'1' and a constant maximum length n (say 5 or 7). A while loop in the main procedure prints the word, builds the length-n repetition into a second buffer using `mod` with a guarded nonzero length, strips trailing last-symbol characters with a guarded inner while loop, then increments the final character, and stops when the word becomes empty. About 70 lines.

## Proof obligations to watch

- **index**: The repeat-and-truncate step indexes the word with (i-1) mod Len, which is safe only if a guard `Len > 0` sits just before the loop and Len is typed 0..N.
- **range**: Incrementing the last symbol needs Character'Succ, which is safe only because the preceding strip loop leaves a symbol that an explicit guard shows is below the final alphabet symbol.
- **overflow**: Len and loop indexes are carried through a while loop with no invariant, so they must be declared with a subtype bounded by the fixed capacity and Len must be guarded before each decrement.
- **termination**: The generation loop sits in a procedure, so no termination check arises, and it ends in practice because each step either yields a lexicographically larger word or empties it.

## Language surface beyond today's Silver

Ranged subtypes, integers, integer division, characters, arrays, string indexing, string building, unconstrained arrays, for loops, while loops, procedures and conditional expressions.

## External effects

- **console output** (allowed): Each Lyndon word is printed on its own line.

Assessed on 2026-10-15 against page revision 414318 of the [task](https://rosettacode.org/wiki/Lyndon_word) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
