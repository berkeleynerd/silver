# Independent review: selected literal CFI/CFG ordinary containers

Review date: 2026-10-19. Research issue:
[#119](https://github.com/berkeleynerd/silver/issues/119).
Frozen implementation: `f21a34471976916160fc82b8be62cfac2d0f6c65`;
base: `ba82867962510165780367e28528e8b8eef9dbfb`.

**Disposition: accepted for the named, conditional ordinary-container claims;
no material findings.** The result does not close all ordinary native helper
lifetimes, native capacity, collector composition or the whole literal pipeline.
The frozen Hello attachment is not a general replacement for its upstream
actual-source evaluators. This packet has no dependency on the separately
reviewed complete native GGC ledger.

## Inputs and method

Reviewed all eight changed files: the source argument
[`retained-literal-cfi-cfg-ordinary.md`](../research/retained-literal-cfi-cfg-ordinary.md)
and the seven files in
[`retained-literal-cfi-cfg-ordinary-20261019`](../evidence/retained-literal-cfi-cfg-ordinary-20261019/README.md).
Compared the frozen MEM/SSA and shared bitmap/pool owners and the retained RTL,
CFI layout and emission records. Source was GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` in the retained full-source tree.
Source coordinates were read with literal LF splitting; GCC form feeds were
not treated as extra lines.

Source inspection covered the selected trace, queue, labels and index paths in
`dwarf2cfi.cc`; the FDE begin/end labels in `dwarf2out.cc`; vector and hash
allocation/probing in `vec.h`, `vec.cc`, `hash-table.h` and `hash-table.cc`;
expansion local-declaration, label-map and head/end lifetimes in `cfgexpand.cc`;
use counting and deletion in `cse.cc`; selected cleanup callers and exclusions;
CFG edge/copy-map helpers; forward, inverse and pre/postorder traversal;
root-only loop discovery; dense bitmap rounding; and dominance construction,
DFS indices, set-size arithmetic and fast-query numbering. Prior source reads
from the immediately preceding native-ledger review were reused where their
identical GCC inputs and selected route remained applicable.

A small independent Python read/hash/record comparison verified all **33 GCC
files, 23 repository files and 26 source excerpts**. It checked all 42 retained
local predicates, the 178 inherited predicates, exact source/count/configuration
joins, unchanged dominance and emission owners, the stated Hello request sizes,
and the false broad-completion fields. It imported or executed no packet
evaluator. Duration: **0.01792075499542989 seconds**.

Reused the successful author record: **148 checks**, 22 count-only cases, 2048
trace lengths, 12 growth boundaries and 58 prime-boundary cases, measured at
**0.07760772301116958 seconds** on Linux 7.0.14 x86_64. The author checker was
inspected but not rerun. Neither review nor this verification ran a native
compiler, prover, solver, capture, predecessor Context/evaluator, aggregate or
corpus replay. These finite cases exercise arithmetic and attachments; the
source/lifetime argument supplies the conditional universal claims.

## Review conclusions

The initial exact 16-element trace vector and its unsigned growth intermediate
are distinguished from the 31-bit capacity field and individual byte request.
`F16(T)=16` through T=16 and `floor(3(T-1)/2)` thereafter bounds every backing.
The trace pointer index is created after all vector growth, so retained element
pointers are stable. Its conservative prime bound handles pre-insertion growth.
`8h<=UINT_MAX`, size_t load products, `2p-3<=UINT_MAX`, prime availability and
individual request spans are separate conditions; the final retained prime
4294967291 correctly fails the probe-addition guard. Diagnostic search/collision
counters have defined unsigned wrap and do not size or direct lookup.

The selected CFI graph is linear with no EH successor. Discovery sets `beg_row`
before enqueueing and the current trace is popped before scanning, bounding the
ordinary pending queue by one. Only the prologue RBP memory save reaches the
queued-save vector; duplicate replacement and flushing preserve its length
bound. The frame-pointer move changes the CFA rule, and the register-save-in-
register vectors remain empty. Release sites prevent subsequent scans from
accumulating these ordinary vectors. Existing GGC CFI rows and save vectors
retain their separate owners. The five ordinary CFI labels and at most two FDE
label copies use the accepted emission endpoints and fit their local buffers.

Expansion's head/end reserve is established after the initial block and is
released before exit-block construction. The selected body creates no EH or
abnormal call split during that loop, so the expansion index extent E=N+6
applies. The block-label map checks for an existing entry before insertion.
Register-valued descriptor locals bypass the MEM/CONCAT append path, bounding
`maybe_local_decls` by C original declarations. Empty stack-partition and copy
maps remain ordinary containers; neither their construction nor deletion
recharges the bitmap owner.

The dead-instruction scan zeroes and frees its signed count array per call.
Using final K=99+5C covers both jump and IRA-entry callers. `count_reg_usage`
visits instruction patterns, call usage and equality/equivalence notes, while
excluding ordinary DF death/unused notes and constant location nops. The
selected wide split substitutes existing DI parts without adding counted REG
occurrences. The R0+1 signed magnitude bound includes a conservative pseudo-PIC
increment; deletion count has its separate M<=INT_MAX condition. Debug and
post-reload exclusions are source-backed, rather than inferred from null-case
capture totals.

CFG scratch bounds distinguish actual live-block allocations from the lifetime
ceiling B. In particular, `find_unreachable_blocks` allocates the actual
`n_basic_blocks`, not literally B. The B-1 edge argument bounds total pushes and
request size, but alone would not prove safety for an arbitrary graph with
repeated initial entry destinations. On the selected invocation boundaries the
entry successor is the unique next block of the chain; subsequent destinations
are marked before push. Thus pending entries fit the actual live-block
allocation as well as the stated 8B request ceiling. This review does not
extend that reasoning to arbitrary transient multigraphs.

Traversal stacks reserve actual live blocks plus one, mark before descent and
use quick pushes. The 20-slot inline cutoff and dense-bitmap unsigned rounding
are represented explicitly. Root-only `loops_list` uses **16 inline int slots**;
its reserve of one causes no heap request. The separate empty loop-candidate
vector can reserve one pointer. Dominance's nine unsigned arrays, index-extent
order array, pointer map and DFS array are separate requests. Forward DFS omits
the exit node and assigns bounded indices; set-size and signed DFS intermediates
are covered by the conservative 4B<=INT_MAX guard. Destruction and later cold
construction do not accumulate array lengths. The existing shared ET node and
occurrence owner is retained exactly, with zero new pool blocks or GGC events.

For Hello the reviewed ceilings are: trace backing **2312 bytes**, trace index
**13 pointers / 104 bytes**, label-map backing **208 bytes**, head/end backing
**104 bytes**, and jump count array **416 bytes**. Traversal stacks stay inline.
Dominance has nine arrays of **40 bytes** each, an order array of **44 bytes**, a
pointer map of **80 bytes**, and DFS storage of **176 bytes**. No simultaneous
RAM sum or lifetime ordinary-request total is claimed.

The frozen attachment validates physical alphabet, exact source identity and all
recognized counts; stored path, launch and shared inputs; inherited guards;
B/K/M/Uf and trace/row chronology; and pool/emission ownership. Complete pinned
predecessor records are part of this published check. Count-only calls do not
claim that a new source passed upstream evaluation, and the attachment docstring
makes that boundary explicit. Production admission is unchanged.

## Round record

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort confirmation,
token usage and monetary cost are unavailable; no live-setting change is claimed.
Inspection interval: **2026-10-19 11:38:40–11:42:34 UTC**, **234 seconds**, including
source reading and a context handoff. This is a clock interval, not measured
model compute time. The independent verification time above is separate.

Owned output is this report only. No implementation, Oracle, launcher, issue,
root index, session memory or CLI memory was changed. Parent integration and
publication remain with the lead. Remaining work includes IRA/LRA private
ordinary arrays and pools, other native helper/stack lifetimes, collector and
parent composition, and producer/proof obligations; acceptance here does not
promote any of those claims.
