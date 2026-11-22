# #421 probe working notes

The initial `baseline` probe is retained unchanged. Run `20261122T123645-37d7c9eab9cd` failed at `main.adb:2`: a configuration SPARK_Mode pragma placed after the context clause is illegal. This is a probe source-placement error, not a profile/runtime limitation. `baseline-v2` moves the identical pragma before the context clause. No production source changed.

Package-state comparison requested by the lead: exported procedure/getter over initialized body-private state versus visible-spec state, with no author Global/Abstract_State/Refined_State aspects. Analyze both in one exact author-unit closure. This is exploratory producer evidence only.

## Clock diagnostic checkpoint

`clock-naive` run `20261122T124455-325a4307f664` is a retained failure: `bounded_probe.adb:25:23`, `VC_RANGE_CHECK`, on `Next := Next + Period`, with an unresolved medium record after the prover time budget. The other arithmetic, ceiling and task-nontermination obligations succeeded. A positive constant period repeatedly added to finite `Time` cannot be assumed to stay representable. The producer suggests a loop invariant, but author annotations are not permitted and an invariant cannot make unbounded positive recurrence fit a finite range. Next focused check: the already separate `clock-guarded` source tests an executable `Next <= Time_Last - Period` guard and an explicit final-time delay branch, without narrowing the Clock return domain or suppressing obligations. This is only a characterization probe; it does not select final horizon-exhaustion semantics for #420.

## Completed bounded checks and status interpretation

Clock guard run `20261122T124545-2b52ecb68e97` proved all eight checks. No native clock build or observation was started; the lead ended characterization after this result.

Two-entry-caller control run `20261122T124616-9c127060e923` emitted high flow `CONCURRENT_ACCESS` and a summary with one unproved concurrency check. The direct GNATprove command and `dev.py tool` exited zero, without an expected-negative wrapper. The managed record says success; that is retained separately from the failed-discharge disposition. The run-history extractor scans `.spark` proof records and SARIF VC_* records, so this flow diagnostic is outside its scope. The canonical evidence checker separately inspects flow/proof/warn_error; no canonical acceptance failure is claimed.

No native job or worker reservation remains from this subthread. The lead is reusing the shared allocation for #416; no further probes are authorized in this handoff.
