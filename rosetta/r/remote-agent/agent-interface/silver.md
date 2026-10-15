# Remote agent/Agent interface

**Excluded from Silver: network.** The program needs only enumerations, records, bounded arrays and procedures whose checks follow from types and capacity guards, but it depends on an admitted network operation with timeouts and failure results, so discharge is plausible rather than certain.

## Approach

A package holds enumeration types for event kind, color and error, a record Event, and a fixed-capacity array of events with a bounded count, plus an Agent state record with the connection flag, sector color, ball color and last error. Each command procedure sends its character through the admitted network operation, then Read_Events loops over received characters in a while loop with a case decoding each into an event under a capacity guard, and Process_Events scans the buffer with a for loop to update state and log lines. A Main procedure runs a short scripted behavior (forward, turn, get ball, drop ball) and reports connection failure, game over or protocol errors as visible outcomes. About 230 lines.

## Proof obligations to watch

- **index**: The event buffer write is guarded by a count-below-capacity test before every append, and overflow yields a visible buffer-full error outcome instead of dropping events silently.
- **termination**: The read loop is a while loop inside a procedure, which gets no termination check, and it ends on the '.' terminator, a stream-closed or timeout result from the network operation, or a full buffer.
- **range**: The event count is a bounded subtype incremented only under the capacity guard, and the for loop over 1 .. Count stays within the array range.
- **other**: Unknown bytes and handshake or connection failures must each be given a specified visible outcome (ignored with a log line or reported as failure), which depends on the admitted network operations exposing status results.

## Language surface beyond today's Silver

Enumerations, records, arrays, characters, case statements, ranged subtypes, integers, Boolean objects, procedures, functions, packages, while loops, for loops and Put without a newline.

## External effects

- **network** (not allowed): The component connects to the agent server over a TCP stream, sends one-character commands, performs the 'A' handshake and receives event characters through an admitted network library with specified failure outcomes.
- **console output** (allowed): The component logs each action and decoded event as a line of text.

Assessed on 2026-10-15 against page revision 381255 of the [task](https://rosettacode.org/wiki/Remote_agent/Agent_interface) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
