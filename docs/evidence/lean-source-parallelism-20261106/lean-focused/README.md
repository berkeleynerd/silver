# Completed focused Lean checks — 2026-11-06

These retained native Linux x86-64 runs have focused partial scopes. Four passed
their selected builds and fresh import/axiom audits; the first NativeShape run
failed during build. Their captured shared-input inventories form three distinct
snapshots. None establishes final complete source correspondence.
[Summary](summary.json) records source identities, commands, resources, outcomes
and timing boundaries. Original ledgers retain each shared-input hash map.

| Selected scope | Result | Observed wrapper | Managed duration | Build | Fresh audit |
| --- | --- | ---: | ---: | ---: | ---: |
| Four output-body line modules | Passed | 2076.993 s | 2073.236 s | 2055.420 s | 7.639 s |
| Predicate Helpers and Flow | Passed | 2026.687 s | 2021.865 s | 2002.216 s | 8.116 s |
| Predicate Body | Passed | 1646.465 s | 1641.304 s | 1623.675 s | 7.098 s |
| Predicate NativeShape, first run | **Failed** | 1616.128 s | 1608.592 s | 1601.849 s | Not run |
| Predicate NativeShape, 24 GiB retry | Passed | 1636.033 s | 1630.921 s | 1614.261 s | 6.661 s |

Output run `20261106T104011-475878966fee` used four Lake workers, automatic
12-thread Lean processes and a 6144 MiB per-process allowance. All four line
modules passed; Lake reported 1591/1869/1970/2048 seconds. Its fresh focused
audit covered 19,232 declarations in ten loaded project modules.

Helpers/Flow run `20261106T105828-7df2e454a509` used one Lake worker, automatic
12-thread Lean processes and a 12288 MiB per-process allowance. Helpers and Flow
passed with Lake-reported module times of 951/1040 seconds. Its fresh focused
audit covered 20,272 declarations in 115 loaded project modules.

Body run `20261106T111948-b39235b3c831` passed with the same one-worker,
12-thread, 12288 MiB settings. Its fresh focused audit covered 33,908 declarations
in 235 loaded project modules. Its captured shared inputs match
`3f5d575635`. The [completed observations](predicate-body/observation.json)
record 12,935,438,336 bytes of sampled peak summed RSS.

NativeShape run `20261106T113432-0d3e6d09f480` **failed** under the same
one-worker, 12-thread, 12288 MiB settings. At
`Silver/PredicateNativeShapeCandidate.lean:217:2`, the tactic in
`native_condition_tail_spec_header` reported:

```text
(kernel) excessive memory consumption detected
```

The source module contains 60 private leaf theorems; the whole module was
attempted and rejected. No completed module object, complete per-leaf result,
success evidence JSON or fresh audit is claimed. Its shared-input snapshot
matches `9100bb2fca` and the earlier Helpers/Flow run. The
[completed failed-run observations](predicate-shape-failed/observation.json)
record 14,164,336,640 bytes of sampled peak summed RSS. The retained failure log
comes from that run's immutable `reports/0/` copy.

Retry `20261106T120256-3017b6fb77a5` subsequently **passed** on unchanged
`9100bb2fca` source, with the same shared-input digest as the failed attempt.
It selected automatic 12 Lake workers and automatic 12-thread Lean processes,
with a 24576 MiB per-process allowance. Lake reported 1608 seconds for the module;
the fresh focused audit covered 19,757 declarations in
108 loaded project modules. Its
[finished observations](predicate-shape-24g/observation.json) record
18,426,343,424 bytes of sampled peak summed RSS and at least 15,772,012,544 bytes
of host available memory; no monitor pause occurred. The earlier 12288 MiB run
remains failed. Its worker reservation was one, while this retry selected 12;
this is not a matched speedup comparison. Complete performance assessment waits
for the final integrated run.

The retry reason's “condition-model” wording is a typo: the actual earlier
failure is `condition_tail`, as its raw diagnostic records. Raw ledger records
remain unchanged. Only terminal-run evidence and finished observations are
retained here; live caches and the final complete run's changing outputs are
excluded.

Each retained monitor would pause only its own process group below 4 GiB host
available memory; none paused. Summed RSS may count shared pages and is not exact
peak physical memory. Approximately five-second CPU samples describe observed
live-process usage, not exact CPU seconds. Lean memory allowances are
periodically checked per-process thresholds, not aggregate or OS hard limits.

[Artifact hashes](artifacts-index.json) bind finished ledgers, retained run
logs/evidence JSON, named observation logs and samples. Changing convenience
logs and active proof caches were not copied. No cold build, independent kernel
replay, matched speedup benchmark or complete-project assurance is claimed here.
No new review or validation run was performed.
