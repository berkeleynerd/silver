# Selected literal CFI and CFG ordinary containers

2026-10-19, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
This packet closes the **named ordinary CFI trace/hash/vector, expansion
label/head-end/map, dead-instruction count, CFG traversal and forward-dominance
scratch representations**, conditional on their explicit arithmetic guards
and the accepted selected literal route. It adds **zero GGC events**, scalar
or array finalizers, bitmap chunks or ET-pool blocks. Independent review is
pending. Separate IRA/LRA private arrays, allocation/cost-class pools and
remaining native, collector, parent and proof obligations stay open.

The [evidence packet](../evidence/retained-literal-cfi-cfg-ordinary-20261019/README.md)
contains 42 local predicates, pure count arithmetic and a checked attachment
to the frozen accepted Hello result. It does not execute an upstream Context
or evaluator, broaden the production launcher or add a language restriction.
It has no dependency on the pending complete native GGC-event ledger.

## Inputs and boundaries

GCC source remains revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
The selected configuration is generic x86-64 SysV, O0 with
`-fsplit-wide-types`, no debug, checking, allocation statistics, PCH, LTO,
plugins or instrumentation. One Main reaches CFG/RTL and emission; the empty
elaboration and initially gimplified size helpers do not. The accepted
[RTL shape](retained-output-rtl.md),
[MEM/SSA attachment](retained-literal-mem-ssa-attachment.md) and
[shared bitmap/pool lifetime](retained-literal-shared-bitmap-pools.md) supply:

```text
C >= 1 output calls; N >= 0 null statements
E = N+6                    expansion block-index slots
B = 2N+10                  lifetime block-index slots and block-object ceiling
lifetime edges <= B-1
T = N+5                    CFI trace ceiling
K0 = 98+3C; K = 99+5C       pre-split and final first-unused register ceilings
R0 = 64C+N+16              pre-split nonchain RTL occurrence ceiling
M = 7C+5N+20               IRA-entry chain ceiling
Uf = 7C+7N+46              final first-unused UID ceiling
```

These are lifetime/source bounds, not a final graph's degree or one captured
compiler run. The small null-only totals in `native-rtl-helpers.json`,
`native-cfi-storage.json` and `native-rtl-emission.json` supply reviewed
layout/caller facts only; this packet replaces their source-sized demands.
Accepted implementations `e28fef05f2`, `86d50fa7ec32` and the acceptance report
in `d22953155f84` remain unchanged. The frozen Hello source has 118 bytes,
C=1, N=0 and SHA-256
`4afeb197991947076cf9d5a678d14ebdaa0ff8fd23339d54caf976a73c8984c7`.

The new manifest verifies 33 complete GCC files, 23 complete repository
records and 26 source excerpts. Repository records include accepted result,
input and check records, source arguments, the acceptance report, retained
layout/installed-header evidence and the standalone source recognizer. The
attachment checks raw source identity and **all** recognized counts against
the top-level, core, MEM and pool owners; it checks the stored source path,
launch, shared inputs and path class, inherited guards, B/K/M/Uf chronology,
trace/row counts, ET ownership and emission-label endpoints. The stored
accepted source path denotes the predecessor's checked workspace, not a
claim that this worktree was compiled. No upstream result is recomputed.
Before recognition, bytes outside printable ASCII, HT, CR and LF are rejected;
the historical recognizer's FF/VT whitespace allowance is not inherited.

## Ordinary CFI lifetime

`dw_trace_info` is 144 bytes and `queued_reg_save` is 24 bytes on the retained
LP64 layout (`dwarf2cfi.cc:114–171,230–237`). The latter contains two pointers
and one fixed poly-int value. Trace records include existing GGC row pointers,
two fixed CFA records and a separate ordinary pointer vector; that does not
change the owners of the pointed-to rows or their GGC save vectors.

`create_pseudo_cfg` makes an exact initial 16-element trace vector, pushes the
entry trace, then one record per selected save point. At most N+2 labels and
two frame notes give T=N+5. Its record IDs and indices are unsigned. For an
ordinary vector with this initial capacity, an upper capacity is

```text
F16(T) = 16,                         T <= 16
         max(16, floor(3(T-1)/2)),    T > 16.
```

