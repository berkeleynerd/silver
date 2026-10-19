# Selected literal SSA lifetime review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept the bounded source argument at
`e0c24340e86f4ae90c9de0794bab6797a0bd1563`. No material findings.** The selected
later Main passes preserve the relevant SSA mutation state and add no fresh
names, name/free-list backing, default mapping or operand slab beyond the
accepted initial allowance. This disposition depends on the accepted literal
source, selected pass/options and source-correspondence premises. It does not
close the global GGC ledger, native capacity or collector proof.

## Inputs and review record

The frozen target contains six new files: the
[SSA lifetime note](../research/retained-literal-ssa-lifetime.md) and its
[five-file evidence packet](../evidence/retained-literal-ssa-lifetime-20261019/README.md).
I read the note, checker, manifest, retained result and round record. The
manifest binds 24 GCC files to revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, eight repository inputs and 26 source
excerpts. The eight repository inputs were taken from exact target Git blobs;
the accepted initial-SSA, helper, literal O0 continuation, whole-unit graph and
shared-query arguments supply the selected branch premises. Relevant inherited
null-continuation gates were read at this same target; the literal call/store
extension, rather than a no-call assumption, governs Main.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime confirmation, token usage and monetary cost are unavailable. Review
began **01:14:30 UTC** and reached the report checkpoint at **01:18:34 UTC**
(**244 seconds**, including preparation and excluding commit). Actual host is
Linux 7.0.14 x86_64. A separate sparse worktree preserved the exact target and
only this report is committed. The live subthread harness goal was null.
The continuing owner-authorized #119 scope, unchanged Oracle/tools/admission
and source-correspondence rules govern this review. CLI memory was not updated;
the lead owns issue, publication, attachment and harness bookkeeping.

The author's **66** identity/excerpt/ownership checks passed in
**0.02111044800039963 seconds**. I inspected and reused them, without running
the checker. No native tool, capture, disassembler, compiler, prover, solver,
predecessor Context, old suite, corpus or aggregate evaluator was run. There
was no GitHub write or delegation.

## Mutation-state argument

The initial builder uses `init_ssa_renamer`, not `init_update_ssa`, and its
`fini_ssa_renamer` clears both per-function rename flags. The helper construction
argument supplies direct gimplification-created names, no incremental updater,
and removal before ordinary lowering. Thus it does not leave the static
incremental manager active for Main. Main starts this later interval with
one `.MEM` default, at most `3C` retained nondefault memory definitions,
no real names/PHIs, both free vectors empty and no rename request.

The inspected direct flag setters agree with the packet: virtual-renaming
markers, scanner replacement/missing-vuse cases and real-variable scanning.
`need_ssa_update_p` tests the active manager or the renaming flag.
`update_ssa` returns on false before initializing its manager or allocating
its maps/bitmaps. A pass's TODO request does not itself establish either
condition. `init_update_ssa` has only the new-definition and actual-update
callers in `tree-into-ssa.cc`.

I checked the queued-inline path beyond its final TODO. It does request virtual
updating even without inlining. The selected call edges have no speculative
target, callback, clone, body or parameter adjustment; their declaration is
still their callee's declaration. `redirect_call_stmt_to_callee` therefore
reaches its equal-callee return before rewriting the statement. The early
inliner and queued transform make no temporary copied body or definition.
`execute_fixup_cfg` finds no pure/const/noreturn call, global write-only store,
call LHS or abnormal/local-EH change. Its DCE worklist stays empty. The straight
CFG retains a successor for each ordinary block, so the unreachable-call
insertion branch is absent as well.

Scanner preservation is explicit, not inferred from the eventual graph.
`finalize_ssa_defs` compares the old virtual name's underlying variable with
the new memory variable and keeps the existing SSA name when they agree.
The removal/release and non-SSA rename cases are false. `finalize_ssa_uses`
similarly retains the same-variable use; its missing-use rename case is false.
Pointer component stores and invariant addresses do not enter the real-variable
setter. The original definitions remain attached throughout.

The mandatory lowerings preserve that invariant on the accepted shape. Complex
lowering's eligibility scan only changes simulation flags and finds no complex
operation. Vector lowering returns on the pointer stores and ordinary calls.
Bitint's initial scan sees virtual definitions with pointer-valued store RHSs
and returns before its renaming marker. Varargs needs IFN_VA_ARG; switch lowering
marks virtual operands only after expanding a switch. Neither form is present.
The selected instruction-selection hook and scalar store/call paths add no
replacement. The accepted warning, instrumentation, EH, NRV, musttail and
optimization gates continue to apply. A true cleanup/TODO dispatch may still
do ordinary graph work; its SSA updater takes the no-work return.

## Release, expansion and operand storage challenges

