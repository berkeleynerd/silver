# Hello world/Web server

**Excluded from Silver: network.** The Silver-friendly solution is a single sequential accept loop on port 8080 that sends the fixed text "Goodbye, World!" as plain text to each client and then closes the connection. Serving multiple clients needs only iteration, not tasking, so no Oracle rule is broken. The only missing capability is a network effect, which the Oracle permits as an admitted library operation with specified failure outcomes, so there are no conflicts.

## Language surface beyond today's Silver

Loops.

## External effects

- **network** (not allowed): The task requires listening on TCP port 8080 and accepting client connections, which needs a socket or server library that Silver does not yet admit.

Assessed on 2026-10-15 against page revision 415549 of the [task](https://rosettacode.org/wiki/Hello_world/Web_server) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