When another backing is needed, the old full capacity is at most T-1 and
GCC computes `old*3/2` before the requested-length comparison. The expression
above therefore bounds every backing, including retained spare capacity.
The guards separately require `3(T-1)<=UINT_MAX`, capacity<=INT_MAX (the
31-bit vector field), unsigned length/ID fit and
`8+144*F16(T)<=PTRDIFF_MAX` (`vec.h:253–261,304–321`, `vec.cc:150–169`).

The trace index is constructed **after the last trace-vector growth**
(`dwarf2cfi.cc:3157–3173`); pointers inserted into the hash cannot be made stale
by vector relocation. It has a 48-byte ordinary control and 8-byte pointer
entries, using the hash argument below with initial request<=T and at most
T insertions. The index receives no deletion/reinsertion cycle.

The selected no-EH trace graph is a linear fallthrough sequence. A scan can
discover only its next trace. `maybe_record_trace_start` changes its initially
null `beg_row` before pushing; an already discovered trace is not pushed again
(`:2541–2568`). Entry is scanned directly and each queued trace is popped
before scanning (`:2929–2949`). Thus the work list has at most one pointer,
capacity 4 and a 40-byte backing. This argument applies at CFI time, after
CFG mutations; it does not assert degree one during earlier edge redirection.

The sole queued register save is the fixed prologue RBP save. Duplicate saves
are replaced before insertion, and flushing truncates the queue; length<=1,
capacity 4 and backing 104 suffice (`:1217–1263`). The incoming return address
and RBP are saved in memory. The RSP-to-RBP move changes the CFA rule without
register-to-register save state. `record_reg_saved_in_reg` receives a null
destination and returns; `cie_return_save` is null. Consequently every
`regs_saved_in_regs` vector and copied vector stays empty (`:1193–1212,
1830–1848,2559–2565`). Work/queue vectors are released after scanning; each
trace vector is released and the index deleted at function end
(`:2931–2949,3295–3333`). Reuse does not accumulate logical length or capacity.

At most five nonempty CFI groups create `*.LCFI` labels. The accepted single
Main counter begins at zero, stores local signed values 0..4 and ends at most 5.
Each label requires at most 8 bytes including NUL and fits the 20-byte local
buffer (`dwarf2cfi.cc:475–482,2481–2532`, `config/elfos.h:122–130`). The ordinary
FDE begin/end `xstrdup` calls remain at most two requests, each<=26 bytes
including NUL, within their 40-byte local buffers
(`dwarf2out.cc:1071–1100,1249–1276`). Existing CFI/GGC vectors, FDEs, range
vectors, chain notes and emission-label/alignment owners are retained once.

## Hash arithmetic

For initial slot request a, at most h distinct insertions, no deletions and
entry size s, let `p=prime(max(7,a,2h))`, where `prime` is the least available
retained GCC prime. An initial request rounds upward; an expansion requests
`2*elts`, where elts<=h. Therefore p bounds every backing. This handles growth
**before** insertion, including a possibly nearly full initial trace table.
The expansion label map first uses a non-inserting `get`, so repeated label
queries do not trigger pre-hit growth. The retained table ends at 4294967291;
failure to find a prime is a failed local predicate, not a Python exception.

The checker covers `3p`, `4h` and `2h` in `size_t`, and conservatively checks
`8h<=UINT_MAX` for the unsigned `too_empty_p` parameter/multiplication. With
no deletions, growth at the insertion threshold normally short-circuits that
test, but the sufficient guard also covers its evaluation. Hash probing uses
unsigned32 `index += hash2`; index<=p-1 and step<=p-2 require
`2p-3<=UINT_MAX`. The last retained prime fails this condition. Each backing
also needs `s*p<=PTRDIFF_MAX` (`hash-table.h:595–624,755–777,818–881,
983–1012,1029–1067`; `hash-table.cc:43–79`). No sum of past backings is used
as an allocation request. Reallocation may retain an old and new backing
transiently, but neither stores a count of their combined bytes.

The hash search/collision counters are unsigned and only report diagnostic
statistics through `collisions()`; they do not size tables or govern lookup.
Their defined wrap is not a representation failure. Live-element/size fields
are `size_t`, and the separate guards above protect their relevant arithmetic.

## Expansion, jump and label helpers

| Ordinary container | Lifetime demand | Individual request ceiling |
| --- | --- | --- |
| Expansion block-to-label map | <=E keys; initial 13 slots | 48-byte control; `16*prime(max(13,2E))` backing |
| Head/end pointer-pair vector | <=E elements; exact initial reserve | `8+16E` |
| `maybe_local_decls` vector | <=C pointers | `8+8*max(4,2C)` |
| Empty stack-partition map | zero keys; 13 slots | 48-byte control;208-byte backing |
| Three empty CFG copy maps | zero keys; 13 slots each | 48-byte control;104-byte backing each |
| Dead-instruction register-use counts | <=K signed int elements | `4K` |

