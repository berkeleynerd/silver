# Changeable words

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared ranges, for-loop indexes and guards on line length and table capacity, and nothing needs an annotation, but the file-reading procedure and the loop-carried counter need careful shape, so the outlook is plausible.

Position 1356 in the [progression](../../progression.md#stage-24), in stage 24.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Read unixdict.txt line by line in a procedure with a while loop, keeping only words of 12 or more characters in a fixed array of records holding a 32-character buffer and a length, rejecting overlong words or a full table with a visible failure. Then a pair of nested for loops over table indexes compares words of equal length, counting differing characters with a saturating counter, and prints each pair with Put and Put_Line using slices of the stored length. About 90 lines.

## Proof obligations to watch

- **index**: Reading each line into a fixed 32-character buffer with a stored length needs explicit guards rejecting lines longer than 32 and a full table of 1024 entries, after which all indexing follows from the declared ranges.
- **overflow**: The count of differing letters is a loop-carried value, so it is kept in a small ranged subtype and saturated at 2 by a guard, which preserves the exactly-one-difference test.
- **termination**: The line-reading while loop lives in a procedure, which gets no termination check, and the pairwise comparison uses only for loops.
- **length**: Output slices Word(1..Len) depend on the stored length, which is bounded by its subtype range, and Len is compared for equality between the two words before characters are compared.

## Language surface recorded by this assessment

Integers, ranged subtypes, characters, arrays, records, string indexing, string building, for loops, while loops, procedures, functions, Boolean objects, file input, exit status, Put without a newline and conditional expressions.

## External effects

- **files** (allowed): The program reads the named dictionary file unixdict.txt line by line, with a specified outcome when it is missing or unreadable.
- **console output** (allowed): Each matching word pair is printed as one line on standard output.
- **exit status** (allowed): An unreadable dictionary or one exceeding the stated capacity is rejected with a visible failure status.

Assessed on 2026-10-15 against page revision 403584 of the [task](https://rosettacode.org/wiki/Changeable_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
