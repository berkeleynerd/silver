# Chat server

**Excluded from Silver: network.** The task needs a listening socket, several clients served at once, and a shared client list, all of which are network and concurrency effects rather than conflicts. A Silver-friendly version uses a fixed number of client slots, each handled by a task declared statically, with bounded nickname and line lengths and a specified outcome for overlong input. Nothing in the task requires exceptions, assertions, access types, or recursion, so the only SPARK feature beyond today's Silver is tasking.

## Language surface recorded by this assessment

Tasking.

## External effects

- **arguments** (allowed): The server takes the listening port as its one command-line argument.
- **network** (not allowed): The server listens on a TCP socket, accepts telnet clients, and reads and writes their lines.

Assessed on 2026-10-15 against page revision 414107 of the [task](https://rosettacode.org/wiki/Chat_server) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
