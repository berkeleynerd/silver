# Sockets

**Excluded from Silver: network.** The task needs one outgoing TCP connection to localhost:256 and a single text send, which is a network effect that a future admitted socket library operation could provide with a specified failure outcome. No fixed Oracle rule is broken: the task explicitly says catching errors is not required, so no exception handling, assertions or unsafe constructs are needed. The existing GNAT.Sockets solution is evidence only; a Silver version would use the same effect with no extra SPARK features.

## External effects

- **network** (not allowed): The program must open a TCP connection to localhost on port 256 and send the text "hello socket world" over it.

Assessed on 2026-10-15 against page revision 413230 of the [task](https://rosettacode.org/wiki/Sockets) by claude-haiku-5-5 at low effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
