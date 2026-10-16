# IPC via named pipe

**Excluded from Silver: processes, OS services, delay.** The task is a server that tallies bytes written to an 'in' FIFO and reports the running total to readers of an 'out' FIFO. A Silver-friendly solution can poll both pipes in one sequential loop, with a bounded total and a visible outcome on overflow, so no Oracle rule is broken. It does need FIFO, file and inter-process effects that Silver lacks today and that would have to come from admitted library operations.

## Language surface recorded by this assessment

Loops, integers, subprograms and packages.

## External effects

- **files** (allowed): Creates and opens named pipes (FIFOs) on the file system and reads and writes them as files.
- **processes** (not allowed): The pipes exist to communicate with other processes, which write to the 'in' pipe and read the 'out' pipe, so the program is a long-running server.
- **OS services** (not allowed): Creating a FIFO (mkfifo) and handling blocking open and read calls on it are operating-system services. The program must also stay responsive on both pipes by polling or multiplexing.
- **delay** (not allowed): Polling the two pipes in a loop, instead of blocking on one, would sleep between polls.

Assessed on 2026-10-15 against page revision 389740 of the [task](https://rosettacode.org/wiki/IPC_via_named_pipe) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
