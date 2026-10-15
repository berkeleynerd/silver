# One-time pad

**Excluded from Silver: system randomness.** The task needs true-random pad generation, file reading and writing, and letter-wise modular addition on bounded strings. None of that breaks an Oracle rule, because invalid or exhausted pads can be rejected with a specified outcome. The management sub-task is optional and is left out.

## Language surface beyond today's Silver

Arrays, loops, string operations, subprograms, characters and integers.

## External effects

- **system randomness** (not allowed): The task states the important part is true random pad data (e.g. from /dev/random), so a deterministic generator would not satisfy it.
- **files** (allowed): Pad files (.1tp) are written, read and updated to mark used lines; encrypted and decrypted output is also stored in files.
- **arguments** (allowed): The pad filename and length are user-specified, which a command-line solution takes as arguments.
- **console output** (allowed): Prints the results and status messages for the encrypt and decrypt operations.
- **standard input** (allowed): The message text to encrypt can be read from standard input.

Assessed on 2026-10-15 against page revision 414370 of the [task](https://rosettacode.org/wiki/One-time_pad) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
