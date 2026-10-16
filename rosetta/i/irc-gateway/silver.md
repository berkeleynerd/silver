# IRC gateway

**Excluded from Silver: network.** The task asks for a gateway that relays messages between an IRC server and another IRC server or chat server. That needs network sockets plus bounded IRC message parsing and a relay loop, all of which fit bounded strings, arrays and iteration. No fixed Oracle rule is broken, so the only gap is the network effect Silver lacks today.

## Language surface recorded by this assessment

String operations, records, arrays, loops, subprograms and enumerations.

## External effects

- **network** (not allowed): The gateway must open network connections to an IRC server and to another IRC server or chat server, and send and receive messages over them.
- **console output** (allowed): Reporting connection status and relayed messages as text; relaying traffic itself is covered by network.

Assessed on 2026-10-15 against page revision 384653 of the [task](https://rosettacode.org/wiki/IRC_gateway) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
