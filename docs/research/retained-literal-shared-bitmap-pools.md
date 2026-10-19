# Literal shared bitmap and selected ordinary pool lifetimes

2026-10-19, research [#119](https://github.com/berkeleynerd/silver/issues/119),
retained Linux x86-64/LP64 GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
This closes the selected **default, register and DF sparse-bitmap allocator
representation obligations**, and supplies shared dominance-pool and LRA
live-range-pool retained-count bounds. It adds **zero GGC events or finalizer
registrations**. Existing allocation owners remain in place. The complete
native event ledger and collector capacities remain open; there is no RAM gate
or production admission change.

The [packet](../evidence/retained-literal-shared-bitmap-pools-20261019/README.md)
pins the source and accepted inputs, checks actual-source/count/owner joins and
exercises the new arithmetic. Reachability and lifetime reasoning below is a
handwritten source argument, pending independent review. Input identity and
finite checks do not prove that argument. Retained installed-source
correspondence and successful ordinary allocation remain the existing explicit
premises.

## Inputs and boundaries

Reuse the accepted [literal RTL shape](retained-output-rtl.md),
[initial CFG/SSA and helper owners](retained-literal-pipeline.md),
[shared-query chronology](retained-literal-shared-query-lifetime.md), and
[MEM/counter/pool chronology](retained-literal-mem-counter-lifetime.md), whose
[review](../reviews/review-literal-mem-counter-lifetime-9d24cab8cf.md) has no
findings. In this new packet:

```
C >= 1; N >= 0
G  = N + 4                 initial GIMPLE block-index extent
B  = 2N + 10               final block-index extent
K  = 99 + 5C               final first-unused pseudo number
M  = 7C + 5N + 20          IRA-entry instruction-chain ceiling
U  = 7C + 5N + 22          LRA first-unused UID ceiling
Uf = 7C + 7N + 46          complete Main first-unused UID ceiling
P  = 2M + B = 14C + 12N + 50
D  = 5869 + 5C + N + 3d    next DECL_UID, d = distinct output callees
```

All bounds retain their source/configuration guards. The source family is the
accepted straight literal-output/null sequence, generic SysV x86 O0 with the
reviewed split-wide selection, no debug, checking, statistics, LTO, plugins,
instrumentation or alternate frontend. There is one lowered/emitted Main, no
recursive lowering, nested function, thunk or clone. The empty elaboration is
never gimplified; the two size helpers are only initially gimplified and never
obtain CFG/RTL. Their earlier allocations are not erased.

The parent subsequently accepted the later-SSA zero-increment result at
`e0c24340e8` under review `c63c6088f91d00e4224c7cf96fe1367e20861e83`, integrated
at `a1959347de`. This packet stays based on `412dfa64e5` and does not copy or
execute that result. Its bitmap allocator argument works independently of
the number of no-work SSA/TODO dispatches; it neither changes nor recharges
that SSA owner.

## Why shared ordinary bitmap history needs no total counter

`bitmap_obstack` contains two freelist pointers and an ordinary obstack, with
no object-count or chunk-count field (`bitmap.h:294–351`). A header is 32 bytes;
an element is 40 bytes and represents 128 bits. `bitmap_alloc` takes a returned
header or allocates one completed header; `bitmap_element_allocate` similarly
takes a returned element or allocates one completed element
(`bitmap.cc:102–145,779–807`). Returned elements may be linked as lists of
lists. These are links, not a monotonically increasing allocation index.

Initialization allocates a 65,536-byte chunk immediately, including for an
empty family (`bitmap.cc:733–752`, `coretypes.h:375–389`). `XOBNEW` uses
`obstack_alloc`, which finishes the object (`include/obstack.h:375–415`). Thus
on entry to `_obstack_newchunk`, the unfinished object size is zero. Its
candidate size is at most `0 + 40 + 7 + 0 + 100 = 147`; taking the maximum
with the configured chunk size still requests exactly 65,536 bytes
(`libiberty/obstack.c:188–235`). The relevant pointer differences and offsets
stay within that individual chunk. Release traverses/releases the chain and
clears the freelists (`bitmap.cc:758–775`). No selected caller asks
`_obstack_memory_used` to sum the chain.

Consequently arbitrary finite allocation/release history, even if it retains
more chunks than currently live elements require, introduces **no cumulative
bitmap counter or larger individual request**. A fresh-chunk upper bound such
as one per fresh header/element is useful optional accounting; it is not an
additional native admission obligation. We deliberately export null for the
whole lifetime chunk count and do not replace it with a live-element count.
This discharges the earlier request for combined incoming/live demand only
insofar as that demand was thought necessary for the shared allocator's
representation. It does not claim a measured or bounded aggregate RAM footprint.

An actual bitmap bit number still matters. For exclusive domain bound X,
one header has at most `ceil(X/128)` live elements. `X+127 <= UINT_MAX` covers
the element-index rounding/reconstruction and iterator next-bit arithmetic;
each selected range end is at most X (`bitmap.cc:1690–1715`,
`bitmap.h:539–573,703–733`). Counts of set bits are at most X and fit the LP64
unsigned-long result (`bitmap.cc:1136–1155`). `bitmap_last_set_bit` returns an
index in the same domain. No operation accumulates a lifetime element count.
The statistics-only 29-bit descriptor and serial do not control selected
allocation behavior because `GATHER_STATISTICS` is false.

This argument applies to ordinary `bitmap_alloc(NULL)` after it resolves to
the default obstack, and to explicit ordinary obstacks. `bitmap_gc_alloc`
is a distinct allocator; `bitmap_initialize(head, NULL)` creates a GGC-backed
bitmap and is not included by pretending that a null pointer is ordinary
(`bitmap.cc:809–821`). Every family below uses the actual ordinary obstack.

The shared `memory_block_pool` behind the bitmap chunk hooks and typed pools
also has only a freelist pointer, not a stored block count. Allocation pops a
returned 65,536-byte block or makes one request of that size. Release pushes
it onto the common list (`memory-block.h:25–78`); a returned block can outlive
its original obstack or typed pool. `mempool_obstack_chunk_free` obtains size
from the individual chunk's limit pointer, not a cross-chunk difference.
`trim` skips a requested prefix (default 16 blocks) with a decreasing local
int, then frees the remaining linked chain without counting it
(`memory-block.cc:36–91`). This common cache therefore needs no sum of retained
blocks across families. Releasing a pool is not a claim that its physical
memory immediately returns to the operating system.

## Selected shared and private bitmap families

The default-obstack signed depth counts nesting. Initialization increments
and returns when already active; release decrements and frees only at zero.
The retained pass-framework source argument gives depth at most nine: eight
sites in `cgraphunit.cc:316,582,607,700,1191,1844,2238,2396`, and one in
`symtab.cc:1454`. The selected unit frontier supplies no recursive lowering
or nested generated-body processing that could revisit a site while active.
The no-callgraph-info, no-selftest and selected-pass gates exclude the other
initializers (`toplev.cc:1920–1943,2265–2295`); LTO, other frontends, strub,
optimized x86 passes and the special RTL frontend are absent. Explicit private
obstacks never increment the default depth. Repeated balanced scope entry
therefore does not spend an unbounded signed initialization counter.

| Owner/family | Selected domains and lifetime |
| --- | --- |
| Initial CF/CFG default bitmaps | Retain three headers; altered set has at most `ceil(G/128)` live elements, other sets empty. |
| Initial SSA default bitmaps | Retain three headers. Kills has one live sparse element keyed by the globally bounded `.MEM` DECL_UID; at most G fresh-element requests remain the prior accounting ceiling. PHI-prune has at most `ceil(G/128)` elements; IDF is empty. |
| Initial SSA private bitmaps | Block indices below G and initial SSA versions below `3C+2`; retain the accepted private-obstack owner. |
| Out of SSA default bitmaps | Retain five headers and zero elements because there are no real partitions/PHIs. |
| Ranger private bitmaps | Two sequential instances, each five private bitmap obstacks, at most `2(N+5)+8` headers and zero elements. Existing initial-chunk and header owners remain unchanged. |
| Split default bitmaps | The accepted three split contexts plus queue/propagation headers; populated sets use pre-split register numbers below `98+3C < K`. No subreg graph edges. |
| `reg_obstack` | Main's one scope (`cgraphunit.cc:1863–1879`) contains register, UID, block and program-point sets detailed below. |
| DF scan register obstack | Five heads (three embedded, two allocated), hard-register domain 92, hence at most five live elements. Each scan generation initializes its own obstack. |
| DF scan instruction obstack | Three embedded deferred/delete/rescan heads, UIDs below Uf, hence at most `3*ceil(Uf/128)` live elements per generation. |
| DF LR private obstack | Four embedded heads per block, register domain K, at most `4B*ceil(K/128)` live elements. Initialized once, retained through analyses, released at LR teardown. Checking-only saved copies are absent. |
| Shared `df_bitmap_obstack` | Core/subset/solver sets use block/postorder indices below B; rescan temporaries use UIDs below Uf; scan artificial-entry/exit, NOTE and regstat sets use registers below K. |

DF sources are `df-scan.cc:133–195,229–277,1177–1250,3613,3790`,
`df-core.cc:500–552,690,821,1032–1045,1288,1480,1696`,
`df-problems.cc:724–787,1077,1318,3754–3756`, and
`regstat.cc:237–246,368`. A focused reference search found no other
`df_bitmap_obstack` client file. Other dataflow problems (RD/LIVE/MIR/CHAIN/
WORD_LR/MD) and checking-only verification are not in the selected schedule.
The accepted two SCAN generations release the old scan obstacks and typed
pools before rebuilding; they do not reset `df->ref_order`. LR state has its
own lifetime. The two generations do not coexist as owning states; returned
blocks may survive in the common cache. None of these facts needs a sum of all
historic bitmap creations.

The `reg_obstack` clients include IRA's empty SCRATCH sets and at most 34
class-indexed dead-point heads (`ira.cc:5499–5500`, `ira-build.cc:2696–2739`);
LRA's per-register instruction bitmaps, five transform sets, inheritance
sets, block gen/killed sets, elimination temporaries, assignment scratch and
spill sets (`lra.cc:1358,2488–2492`, `lra-constraints.cc:5600,7551–7555`,
`lra-lives.cc:487–498`, `lra-assigns.cc:1408–1418,1655–1686`,
`lra-eliminations.cc:1148,1521`, `lra-spills.cc:541–542`). Their bit keys are
registers/ORIGINAL_REGNO below K, hard registers below 92, instruction UIDs
below U (conservatively Uf), block indices below B, or IRA live points below
P. The per-register header array has the already accepted `floor(3K/2)+1`
extent; its populated instruction sets retain the 10C live-element ceiling.
No new/reload pseudo changes an ORIGINAL_REGNO domain. O0 gates exclude
peephole2, scheduler, combine-stack-adjust and the other optimizing clients;
the accepted no-spill/no-failure path excludes failure-only assignment sets.

The two private LRA assignment obstacks are distinct from `reg_obstack`.
Both have a P-entry header array, at most 32P bytes per array. Their keys are
register numbers below K (`lra-assigns.cc:346–365,418–456`). The assigned
hard-register-pseudo sets can be populated; they are **not** classified as
empty. The reload/inheritance sets are empty because the corresponding
pseudo interval is empty. Their two initial chunks retain the older ordinary
owner. The allocator theorem covers any additional ordinary element requests.

## LRA live ranges and program-point requests

The accepted schedule has one LRA live-range construction, one assignment,
two constraint iterations and no secondary live-range rebuild. Each instruction
advances the live point at most twice, each processed block at most once
(`lra-lives.cc:937,1032,1196`); the counter starts zero at `:1433`.
The final deleted note is not a nondebug instruction. Thus `P=2M+B` covers
the point endpoint. IRA has the same two instruction and one block increments
(`ira-lives.cc:1515,1545,1604`); its extra increment at `:590` belongs to the
excluded early-clobber/tied-operand conflict routes (`:635–655`). Compression
can only reduce the endpoint.
Require `P+1 <= INT_MAX` for finish-plus-one and inclusive loops.

The point-frequency vector initially reserves `2*get_max_uid()` unsigned
entries (`lra-lives.cc:1434–1437`), at most 2U. Each point increment pushes
one entry (`:538–542`). Before a subsequent growth the old capacity is below
the eventual length P, so its three-halves growth is covered by 2P, with
intermediate at most 3P. Use capacity `max(2U,2P)`, require it to fit the
31-bit vec field, and require `2U,3P <= UINT_MAX`. Its individual backing
request is at most `8+4*max(2U,2P)` bytes. This is a capacity bound, not an
assumption that the initial reserve always suffices.

The point bitmaps used by compression have requests
`8+8*ceil(P/64)`, with unsigned rounding and stored-size checks. The map is
4P bytes; assignment's two bitmap-head arrays are each 32P bytes. The selected
register sparse sets have individual request `32+8K`, checked against the
actual unsigned request field. These checks complement the predecessor's
register/UID/DF guards rather than replacing them.

`lra_live_range` is 32 bytes on the selected layout (`lra-int.h:37–51`). Its
pool is ordinary and starts empty. `update_pseudo_point` immediately ignores
hard registers and creates at most one range per USE_POINT call
(`lra-lives.cc:251–285`). There are no pseudo live-outs at block boundaries,
so `:685` creates none. The instruction loop calls USE_POINT once for each
non-OP_IN record at `:873`, or once for each OP_IN record at `:958`; these
cases are disjoint. The accepted instruction-register record ceiling 10C
therefore bounds live-range creation and retained live objects. The only
other creator copies a range list; its callers belong to spill/coalescing
routes excluded here (`lra-spills.cc:365,389`, `lra-coalesce.cc:114`). The
pool is released at finish (`lra-lives.cc:1574`).

The copy pool remains empty: `lra_create_copy` in the selected live scan
requires both operands at or above `lra_constraint_new_regno_start`
(`lra-lives.cc:835–846`). The initial unused pseudo is created before that
boundary; no new reload pseudo follows it. The invariant pool likewise
remains empty: its only insertion caller is
`process_invariant_for_inheritance` (`lra-constraints.cc:6806`), whose call
requires a destination reload pseudo (`:7174–7185`). Original SYMBOL_REF
definitions do not satisfy this condition. The invariant vector's initial
100 slots and initial 127-slot hash are still allocated by initialization;
they retain their accepted ordinary owners (`:5916–5938`). Zero pool objects
does not mean zero initialization requests.

## Shared Euler-tour dominance pools

The only non-selftest `et_new_tree`/`et_set_father` clients are in
`dominance.cc`. Every node is stored in a basic block's one slot per direction
(`:733–749,784–792,1563–1580`); only Main obtains a CFG. G is at most B. Allowing
both directions conservatively gives at most **2B simultaneous nodes** across
all selected phases. Each node has one rightmost occurrence and at most one
parent-edge occurrence, so there are at most **4B simultaneous occurrences**
(`et-forest.cc:443–477,517–545`). Relinking splits/releases the old parent
occurrence first (`dominance.cc:872–888,1000–1005`, `et-forest.cc:603`).
The one new occurrence allocated before installing the new edge is included
by the at-most-one-parent-edge allowance. Construction/destruction of a later
phase does not add its former live population again.

Teardown returns each node and both occurrences, releases empty pools and
resets the per-function direction counter (`dominance.cc:802–819`,
`et-forest.cc:483–511`). Even if the opposite direction keeps a pool alive,
returned slots are reused before another block is allocated. Hence live
coexistence, including both directions, bounds retained backing; a count of
all past dominator constructions is unnecessary.

The selected nonchecking sizes are node 64 bytes and occurrence 48 bytes;
capacities per 65,536-byte block with an eight-byte link are 1,023 and 1,365.
The retained initial SSA/CFG envelope used more conservative checking-safe
72/56-byte sizes (910/1170 slots); **its block owner is not reduced or charged
again**. This join uses the actual selected capacities to bound the pool's
stored `size_t` counts, including all free slots in the last block:

```
ET node retained slots <= 1023 * ceil(2B / 1023)
ET occurrence slots   <= 1365 * ceil(4B / 1365)
LRA live-range slots  <= 2047 * ceil(10C / 2047)
```

`base_pool_allocator` allocates only when both returned and virgin free slots
are exhausted, increments allocated/free counts by one block capacity,
decrements free on allocation, increments free on return, and zeros all
counts on release (`alloc-pool.h:208–226,315–327,348–426,457`). Thus these
are retained-slot bounds, not lifetime allocation-call bounds. Each block
request is fixed at 65,536 bytes. Unsigned pool-ID wrapping has no selected
uniqueness role: the ID stores/checks are compiled out with checking disabled.

Per-direction DFS numbering starts zero and assigns at most two numbers per
node, at most 2B (`dominance.cc:640–688`). The previously accepted relative
depth/min argument applies to each tree of at most B nodes: fields describe
differences of tree depths; the fixed-number intermediate expressions in
splay/relink are bounded conservatively in magnitude by 8B
(`et-forest.cc:61–83,302–421,517–545`). Require `8B <= INT_MAX`. Repeated
queries do not accumulate the query count into these depth fields.

## Ownership and remaining collector inputs

All objects in this packet are ordinary malloc/obstack/pool objects. They add
no GGC events, scalar registrations or array registrations. Existing initial
CFG/SSA, ranger/out-of-SSA, split, DF and LRA initialization rows remain with
their prior owners. The accepted DF typed-pool generations and LRA recognition/
instruction-register pools retain their earlier bounds. This packet does not
close other IRA allocno/object/live-range/cost pools or all ordinary pass helpers.

The accepted [collector callback effect](retained-literal-collector-callbacks.md)
remains zero added GGC events; each empty value-expression marker makes one
ordinary 104-byte hash request and frees it on return. Its unknown invocation
count is not needed for that individual request. Scalar finalizer lifetime
has the accepted shared-query owner (Hello: 39,275 registrations); this packet
does not add to it.

The next collector join still needs the disjoint positive GGC event and
individual-request ledger, then the selected typed-array registrations and
element counts, outer context/finalizer-vector backing, and page/order/mark
metadata and epoch/counter bounds. Context depth zero and callback zero-effect
must be preserved in that composition. These are specific unjoined collector
inputs, not a reason to invent a cumulative ordinary-allocation or RAM limit.
The parent has separately frozen a typed-array/outer-finalizer candidate at
`2b16ef1814`; its review is pending at this packet's freeze and its work is
neither duplicated nor consumed here.
`total_GGC_events`, whole-native capacity and complete collector lifetime stay
null/false. No native build/capture, solver, predecessor suite, aggregate
evaluator or corpus checker was executed for this packet.
