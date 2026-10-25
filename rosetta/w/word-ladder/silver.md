# Word ladder

**Candidate: proofs plausibly discharge automatically.** Everything is bounded arrays and nested for/while loops in procedures, so checks follow from range subtypes and capacity guards without annotations. The main uncertainty is the loop-carried queue and parent indexes plus the dictionary file-reading library operation, which needs specified failure outcomes.

Position 1333 in the [progression](../../progression.md#stage-22), in stage 22.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Load the unixdict file through an admitted line-reading operation into a fixed-capacity two-dimensional Character array with a length array, keeping only lowercase words, then for each demo pair run an iterative breadth-first search over words of the start length using an array queue and parent array, treating two words as neighbours when they differ in exactly one position. The path is rebuilt by walking parents into a bounded array and printed with Put and Put_Line, with explicit messages for unequal lengths, words not in the dictionary, and no ladder found. About 170 lines.

## Proof obligations to watch

- **index**: Queue head and tail and parent-chain indexes are loop-carried, so each increment is guarded by a capacity test and indexes are typed as subtypes of the dictionary range.
- **overflow**: Dictionary count, queue tail and ladder length are range-typed with explicit full-capacity guards that visibly reject oversized input rather than truncating.
- **length**: Word lengths are bounded by a fixed maximum, and lines that are too long or contain non-lowercase characters are skipped explicitly with a specified outcome.
- **termination**: The breadth-first search and path walk use while loops only inside procedures, which get no termination check, and the search is bounded by the visited marks anyway.
- **initialization**: All arrays of words, parents and visited flags are fully initialized by loops or aggregates before use.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, string indexing, string building, procedures, functions, for loops, while loops, file input and Put without a newline.

## External effects

- **files** (allowed): The unixdict word list must be read from a named file.
- **console output** (allowed): Each ladder, or a no-solution message, is printed to the console.

Assessed on 2026-10-15 against page revision 413966 of the [task](https://rosettacode.org/wiki/Word_ladder) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
