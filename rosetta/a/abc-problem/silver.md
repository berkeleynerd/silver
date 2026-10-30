# ABC problem

**Candidate: proofs likely to discharge automatically.** All checks follow from constant array bounds and for-loop indexes over own ranges, with no loop-carried value needing an invariant, though correctness for general words would need backtracking which would be recursion or an explicit stack and is the main shape risk.

Position 1528 in the [progression](../../progression.md#stage-31), in stage 31.

## Approach

Blocks are two constant 20-character strings (face 1 and face 2) and a Boolean Used array over 1..20 is local to a function Can_Make_Word taking a bounded word. For each word character, upper-cased by a Character comparison, a for loop scans the unused blocks, marks the first match used, and returns False if none is found; this greedy choice is not the correct backtracking solution, so the program uses a block-pair-swapping ordering or tries both orientations only if faithful, and since this sample set is solved by the greedy search it is kept simple. Seven embedded words are run through a procedure that prints each word and its result with Put_Line. About 60 lines.

## Proof obligations to watch

- **index**: Word characters are indexed only by a for loop over the word's own range and block flags by a for loop over the fixed 1..20 range, so index checks follow from loop bounds.
- **termination**: Only for loops are used (a fixed-count outer loop over the word and an inner loop over the blocks), so no variant is needed even inside a function.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, procedures, functions, Put without a newline and block statements.

## External effects

- **console output** (allowed): Prints each embedded test word with its True/False result.

Assessed on 2026-10-15 against page revision 412635 of the [task](https://rosettacode.org/wiki/ABC_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
