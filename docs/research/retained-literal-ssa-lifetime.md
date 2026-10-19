# Selected literal SSA allocation lifetime

2026-10-19, Linux x86-64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). Under the accepted
literal-output source and selected O0 invocation, the initial Main SSA-name,
default-definition and operand-slab allowance covers their complete lifetime.
**Later SSA updating adds no names, name-vector or free-list backing, default
mapping or operand slab beyond that allowance.** This is a source argument
requiring independent review, not a conclusion drawn from a final graph size.

The [packet](../evidence/retained-literal-ssa-lifetime-20261019/README.md) pins
GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, accepted source-shape
arguments and the current selected-route result. It preserves all initial
SSA arithmetic guards. No native execution, capture, aggregate evaluator,
predecessor suite or corpus census was repeated.

## Entry and invariant

Use the [literal initial SSA and O0 continuation](retained-native-expansion.md#the-literal-call-path-through-cf-eh-cfg-and-initial-ssa),
[whole-unit literal graph](retained-literal-pipeline.md) and
[selected shared-query argument](retained-literal-shared-query-lifetime.md).
Main has C>=1 output calls, N>=0 null statements, at most 2C pointer component
stores into C local aggregate descriptors and a bare return. Calls are direct,
external, void, nonbuiltin, not pure/const/noreturn and not available for
inlining. There are no real SSA values, PHIs, scalar copies, clobbers, local EH
regions, abnormal edges, debug bindings or optimized/instrumented passes.
The CFG is a straight path. Descriptor alignment changes no operand kind.
The two earlier size helpers are removed before ordinary IPA/per-function
optimization; their separate SSA construction costs remain with the synthetic
helper owner. The dummy RTL context does not run a GIMPLE SSA pass.

After Main's initial renamer:

- `update_ssa_initialized_fn` is null. It is a static singleton initialized
  null (`tree-into-ssa.cc:117`); the initial builder calls `init_ssa_renamer`,
  not `init_update_ssa`. Earlier helpers neither enter the incremental updater
  nor create replacement mappings.
- `ssa_renaming_needed=rename_vops=0`. `fini_ssa_renamer` explicitly resets
  both (`:2428–2437`) and is called at the end of the initial builder
  (`:2520–2538`). The initial per-function name manager also started both
  fields at zero (`tree-ssanames.cc:143–165`).
- Every memory operand is already the appropriate SSA_NAME of the same
  `.MEM` declaration. There are at most 3C nondefault names and one default
  name. All memory definitions remain attached to retained stores/calls;
  the bare return has one use. The default-definition table has one key.
- Both free-name vectors remain empty. No transformation has released a
  nondefault name; default definitions are never queued for release.

These are mutation-state premises supplied by the selected branch argument,
not an inference that a small output graph must have a small creation history.

## Update triggers and selected clients

`need_ssa_update_p` is exactly the disjunction of the active incremental
manager and the per-function renaming flag (`tree-into-ssa.cc:3146–3151`).
`update_ssa` tests it before allocating its manager, maps or bitmaps
(`:3369–3385,3432–3449`). A TODO flag alone does not initialize that state.
`execute_function_todo` dispatches either CFG cleanup with the update flags
or the direct updater (`passes.cc:2056–2072`).

The relevant ways to invalidate the invariant are concrete:

| Client | Selected exclusion or preservation |
| --- | --- |
| `create_new_def_for`, replacement mappings and PHI creation | Require a copied/replaced definition or changed join. The accepted early/whole-unit/queued-inline routes make no clone, copied body, replacement statement, PHI or speculative call. The selected direct call's declaration still equals its edge callee. `redirect_call_stmt_to_callee` returns at `cgraph.cc:1835–1837`, before argument/statement rewriting. |
| Queued inline TODO | `ipa-inline-transform.cc:838–883` still sets `TODO_update_ssa_only_virtuals` even when no call was inlined. The equal-callee return and absent fixup transformations above leave the state unchanged; the updater therefore returns before allocation. |
| Virtual renaming markers | `mark_virtual_operands_for_renaming` sets both flags, while single-operand and PHI variants act on removed definitions (`tree-into-ssa.cc:3092–3140`). No selected pass removes a descriptor store/call, introduces a memory definition or changes a PHI. A missing call to a marker is not assumed merely from O0. |
| Statement rescanning | `finalize_ssa_defs` normalizes an old SSA vdef to its variable for comparison, preserving the old name when the new variable is the same; it marks renaming only for a non-SSA vdef (`tree-ssa-operands.cc:387–421`). `finalize_ssa_uses` similarly preserves an existing same-variable use and marks only a newly missing use (`:429–474`). Unchanged selected operands keep both flags zero. |
| Real operand scanning | The other direct scanner setter is the real-variable case at `tree-ssa-operands.cc:583–600`. Component stores are memory operands; their RHS addresses are invariants; calls and return supply virtual uses. No real variable is discovered. |
| CFG fixup and final cleanup | `execute_fixup_cfg` can rescan pure/const calls, delete global write-only stores, remove a call LHS, change noreturn/EH edges or add unreachable calls (`tree-cfg.cc:10017–10138`). The selected calls/stores exclude all those branches. Later path cleanup only removes/merges labels and straight edges; there is no memory-defining statement or PHI to release or replace. `cleanup_tree_cfg_noloop` invokes the updater at `tree-cfgcleanup.cc:1196–1200`; that invocation is still the no-work branch. |
| Mandatory lowering and instruction selection | Varargs, vector, complex, bitint and switch transforms have no eligible operand, as established in the accepted O0 continuation. In particular bitint checks virtual definitions' RHS types and returns at `gimple-lower-bitint.cc:6996–6997` before its later virtual-renaming marker. Complex returns before its transform at `tree-complex.cc:1994–2002`; selected vector scanning preserves statements. GIMPLE instruction selection has the default target hook, no vector/comparison RHS, and its builtin helper returns at O0 (`gimple-isel.cc:1274–1281,1350–1393`). |
| Warnings, summaries, alignment and IPA | The accepted selected option/pass partition excludes the transforming optimizers, access warnings, instrumentation and special attributes. Alloca's ranger has no eligible call or real SSA query. Other active scans preserve these statements; local alignment changes declaration metadata only. No range/pointer metadata constructor has a real SSA input. Those scans still own their ordinary storage and any unrelated objects. |

The selected-source branch arguments in the accepted notes discharge the
client partition; this packet does not apply the null body's no-call result
to literal output. The actual two pointer stores and void external call per
output occurrence are retained in every row.

## Name storage, use storage and teardown

With no fresh definition or replacement mapping, later `make_ssa_name_fn`
requests are zero. SSA-name compaction frees the free vector, moves existing
name pointers and truncates the live vector (`tree-ssanames.cc:983–1013`);
it does not reserve a larger backing. `release_ssa_name_fn` returns for a
default definition and otherwise queues an actually released nondefault name
(`:665–728`). The selected body removes none. `flush_ssaname_freelist` splices
the empty queue and truncates it (`:322–329`), so neither free vector grows.

Out-of-SSA encounters zero real partitions and PHIs. Its indirect-clobber
removal is the only local `release_defs` path and requires a clobber with
SSA-based MEM_REF (`tree-outof-ssa.cc:1335–1360`), absent here. Existing
partition/ranger requests remain separately charged. RTL expansion clears
GIMPLE sequences and switches the representation, rather than copying SSA
names or calling `gimple_seq_discard` for these statements
(`cfgexpand.cc:7260–7300`). It creates no new SSA operand producer.

For operand uses, rescanning first links the whole old list into `free_uses`
before creating its replacement (`tree-ssa-operands.cc:456–485`). `alloc_use`
consumes that freelist first (`:351–363`). Every selected statement still has
at most its original one use. Thus arbitrary repetitions of these same-shape
rescans cannot increase the total allocated entry requirement beyond
u=3C+1: each replacement can reuse the entries just returned. Slabs remain
rooted in the function's operand-memory chain until teardown; collection
cannot discard them and force an uncharged cold reconstruction. There is no
intermediate `fini_ssa_operands` followed by reinitialization on this route.

Final cleanup calls `delete_tree_ssa` (`final.cc:4515–4516`). The helper
removal route also calls it (`cgraph.cc:2186–2201`). It frees the name vectors,
clears default-def state and releases active operand slabs
(`tree-ssa.cc:1226–1241`, `tree-ssanames.cc:170–185`,
`tree-ssa-operands.cc:284–300`). It does not release names individually into
a newly allocated free list. The one-key default hash uses its already
accepted small-table clearing path; no new backing is introduced.

## Transfer and remaining work

The [initial allocation envelope](retained-literal-pipeline.md#initial-ssa-lifetime)
therefore remains valid for these Main SSA families through teardown:

```text
fresh SSA_NAME objects <= 3C+1; live-vector logical length <= 3C+2;
default hash keys = 1; new later free-list or queue requests = 0;
L = 1 + [3C+1 > 25] + ceil(max(0, 3C+1-127)/409);
SSA-owned GGC requests <= 6C+10+L.
```

This is the same already-owned initial allowance, extended in lifetime.
It is not an added subtotal. The name-vector rounding/capacity, version,
renamer and request-size guards remain conjunctive and unchanged. For retained
Hello, the same 17 SSA-owned events cover the whole selected lifetime.
The two helpers' earlier names and backing, `.MEM` identifier/UID accounting,
and shared scalar finalizer registration retain their existing owners.
Global created/reused statistics are separately classified by the pending
MEM/counter argument and are not used here as semantic indices.

This closes no pass-manager, shared bitmap/ET pool, ordinary traversal/stack,
typed-array/outer-finalizer or collector page/accounting obligation. Removing
an incremental-updater allocation term does not remove the ordinary CFG
cleanup work around its early return. The complete disjoint GGC ledger,
actual-source aggregate attachment of this extension, remaining native and
Why/parent/required-consumer work and full-current-grammar #119 composition
remain required. Oracle, installed tools and production admission are unchanged.
