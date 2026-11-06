# Complete integrated Lean checkpoint — 2026-11-06

Managed Linux x86-64 run `20261106T123115-e73dba359d09` passed the ordinary
cached complete build and a freshly executed whole-project import/axiom audit.
The audit covers **634 project modules and 130,923 declarations**, with only
`propext`, `Classical.choice` and `Quot.sound` as foundations. This completes
the output reconstruction, Predicate assembly and dependent source bridges on
integrated governed source `3f5d575635`.

The checkout at launch was documentation descendant `8b3177ed0d`; documentation
commit `d451d3c42c` was added while the governed inputs remained frozen. Read-only
Git/source comparisons establish that their `src`, `scripts`, `proof` and
`tests` trees match `3f5d575635`. [Independent input verification](source-input-verification.json)
matched all **745 captured shared inputs**, **32 generated candidates**, all
634 workspace module sources and both Lean/Lake executable hashes against the
captured records, current frozen bytes and immutable source Git objects.
The [workspace inventory](workspace-inputs-sha256.json.gz) records 636 source/build
input hashes. Source/tool inspection occurred after terminal success and did
not run Lean or copy build caches.

| Timing boundary | Seconds |
| --- | ---: |
| External observed wrapper | 2221.662 |
| Checker's reported elapsed time | 2220.833 |
| Managed run | 2217.523 |
| Lake build phase | 2197.453 |
| Fresh audit phase | 9.366 |

Lake reported 1872 seconds for `OutputBodyCertificate` and 2.7 seconds for
`PredicateSourceCandidate`; the retained log records the remaining bridge and
assembly builds. These are Lake's formatted per-module durations, distinct from
the phase and wrapper boundaries above. This is an ordinary cached checkpoint,
not a clean build, independent kernel replay or matched speedup experiment.

Both Lake workers and threads per Lean process selected 12 automatically.
The 24576 MiB memory allowance is a periodically checked per-process threshold,
not an aggregate or OS hard cap. The completed monitor sampled a peak summed
RSS of **24,827,617,280 bytes**, with at least **9,268,830,208 bytes** host available;
its 4 GiB host-available pause guard did not fire. Summed RSS can count shared
pages and is not exact peak physical memory. Approximately five-second CPU
samples describe sampled live-process usage, not exact CPU-time accounting.

[Summary](summary.json) records exact commands, resources, timings and source
identities. [Artifact hashes](artifacts-index.json) bind the immutable finished
ledger/log/evidence and completed named wrapper observations. The runner did
not select optional detailed compiled-object provenance; the independent source
inventory here records the completed frozen source bytes without claiming a
compiled-object attestation.

The [48-file transfer record](../object-transfer.json) accounts for three
completed Predicate module families copied between idle workspaces. The normal
complete runner still performed dependency/source checks and the fresh global
audit. Earlier [focused checks](../lean-focused/README.md),
[native proof/build](../native/README.md) and [scoped tests](../tests/README.md)
retain their own outcomes and attribution; they are not duplicated here.
No macOS or hosted-CI result is added. This packet retains completed evidence;
it launches no new validation or review and claims no matched performance gain.
