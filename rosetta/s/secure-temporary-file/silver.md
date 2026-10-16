# Secure temporary file

**Candidate: proofs likely to discharge automatically.** Exclusive creation and collision handling belong to the admitted library operation's specified contract, so all the program has to prove is initialization and a guarded branch on the success flag, which discharges routinely. The real work is admitting a temporary-file operation with specified failure outcomes; the proofs themselves are not the hard part.

Position 1418 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **file output**: a file that cannot be created, and a failed or partial write.
- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

Main calls an admitted Silver file-library operation, such as Create_Temporary (File, Success), whose specified behavior is an exclusive, race-free creation with automatic collision resolution. An if statement on Success either writes a short line to the file and prints a confirmation, or prints the failure reason and sets a failure exit status. The program does no arithmetic, has no loops and does no indexing. About 25 lines.

## Proof obligations to watch

- **initialization**: The file handle and the success flag are out parameters of the admitted create operation, so flow analysis sees them initialized on every path, and the write happens only on the path where creation succeeded.

## Language surface recorded by this assessment

File output, Boolean objects and exit status.

## External effects

- **files** (allowed): The program creates a temporary file through an admitted library operation that opens it exclusively, resolves name collisions itself, and reports failure such as permission denied, a read-only filesystem or a full disk.
- **console output** (allowed): The program prints the outcome: that the file was created, or why creation failed.
- **exit status** (allowed): A failed creation is reported to the environment as a non-zero exit status, which is the error result the task asks for.

Assessed on 2026-10-15 against page revision 414458 of the [task](https://rosettacode.org/wiki/Secure_temporary_file) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
