# Brace expansion

**Candidate: proofs plausibly discharge automatically.** The task needs only bounded string buffers, array scanning and a worklist loop in a procedure, so every check follows from ranged types and explicit capacity guards with overflow of capacity rejected visibly, but the brace and comma association logic makes the program shape delicate.

Position 755 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Represent a string as a record holding a fixed-capacity Character array and a ranged length, and keep a fixed-capacity worklist array of such records. A procedure scans the top item with an escape flag and depth counter to find the outermost brace pair with at least one comma, builds one new item per branch as prefix, branch and suffix (checking capacity first), and pushes them in reverse order so output order is preserved, while items with no alternation are printed; the four test inputs are embedded and run in sequence. About 220 lines.

## Proof obligations to watch

- **index**: Scan positions, comma-position tables and stack slots are loop-carried, so each access is guarded by an explicit bound test (or the table is sized to the maximum string length) just before use.
- **length**: Building prefix & option & suffix into a bounded buffer is preceded by an explicit check that the total fits the capacity, otherwise the input is rejected with a visible message.
- **overflow**: Brace depth and counters are ranged subtypes bounded by the maximum input length, with guards before each increment so the loop-carried values cannot exceed their ranges.
- **heap**: The expansion worklist is a fixed-capacity array of bounded strings with an explicit full check, so exponential blow-up yields a specified rejection instead of unbounded growth.
- **termination**: Recursion is replaced by a worklist loop inside a procedure, which gets no termination check, so no variant is needed.
- **other**: The paired-brace and innermost-comma rules (escapes, unmatched braces, nearest-opener association) require careful scanning code whose correctness is not proved but whose run-time safety follows from guarded indexes.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, multidimensional arrays, records, string indexing, string building, for loops, while loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): Each expanded string is written to standard output, one per line, using Put_Line (and Put for quoting or markers if wanted).

Assessed on 2026-10-15 against page revision 414093 of the [task](https://rosettacode.org/wiki/Brace_expansion) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
