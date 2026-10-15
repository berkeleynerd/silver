# OLE automation

**Excluded from Silver: OS services, processes.** The task needs a COM/OLE automation server and an out-of-process client exchanging variant values. That is an operating-system service and inter-process effect that a future admitted library could specify, so it is an effect gap rather than a fixed-rule conflict. Variants can be modelled as a discriminated record, so no Oracle rule is broken.

## Language surface beyond today's Silver

Records, subprograms and enumerations.

## External effects

- **OS services** (not allowed): OLE Automation is a Windows COM mechanism, an operating-system service the task requires for the server and the proxy-object client.
- **processes** (not allowed): The server and client must run in separate processes and communicate across the process boundary.

Assessed on 2026-10-15 against page revision 382448 of the [task](https://rosettacode.org/wiki/OLE_automation) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
