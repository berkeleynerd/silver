# Last letter-first letter

**Candidate: proofs plausibly discharge automatically.** The task needs no recursion because backtracking can use an explicit bounded stack in a procedure, and all indexes are typed ranges or guarded before use, so no annotation is needed. The risk lies in loop-carried stack depth and cursor values needing careful subtypes and guards.

Position 572 in the [progression](../../progression.md#stage-10), in stage 10.

## Approach

Embed the 70 names as a constant array of fixed-width padded strings with a parallel array of lengths, and precompute first and last letters by indexing. A single procedure runs an iterative depth-first search with an explicit stack array of chosen indices and per-level cursors plus a used-flag array, copying the best chain whenever a longer one is found. After the search it prints the best length with Integer'Image and each name from its buffer using its length. About 170 lines.

## Proof obligations to watch

- **index**: The explicit DFS stack depth is a loop-carried value, so the program guards each push with a test against the 70-element capacity and has a specified visible outcome if it were reached, with all other indexes typed as ranges of 1..70.
- **range**: Candidate cursors and best-length counters are loop-carried, so they are declared with subtypes that include one-past-the-end values and incremented only after a guard just before the increment.
- **termination**: The search is an iterative while loop inside a procedure, which gets no termination check, so no variant is needed, though exhaustive backtracking over 70 names is a practical runtime concern rather than a proof one.
- **index**: Reading first and last letters from fixed-width padded name buffers requires each stored length to be a typed range within the buffer width, so the last-letter index is safe by type.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, 'Image of scalars, for loops, while loops, procedures and Put without a newline.

## External effects

- **console output** (allowed): The program prints the length of the longest chain and the names in one such chain.

Assessed on 2026-10-15 against page revision 413756 of the [task](https://rosettacode.org/wiki/Last_letter-first_letter) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
