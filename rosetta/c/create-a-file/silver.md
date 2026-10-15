# Create a file

**Excluded from Silver: directories.** The task creates two empty files and two empty directories, in the current directory and in the filesystem root. That needs only admitted file-creation and directory-creation operations, with a specified outcome (for example a message and exit status) when creation fails, such as a permission error at the root. No fixed Oracle rule is broken.

## External effects

- **files** (allowed): Creates an empty (0-byte) file named output.txt in the current directory and another in the filesystem root.
- **directories** (not allowed): Creates an empty directory named docs in the current working directory and another in the filesystem root.

Assessed on 2026-10-15 against page revision 415150 of the [task](https://rosettacode.org/wiki/Create_a_file) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
