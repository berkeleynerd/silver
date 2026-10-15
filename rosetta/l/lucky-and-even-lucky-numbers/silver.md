# Lucky and even lucky numbers

**Candidate: proofs plausibly discharge automatically.** Every check follows from declared index subtypes, for-loop ranges and explicit capacity guards, and all loops live in procedures so no termination variant is needed, though the loop-carried compaction indices and digit parsing need careful guard placement.

Position 1457 in the [progression](../../progression.md#stage-28), in stage 28.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Keep the lucky list in a fixed Integer array of about 120000 entries with a length variable, initialized with odd or even numbers, then sieve it in a procedure by, for each position n, reading m = list(n) and compacting the array by skipping every m-th element with guarded write and counter indices. The argument handling parses j and k (or negative k) into bounded integers with digit-overflow guards, matches lucky or evenLucky case-insensitively character by character, and rejects wrong argument counts, illegal numbers, misspellings and out-of-capacity requests with a printed message and nonzero status. Output builds a single line of numbers in a bounded string buffer for a single index, an index range, or a value range. About 230 lines.

## Proof obligations to watch

- **index**: The in-place compaction sieve uses read and write indices into a fixed array of about 120000 entries, so the for-loop read index is safe by its range and the write index needs an explicit guard against the capacity before each store.
- **overflow**: Loop-carried counters (write index, every-m-th counter, accumulated list length) are declared with ranged subtypes bounded by the capacity and guarded before increment, since no invariant can relate them.
- **range**: Parsing j and k from text must accumulate digits with a guard against exceeding a documented maximum, and the requested index or value must be checked against the generated list length with a specified rejection.
- **termination**: Every loop sits in a procedure, with the outer sieve being a for loop over n and the parse and value-range scans being for loops or while loops in procedures, so no variant is required.
- **initialization**: The list array and its length are fully initialized by a for loop before the sieve starts, which flow analysis accepts.
- **other**: The fixed capacity must cover the required 10,000th numbers (115591 and 111842) while any larger request is rejected visibly rather than truncated, and the fixed 2D-free arrays make this a documented resource limit.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, arrays, unconstrained arrays, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, Put without a newline, further arguments and exit status.

## External effects

- **arguments** (allowed): The command line supplies j, optional k or -k, and an optional lucky or evenLucky word.
- **console output** (allowed): Results, optional verbiage and error messages are printed on a single line.
- **exit status** (allowed): Missing, extra, illegal or misspelled arguments are rejected with a nonzero status.

Assessed on 2026-10-15 against page revision 412901 of the [task](https://rosettacode.org/wiki/Lucky_and_even_lucky_numbers) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
