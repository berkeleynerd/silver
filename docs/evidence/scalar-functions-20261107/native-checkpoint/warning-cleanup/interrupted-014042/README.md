# Interrupted corrected-source native audit

Complete native run `20261108T014042-81a35c010d1f` is **interrupted**, not
successful proof/audit evidence. It has no managed `finished` event, exit code,
recorded completion time, or successful full provenance certificate.
`observations/resume-status-20261108.json.gz` records the authoritative inactive,
interrupted state observed on 2026-11-08. The final event remains native-tool
phase-start at01:40:46 UTC. Logs end with proved path-fact preconditions and no
warning/error/might-fail diagnostic; absence of a failure diagnostic is not
successful completion.

The old driver/shell/GNATprove PIDs337082/337044/337120 and every member of
PGID337044 were absent in the saved process census. Both own execution-session
IDs70936/55984 returned Unknown process id. The prior handoff claimed the native
command would survive agent-turn completion. That lifetime claim was unverified
and is retracted. The earlier status helper showed only the last event and thus
did not establish liveness; it now reports managed state and active flag, and the
watcher detects a missing driver. No termination signal was issued by this
thread or reported by the coordinator. The old tool host1783 remained present
and parented the resumed execution shell; no termination-cause record is
available. Turn finalization is a possible association, not an established cause.

Frozen source remained source-only commit `560144172c`:

- report body SHA-256
  `3254d7d3236cbaa689e61a4dc13478d29ab9cafe6cfdd5f0ba8b2ecff4d13b25`;
- parser profile SHA-256
  `9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.

Before continuation, the owning thread retained all readable partial SPARK
reports, logs/events, source/generated/project inputs, saved sessions/shapes,
managed interruption observation and process census as individually indexed
gzip artifacts. All758 saved roots were proved in that retained session scope;
the complete current obligation/provenance audit had not finished. Names such
as partial-reports and partial-sessions distinguish this packet from a final run.

`full-scratch-archives.json` identifies complete report-tree and solver-cache
snapshots in the owned `tmp/report-warning-repair/` scratch directory. The report
archive contains4,024 files/2,291,961,805 source bytes; the cache archive contains
83,564 files/143,638,379 source bytes. Source size/mtime inventories matched
before/after each inactive-tree archive. Archive compressed hashes and exact file
inventories are retained; the detailed inventory is compressed and indexed.
The large archive payloads remain in owned scratch, rather than being added to
Git. Original reports/sessions/cache were retained in place for reuse.

The coordinator authorized the required complete audit continuation. After the
interruption checkpoint and fresh managed summary (22CPUs,10 reserved,12
available, no required diagnoses), identical full options and12workers resumed
on the exact unchanged source as `20261108T040128-2651963b8574`. Its outcome is
separate; it subsequently finished with four unproved parser postconditions,
as recorded in the [final continuation packet](../README.md). The owning agent
remained active through that run's actual outcome. No source change, rebuild, test, Lean validation or
implementation merge formed part of this interruption handling.
