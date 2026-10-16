# Handle a signal

**Excluded from Silver: delay, clock, processes.** The program has to react to an asynchronous OS signal. In SPARK that means a library-level protected object attached to SIGINT with the Attach_Handler aspect (allowed under the Jorvik/Ravenscar tasking subset), plus a main loop that prints, delays and checks the handler's flag. That needs tasking and admitted signal, clock and delay operations, but no fixed Oracle rule breaks, provided the tasking profile can be selected outside the program source rather than with a pragma.

## Language surface recorded by this assessment

Integers, loops, tasking, packages and records.

## External effects

- **console output** (allowed): Prints an increasing integer on each line, then the number of seconds the program ran.
- **delay** (not allowed): Waits about half a second between lines of output.
- **clock** (not allowed): Measures elapsed run time so it can report the seconds run when the signal arrives.
- **processes** (not allowed): Must catch the asynchronous SIGINT (or SIGQUIT) signal from the OS and respond to it in a defined way.

Assessed on 2026-10-15 against page revision 413188 of the [task](https://rosettacode.org/wiki/Handle_a_signal) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
