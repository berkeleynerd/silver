# Write to Windows event log

**Excluded from Silver: OS services.** The task only asks to write a script status to the Windows Event Log. That needs an OS-service effect Silver lacks today. It does not break any fixed Oracle rule, because an admitted library operation could specify the call and its failure outcomes.

## External effects

- **OS services** (not allowed): Writing a status entry to the Windows Event Log is a Windows operating-system service; Silver has no admitted library operation for it.

Assessed on 2026-10-15 against page revision 415326 of the [task](https://rosettacode.org/wiki/Write_to_Windows_event_log) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
