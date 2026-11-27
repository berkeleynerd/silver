# Canonical namespace contracts and direct callers

2026-11-27, Linux x86-64. The namespace blockers are tracked as
[#426](https://github.com/berkeleynerd/silver/issues/426) and
[#427](https://github.com/berkeleynerd/silver/issues/427), within #416.
All checks in this packet use `scripts/dev.py prove`
with its canonical focused final policy: complete selected helper/unit,
all flow and proof obligations, level 2, cvc5/z3/altergo and the unchanged
30-second timeout. Each run reserved two workers within the shared eight-CPU
allocation; its ledger and summary retain the actual CPU affinity. Selected
proof role was GPT-6 Astra Max; runtime settings are not independently exposed.

| Complete selection | Run | Outcome |
| --- | --- | --- |
| `silver_names.adb` | `20261127T183145-df8197ddc96d` | 138/138: 27 flow, 111 proof; 27.814 s. All 12 declared entities have `all` coverage. |
| `Package_Name_Allowed`, body declaration 7925 | `20261127T183236-cbad4c88cef4` | 113/113: 2 flow, 111 proof; 93.821 s. The selected helper has `all` coverage. |
| `Call_After`, declaration 657 | `20261127T183750-dd1b3af8e76e` | 19/19: 2 flow, 17 proof; 41.957 s. Selected entity has `all` coverage. |
| `Argument_At`, declaration 2708 | `20261127T183902-1e32f4de3af9` | 21/21: 2 flow, 19 proof; 83.446 s. Selected entity has `all` coverage. |
| `Imported_Package`, public declaration 100 | `20261127T184051-950b2fdb7d81` | 39/39: 2 flow, 37 proof; 53.764 s. Selected entity has `all` coverage. |

All selections preserve their full declared input domains. Names includes the
optional absent package, every operation enum value and both hidden/qualified
branches. The identity helper includes arbitrary String/Name_Span inputs and
its complete short-circuit validity guards. Every `.spark` report was inspected
for the selected entity coverage and checked-row totals. The retained summary,
SPARK report, SARIF report, raw output and ledger bind each result to its exact
inputs; separate source snapshots are checked against the managed input hashes.

Both direct callers of `Names.Operation_After` and the discovery caller of
`Package_Name_Allowed` pass here. The second identity caller, `Package_Spec_At`,
is being rechecked with its strengthened original-unit preservation contract.
The Main/Analyze/public-wrapper gates and complete final compiler, Lean and
source-correspondence checkpoints remain required. These focused successes
alone do not establish feature completion.
