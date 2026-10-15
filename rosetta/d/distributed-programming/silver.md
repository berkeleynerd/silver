# Distributed programming

**Excluded from Silver: network.** The task asks for two networked programs (or one program with two modes) exchanging messages under a generic protocol. A Silver-friendly solution is one SPARK program with a server mode and a client mode, sending bounded fixed-size messages (records and arrays of bounded strings) over a TCP connection, with a checked, specified outcome for oversized or malformed input. Nothing in the requirements breaks an Oracle rule: no exceptions, annotations, recursion or unsafe features are required, and the only gap is the network effect Silver lacks today. The existing Ada DSA solution relies on pragmas and PolyORB and is treated only as evidence.

## Language surface beyond today's Silver

Records, arrays and string operations.

## External effects

- **network** (not allowed): The task requires two programs on networked computers exchanging messages over the network, for example a TCP connection carrying a bounded, line-based message protocol.
- **arguments** (allowed): One program with two modes (server and client) and the peer address or port can be selected by a command-line argument, the natural way to pick the mode.
- **console output** (allowed): Each side prints the messages it sends and receives so the exchange is visible.

Assessed on 2026-10-15 against page revision 413982 of the [task](https://rosettacode.org/wiki/Distributed_programming) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
