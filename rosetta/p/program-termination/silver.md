# Program termination

**Candidate: proofs likely to discharge automatically.** The program needs only a String comparison, an if statement, output and one library operation that stops the process, so it has no arithmetic, index or loop checks and its proofs should discharge trivially. The only new piece is the exit operation's library-side contract.

Position 1336 in the [progression](../../progression.md#stage-23), in stage 23, which adds exit status.

## Failure paths to test

- **exit status**: every failure outcome reaching its specified status, and success reaching success.

## Approach

A single-threaded Main reads the first argument with First_Or_Default and tests it in an if statement. If it matches a stop word, Main prints a notice and calls an admitted library operation that ends the process with a specified exit status; otherwise it prints that it is continuing and returns normally. Comments explain the cleanup: Silver has no tasks, heap, or open files, so the operating system reclaims everything. About 22 lines.

## Proof obligations to watch

- **other**: The admitted stop operation must carry a verified no-return or program-exit contract so that flow analysis treats the code after it as unreachable without any annotation from the author.

## Language surface recorded by this assessment

Exit status.

## External effects

- **console output** (allowed): The program prints a message before stopping and another on the path where it does not stop, so the stop can be seen.
- **arguments** (allowed): The first command-line argument supplies the condition that triggers the stop, so the conditional is real rather than constant.
- **exit status** (allowed): Stopping the whole program from inside the conditional needs an admitted library operation that ends the process with a specified exit status.

Assessed on 2026-10-15 against page revision 415100 of the [task](https://rosettacode.org/wiki/Program_termination) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
