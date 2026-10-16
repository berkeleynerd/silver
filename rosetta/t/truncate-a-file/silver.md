# Truncate a file

**Excluded from Silver: directories.** The arithmetic is trivial and the copy loop's only carried value is a guarded counter, so proofs should discharge; the open work is the file, rename and delete library operations with status-based failure outcomes. The Ada solution's raised errors become specified rejections with an exit status, so no Oracle rule is broken.

## Approach

A procedure takes the file name and a bounded-range length from the first two arguments, validating and rejecting a missing or unparsable length. It streams bytes from the source into a temporary file with a while loop that stops at end of file or when the remaining count reaches zero, then, if the count reached zero and the file had more bytes, deletes the original and renames the temporary file, otherwise removes the temporary file and rejects with a specified message and exit status. Every file operation returns a status that is checked before continuing. About 70 lines.

## Proof obligations to watch

- **overflow**: The remaining-byte counter is only decremented inside a loop guarded by Count > 0, and the parsed length is a bounded natural type, so the subtraction check discharges from the guard.
- **length**: The temporary name is the file name with a suffix appended, so the bounded name buffer must be capped and over-long names rejected with a visible outcome.
- **termination**: The copy loop is a while loop inside a procedure, which gets no termination check, so no variant is needed.
- **other**: Admitted file operations must expose end-of-file, open, create, delete and rename failures as specified status results rather than exceptions, which depends on the library design.

## Language surface recorded by this assessment

Integers, ranged subtypes, modular types, Boolean objects, text parsing, further arguments, procedures, while loops, file input, file output, exit status, standard error and string building.

## External effects

- **arguments** (allowed): Reads the file name and the required length from command-line arguments.
- **files** (allowed): Reads the source file as bytes and writes a binary temporary copy through admitted file operations with specified failure outcomes.
- **directories** (not allowed): Deletes the original file and renames the temporary file over it, or deletes the temporary file on rejection.
- **exit status** (allowed): Signals the error condition (missing file, length not less than file size, bad length) through a nonzero exit status.
- **console output** (allowed): Prints a message describing the rejection or success.

Assessed on 2026-10-15 against page revision 415172 of the [task](https://rosettacode.org/wiki/Truncate_a_file) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
