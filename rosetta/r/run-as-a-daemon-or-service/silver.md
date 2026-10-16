# Run as a daemon or service

**Excluded from Silver: processes, delay.** The task needs a loop that writes a message to stdout about once a second, plus an operating-system process operation that detaches the program from the terminal or launches it with stdin and stdout redirected to files. These are external effects that admitted library operations could provide in a future Silver, so no fixed Oracle rule is broken and the task is a candidate.

## Language surface recorded by this assessment

Loops, string operations and subprograms.

## External effects

- **processes** (not allowed): The program must detach from its controlling terminal and run in the background, for example by forking and starting a new session. Where that is not possible, a helper program written in Silver must launch the worker process with its stdin and stdout redirected.
- **files** (allowed): The program's stdout (and stdin) must be redirected to files: either the daemon reopens them itself, or the helper opens them before it starts the worker.
- **console output** (allowed): The worker writes a message to its standard output stream.
- **delay** (not allowed): The worker writes its message roughly once a second, so it sleeps about one second between writes.

Assessed on 2026-10-15 against page revision 385230 of the [task](https://rosettacode.org/wiki/Run_as_a_daemon_or_service) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
