# Odd words

**Candidate: proofs plausibly discharge automatically.** Every check follows from bounded types and guards, and no recursion, heap or annotation is needed, but the file-read, nonlinear odd-index arithmetic and binary-search cursors need careful shape, so the outlook is plausible rather than likely.

Position 1486 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Load unixdict.txt line by line into a fixed array of records, each holding a bounded character buffer and a length, rejecting overlong lines, overfull dictionaries and unsorted input. For each word, build the odd-index letters into a bounded buffer with a for loop, and if its length exceeds 4, binary-search the array with a while loop in a procedure and print the word and its odd word when found. Everything is in procedures with range-typed indexes and guards before each array access. About 130 lines.

## Proof obligations to watch

- **index**: Odd-letter positions 1+2*(i-1) and the binary-search midpoint are nonlinear or loop-carried, so they discharge only because word length, count and the low/high cursors are ranged subtypes with a guard before each use.
- **overflow**: Capacity limits (such as 32 characters per word and about 30000 words) are explicit, and a longer line or overfull dictionary is rejected visibly at load time instead of truncated.
- **termination**: The binary search and file-reading loops are while loops, so they live in procedures, which get no termination check.
- **other**: Binary search is only correct if the list is sorted, so the load step checks ordering and rejects an unsorted file rather than assuming it.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, string ordering, for loops, while loops, procedures, functions, file input and Put without a newline.

## External effects

- **files** (allowed): Reads the unixdict.txt word list named in the task, which needs a specified outcome when the file is missing or unreadable.
- **console output** (allowed): Prints each odd word with its derived word, plus a rejection message for invalid input.

Assessed on 2026-10-15 against page revision 393538 of the [task](https://rosettacode.org/wiki/Odd_words) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
