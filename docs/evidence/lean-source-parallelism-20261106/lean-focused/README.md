# Completed focused Lean checks — 2026-11-06

These retained native Linux x86-64 runs passed their selected builds and fresh
import/axiom audits. Each is partial validation. Their captured shared source
inventories differ; neither establishes final complete source correspondence.
[Summary](summary.json) records both exact inventories' identities/differences,
commands, resources and timing boundaries. The original ledger retains each
captured shared-input hash map.

| Selected scope | Observed wrapper | Managed duration | Build | Fresh audit |
| --- | ---: | ---: | ---: | ---: |
| Four output-body line modules | 2076.993 s | 2073.236 s | 2055.420 s | 7.639 s |
| Predicate Helpers and Flow | 2026.687 s | 2021.865 s | 2002.216 s | 8.116 s |

Output run `20261106T104011-475878966fee` used four Lake workers, automatic
12-thread Lean processes and a 6144 MiB per-process allowance. All four line
modules passed; Lake reported 1591/1869/1970/2048 seconds. Its fresh focused
audit covered 19,232 declarations in ten loaded project modules.

Predicate run `20261106T105828-7df2e454a509` used one Lake worker, automatic
12-thread Lean processes and a 12288 MiB per-process allowance. Helpers and Flow
passed with Lake-reported module times of 951/1040 seconds. Its fresh focused
audit covered 20,272 declarations in 115 loaded project modules.

The [output observations](output-lines/observation.json) and
[predicate observations](predicate-helpers-flow/observation.json) retain wrapper
wall time, sampled summed RSS and host available memory. Both monitors would
pause only their process group below 4 GiB host available memory; neither paused.
Summed RSS may count shared pages and is not exact peak physical memory. The
retained approximately five-second CPU samples describe observed live-process
usage, not exact CPU seconds. Lean memory allowances are periodically checked
per-process thresholds, not aggregate or OS hard limits.

[Artifact hashes](artifacts-index.json) bind the original finished ledgers,
retained run logs/evidence JSON, named observation logs and samples. All copies
come from completed run directories or their named finished observations;
changing convenience logs and active proof caches were not copied. No cold
build, independent kernel replay, matched speedup benchmark or complete-project
assurance is claimed here. No new review or validation run was performed.
