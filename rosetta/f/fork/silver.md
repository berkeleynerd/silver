# Fork

**Excluded from Silver: processes.** The task only needs to spawn a concurrent OS process, which a future admitted process library operation with specified failure outcomes could provide. It needs a processes effect and text output, and it breaks no fixed Oracle rule. A failed spawn can be reported as an ordinary result value, so no exception handling is needed.

## External effects

- **processes** (not allowed): The task's core requirement is spawning a new OS process that runs at the same time as the parent and independently of it.
- **console output** (allowed): Each process prints a line saying whether it is the parent or the child, to show that the spawn worked.

Assessed on 2026-10-15 against page revision 413184 of the [task](https://rosettacode.org/wiki/Fork) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
