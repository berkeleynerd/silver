# Literal MEM and counter-lifetime review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept the bounded packet. No material findings.** The selected MEM attribute
partition retains its existing `5C` owner, the reset/reuse chronology is supported
by source, and the additional register backing and ordinary DF pool bounds
preserve the distinction between allocation history and simultaneous storage.
This does not close the later SSA event ledger, shared bitmap/pool storage,
typed-array finalizers or collector totals.

## Frozen inputs and review record

Review target: **`9d24cab8cf9ba9fa6148ed21d340926444cbdd31`**, all eight new
files: the [source note](../research/retained-literal-mem-counter-lifetime.md)
and seven files in its
[evidence packet](../evidence/retained-literal-mem-counter-lifetime-20261019/README.md).
The packet's base is `054b25caec5c46974f484a21ecd7ab7b0fa52bd3`; its 19
repository inputs were read as frozen Git blobs, including the accepted pipeline,
shared-query, initial SSA/helper, operation, RTL/DF/LRA and emission interfaces.
The 56 GCC input files are pinned to revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Source inspection used matching
local files, retained in this review worktree's scratch directory.

The lead assigned this independent review under the continuing owner-authorized
#119 work, with Oracle, tools and admission unchanged. Selected reviewer:
**GPT-6 Astra / Extra High**. Runtime confirmation, token usage and monetary
cost are unavailable. Review began **01:08:09 UTC** and reached the report
checkpoint at **01:13:28 UTC**, **319 seconds** at one-second resolution,
including report preparation and excluding final commit. This is reviewer
wall time, not native execution time or whole-team cost. Actual host:
Linux 7.0.14 x86_64. An isolated sparse worktree
held the exact target. Only this new report is committed. The subthread harness
goal was null; CLI memory was not updated. The lead owns integration, GitHub
and harness bookkeeping.

The retained 49 author checks, 27 count-transfer cases, 48 register boundaries
and 42 pool boundaries passed in **0.06509972499770811 seconds**. I read their
implementation and recorded result and reused that evidence. No native tool,
capture, disassembler, compiler, prover, solver, predecessor Context, old suite,
corpus or aggregate evaluator was run. No GitHub write or delegation occurred.

## MEM attributes and allocation ownership

`emit-rtl.cc:378–395` allocates at most one record per effective
`set_mem_attrs` update. Equality/default cases reuse or clear the pointer. There
is no `mem_attrs` hash table in this implementation, despite the historical
comment in `rtl.h`. The record holds tree/offset metadata; assigning it does not
recursively copy its referenced tree.

The selected tree-pool construction makes at most `2C` MEMs with two setters
each (`varasm.cc:3781–3786`); `gen_const_mem` itself only changes flags. Direct
calls supply one expression setter per call. The retained x86 direct-call path
keeps that MEM, so `calls.cc:483–486` does not apply a second expression setter.
Function declarations skip `set_mem_attributes`; the descriptor/component paths
are REG/SUBREG paths. `copy_rtx` and final unsharing shallow-copy the non-RTL
attribute pointer while sharing the SYMBOL_REF, rather than allocating another
attribute record.

Ordinary RBP push/pop use raw `gen_rtx_MEM` with PRE_DEC/POST_INC, and that
constructor clears `MEM_ATTRS`. The inspected `gen_frame_mem` alternatives
belong to the excluded extra saves, realignment/DRAP, probing, EH-return,
static-chain or separate shrink-wrap routes. The two CFI `adjust_address` sites
initialize the builtin dwarf-register-size table; they are not part of the
ordinary CFI scan. Final `alter_subreg` adjusts a MEM only for SUBREG-of-MEM,
absent after the selected register split.

The setter partition therefore supports **`5C` existing 40-byte records and
zero additional later records**. The fixed RTL setup's records remain in its
437-event envelope. This review does not recharge either owner or remove the
separately conservative frame-alias ID from the accepted graph.

## Counter chronology and backing growth

The unsigned global `ssa_name_nodes_created/reused` references are confined to
declarations, increments and statistics output. Version selection uses the
per-function SSA vector and free lists instead. Defined unsigned wrapping of
these disabled statistics is not a capacity-control failure; it supplies no
bound for later SSA allocations. The packet correctly leaves those events open.

`prepare_function_start` calls `init_emit` for the dummy and Main. Each starts
UID 1 and pseudo 98 and obtains its own 198-entry arrays. Dummy cleanup frees
the ordinary alignment array, clears RTL state and the global register pointer,
then pops. `init_emit` snapshots the global label allocator rather than resetting
it. The retained emission prefix and its final endpoints are preserved.

The register-growth subtraction uses the established three new pseudos per
literal call, followed by exactly two split pseudos per call and LRA's one
unused pseudo. `gen_reg_rtx` checks capacity before incrementing the next
number, so an extent equal to capacity needs no growth. Starting at 198,
the complete count is `q(99+5C)` and the already-owned count is `q(98+3C)`.
The difference correctly owns the additional pointer and alignment backings.
The separate `q <= 23` guard protects actual signed doubling; the two initial
array owners remain separate. Pointer-array elements are trivial, so this
additional backing does not create scalar or array finalizer registrations.