`label_rtx_for_bb` returns an existing RTL label or leading GIMPLE label
before creating a map entry. At most one key is inserted per block
(`cfgexpand.cc:2779–2831`). `head_end_for_bb.create(last_basic_block...)` runs
after construction of the initial block and before body expansion. Its
length grows within this reserve as blocks are visited. The selected body
has no local EH, abnormal edge or call split, so the initial E-slot reserve
covers every index encountered by that loop (`:6216–6217,7248–7277`). Both
the vector release and map deletion precede `construct_exit_block`
(`:7277–7307`); later lifetime block slots do not enlarge this vector.

For `maybe_local_decls`, charging C entries avoids depending on whether each
artificial declaration is ignored. At entry there are at most C descriptor
locals. They are register values; `is_gimple_reg` takes the `next` path.
Its MEM/CONCAT branch cannot append another local declaration. The retry
branch can push each original declaration at most once (`:2469–2570`). For
cold single pushes, capacity<=max(4,2C): cold allocation is 4, capacities below 16
double, larger capacities grow by3/2. The largest multiplied old capacity is
below C, so `3(C-1)<=UINT_MAX`, capacity<=INT_MAX and the individual byte span
are separate guards. The vector's destructor releases any backing.

All descriptors use registers, there are no scalar SSA partitions or stack
payloads, and `stack_vars_num` stays zero. The map is nevertheless constructed
and later deleted; its stack partition/sort/conflict arrays are absent
(`cfgexpand.cc:2374–2400,2488–2500,2590–2605`). Its bitmap obstack belongs to
the accepted shared bitmap/pool argument. CFG layout constructs three
`hash_map<int_hash<int,-1,-2>,int>` objects with request 10, rounding to 13 slots.
No block or loop duplication occurs, so they stay empty through reset and
deletion (`cfg.cc:1058–1094`, `cfgrtl.cc:4555–4583`). No new pool charge follows.

`delete_trivially_dead_insns` runs at the initial jump pass and again at IRA
entry, with possible pre-reload cleanup callers (`cfgcleanup.cc:3110–3162,
3237–3242`; `ira.cc:5805`). The no-debug branch allocates `int[nreg]`; debug's
three arrays, replacement array and later-debug heap growth are absent
(`cse.cc:7073–7243`). Use K throughout, rather than assuming every call sees
K0. Each invocation zeroes and frees its own counts array.

`count_reg_usage` visits instruction patterns, CALL_FUNCTION_USAGE and only
REG_EQUAL/REG_EQUIV notes (`cse.cc:6834–6945`). Selected O0 creates no new
equivalence note. The wide split replaces each DI SUBREG by its existing DI
part and adds no instruction or counted REG occurrence. Later location nops
have a constant payload; DF death/unused notes are not traversed. Thus the
accepted R0 operand-occurrence ceiling still bounds positive and negative
visits at both scans. Allow one extra pseudo-PIC increment conservatively.
The signed count magnitude is bounded by R0+1, and `ndead` by M; require both
to fit INT_MAX. This does not transfer the null program's zero-use assumption
to output calls. Post-reload cleanup excludes this API, and selected
threading, crossjumping and optimized repairs are disabled.

## Generic CFG traversal and dominance scratch

`find_unreachable_blocks` requests a B-pointer work list (`cfganal.cc:184–225`).
The entry edges are pushed once; later destinations are marked before another
push can be made. Each push has a distinct traversed edge responsible for it,
including any initial entry-edge multiplicity. The accepted lifetime edge
ceiling B-1 therefore suffices even without inferring an intermediate degree
from the final chain. Work-list storage is at most 8B bytes.

The postorder, inverse-postorder and preorder helpers use
`auto_vec<edge_iterator,20>(n_basic_blocks+1)`, mark a newly visited block
before descent and hold at most B+1 iterators. Their initial reserve is exact;
all subsequent pushes are `quick_push`, so they need no geometric growth
(`cfganal.cc:655–735,824–965,979–1071`). An iterator is 16 bytes. If B+1<=20,
the stack is inline and requests no heap storage; otherwise its request is
`8+16(B+1)` (`vec.h:1665–1710`). Pre-/postorder counters stay between -1 and B.
At the selected invocation boundaries the reachable graph is the acyclic
entry-to-exit chain, so inverse traversal's infinite-loop recovery is absent.

