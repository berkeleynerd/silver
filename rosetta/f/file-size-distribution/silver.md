# File size distribution

**Excluded from Silver: directories.** The task counts files by size bucket across a directory tree. This needs only directory listing and metadata, an optional argument and text output. Buckets can be computed with integer comparisons against powers of ten, and traversal can use an explicit bounded stack, so nothing conflicts with the Oracle rules. A missing or invalid directory gets a specified message.

## Language surface recorded by this assessment

Integers, arrays, loops, subprograms, string operations and enumerations.

## External effects

- **directories** (not allowed): Walks a directory hierarchy, listing entries and reading file kind and size.
- **arguments** (allowed): Optional command-line argument names the starting directory, defaulting to the current directory.
- **console output** (allowed): Prints the count of files per size bucket and a message when the directory is missing.

Assessed on 2026-10-15 against page revision 414204 of the [task](https://rosettacode.org/wiki/File_size_distribution) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
