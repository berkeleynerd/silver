# Draft:GC-60 Passive Window Prime Sieve

**Candidate: proofs plausibly discharge automatically.** Everything is bounded loops over fixed-capacity arrays in procedures with explicit guards, so no annotations should be needed, but 128-bit arithmetic, text parsing and guarded loop-carried positions need careful shape and the required multithreading cannot be provided.

Position 1452 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.
- **further arguments**: too few or too many arguments, and an empty or invalid argument.
- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Parse A and W from the arguments into bounded unsigned values (accepting digits or base^exp, rejecting overflow), generate base primes up to the integer square root of A+W with a fixed-capacity segmented sieve, then mark multiples in a window-sized Boolean array by stepping with additions only along each of the 16 residue rails in turn. Surviving offsets are formatted into a bounded text buffer and written to finestra_1.txt, with every capacity and range check guarded and failures reported. About 260 lines.

## Proof obligations to watch

- **overflow**: Parsing base^exponent, computing A+W and sieve positions need 128-bit-capable fixed-width values with guards rejecting inputs whose A+W exceeds the documented limit.
- **range**: Loop-carried sieve positions and window indices stay in range only if each step is guarded against the array bound immediately before use, with no invariant.
- **index**: The compressed window array has a fixed capacity, so W is validated against it before indexing, with oversized W rejected visibly.
- **termination**: All while loops (stride marking, prime enumeration) live in procedures, which get no termination check, so no variant is needed.
- **other**: The task asks for 16 parallel threads, which cannot be expressed without tasking, so the program processes the 16 rails sequentially as logical partitions, a deviation from the stated requirement.
- **floating point**: The square root bound must be computed by integer search rather than floating point to keep the proof routine.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, modular types, big numbers, Boolean objects, characters, arrays, unconstrained arrays, string indexing, text parsing, 'Image of scalars, string building, for loops, while loops, procedures, functions, further arguments, file output and exit status.

## External effects

- **arguments** (allowed): A and W are read from the first two command-line arguments, including the base^exponent notation.
- **files** (allowed): The prime offsets are written to finestra_1.txt, with a specified outcome when the file cannot be written.
- **console output** (allowed): Rejection of invalid arguments and a short summary are printed.
- **exit status** (allowed): Invalid input or a failed file write must produce a nonzero exit status.

Assessed on 2026-10-15 against page revision 413605 of the [task](https://rosettacode.org/wiki/Draft:GC-60_Passive_Window_Prime_Sieve) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
