# Echo server

**Excluded from Silver: network.** The task needs a TCP listener and client I/O, which are effects Silver lacks, but nothing the Oracle forbids. A Silver-friendly version can serve several clients at once without tasking, by polling a fixed-capacity array of connections and bounding line length with an explicit documented limit. Partial lines are buffered per connection, so a stalled client does not block others. No conflicts with the fixed rules.

## External effects

- **network** (not allowed): Must listen on TCP port 12321 on localhost and accept client connections, reading and writing their data.
- **console output** (allowed): Logging of connection information to standard output is recommended by the task.

Assessed on 2026-10-15 against page revision 413173 of the [task](https://rosettacode.org/wiki/Echo_server) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
