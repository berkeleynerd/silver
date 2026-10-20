# Initial exit timing and formatter projection

2026-10-20 UTC, #119 / #153 Round 38. See the
[argument and boundaries](../../research/retained-why-exit-initial-values.md).

- `check.py` derives the projection from the five retained capture archives.
  It hashes each archive and selected raw member against the original manifest,
  checks the timing-table bucket chains and value layouts, and scans the two
  named raw-read logs for the Debug formatter's immediate pointer targets.
- `result.json` contains exact per-process values, selected raw spans with line
  references, member identities and six retained source excerpts. It keeps all
  whole-formatter, exit and save claims false.
- `round.json` records the actual author check and its limits.

To check the saved projection offline:

```sh
python3 -B docs/evidence/retained-why-exit-initial-values-20261020/check.py
```

The initial changed-input extraction/check passed in **26.796356641 seconds**.
It consumed existing memory-read records; it did not replay the collectors,
execute gnatwhy3, capture new process state or rerun prior proof/graph checkers.
The small extractions retain 30 selected spans for each registration case and
38 for Input_Is_Valid. A missing first byte in the two named logs is reported
as missing evidence, not reconstructed from matching scalar defaults.

The source/runtime representation relation and retained capture provenance
remain assumptions. Byte checks alone do not establish prefix execution,
preservation, future bounds or universal source/native refinement. A complete
formatter graph and whole exit/save capacity remain open.
