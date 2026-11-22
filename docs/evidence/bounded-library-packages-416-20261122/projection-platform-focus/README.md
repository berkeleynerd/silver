# Report projection and platform focused contracts — 2026-11-22

Canonical Linux x86-64 whole-unit final-policy verification passed for both
units, with two workers each under the host's shared eight-CPU allocation.
The complete native compiler and Lean/source integration checkpoints remain
pending; these results establish the selected complete-unit contracts only.

| Unit | Managed run | Owned entities | Flow checks | Proof checks | Seconds |
| --- | --- | ---: | ---: | ---: | ---: |
| `silver_report_projection_audit.adb` | `20261122T160820-3e8265d55e25` | 3 | 2 | 16 | 21.427 |
| `silver_platform.adb` | `20261122T160926-0f44e0ffe644` | 9 | 36 | 132 | 39.461 |

The isolated audit tree was at `8dea77baad8f17d61c9a61549f22cb8d91c11c0c`,
with the exact `silver_platform.ads` bytes from primary `02608f1622` copied
before both runs. This changes `Max_File_Length` to 268,435,456; the import
record preserves both hashes. The earlier library success packet retains its
original platform input and has not been relabelled as a whole-tree success
for this snapshot. Other library/projection/metadata source and spec bytes
were compared with the primary tree before these checks.

Both commands used `dev.py prove --unit FILE --jobs 2` with the shared-host
resource reason recorded in their events. Each managed audit checked complete
owned-entity coverage and every required flow/proof entry. The run inventories
contain 2,642 captured input hashes each; all matched the isolated tree again
after completion. Native source, scripts, project and generated inputs are
snapshotted in `native-source-inputs.tar.gz`; the full managed inventories and
tool identities remain in each compressed input record.

`summary.json` records exact commands, allocation, affinity, fingerprints and
results. Each run directory retains native logs, raw reports, SARIF and managed
events. `manifest.json` hashes every retained file. No proof inputs or report
results were normalized. Selected proof integration policy was Astra Max; the
live model setting was not independently available. CLI memory was not updated.
