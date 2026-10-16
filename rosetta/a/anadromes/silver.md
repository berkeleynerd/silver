# Anadromes

**Candidate: proofs plausibly discharge automatically.** Every check follows from ranged subtypes, bounded buffers and for-loop bounds, but the large fixed tables, hash probing and loop-carried counts need careful shape; loops live in procedures and probing is bounded, so discharge is plausible rather than routine.

Position 1490 in the [progression](../../progression.md#stage-30), in stage 30.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

The program reads each line of words.txt (path from the first argument) into a fixed-capacity table of bounded words (length-tracked buffer plus count), rejecting over-long lines or overflow of capacity, and inserts each word's index into an open-addressing hash table using a modular hash and a bounded probe loop. A second pass over the stored words skips those of 6 or fewer characters, builds the reversed word by a for loop into a bounded buffer, looks it up in the hash table, and prints a padded pair only when word is less than its reverse so each pair appears once. About 120 lines.

## Proof obligations to watch

- **index**: Hash probing and word-table indexing are kept in range by subtypes sized to the table, modular wraparound of the index, and a bounded for-loop probe count rather than an unbounded search.
- **overflow**: The hash is computed in a modular type so wraparound is intended and no overflow check arises, and the loop-carried word count is a ranged subtype guarded against capacity before each insertion.
- **length**: Lines longer than the fixed word buffer, and word lists exceeding table capacity, are rejected with a visible outcome rather than truncated.
- **initialization**: The large word table and hash table must be fully initialized by aggregate or loop before use, which is routine but sizeable.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, modular types, Boolean objects, characters, arrays, records, string indexing, string building, string ordering, for loops, while loops, procedures, functions and file input.

## External effects

- **files** (allowed): The task requires reading the words.txt word list line by line.
- **console output** (allowed): Each anadrome pair is printed as a line of text.
- **arguments** (allowed): The words file path is taken from the first command-line argument, with a rejected-input outcome if missing or unreadable.

Assessed on 2026-10-15 against page revision 414628 of the [task](https://rosettacode.org/wiki/Anadromes) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
