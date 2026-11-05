# Final Lean checkpoint — 2026-11-05

Complete run `20261105T192530-524a4096ef8f` **passed** on native Linux
(`linux-x86_64`, Lean 4.34.1): a cached build of 661 jobs followed by a
separate fresh whole-project axiom/module-coverage audit of 626 modules and
129,947 declarations. The audit reports only `propext`, `Classical.choice`, and
`Quot.sound`. See the [runner evidence](lean-evidence.json),
[build/audit log](lean-proof.log.gz), [managed events](events.jsonl.gz), and
[retained success summary](success-summary.json).

This validates the exact input bytes later committed as `ddb183a918c78c8636b94961172dc923e7d88d30`.
The run itself started from `cc3243b726a4f89a4d857b213832f002fdd088a7`
with the authorized helper cleanup uncommitted. A fresh read-only enumeration
matched all 741 current shared input paths and SHA256 hashes to the managed
start record and repaired snapshot; the resulting digest matches the success
evidence:
`1b9d4c7420edefb34463a3552e485cd1ecff3179d6f84bb756bbae671f1e7740`.
The current Lean/Lake binary hashes also match. See
[current input verification](current-input-verification.json) and the exact
[before/after helper input maps](helper-source-identities.json.gz).

| Measurement | Seconds | Source |
| --- | ---: | --- |
| Cached build phase | 677.960 | Runner evidence/log |
| Fresh whole-project audit phase | 14.158 | Runner evidence/log |
| Runner elapsed | 708.151 | Runner evidence |
| External wrapper elapsed | 708.579 | [Wrapper outcome](wrapper-outcome.json) |
| Managed ledger started-to-finished duration | 703.807 | Managed events |

These are distinct recorded measurement scopes. The runner clock starts before
managed registration; the external wrapper surrounds process invocation. The
retained records are unchanged, and the ledger duration is not substituted for
runner or wrapper elapsed.

## Repairs and retained prior outcomes

The declaration-local [budget patch](budget.diff), committed in `cc3243b726`,
adds only `set_option maxHeartbeats 10000000 in` to `outputImplementation`.
This finite sufficient ceiling follows existing certificate precedent; it is
not a measured minimum. The 50,230-token literal remains SHA256
`cefce4aa9d187cfadd3447d74e7cba99f3f0ca0d33c5bfeff9a41eae85642d53`.
The [budget identity record](budget-source-identities.json.gz) retains its
before/after inputs.

The exact [helper patch](helper-simp.diff) removes four unused simp entries
from private `string_helper_guarded_at_ordinary`: `StringNative.Command.list`,
`List.foldr_cons`, `List.foldr_nil`, and `StringNative.Command.renderElse`.
The statement, sibling theorems, source/model/axiom inputs and other file bytes
are unchanged except necessary list separators; no linter suppression was added.
Patch SHA256 is `97fb5aa403f2d9e712e3592b7b9d916a45b5982990f473cb058b95cd495155ff`;
repaired file SHA256 is
`3b8248b88f3974725510f85537252cd4bcfd0dd71455957f033c2263e575ff62`.

| Earlier run | Retained outcome and scope | Evidence |
| --- | --- | --- |
| `20261105T170530-55ec63277225` | Focused PASS for `Silver.ReviewedOutputShape`: build 241.853 s, fresh audit 12.110 s / 14 declarations in two modules. Runner 280.515 s, wrapper 281.194 s, managed ledger 274.688 s. Partial validation only. | [Evidence](focused-evidence.json), [log](focused-lean.log.gz), [events](focused-events.jsonl.gz), [wrapper](focused-wrapper-outcome.json) |
| `20261105T171116-aab6d635d383` | Complete build FAILED solely on four unused simp arguments; no whole-project audit ran. `PredicateSourceCandidate` built successfully in 6,899 s. Build 7,831.244 s, wrapper 7,842.499 s, managed ledger 7,838.471 s. | [Summary](failed-summary.json), [log](failed-build.log.gz), [events](failed-events.jsonl.gz), [resources](failed-resources.jsonl.gz), [wrapper](failed-wrapper-outcome.json) |

The prior `20261105T133612-ecc276b25c57` remains **failed** at the compiler
heartbeat limit, despite its successful 11,061-second `OutputBodyCertificate`
build. Its already-retained [terminal packet](../lean-cpu-restart/README.md)
is linked rather than duplicated. The earlier interrupted run remains
interrupted. Later success does not relabel either failure or interruption.

All 32 retained `OutputBodyCertificate` and `PredicateSourceCandidate` artifact
content hashes and nonhash object mtimes remained unchanged in the final
[reuse record](retained-artifact-reuse.json). Lake rehash refreshed only 14
hash-sidecar timestamps. The [pre-helper artifact snapshot](retained-artifacts-before-helper.json)
and [earlier metadata comparison](artifact-metadata-differences.json) are retained.

## Resources and scope

Automatic settings resolved to eight Lake workers and twelve Lean threads per
process for both complete runs, with 24,576 MiB per process; the focused run
resolved to four workers and twelve threads. The final [run metadata](run-metadata.json)
and [resource preflight](resource-preflight.json) record the command and concurrent
native proof's four-worker reservation. Final monitoring retained 136 samples:
peak summed process RSS 4.228 GiB, minimum host available memory 24.212 GiB,
no 4 GiB guard event, and no sampled retained expensive-module rebuild. Summed
RSS includes shared pages; these are sampled observations. See
[resource samples](resources.jsonl.gz).

This is cached Linux validation with fresh axiom/module coverage. Independent
kernel replay, a cold build, detailed artifact-provenance mode, macOS and CI
were not run. No Lean/native/test rerun or cache modification was performed to
retain this packet. The [captured managed status](managed-status-final.json.gz)
records native proof `20261105T110725-477d91dbd07d` still active independently;
overall delivery remains pending that work and root integration. PR #307 is
to remain draft/open; merge is unauthorized.

| Documentation round | Selected setting | Result and measurements |
| --- | --- | --- |
| Retain final Lean checkpoint | GPT-6.1 Sol / High | Exact input/tool identity rechecked and compressed artifacts verified; runtime model/effort identity, round elapsed time and token/cost measurements unavailable. Native run times above are separate measurements. |

The [artifact index](artifacts-index.json) records original/stored byte counts
and SHA256 digests for 25 unchanged source artifacts plus the derived input
verification. Gzip streams are deterministic (`mtime=0`). This worker made no
commit, push, GitHub write or CLI recall update; root owns publication and
broader evidence applicability.
