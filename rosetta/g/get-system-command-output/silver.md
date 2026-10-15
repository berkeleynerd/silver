# Get system command output

**Excluded from Silver: processes.** The task asks for running a system command and capturing its output in a collection. This is a process-execution effect that a future Silver library operation could specify, with bounded output and a specified failure outcome. It breaks no fixed Oracle rule.

## Language surface beyond today's Silver

Arrays, string operations and loops.

## External effects

- **processes** (not allowed): The task requires executing a system command and capturing its standard output into the program.
- **console output** (allowed): The captured output is stored in a collection and, in the existing solution, printed. Printing is optional, but the Silver-friendly program would print it to show the capture worked.

Assessed on 2026-10-15 against page revision 413306 of the [task](https://rosettacode.org/wiki/Get_system_command_output) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
