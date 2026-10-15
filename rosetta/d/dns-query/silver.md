# DNS query

**Excluded from Silver: network.** The Silver-friendly solution performs one DNS lookup for www.kame.net, prints each returned IPv4 and IPv6 address as text, and uses only iteration over the result list with bounded storage. The only requirement that Silver lacks is the network effect for the lookup itself, and nothing in the task asks for a run-time error, annotation, or other rule-breaking construct, so conflicts are empty. The existing Ada solutions use GNAT.Sockets, which is evidence of the effect but not a conflict.

## External effects

- **network** (not allowed): The task requires resolving www.kame.net to IPv4 and IPv6 addresses through DNS, which needs network access. Silver lacks this today, so it is an effect, not a conflict.
- **console output** (allowed): The resolved IPv4 and IPv6 addresses are printed to standard output.

Assessed on 2026-10-15 against page revision 413979 of the [task](https://rosettacode.org/wiki/DNS_query) by claude-haiku-5-5 at low effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