The dense visited bitmap has `8+8*ceil(B/64)` bytes. `sbitmap_alloc` stores
its rounded size, bytes and final request in unsigned32, so both B+63 and
the final request must fit UINT_MAX (`sbitmap.cc:42–54`, `sbitmap.h:83–94`).
The preorder helper's block flag uses bit 15 and balanced RAII; it does not
consume a new bit on every invocation (`cfg-flags.def`, `cfg.h:140–190`).
The ordinary loop reverse-order array is 4B bytes. Root-only loop discovery
has no loop-header insertion; its empty candidate vector reserves exactly
one pointer, 16 bytes (`cfgloop.cc:435–524`). `loops_list` holds at most the
root index in **16 inline integer slots**, so its reserve of one requests no
heap backing (`cfgloop.h:771,803–847`). This is the actual inline behavior,
not a heap charge inferred from the reserve argument.

Cold full-function forward dominance requests nine unsigned[B] arrays, one
unsigned[B+1] order array, one pointer[B] map and one edge_iterator[B+1] DFS
array (`dominance.cc:148–219,302–391`). B bounds both live blocks and the
last block-index extent, including holes. DFS starts at one and omits the
exit node, so all assigned array indices fit; mark-before-descent limits the
signed stack pointer. Set sizes and their doubling/additions are bounded by
2B; fast-query numbering performs at most 2B signed increments. The retained
conservative `4B<=INT_MAX` guards these intermediates separately from each
request span (`:516–545,640–688`). Arrays are destroyed after construction;
another setup starts fresh. No region or incremental-repair construction is
selected. Existing shared ET pools retain both-direction coexistence and
relative-depth arithmetic; their accepted owner is copied without recharge.

Selected caller exclusions matter: CFG dump/checker arrays require their
disabled gates; partition-fix vectors require `crtl->has_bb_partition`, false
on this unpartitioned route (`cfgrtl.cc:2227–2229,2417–2465,2940`). Threaded
edge arrays require CLEANUP_THREADING, and head-match arrays require the
crossjump/hoist path (`cfgcleanup.cc:480–493,2442–2444,2937–2951`). The
dominated-block deletion vector requires GIMPLE plus debug binds
(`:3013–3031`). These exclusions do not use a whole-file allocation census
as proof that unrelated native helpers are closed.

## Result and remaining obligations

For Hello, the trace vector remains 2312 bytes; the conservative trace-index
ceiling is 13 pointers/104 bytes, rather than claiming its old null-case
exact seven-slot allocation. The expansion label map has a 208-byte backing,
head/end vector 104 bytes and jump count array 416 bytes. CFG iterator stacks
fit inline; cold dominance's nine unsigned arrays are 40 bytes each, order 44,
pointer map 80 and DFS array 176. These are **individual request ceilings**,
not a simultaneous-memory or lifetime-allocation sum.

The new check passed **148 checks**, **22 count-only cases**, **2048 trace
lengths** (12 growth boundaries) and **58 hash-prime boundary cases**, in
**0.07760772301116958 seconds** on Linux 7.0.14 x86_64. It checks signed usage
and deletion limits, inline/heap transition, prime exhaustion, unsigned probe
addition, per-request overflow, exact owner preservation and source/path/
configuration/count/pin mutation rejection. Finite checks exercise the
interfaces and arithmetic; the preceding source argument supplies the
universal lifetime claims. No native tool, build, capture, prover/solver,
accepted suite, aggregate or corpus replay ran.

Implementation selected **GPT-6 Astra / Extra High**. Runtime setting
confirmation, token usage and monetary cost are unavailable. The
[round record](../evidence/retained-literal-cfi-cfg-ordinary-20261019/round.json)
separates measured checker time from the clock-checkpoint interval. No retry
or expensive validation was required. The parent owns review, issue/index
updates and publication; CLI memory was not updated by this subthread.

IRA/LRA private arrays and allocation/cost-class pools, remaining ordinary
native helper/stack state, complete collector composition, the separate
parent materializer and producer/proof pipeline remain distinct obligations.
Nothing here revives a GPRbuild/Gprbind inventory for the selected native
design. No complete-native, complete-collector, complete-parent, full-current-
grammar or production-capacity claim follows from this named container join.
