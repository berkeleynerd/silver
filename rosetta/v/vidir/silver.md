# Vidir

**Excluded from Silver: directories, processes.** The task is a bulk file-renaming tool. It lists a directory to a text file, runs an external editor on it, then renames or deletes files to match the edit. None of this breaks an Oracle rule. It needs directory, file and process effects that Silver lacks today, and bounded string handling for parsing the edited lines. Invalid or mismatched edits can be rejected with a visible outcome.

## Language surface recorded by this assessment

String operations, loops, subprograms, arrays, records, integers and characters.

## External effects

- **directories** (not allowed): Lists the file names in the current directory.
- **files** (allowed): Writes the numbered listing to a text file, reads the edited file back, renames files and deletes files.
- **processes** (not allowed): Launches an external text editor on the listing file so the user can edit it.
- **console output** (allowed): Prints a message for each rename or delete and a completion message.

Assessed on 2026-10-15 against page revision 397731 of the [task](https://rosettacode.org/wiki/Vidir) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
