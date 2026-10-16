# Events

**Excluded from Silver: delay.** The task asks for a manual-reset event that one task waits on while the main program signals it after 1 second. That needs a second task and a synchronization object. SPARK allows this under the Ravenscar/Jorvik profiles, using a protected object with a Boolean-barrier entry, so no fixed Oracle rule is broken. It only needs tasking, delay and console output, which Silver does not have yet.

## Language surface recorded by this assessment

Tasking, records and packages.

## External effects

- **delay** (not allowed): The program must wait 1 second before signaling the event.
- **console output** (allowed): Prints messages showing the task waiting for the event and then receiving it.

Assessed on 2026-10-15 against page revision 412774 of the [task](https://rosettacode.org/wiki/Events) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
