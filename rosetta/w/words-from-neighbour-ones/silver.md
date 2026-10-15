# Words from neighbour ones

**Candidate: proofs plausibly discharge automatically.** Every check follows from fixed-capacity typed ranges, for-loop indexes over the table and guards before use, with all while loops in procedures, but file reading, bounded line handling and the 2D table add shape-dependent work. No annotation is needed, so it is plausible rather than likely.

Position 1335 in the [progression](../../progression.md#stage-23), in stage 23.

## Failure paths to test

- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.

## Approach

Read unixdict.txt in a procedure with a bounded line buffer, keeping only words of length 9 or more as a 2D Character table of their first nine characters plus a flag for exactly nine, rejecting input beyond the fixed capacity. For each n up to Count-8, build the nine-character diagonal word by indexing row n+k-1 column k, then scan the table for an exact length-9 match using a for loop, skipping repeats of the previously printed word, and print matches with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: Word storage and the n+k-1 row lookups are safe only because the loop bound is Count-8 and a guard rejects the file when more than the fixed capacity of words arrives, which is a visible outcome.
- **length**: Each line is read into a bounded buffer with an explicit length guard, and over-long lines are rejected visibly rather than truncated.
- **overflow**: The word counter and output counter are typed ranges bounded by the capacity, with a guard before every increment, so no loop-carried value needs an invariant.
- **termination**: The line-reading and lookup loops are while loops inside procedures (no termination check), and the lookup is a for loop over the fixed word table.
- **initialization**: The word table and result list must be fully initialized by aggregate or loop before reads, which is routine but costs a nested initialization loop that flow analysis must accept.

## Language surface beyond today's Silver

Integers, ranged subtypes, characters, Boolean objects, arrays, multidimensional arrays, string indexing, string building, for loops, while loops, procedures, functions, file input and Put without a newline.

## External effects

- **files** (allowed): Reads the dictionary file unixdict.txt line by line, with a specified outcome if it is missing or unreadable.
- **console output** (allowed): Prints each matching nine-letter word on its own line.

Assessed on 2026-10-15 against page revision 405564 of the [task](https://rosettacode.org/wiki/Words_from_neighbour_ones) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
