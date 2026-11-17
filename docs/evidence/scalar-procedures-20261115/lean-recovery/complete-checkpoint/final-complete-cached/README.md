# Complete Lean/source checkpoint success — 2026-11-15

The complete cached Lean project check **passed** on frozen production
`32c6fbca5`, equivalent to the independently reviewed integrated production
`1dde32cce`. Managed run **`20261115T215223-28e04bff3fce`** covers the complete
`Silver.Audit` target on **Linux ARM64, Lean 4.34.1**. Original execution session
`79079` returned exit 0, with no diagnostic interruption or resource guard.

The freshly executed audit imported **all 1,009 current project modules** and
checked **162,269 declarations**, finding only the documented foundations
`propext`, `Classical.choice` and `Quot.sound`. The actual imported module set
equals the complete project source inventory, not just its textual import graph.
This includes the source candidates, source bridges, semantic connections and
top-level facade previously blocked by the retained memory failures.

## Scope and exact continuity

This is a complete **incremental/cached** project check with fresh whole-project
coverage, axiom and input/provenance auditing. It is not a clean build or an
independent `leanchecker --fresh` replay. All 681 prior ordinary objects and
4,082 variant/hash files remain byte-identical; the successful continuation adds
the remaining 328 ordinary objects, bringing the project total to 1,009.
No temporary diagnostic module is part of the current source/module inventory.

The runner regenerated candidate certificates against the authoritative `src`
tree, checked workspace/source/tool identities around build and audit, and
checked compiled-artifact stability during verification. After original terminal
collection, this packet's verification rechecked every captured hash:

| Captured input or artifact set | Verified entries |
| --- | ---: |
| Shared proof, native source and runner inputs | 1,116 |
| Synchronized proof workspace inputs | 1,011 |
| Compiled artifacts | 6,046 |
| Lean and Lake executables | 2 |

All captured hashes match the final files. The input-set digest is
`7179d60c18e7b55e4a19f09d132a9d3b9951bd70c7dc95e7af1f364de7ad825b`.
Exact managed-log SHA-256 is
`171b56cb0a57abd689bb711d6ab7e1d4eb06069aa11df925b01136ef8287d40d`.
The source definitions, native implementation/contracts/domains, tools and
scripts remained unchanged throughout this continuation. Only the previously
reviewed exact proof-representation repairs are present; no proof was waived.

## Execution and retained records

One Lake worker, automatic **twelve Lean threads**, and **8,192 MiB per process**
were used. The one-worker allocation follows measured dense-module memory on
this 15.8-GiB host; the native audit and build had already completed. The original
10-GiB source-tree, 1.5-GiB host-headroom and first-memory-diagnostic guards remained
active throughout. No guard fired.

Build elapsed was **684.761 s**, fresh audit elapsed **2.171 s**, runner elapsed
**693.969 s**, and monitored elapsed **695.766 s**. Five-second sampling recorded
peak process RSS **8,788,832 KiB**, process-tree RSS **9,836,544 KiB**, and minimum
host availability **7,277,152 KiB**. These are sampled observations, not exact
maxima or general resource guarantees. The original launcher finished at
`2026-11-15T22:03:59.479747+00:00`; its managed lease is released and the post-run
readout reports zero reserved workers and no active Lean run.

The packet retains the exact complete evidence JSON, managed and outer logs,
resource samples, terminal summary, managed events, full module-coverage check
and hash/object verification. The six earlier interrupted complete attempts and
their focused repairs remain separate historical evidence; none is relabeled as
a successful complete run. Matching successful focused gates were not repeated.

| Work | Model / effort | Result | Available cost evidence |
| --- | --- | --- | --- |
| Complete source/proof recovery and verification | Selected Astra Max for proof/source work; live lead setting not independently exposed | Complete cached project and fresh coverage/axiom/provenance audits passed | This successful continuation: 695.766 s monitored elapsed; token and whole-team cost unavailable |

The parent owns independent final evidence review, integrated native/provenance
continuity, regressions, samples and final capability/delivery acceptance. This
record establishes the completed Lean/source checkpoint; it does not claim that
those separate remaining delivery checks have finished or that a clean replay
was performed. The existing assurance and trusted-boundary qualifications remain
unchanged.
