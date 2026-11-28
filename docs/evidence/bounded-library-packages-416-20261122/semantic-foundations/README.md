# Package semantic foundations — focused checks

These Linux checkpoints cover initial semantic helpers, not actual package source
correspondence or the whole-language package endpoint. All selected targets were
built through the managed Lean runner and their imported declarations freshly
audited; only `propext`, `Classical.choice` and `Quot.sound` were used. No independent
kernel replay or clean rebuild is claimed.

| Implementation | Focused run | Scope and result |
| --- | --- | --- |
| `488d821811` (integrated unchanged as `8c16de4515`) | `20261122T130212-b9742bea2354` | Four new modules: ApplicationUnits, PackageState, PackageEffects, PackageClosure; 5,927 declarations audited. Exact byte packing/slices, typed cell initialization, effect inclusion and capture copy-in/copyback lemmas. |
| `8182cc92fb` (integrated unchanged as `5928b98159`) | `20261122T131112-bc4a3d4bb2bc` | ScalarFunctionComposition, ScalarProcedureComposition, FunctionDeclarationMeaning, ProcedureMetadataSemantics, FunctionBodyMeaning and ProcedureDeclarationHeaderMeaning; 26,028 declarations audited. Semantic signatures permit zero formals/outputs while existing Main-local admission remains unchanged. |
| `452689a054` (integrated as `23e29da4b8`) | `20261122T133603-c1dea8be38d0` | PackageReindex, PackageSyntax, PackageExecution and PackageLowering; 21,675 declarations audited. Arbitrary slot reindexing and shared execution effects. |
| `896c1a0c10` (integrated as `10f54fabc5`) | `20261122T134022-47d5525ee05c` | PackageLowering; 21,712 declarations audited. Whole-body read locality through calls and finite loops. |
| `6d30f52bd5` (integrated as `1591edb8e4`) | `20261122T134357-6fd24dfadbaa` | PackageDefinitions; 21,818 declarations audited. Earlier-callee locality constructed in completion order. |
| `8ec11701f4` (integrated as `e74156d29f`) | `20261122T134832-ecd089d7673d` | PackageDefinitions; 21,867 declarations audited. Exact final globals and explicit outputs agree between capture execution and shared execution; entry fit preserves the full declared state product. |

All used the automatic eight-worker/eight-thread allocation and guest CPUs 0–7,
within the host's eight-CPU allocation. The zero-formal change rebuilds affected
semantic consumers; this result does not stand in for the later complete source
checkpoint. The later rows establish the semantic reindexing, body locality and
capture-equivalence results. Native effect/slot correspondence, body admission
and automatic discharge, and the original-bundle source endpoint remain
outstanding. These results do not yet establish the package language guarantee.

The compressed run records retain exact inputs, phases, logs and audit outputs.
`packages-416-proof-foundation.json.gz` records the initial four-module checkpoint;
`packages-416-zero-formals-evidence.json.gz` retains the second result. The cache
seed record identifies the verified local Lean installation and copied prior
workspace used by this proof worktree. The seed was existing local cache reuse,
not a download, a clean build or evidence that the new package feature was already
proved. Completed objects from intermediate failed focused attempts were retained
under the ordinary Lake policy; their run history remains in the managed ledger.
The later four results have their named evidence files plus run-ID-prefixed
event streams and build/audit logs. Their elapsed managed check times were
15.660, 16.728, 15.464 and 15.717 seconds respectively, with cached dependencies;
these are focused check times, not development duration or final-checkpoint costs.

Selected proof role: GPT-6 Astra Max. Live serving settings and team token/cost
usage are not independently exposed. These are partial implementation checkpoints
for #416; support and completion require the final integrated evidence and review.
