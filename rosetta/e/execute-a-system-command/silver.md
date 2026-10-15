# Execute a system command

**Excluded from Silver: processes.** The task only asks to run a fixed command like 'ls', so the only thing it needs is a process-execution effect. No Oracle rule rules that out, because Rule 6 lets a specified library operation such as a spawn with a checked return code provide it; the foreign-call import in the existing solution is just one way to write it, not a requirement, so the task is a candidate once a process library is admitted.

## Language surface beyond today's Silver

String operations and subprograms.

## External effects

- **processes** (not allowed): The task's whole point is running the 'ls' (or 'pause') system command, so a future Silver would need an admitted, fully specified process-spawn library operation.
- **console output** (allowed): The child command's output (the directory listing) goes to standard output.

Assessed on 2026-10-15 against page revision 412776 of the [task](https://rosettacode.org/wiki/Execute_a_system_command) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