I additionally checked `remove_unused_locals` in `tree-ssa-live.cc:825–1005`,
because initial-SSA and name-release TODOs can run it. Its statement-release
paths need a clobber or IFN_DEFERRED_INIT, absent here. Descriptor declarations
are marked by their retained actual statements. Removing an unused local's
default would not manufacture a replacement, and the existing `.MEM` default
is not such a descriptor-local default. No nondefault name enters the release
queue through this path.

Out-of-SSA's backedge-copy constructors require PHIs, and its indirect-clobber
release path requires the absent SSA-based MEM_REF clobber. The coalescing
interface has zero real partitions. I also inspected the explicit
`make_ssa_name` in `cfgexpand.cc:1140`: it belongs to
`update_alias_info_with_stack_vars`, where a nonsingleton stack partition is
required. The accepted register-only descriptor/storage shape supplies no such
partition. The no-debug route excludes its debug-statement update path. These
are concrete exclusions of temporary creation before later deletion.

`release_free_names_and_compact_live_names` frees the free vector, moves existing
name pointers and truncates. It does not grow a backing. `release_ssa_name_fn`
returns on default definitions and queues only an actually released nondefault
definition. With no selected release, `flush_ssaname_freelist` sees an empty
queue, so both free vectors remain empty.

For every rescan, `finalize_ssa_uses` links the old complete use list to
`free_uses` before requesting replacement entries. Each selected statement
still has at most its original one virtual use. The returned entries therefore
cover the replacement without another slab request, regardless of repetition
order. This is an invariant of the release-before-allocate operation, rather
than a claim based only on the final use count.

The rooting premise also has a concrete source basis:
`gimple-ssa.h:72–112` embeds `ssa_operands` in the traced `gimple_df`, and
`tree-ssa-operands.h:48–64` traces the operand-memory chain. `free_uses` is
skipped by tracing, but the slabs containing its entries remain reachable
through that chain. The narrow init/fini call-site search found no intermediate
teardown/rebuild on this route: the other initializers construct cloned,
outlined, streamed, parsed or newly synthesized bodies excluded by the accepted
unit shape. The sole `fini_ssa_operands` caller is `delete_tree_ssa`.

Expansion clears the GIMPLE sequence pointers and changes representation,
without releasing these statements one by one into a growing SSA free list.
Final `delete_tree_ssa` frees name vectors and active slabs and clears the
one-key default table through its already-accepted small-table path. It does
not restart operand management. Thus collection cannot force an uncharged cold
slab reconstruction during the selected interval.

## Independent evidence and ownership

An independent identity read passed for all **24 GCC and eight frozen repository
inputs** in **0.07363865099978284 seconds**. A separate direct comparison in
**0.009820267001487082 seconds** checked the four implementation identities,
actual-source identity/count binding, exact retained owner rows, all ten initial
guards and their conjunction, and the null/false global-completion claims.
Neither operation ran checker or predecessor code. The retained 26 excerpt
checks were not replayed.

Additional narrow source reads/searches examined release paths, reconstruction
callers and slab roots. In addition to the pinned files, the decisive extra
inputs are these exact local source identities at the selected GCC revision:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `gcc/tree-ssa-live.cc` | 49,687 | `52edc87c7b0d3a45f92c72322cb18a20b0fbd481e8a8eb17f9d1d936c6cf3872` |
| `gcc/tree-ssa-operands.h` | 3,972 | `7f2c5b095b973ab9d2dee364e4c25684faa602c654d5dcae90151c7ac138ed59` |
| `gcc/gimple-ssa.h` | 5,539 | `8de9708a65db22dcab01a8026dd54805e789a5d61b095149d9a4fca136173eed` |
| `gcc/cgraphunit.cc` | 81,742 | `530fa98e6219e79d0832e41ddb4be92f01468b57a9868811e997402a4ddafefc` |
| `gcc/tree-inline.cc` | 214,934 | `fd7e55d826abce9e7e8ffd47a52fd11befec98346c9a73982620d322e232f903` |

The source bytes and nine extra-file identities, including the coalescer,
ranger and TER constructor/release searches, remain in review scratch. Source
identities and finite arithmetic checks establish correspondence and
consistency of these inputs; the handwritten selected-branch argument supplies
the zero-increment conclusion.

The initial owner remains `6C + 10 + L`, with
`L = 1 + [3C+1 > 25] + ceil(max(0,3C+1-127)/409)` and all its existing
representation guards. The retained Hello value is **17 events**, extended in
lifetime rather than added again. Helper SSA costs, `.MEM` identity/counter
effects and the initial scalar finalizer retain their existing owners.

**Disposition:** accept zero additional selected later SSA-family requests
under the stated premises. Actual-source attachment, complete direct/shared
GGC ownership, ordinary pass/bitmap/pool lifetimes, typed-array and outer
finalizers, collector composition and other required phases remain open.
Whole-native and full-current-grammar #119 capacity are not established by
this packet; production admission and the Oracle remain unchanged.
