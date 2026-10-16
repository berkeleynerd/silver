# ABC incremental counts

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded counter subtypes, for-loop indexes over the word's own range and a guard before each increment, with the file-reading while loop confined to a procedure. The only new demands are file input and bounded string handling, with no annotation needed.

Position 1328 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

A function Count_Letter(Word : String; C : Character) returns a bounded count with a for loop over Word'Range, and a generic Incremental function takes three letters in a fixed array, counts each, orders the three counts with compare-and-swap, and checks the least count is at least the minimum and that consecutive differences are exactly 1. A procedure runs the six searches (file, letters, minimum) by reading each line into a fixed-capacity buffer, rejecting overlong lines, printing matching words, and printing <none> when there are no matches. About 90 lines.

## Proof obligations to watch

- **overflow**: The per-letter counters are a subtype 0..Max_Word_Length and are incremented only under a guard that the counter is below the maximum, so the loop-carried increment discharges without an invariant.
- **length**: Lines longer than the fixed word buffer are rejected with a visible outcome, so slicing and indexing into the buffer stay in range.
- **termination**: The read-until-end-of-file loop lives in a procedure, which has no termination check, while the counting and sorting loops are for loops.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, arrays, unconstrained arrays, string indexing, 'Image of scalars, string building, for loops, while loops, procedures, functions, Boolean objects, Put without a newline and file input.

## External effects

- **files** (allowed): The dictionary words (unixdict.txt, words_alpha.txt) must be read from named files.
- **console output** (allowed): Each matching word, a heading per search, and the <none> outcome are printed.
- **arguments** (allowed): The dictionary file name can come from the first command-line argument, rejecting a missing or unreadable file.

Assessed on 2026-10-15 against page revision 405512 of the [task](https://rosettacode.org/wiki/ABC_incremental_counts) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
