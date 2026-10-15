# Find duplicate files

**Excluded from Silver: directories.** The task needs a command-line program that walks a directory tree, compares file contents by hash or byte comparison, and prints duplicate sets sorted by size. This works with bounded arrays and strings and iteration (an explicit stack for the directory walk), so it needs only directory, file, argument and console effects. It has no fixed-rule conflict, but it depends on library operations that do not exist yet. The extra-credit parts, removing or linking files and detecting identical subtrees, are optional.

## Language surface beyond today's Silver

Integers, characters, string operations, arrays, records, loops, subprograms, packages and big numbers.

## External effects

- **arguments** (allowed): Takes the minimum size and the root directory as command-line arguments.
- **directories** (not allowed): Recursively walks the directory tree and inspects file metadata such as size and file kind, and must identify hard links.
- **files** (allowed): Reads the contents of each candidate file to compare it directly or hash it.
- **console output** (allowed): Prints the sets of duplicate files in order of decreasing size.

Assessed on 2026-10-15 against page revision 414208 of the [task](https://rosettacode.org/wiki/Find_duplicate_files) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
