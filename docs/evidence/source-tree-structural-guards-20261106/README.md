# Structural-guard validation — 2026-11-06

Governed source: `92ab046be220177eb850be943791df57d87043dc`, after authorization
`584e230e31`. [Summary](summary.json) records all nine terminal managed runs.
Their compressed original event records, logs and available result files are
under `runs/`; [artifact hashes](artifacts-sha256.json) identify those copies.
The copies exclude prior-result backups, cache objects and lock files.

Complete run `20261106T164208-1614accb2e5e` passed on native Linux x86-64:
**641 modules, 128,705 declarations**, with exactly `propext`, `Classical.choice`
and `Quot.sound`. The cached build rebuilt 86 modules in 155.542 s; the fresh
whole-project audit took 9.978 s. Managed duration was 175.393 s. The runner
selected 12 workers/12 threads automatically and 24576 MiB per-process memory.
No clean build or independent kernel replay was requested. Source comparison
matched all 748 captured shared inputs to both the current tree and immutable
governed Git blobs; both captured tool executable hashes match. Regenerated
certificates are outside that shared-input count and are covered by the passing
parity test and complete source proofs.

The idle cache seed was the completed 638-module checkpoint
`20261106T150342-2526cc1a0ef4` in `tmp/lean-chunk-reuse`, on source `524dbfbd40`.
The complete proof workspace, including private/server object sidecars and Lake
metadata, was copied into each isolated workspace before development. The
existing pinned installation is shared through a symlink; writable caches are
separate. Earlier seed provenance remains in the
[performance packet](../lean-incremental-throughput-20261106/integrated-complete/README.md).
The integration used that original seed, not later worker-cache transfers.

Focused predicate run `20261106T163857-813cf8538291` passed 348 modules/95,856
declarations. Focused Image run `20261106T163545-5268a6d953e4` passed 47
modules/11,226 declarations. Earlier successes retain their original input
scope. Failed runs `20261106T163308-adbc9c2e3e62` (opaque numeral-rendering
reduction) and `20261106T163324-255725b4e769` (constructor/binder collisions)
remain failures; subsequent proof-only repairs are documented in the
[task record](../../source-tree-structural-guards.md).

Managed test run `20261106T164008-c4b3837f4da3` passed all **16**
`test_lean_source.py` methods in 76.685 s, without skips. The run includes source
partition/dependency checks, exact certificate regeneration and real kernel
acceptance/rejection fixtures. Compiler, test tooling, fixtures and samples are
unchanged; no whole application suite rerun is claimed for this proof-only task.

[Native applicability](native-applicability.json) recomputes the original
installation's full 2,586-path input inventory and 12 tool hashes, and compares
the 143 tracked inputs and path set to integration. All match the
[retained native packet](../lean-incremental-throughput-20261106/native/README.md):
full proof/audit `20261106T145116-6582d1e5fcb5` passed 17,496 checks, and build
`20261106T145251-335323a924fa` was up to date. No native proof/build rerun,
macOS or hosted-CI result is added here.
