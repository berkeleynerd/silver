# Canonical namespace contracts and direct callers

2026-11-27, Linux x86-64. All checks in this packet use `scripts/dev.py prove`
with its canonical focused final policy: complete selected helper/unit,
all flow and proof obligations, level 2, cvc5/z3/altergo and the unchanged
30-second timeout. Each run reserved two workers within the shared eight-CPU
allocation; its ledger and summary retain the actual CPU affinity. Selected
proof role was GPT-6 Astra Max; runtime settings are not independently exposed.

| Complete selection | Run | Outcome |
| --- | --- | --- |
| `silver_names.adb` | `20261127T183145-df8197ddc96d` | 138/138: 27 flow, 111 proof; 27.814 s. All 12 declared entities have `all` coverage. |
| `Package_Name_Allowed`, body declaration 7925 | `20261127T183236-cbad4c88cef4` | 113/113: 2 flow, 111 proof; 93.821 s. The selected helper has `all` coverage. |

Both selections preserve their full declared input domains. Names includes the
optional absent package, every operation enum value and both hidden/qualified
branches. The identity helper includes arbitrary String/Name_Span inputs and
its complete short-circuit validity guards. Every `.spark` report was inspected
for the selected entity coverage and checked-row totals. The retained summary,
SPARK report, SARIF report, raw output and ledger bind each result to its exact
inputs; separate source snapshots are checked against the managed input hashes.

The direct `Call_After` and `Argument_At` caller checks remain pending at this
checkpoint. The previous Main/Analyze/public-wrapper gates and complete final
compiler, Lean and source-correspondence checkpoints remain required. These
focused successes alone do not establish feature completion.