The alias vectors are static null pointers before the sole selected IRA alias
analysis. The dummy runs setup, not RTL passes; no helper reaches RTL. The
other inspected alias-analysis callers belong to unselected optimizing passes.
Iterations reset `unique_id` and reuse the vectors. The absent REG_NOALIAS
route leaves the ID at 1. Thus the cold incoming state and two already-owned
requests are justified without multiplying requests by the iteration ceiling.

`df_d` is initially zeroed, but SCAN reconstruction frees its arrays/pools and
does not reset `df->ref_order`. Both accepted generations and transient
rescan references therefore remain in the same `F+A` counter bound. The
similarly named `df_ref_info.ref_order` is an ordering enum for optional tables,
not this creation counter. LUID resets per block; LR age/dcount state is local
to each solver invocation. LRA resets its recognition pointer array and
`last_reg_value`; its existing no-repair/no-coalescing result bounds the latter
by `floor(3K/2)+1`. The signed tripling and recognition capacity guards remain
in the consumed interface.

Balanced cfun pushes/pops and the bounded dummy/TODO/gimplification nesting fit
the existing four slots. The separate language-context stack has no selected
push. The sequence cache is explicitly deletable, so peak nesting cannot
replace the retained cold allocation budgets `10 + 8C + 5`. No global native
stack bound is inferred from these local facts.

## DF collection vectors and ordinary pools

The call-reference collector traverses the 92 canonical hard registers and
the two argument USEs. The admitted call pattern has no additional
register-valued address. Definition/use ceilings 92/94 hold before collection
deduplication; ordinary frame and register patterns are smaller. Selected
REG_EQUAL/REG_EQUIV payloads do not add register uses, and no multiword hard
register survives this route. Collection vectors truncate between instructions
and blocks rather than retaining all `C` call entries.

At the first heap reserve, `vec.h:1966–1991` hides the inline buffer, adds its
current length to the request and uses an initial allocation of 33. The later
growth recurrence gives **33, 49, 73, 109** and requests **272, 400, 592, 880
bytes**. Truncation keeps that backing; destruction/release ends the record's
heap lifetime. The selected nonchecking callers use a single collection record
at a time. The four-request bound is per record, not a total for the pass.

The nonchecking object allocator adds no per-object ID prefix. Its eight-byte
block header and rounded object sizes give the stated slots per 65,536-byte
block. A new block is requested only when returned and virgin slots are both
exhausted. At that point all retained slots are outstanding, so an outstanding
ceiling `L` bounds retained blocks by `ceil(L/t)`. Returning an object changes
the free count, not the retained-block count. Release frees blocks and zeroes
the allocated/free/block counters.

Using the accepted all-lifetime `F` and `A` as separate per-generation ceilings
is conservative even for temporary rescan references coexisting with installed
ones. DF instruction records are unique by UID, returned on deletion and
bounded by `Uf`. The old six pools are deleted before reconstruction. The four
newly priced rows therefore give **60 retained blocks per generation and 120
lifetime block requests for Hello**; those are not 120 simultaneous blocks.
The register row remains with its predecessor owner. LRA likewise returns old
records before replacement and releases its pools at finish; its slot counters
do not count every historical allocation. These ordinary pools add no GGC
events or finalizers. Shared bitmap obstacks and the other listed pools remain
outside this closure.

## Independent verification and disposition

All **56 GCC and 19 frozen repository identities** matched. The seven exact
review-input identities in `round.json` also matched. One narrow arithmetic
diagnostic passed in **0.021284920003381558 seconds**. It extracted only the
new pure register/vector/pool functions via AST; it instantiated no Context and
called no predecessor evaluator. Independent finite source-state probes covered:

- Six register creation histories, including `C=33/34` and `C=99/100`, where
  the pre-split owner crosses a backing threshold and the additional count
  drops from one to zero while the final backing size stays unchanged.
- Collection fill/truncate/regrow histories through 94 uses, retaining exactly
  the four initial heap requests.
- Five pool object sizes with repeated allocate/return waves and two released
  generations, distinguishing many allocation calls from three retained blocks
  per generation and six lifetime block requests.
- Retained Hello results and explicit null/false later-SSA, all-GGC,
  finalizer, collector and whole-pipeline completion fields.

These probes supplement the source argument; finite cases do not establish its
universal reachability claims. Scratch script SHA-256:
`3bda2aa9d66e192f862a1000cf06db45df861ed6bca51a69ec6b80bffb9c8299`;
result SHA-256:
`91997812321065bd2ab75192c8095a0dcb73c89b5bf845d1ccc97faf1038c428`.

**Disposition:** accept this packet's selected MEM, counter chronology and
typed-pool bounds under its exact source/option/platform premises. Preserve
the additional `q(K)-q(K0)` backing events when composing the future ledger,
and preserve each earlier owner exactly once. Later SSA update/rename events,
all direct/shared GGC events, shared ordinary bitmap/pool lifetimes, typed-array
and outer finalizer bookkeeping, collector epochs/pages/metadata/counters and
production materialization/source correspondence remain required. No complete
native or full-current-grammar capacity result is established here.
