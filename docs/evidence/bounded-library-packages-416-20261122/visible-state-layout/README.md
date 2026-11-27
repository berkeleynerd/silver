# Source-derived visible-state layout, first checkpoint

`ApplicationPackageVisibleStateLayout.lean` derives state defining-span order and
name validity from the actual StateObjects history. Positive state ordinals with
equal original defining spans are equal. Visible integer and Boolean state
lookups therefore select the exact same global identity in the concrete layout.
The model also returns State_Target = 0 at cursor 0, over arbitrary metadata.

Focused Linux validation: `20261127T193146-c63e7d293144`, two workers, two Lean threads,
8192 MiB/process. Existing dependency objects were reused; the new target was
compiled and its 32,409-declaration axiom audit was fresh. This is partial
validation. No full OutputBody or final admission theorem was checked.

Remaining work: source-derived no-later-shadow preservation, reverse visibility,
exact reset membership/ranges, and State_Target correspondence for parsed targets.
No whole-text metadata validity assumption was added to source prefixes.

## Actual target identity and shadow primitives

StateDeclarations now also derives distinct state spellings from each original
Object freshness guard. `stateTarget_integer_iff` and `stateTarget_boolean_iff`
connect the original target span and its native lookup to the exact global
layout identity. The Boolean case retains the scalar-precedence check.

The new GlobalShadowHistory module supplies preservation under removal and
append, successful Hide_Outer exclusion, and the lookup-zero exclusion lemma.
The complete state/formal/local/output history and reset bridge remain next.

Run `20261127T194059-6b59a5718f41` passed both focused targets and a fresh
32,449-declaration axiom audit. The State_Target target was compiled in preceding
run `20261127T194001-ce0271c23360`; the successful run reused that matching
object and compiled GlobalShadowHistory after fixing its qualifier reduction.

## Exact reset representation

GlobalRowsClear.integer_lookup derives self lookup of retained original globals
from the no-later-shadow relation. Reverse integer visibility follows.
`resetSlots_global_iff` proves exact native reset membership for all positive
state indices, and `resetSlots_declared` / `resetSlotsFlow_source` connect those
slots and their original declaration ranges to the semantic global reset.
These representation theorems take the explicit source history invariant; its
construction through states/formals/locals/outputs remains the next increment.

Run `20261127T194359-5c19c915ad71` compiled the changed focused target and passed a
fresh 32,465-declaration axiom audit with the same two-worker/two-thread/8192-MiB
allocation. Other dependency objects were reused.

## Source-history preservation

The no-later-shadow invariant now follows through StateObjects, routine entry
with its complete hide pass, readable formal installation, LocalObjects and
Stored formal append. Retained globals stay apart from every formal name while
locals are added, so delayed output-only installations preserve the invariant.
No spelling uniqueness premise is imposed on unrelated local/formal rows.

Run `20261127T194911-820aa97a282c` compiled the changed history target and passed a
fresh 32,489-declaration axiom audit. The final CompletionFrames assembly is
being added separately; this run checks all of its new history helpers first.

## Completed source-context assembly

`ApplicationPackageCompletionVisibleState` now derives VisibleContext from the
actual CompletionFrames: the original signature, routine entry, complete local
declaration history, output initializer pass and delayed output-formal append.
Its fields provide declarations, no-later-shadow, scalar capacity, body widening
and original declaration ranges. `VisibleContext.reset` composes the exact
native slot reset with semantic resetGlobalFlow. `globals_visible` preserves the
package facts across successful completions for the following routine.

Run `20261127T195154-9af213983e16` compiled this final new target and passed a fresh
33,036-declaration axiom audit. It reused the matching history helpers already
checked in the preceding focused checkpoints. All 1513 recorded input hashes
were compared with the current worktree after success and matched. The complete
input manifest is retained in completion-inputs.json. Actual allocation was
two workers, two Lean threads per process, 8192 MiB/process, Linux CPU IDs 6–7.
No private job remains active and no full OutputBody build was run.

The assigned visibility/State_Target/reset history bridge is complete. Parent
integration and the sibling procedure consumer use these checked APIs; complete
package-admission assurance remains a separate integration checkpoint. No
whole-text validMetadata assumption, source-prefix domain narrowing, project
axiom or unfinished proof was introduced.
