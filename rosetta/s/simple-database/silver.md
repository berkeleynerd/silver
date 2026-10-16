# Simple database

**Candidate: proofs plausibly discharge automatically.** All checks follow from bounded buffers, ranged counts and guards before each index, with no recursion or annotation needed, but the program is large and relies on admitted multi-argument and file operations that Silver lacks today. Outlook is plausible because loop-carried cursors and counts need careful guards, not because any fact requires an invariant.

Position 1499 in the [progression](../../progression.md#stage-29), in stage 29.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Entries are records of bounded description, category and date text (fixed buffers plus lengths) held in a fixed-capacity array with a ranged count; the file stores one delimiter-separated line per entry and is loaded in a while loop inside a procedure, rejecting overlong or malformed lines. The first argument selects add, latest, per-category latest or sorted-by-date, add appends and rewrites the file, latest-per-category scans with for loops, and the sort is an insertion or selection sort over an index copy comparing the date strings. Every capacity, argument-count and file-status condition is guarded with a visible rejection and nonzero exit. About 260 lines.

## Proof obligations to watch

- **index**: Entry counts and string cursors are loop-carried, so each use is guarded by explicit tests against the capacity and the bounded field length, and the entry count is a ranged subtype.
- **length**: Fields are stored in fixed-capacity buffers with a length component, and any argument or file line exceeding the limit is rejected visibly instead of truncated.
- **termination**: Line-splitting and file-reading loops are while loops confined to procedures, which get no termination check, while the sort uses only for loops.
- **initialization**: The entry table and buffers are fully initialized by aggregate before loading, so flow analysis passes.
- **other**: File open, read and write failures and a full database must each map to a specified visible outcome, which depends on the admitted file library exposing status results.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, records, arrays, string indexing, string building, string ordering, text parsing, for loops, while loops, procedures, functions, further arguments, file input, file output, exit status and Put without a newline.

## External effects

- **arguments** (allowed): The command (add, latest, latest-per-category, sorted) and the add fields description, category and date arrive as command-line arguments.
- **files** (allowed): The database is read from and rewritten to a line-oriented text file on disk, with specified outcomes for a missing, unreadable or unwritable file.
- **console output** (allowed): Entries and rejection messages are printed to the console.
- **exit status** (allowed): Invalid commands, malformed arguments, a full database or a failed save end with a nonzero status.

Assessed on 2026-10-15 against page revision 415010 of the [task](https://rosettacode.org/wiki/Simple_database) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
