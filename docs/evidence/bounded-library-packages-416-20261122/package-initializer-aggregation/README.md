# Package initializer inventory checkpoint — #416

This packet retains the per-Object source inventory increment. It does not
complete endpoint 2, routine/Main aggregation, or the final assurance join.

`ApplicationPackageInitializerInventory.object_inventory` derives the original
optional scalar-range endpoint syntax and Integer/Boolean initializer syntax
from successful `objectStep`, the original input frame, and its native reader
domain. The exact shadow-removed initializer frame, name masks, source spans,
inferred interval, and declared target interval remain distinct. Arithmetic
obligation discharge, Boolean path checks, nonemptiness, and target containment
are conclusions of the original successful reads. They are not fields required
in the raw `ObjectSyntax.SourceAt` representation.

The focused Linux x86_64 / Lean 4.34.1 run
`20261127T221316-300ed176f105` passed with a fresh axiom audit of 71,173
declarations. All 1,615 captured input hashes matched the retained source bytes.
The run used two workers, two Lean threads, CPUs 6–7, and an 8,192 MiB limit per
Lean process. This was an incremental managed run with a fresh audit, not an
independent replay. Earlier successful prefixes and all failed drafts are
retained separately, with honest changed-input reports for the failed drafts.
Those failures concerned local proof normalization and warnings treated as
errors; no language domain, source model, or proof budget was weakened. The
managed diagnostic for `20261127T220020-fc4848eb208c` records the repeated
Boolean-context rewrite diagnosis.

The remaining endpoint work includes public specification/subtype histories,
state/local/output source-order folds, construction of existing
`Packages.LocalInitializer` consumers with full input/global domains, and Main
declarations starting at the imported frame. The Main join must preserve
`Current.SourceBoundsRefinement` and `Current.StringBoundsSafe`; standalone
empty-import `Predicate.SourceMeaning` is not assumed.

Raw source-body correspondence, final complete validation, publication, and
issue bookkeeping remain with the lead. No native launch is represented by
this packet.

## State/local folds and output history

`ApplicationPackageRoutineInitialization.state_objects_inventory` and
`local_objects_inventory` fold every original declaration in source order,
deriving each successive reader frame and the aggregate raw obligation
discharge. `OutputObjects` is recovered from the original `outputInitializers`
pass. Its order theorem retains exactly the output formal subsequence; its
preappend theorem proves that every RHS uses the same declaration tables as
the pre-output frame. Each reconstructed output context has declaration count
zero. This increment does not yet construct the semantic initializer list or
prove the full-domain range bridge.

Focused run `20261127T222004-da4874be70f2` passed on Linux x86_64 with a fresh
axiom audit of 72,780 declarations. All 1,616 captured input hashes matched.
Allocation was two workers, two threads, CPUs 6–7, and 8,192 MiB per Lean
process. Its two failed drafts and the successful source snapshot are retained.
It reused the prior cache; no independent replay was performed.

## Exact elaboration and original String context

`object_global_singleton` derives exact nonlocal initializer bounds from the
original Object rejection guard. `ValueCalls.scalar_exact` combines this with
the original raw expression reading and inference: for every fitting original
elaboration store, that expression evaluates to the proved seed value.
`ComposeInitializerTrace.DeclarationChecksAt.string` now retains the original
`state.contextFirst` instead of using the default context start.

Run `20261127T223341-4c12f4133f11` passed the complete Inventory, Routine caller,
and ComposeInitializerTrace targets, with a fresh audit of 72,860 declarations.
All 1,617 captured input hashes matched; allocation remained two workers/two
threads, CPUs 6–7, 8,192 MiB, Linux x86_64, incremental build without replay.
The snapshot includes draft Main/String modules as captured context; this run
does not validate those drafts. The prior failed normalization runs and the
Main prerequisite failure are retained separately. A managed diagnostic on
`20261127T223222-138cb39ee64c` records the exact guard rewrite correction.

## Public specification inventory

`specification_loop_inventory` retains each original routine, subtype, and
object continuation, including subtype declarations with no runtime cell.
Subtype endpoint syntax and the original reader equations are retained;
arithmetic discharge and the successive ReaderFrame domains are derived.
Terminal ready/returned histories remain explicit. The existing source
representation gains no checker-success or semantic-validity field.

Run `20261127T224428-cf573b5cec83` passed the RoutineInitialization target and
its imports with a fresh audit of 72,885 declarations. All 1,617 captured inputs
matched. Allocation remained two workers/two threads, CPUs 6–7, 8,192 MiB,
Linux x86_64 / Lean 4.34.1, incremental build without independent replay.
The failed subtype-obligation rewrite and the separate Main inherited-caller
failure are retained. Main and the String extension remain unvalidated drafts
even though their bytes appear in the successful run's captured input set.

Required proof/design category for this round was Astra Max; actual runtime
model/effort and token/cost measurements are unavailable. This bounded round
completed the public syntax/history fold; the static export and semantic
initializer bridges remain outstanding.
