# Qualified scalar source closure — 2026-11-22

Focused Linux x86-64 run `20261122T161157-4d9d5a172c67` passed the complete
`ScalarExpressionSourceBridge`, array-atom and table-dispatch targets, together
with `BooleanElaboration`. The fresh axiom audit checked 17,649 declarations
using only `propext`, `Quot.sound` and `Classical.choice`. It reused matching
compiled dependencies, including the actual scalar specification/body source
certificates; this was neither a clean build nor an independent kernel replay.

The typed qualified reference reader, qualifier-aware lookup, scalar/array
atom interpretation and recursive expression source bridge cover their complete
native argument domains, including cursor zero and failed/malformed references.
Actual-source checks bind the updated helper contracts and typed bodies to the
scalar specification/body. Whole-unit token shapes are reviewed alongside these
semantic changes; the token pins alone are not the correspondence argument.
The model witness is constructed rather than assumed.

The preceding focused failures and compiled partial results remain in the shared
run ledger. The final repairs use checked dispatch equations in array/table
recursion congruence, explicit equal alias types at the reference boundary, and a
local symbolic reference record to avoid expanding the full reader during case
splitting. No source rule, native contract or accepted input domain changed.

Command: `python3 scripts/check_lean.py --task packages-416-scalar-source-closure
--target Silver.ScalarExpressionSourceBridge --target Silver.ScalarExpressionNativeArrayAtoms
--target Silver.ScalarExpressionNativeTableDispatch --target Silver.BooleanElaboration
--workers 2 --threads 2 --resource-reason "Shared eight-CPU allocation with root
Compose, package-spec native and audit projection checks"`.

The run used two Lake workers and two Lean threads per process within the shared
eight-CPU host allocation, with 25.200 seconds build, 3.245 seconds fresh audit
and 38.408 seconds recorded total. Selected proof role: GPT-6 Astra Max; live
model/effort and whole-team token/cost measurements are not independently exposed.

Retained `lean-focused-evidence.json.gz`, `lean-focused.log.gz` and
`events.jsonl.gz` preserve the exact input/tool identities, modules and producer
output. This is focused evidence only: the Static_Boolean actual-source chain,
package declarations/calls, full package/Main endpoint and complete project
assurance remain outstanding. The BooleanElaboration module supplies value and
readability lemmas, not an actual-source link for Static_Boolean by itself.
