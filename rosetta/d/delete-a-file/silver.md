# Delete a file

**Excluded from Silver: directories.** The task needs two deletions (input.txt and docs) in each of two locations, so four fixed operations with no data-dependent logic. This is a file and directory effect that a future Silver library could admit, provided the outcome for a missing or undeletable target is specified. Nothing in it breaks an Oracle rule.

## External effects

- **files** (allowed): Deleting the named file input.txt, both in the current working directory and at the filesystem root, needs a library operation that deletes a file and reports a specified outcome (for example when the file is missing or not permitted).
- **directories** (not allowed): Deleting the directory docs, both in the current working directory and at the filesystem root, needs a library operation that removes a directory and reports a specified outcome. This is directory removal, not file I/O.

Assessed on 2026-10-15 against page revision 415101 of the [task](https://rosettacode.org/wiki/Delete_a_file) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
