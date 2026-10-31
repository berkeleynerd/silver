# Final annotation-repair regression refresh — 2026-10-31

All **46 planned regression identities passed**, with no skips, on frozen
integration target `91de078ed81d102485c7dd286758e127630b01d6`. This Linux x86-64 packet
retains exact commands, per-ID outcomes, managed event streams/logs, the complete
830-file test-visible snapshot, input comparisons and restoration evidence.
The native certificate kernel fixture passed; its observed installed Lean
identity is in [kernel-tool-observation.json](kernel-tool-observation.json).

| Batch | Managed run | Passes | Workers reserved | unittest s | Managed s |
| --- | --- | ---: | ---: | ---: | ---: |
| source | `20261031T062630-15922d8efdb5` | 12 | 1 | 75.003 | 77.271 |
| platform | `20261031T062757-d817703939c6` | 16 | 1 | 207.912 | 210.255 |
| integrity | `20261031T063136-92db46acc552` | 17 | 2 | 36.551 | 38.802 |
| tool-source | `20261031T063241-6a51163735a4` | 1 | 1 | 12.276 | 14.370 |

Each batch captured **838 inputs**: 830 frozen snapshot files, the installed
compiler, three generated bindings, three toolchain configuration files and
Python. The runner's successful terminal comparison and the independent
per-batch comparisons found no drift. Immediately before restoration, all four
complete maps were rehashed again, with zero mismatches, together with all 830
snapshot files. See [final-input-verification.json](final-input-verification.json)
and each batch's `verification.json`.

## Snapshot and matching native build

The archive was exported directly from `91de078e` for `scripts/`, `tests/`,
`src/`, `proof/`, `samples/`, `catalogue/`, `silver.gpr`, `alire.toml` and the
three selected Rosetta dependencies. Every archived byte was compared with the
frozen Git commit; all 143 successful final native inputs matched. No native
tool tree was copied or installed for this overlay. Existing paths and generated
bindings were retained. The main compiler and adapter matched successful build
`20261031T022612-eb8a9047980e`, so that build was reused:

- Compiler: `69006d784a7fa256c3a7bd78db22a9003e9053b199c97b8c6a82e3bbe31cb506`.
- Adapter: `524f344475f1bb636826214b1f2113d0cf9e03839be65a05c8f389681b1ffcfc`.

The 17 output-integrity tests and selected Silver test built their own
fixture-specific compiler as their unchanged test setup requires. Those fixture
builds establish regression behavior; complete native and Lean assurance have
separate evidence. [The retained native build](../full-native-build-bb3bd71e/README.md)
records the reused main binary's actual build inputs and result.

An initial setup-only mode assertion rejected Python tar extraction's normal
`0664` to `0644` group-write sanitization. Every byte already matched; no test
had started. The checker was corrected to compare Git-tracked executable bits,
which match for all 830 files. Original Unix modes were retained independently
and verified exactly after restoration. The checkpoint is retained in
[installation-permission-checkpoint.json](installation-permission-checkpoint.json).

## Coverage and applicability

[final-coverage.json](final-coverage.json) maps every one of the **568 literal
unittest IDs / 559 underlying methods** to its actual result source. The groups
are disjoint: **46 new passes + 522 retained passes**. Equivalently, 516 original
suite passes plus 52 later passes cover the inventory; six earlier branching,
maximum-expression and Rosetta passes are retained alongside these 46.
Nine preexisting SharedBindings methods retain both literal import identities.
The original whole suite and the earlier three-test rerun retain their failed
whole-run outcomes; individually applicable passes are used as independently
reviewed in the existing census.

The exact five changed test-visible paths since reviewed target `cff54ae34d`,
review hashes, full 46-ID inventory and retained partitions are in
[coverage-applicability-inputs.json](coverage-applicability-inputs.json).
Independent applicability reviews of the
[equality transports](../../../reviews/review-boolean-equality-transports-88b54a1df3.md),
[Body_Tail assertions](../../../reviews/review-boolean-body-tail-20261031.md) and
[body condition wiring](../../../reviews/review-boolean-body-condition-wiring-20261031.md)
retain the 46-test scope. The Ada changes preserve executable meaning under the
reviewed ghost-erasure basis; the additional Lean repair has no runtime,
script or test dependency. Retained Rosetta inputs remain byte-identical.
This packet supplies the actual refresh outcomes and mechanical census for the
integration owner's final review; it adds no independent universal assurance claim.

## Restoration and handoff

The original source/configuration nodes were moved intact before exposing the
snapshot. After all terminal checks, the tested overlay was retained under
`tmp/boolean-repair-regression-91de/tested/` in the installed worktree and all
original nodes were restored. [Restoration verification](restoration-verification.json)
checked all **864 original nodes** for type, bytes/target and mode, with no
mismatches or extras, and preserved Git branch, HEAD and full preexisting status.
The installed worktree retains its original dirty overlay and subtype-base HEAD;
its restored source is not the frozen test snapshot.

The two native originals plus seven unrelated dirty files have exact beforeimages
in [dirty-beforeimages.tar.gz](dirty-beforeimages.tar.gz) and hashes/modes in
[preexisting-dirty-nodes.json](preexisting-dirty-nodes.json). Both main binaries,
all nine dirty-file hashes/modes and all **80 retained native report hashes**
were rechecked unchanged. Workspace ownership was explicitly released at
06:33:44 UTC; [the release](workspace-release-after-regressions.json) records
that no further installed-workspace writes are planned. Original node/status
inventories, managed history and the superseded `87dd` scratch archive are retained.

## Round record

Selected **GPT-6.1 Sol / High**, as explicitly assigned. Runtime confirmation
and token/cost measurements are unavailable. The intended 46-test refresh,
terminal correspondence and exact restoration are complete. The four commands
used 331.742 s summed unittest time and
340.698 s summed managed time; the snapshot-manifest
to restoration interval was 448.751 s.
These scopes exclude earlier planning/model time. The sole setup correction is
recorded above. [round-record.json](round-record.json) retains settings,
authorization, measurement limits, null live harness goal and memory status.
Integration source/proof/scripts, support documentation, PR state and issue state
were outside this evidence task. Parent PR #289 and issues #291/#293/#294 and
milestone 14 remain open; merge and next-feature work require owner instruction.
