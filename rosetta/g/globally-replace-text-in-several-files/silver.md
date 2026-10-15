# Globally replace text in several files

**Candidate: proofs plausibly discharge automatically.** All checks are bounded-buffer index and capacity guards in procedure loops, so no annotations are needed, but the nested scan with a loop-carried position and growing output needs careful guard placement, hence plausible. File reading and writing, multiple arguments and byte-level Character buffers are all new surface rather than Oracle conflicts.

Position 1451 in the [progression](../../progression.md#stage-27), in stage 27.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **file input**: a missing or unreadable file, content larger than the buffer, and a read error part way.
- **file output**: a file that cannot be created, and a failed or partial write.

## Approach

Files are read whole into a fixed-capacity Character array (for example 64 KiB) with a length counter, then a while loop in a procedure scans for the pattern and appends either the replacement or the current character to a second bounded buffer, and the result overwrites the same file. The pattern, replacement and file names come from the arguments (the list embedded as a bounded set if argument access stays limited). Guards before every index and append reject an empty pattern, an over-capacity input or an output that would exceed capacity, with a message, and files that fail are reported without altering others. About 130 lines.

## Proof obligations to watch

- **index**: The match scan and the output copy index a bounded buffer with loop-carried positions, so each access needs an explicit guard on position plus pattern length just before use.
- **overflow**: Output length grows when the replacement is longer than the pattern, so each append is guarded against the output capacity and an overflow rejects the file visibly instead of truncating.
- **termination**: The scan loop is a while loop inside a procedure, which gets no termination check, and each iteration advances the position.
- **length**: The pattern and replacement are copied into bounded buffers after a length check, and an empty pattern or an over-long argument is rejected so that no match loop can fail to advance.

## Language surface beyond today's Silver

Integers, ranged subtypes, Boolean objects, characters, arrays, string indexing, string building, for loops, while loops, procedures, further arguments, file input, file output and Put without a newline.

## External effects

- **files** (allowed): Each named file is read in full and then rewritten with the replaced text, with specified outcomes for missing, unreadable or oversized files.
- **arguments** (allowed): The pattern, the replacement and the file names come from the command line, as in the task's list of files.
- **console output** (allowed): A one-line report of what was replaced and a rejection message for failed files.

Assessed on 2026-10-15 against page revision 412819 of the [task](https://rosettacode.org/wiki/Globally_replace_text_in_several_files) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
