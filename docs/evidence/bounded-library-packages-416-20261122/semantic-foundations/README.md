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

Both used the automatic eight-worker/eight-thread allocation and guest CPUs 0–7,
within the host's eight-CPU allocation. The zero-formal change rebuilds affected
semantic consumers; this result does not stand in for the later complete source
checkpoint. Package execution, local initialization, arbitrary slot reindexing,
closure equivalence, native-reader correspondence and original-bundle admission/
safety/discharge integration remain outstanding at this checkpoint.

The compressed run records retain exact inputs, phases, logs and audit outputs.
`packages-416-proof-foundation.json.gz` records the initial four-module checkpoint;
`packages-416-zero-formals-evidence.json.gz` retains the second result. The cache
seed record identifies the verified local Lean installation and copied prior
workspace used by this proof worktree. The seed was existing local cache reuse,
not a download, a clean build or evidence that the new package feature was already
proved. Completed objects from intermediate failed focused attempts were retained
under the ordinary Lake policy; their run history remains in the managed ledger.

Selected proof role: GPT-6 Astra Max. Live serving settings and team token/cost
usage are not independently exposed. These are partial implementation checkpoints
for #416; support and completion require the final integrated evidence and review.
