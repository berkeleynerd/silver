# MAC vendor lookup

**Excluded from Silver: network, delay.** The task needs a network lookup of a MAC address, returning N/A for no match and a null result for network or API errors. No fixed Oracle rule is broken, so network is only an effect Silver lacks today, with a delay between calls and console output. A future admitted network library operation with specified failure outcomes could cover it.

## Language surface beyond today's Silver

String operations, arrays, loops and subprograms.

## External effects

- **network** (not allowed): The task requires querying an internet API (such as api.macvendors.com) to retrieve the manufacturer for a MAC address.
- **console output** (allowed): Results (vendor name or N/A) are printed.
- **delay** (not allowed): The task advises pausing between calls to avoid API throttling.

Assessed on 2026-10-15 against page revision 413769 of the [task](https://rosettacode.org/wiki/MAC_vendor_lookup) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
