# Retained literal IRA graph, cost and traversal storage

Date: 2026-10-19. Issue: #119. Candidate for independent review.

This packet derives individual ordinary requests, pool counts and local
representation guards for IRA's allocation graph, cost-storage buffers,
live-point storage, graph traversal, fast color buffers and no-region emit
setup. Its allocation-site inventory covers those named storage families in
`ira_build`, `ira_color`'s fast branch, `ira_initiate_emit_data`,
`ira_emit(false)`, and their teardown. Imported DF, bitmap, target and query
interfaces retain their owners. This is not complete IRA capacity: numeric
cost and excess-pressure arithmetic, outer IRA-pass helper lifetimes, and
remaining LRA helper storage are explicit residuals below.

The evidence is [here](../evidence/retained-literal-ira-lra-ordinary-20261019/README.md).
The retained GCC source is revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; the repository base is
`d8e9c70e373de172280b87a1459ece88114c2eaf`.
The source argument is handwritten. Arithmetic checks and byte pins do not
constitute a universal machine-checked proof or alter production admission.

## Route, interfaces and extents

The selected route is Linux x86-64 LP64, SysV generic O0 with wide-type
splitting, no debug/checking/statistics, and no PCH, LTO, plugins,
instrumentation or target reinitialization. Exactly one physical Main reaches
CFG/RTL. The accepted [output RTL argument](retained-output-rtl.md) supplies
one root region, no loops/caps/shuffles, no spills/reload pseudos, no local EH,
asm or scratches, and only whole one-word pseudo references after splitting.
No pseudo lives at a call or block boundary. No trace/dump output is enabled.

For output calls `C>=1` and null statements `N>=0`, use:

| Extent | Bound | Meaning |
| --- | --- | --- |
| A | 4C | Referenced DI pseudos, allocnos, objects |
| K | 99+5C | Conservative first-unused register through IRA/LRA |
| B | 2N+10 | Lifetime block slots |
| M | 7C+5N+20 | IRA-entry instruction-chain bound |
| U | 7C+5N+22 | LRA UID endpoint, also a safe IRA UID reserve bound |
| P | 2M+B | IRA/LRA point endpoint before compression |
| H | K-92 | Cost-class insertion-capable query bound |

The [MEM/SSA attachment](../evidence/retained-literal-mem-ssa-attachment-20261019/result.json)
owns A, K, B and M; the
[shared bitmap/pool packet](retained-literal-shared-bitmap-pools.md) owns
the common K, B, M, U and P interfaces and generic allocator transfer.
The accepted [GGC ledger review](../reviews/review-literal-native-ggc-ledger-ca4ef8d20f.md)
owns all existing GGC events and finalizer registrations. This packet adds
zero such events; zero means the newly named ordinary storage, not zero
events in all called functions. The fixed Hello check preserves its 47054
positive GGC requests exactly. It does not turn that fixed-input number into
a rule for other inputs or execute a predecessor evaluator.

The API `arithmetic(C,N)` returns mathematical integers, local booleans and
`failed_predicates`, even when the local conjunction is false. Invalid count
domains raise `ValueError`. `conditional_named_IRA_allocation_capacity`
is only the conjunction of this packet's 25 local guards; inherited source,
configuration, shape, numeric and other native requirements remain necessary.
There is no actual-source adapter in this packet. A later adapter must bind
actual source identity and complete counts to the accepted owner extents.

## Selected allocation sites and lifetimes

`ira.cc:642–675` selects `IRA_NO_OBSTACK`: `ira_allocate` calls `xmalloc`,
and `ira_free` calls `free`. These are ordinary requests. The native allocation
failure assumption remains unchanged; no aggregate RAM gate or lifetime byte
sum is introduced. Sizes below bound individual requests, not a simultaneous
sum. Source-scaled expressions use size_t multiplication except the explicitly
identified narrower callers and container fields.

| Source and storage | Individual request / multiplicity bound | Lifetime |
| --- | --- | --- |
| `ira-build.cc:429–440`, allocno/object vectors | two exact reserves, each `8+16K` | Graph setup to destroy |
| Global and root register maps, `:107,438` | two `8K` arrays | Graph setup to destroy |
| Block/root node arrays, `:135–159` | `256B`, `256` | Graph setup to destroy |
| Preference/copy vectors, `:1181,1368` | two exact reserves, each `8+8U` | Setup to destroy, even with zero copies |
| `ira-costs.cc:2592,2622`, working/total costs | two `140A` arrays | One cost pass; freed before live-range build |
| Preferred classes, `:2594` | `4A` | Cost pass |
| Allocno class/equivalence gain/best class, `:2596,2598,1983` | three `4K` arrays | Cost pass |
| Cost-class pointer map, `:204–206` | `8K`, **signed int caller** | Cost pass |
| Cost-class records/hash, `:229,212` | at most H records of 644 bytes; 48-byte wrapper; pointer backing below | Cost pass, hasher frees records |
| `reginfo.cc:1316–1347`, valid-mode map/obstack | `8K` and initial 65536-byte chunk | One cost pass; no payload records |
| `ira-build.cc:1630`, cost-pool wrappers | at most 34 wrappers of 136 bytes | Setup to destroy; no backing blocks on this route |
| `ira-lives.cc:1812–1817`, sparse sets/saved-call map | two `32+8A`; one `4A` | Live scan; freed at end |
| `ira-lives.cc:1631–1634`, start/finish arrays | two `8P` | Rebuild frees old arrays before allocating replacements |
| Point compression, `:1660–1710` | `4P` map; three `8+8ceil(P/64)` bitmaps | Compression only |
| `ira-build.cc:2895,2933`, minimum range/last-lived | `4A`, `4P` | Conflict-ID setup only |
| Traversal `:1681–1822` | preorder `8+8max(4,2B)`; two reverse-order/DFS reserves each `8+8B` | Per traversal; vectors released |
| Optional root-region removal, `:2289,2656–2661` | sort array 8; two exact vectors each `8+8(B+1)` | One call; root-only route can return earlier |
| Fast color `ira-color.cc:5281–5290` | sorted allocnos `8A`, priorities `4A`, used hard-register sets `16P` | All freed at `:5370–5372` |
| Emit-data setup `ira-emit.cc:101–115` | `24A`, empty 50-pointer reserve 408 | Emit setup to finish |

The target setup owner also has 62 individual cost buffers, each at most 140
bytes (`ira-costs.cc:2562–2581`). Per initialized mode, each of three move
matrices is `34*34*sizeof(unsigned short)=2312` bytes
(`ira-int.h:70`, `ira.cc:1599–1601`); cached modes may alias prior matrices.
The packet exposes these request sizes without inventing another target
initialization or charging a per-Main target-history total.

IRA has one build and one fast color call. At O0 the cost pass starts at zero
and ends at zero (`ira-costs.cc:1990–2043`). The path does not invoke an
additional `ira_set_pseudo_classes`. With one region, `ira_emit(false)` sets
existing register pointers and returns at `ira-emit.cc:1263–1265`, before
region move arrays, copy/shuffle vectors or new allocnos. `ira_destroy`
(`ira-build.cc:3570–3583`) releases loop nodes, preferences, copies, allocnos,
cost vectors and point arrays. `ira.cc:6065–6076` calls it before `lra`.
Pool blocks can remain in the accepted common block cache; graph destruction
does not assert that the process returned every ordinary block to the OS.

## Pools and excluded backing

One root creates at most A allocnos and exactly one object for each existing
allocno. The objects are whole DI, not two-subword objects
(`ira-build.cc:555–582`). The pools start empty. For a pool stride s, the
retained no-checking allocator rounds to eight bytes, adds no checking ID,
reserves an eight-byte block header, and has `q=floor(65528/s)` elements per
65536-byte block (`alloc-pool.h:253–287`). Allocated/free/block counters are
size_t (`:214–229`), and release resets them (`:304–327`).

| Family | Creation/live ceiling | Layout/stride argument |
| --- | --- | --- |
| Allocnos | A | Safe aligned upper bound 256, not an asserted exact layout |
| Objects | A | Exact 88: three pointers, five 4-byte integers, alignment, two 16-byte hard sets, final integer/bitfield |
| Preferences | A | Exact 32: three integers, alignment and two pointers |
| Live ranges | 2A=8C | Exact 40: object pointer, two integers, three pointers |
| Copies | 0 | Conflict-only creation is excluded |

For exact s the packet bounds blocks by `ceil(objects/q)` and each retained
element count by `q*ceil(objects/q)`. For the unknown exact allocno packing,
`8<=s<=256`, so `q>=255` and `q<=8191`: blocks are at most
`ceil(A/255)`, while each allocated/free count is at most `A+8190`.
Using the lower slot quotient as an exact packing would be unsound; the
artifact deliberately separates the exact and upper-stride cases.

Preferences are not assumed empty. The single cost pass can add one
singleton preference per allocno (`ira-costs.cc:2342–2360`);
`ira_add_allocno_pref` deduplicates. A<=U keeps the initial preference vector
large enough. Other preference creators are optimizing hard-move or conflict
paths. `ira_build_conflicts` builds conflict tables and invokes `add_copies`
only under `ira_conflicts_p` (`ira-conflicts.cc:812–843`), which is false.
Region copy creation is also absent.

The live scan calls `make_object_live` through pseudo definitions and uses
(`ira-lives.cc:1380–1525`). Each referenced pseudo has one definition and
one use in its own call group. Thus it offers at most two creator calls per
allocno, and `make_object_live` can reuse an adjacent range (`:126–134`).
Pseudo live-outs, multi-output pseudo operands, early-clobber/tied routes,
partial/multiword references and asm are absent. The repeat use loop at
`:1531–1541` explicitly ignores pseudos. All other range creators/copies
are regional emission, propagation or coalescing
(`ira-emit.cc:1143,1165,1200`, `ira-build.cc:2189`, `ira-color.cc:4535`),
excluded here. The 8C creation bound is sufficient even without using any
returned pool slot twice.

No hard-cost-vector backing is created: optimizing detailed/hard-move
cost setup is gated (`ira-costs.cc:2475–2523`); call-crossing and multiword
tuning are absent (`:2663–2753`); conflict processing is gated. The separate
site in `ira-lives.cc:1047` requires a singleton operand class.
Selected pseudo moves use the nonsingleton r/rem alternatives of
`*movdi_internal` (`config/i386/i386.md:2594–2601`);
`single_reg_class` returns NO_REGS for these (`ira-lives.cc:877–897`).
Fixed RDI/RSI operands are hard registers, and calls have no pseudo operands.
`update_conflict_hard_reg_costs` requires both vectors already nonnull before
it can update (`ira-build.cc:3451–3453`); it cannot seed this storage.
General graph coloring/coalescing/assign worklists are outside the fast branch.

## Caller, container and index guards

The strongest register-byte guard here is `8K<=INT_MAX`:
`initiate_regno_cost_classes` assigns `sizeof(cost_classes_t)*max_reg_num()`
to a signed `int size` before `ira_allocate(size)` and `memset`. Size_t
representability alone does not establish that narrowing is safe. The exact
largest C at N=0 satisfying this guard is checked on both sides, independently
of other guards. Exact allocno/object reserves additionally evaluate signed
`2*max_reg_num()` and store a 31-bit vector capacity. A<=2K ensures no growth.
The preference/copy reserve U must fit that capacity field.

Each cost buffer record has a 4-byte memory cost and at most 34 class costs,
so its size is at most 140. `max_struct_costs_size` and `struct_costs_size`
are size_t; `cost_elements_num`/allocno IDs remain signed and are bounded by A.
Cost-class records have `4+34*4+34*4+92*4=644` bytes. Nonnull pseudo slots
use at most one mode-restriction query; null slots use the class cache and
skip mode restriction. The sole first pass therefore has at most H insertion-
capable queries and H record creations. The hash may expand before a cache
hit: its capacity upper bound is the first retained GCC prime at least
`max(200,2H)`, and the proof uses attempted queries rather than only misses.
Guards cover prime-table exhaustion, `8H<=UINT_MAX` for `too_empty_p`,
size_t load products, unsigned probe addition `2p-3<=UINT_MAX`, and each
`8p<=PTRDIFF_MAX` backing request. No entries are deleted before finish.

Preorder traversal has zero inline capacity and at most B pushes. Initial
heap capacity four and nonexact three-halves growth stay at most `max(4,2B)`;
the pre-growth unsigned product is bounded by 3B. Both resulting capacity
and signed B+1 region-reserve expressions are guarded. Reverse-order DFS
marks a block visited before pushing, so each block enters at most once,
independently of edge degree. Its two exact reserves need at most B pointers.
Only the root loop is traversed: block visits do not recursively nest regions.

P+1 fits signed int for point increments, finish-plus-one and inclusive point
loops. Compression only reduces P. Range-comparator endpoint differences
and allocno-ID differences fit signed int under P and A. `last_call_num`
starts zero, increments once per processed block and call, and can store its
successor (`ira-lives.cc:1366,1454,1490`), so `C+B+1<=INT_MAX` suffices.

`sparseset_alloc` stores request bytes in unsigned int and computes
`2*(A-1)` before multiplying by `sizeof(unsigned)`. Require both this inner
product and `32+8A` to fit unsigned int; the positive A domain matters.
Dense point bitmaps separately guard unsigned rounding `P+63` and the
unsigned stored byte request `8+8ceil(P/64)`. Every named ordinary request
fits PTRDIFF_MAX, and typed-pool retained fields fit size_t. These guards
control storage dimensions; they do not prove arithmetic inside stored costs.

## Imported ownership and concrete residuals

The IRA private bitmap obstack keeps its prior initial-chunk owner. Four
root bitmap heads have keys below K (allocno IDs <=A<=K); basic-block maps
remain null. `update_bad_spill_attribute` uses at most 34 stack bitmap heads
with keys below P; `calculate_equiv_gains` uses one stack head with keys below
K. Their backing follows the accepted generic ordinary bitmap theorem,
including the common cache; no additional shared bitmap/ET charge is made.
Target tables, DF analysis, generic CFG/dominance, alias/query handling,
libc allocation and sorting retain their respective interfaces. This packet
does not promote an imported open helper to complete capacity merely because
it is called from a named IRA function.

| Residual | Concrete source/counter | Next proof question / hypothesis |
| --- | --- | --- |
| Numeric cost, frequency, equivalence and preference accumulation | `ira-costs.cc` `record_reg_classes`, `record_operand_costs`, `calculate_equiv_gains`, `find_costs_and_classes`, `setup_allocno_class_and_costs`; int cost fields, `cost*freq`, gains and preference frequencies | Use the single-definition/single-use call-group invariant to bound each live arithmetic operation, including multiplication before saturation. Two references per pseudo may make per-allocno bounds independent of C; this has not been proved here. |
| Excess-pressure arithmetic | `ira-lives.cc:139–162,246–280`, `ALLOCNO_EXCESS_PRESSURE_POINTS_NUM`, `high_pressure_start_point`, `curr_reg_pressure` | Analyze cross-class threshold resets before claiming a disjoint-interval sum. `dec_register_pressure` updates all live objects when any class crosses, so a naive two-ranges-times-P argument is not sufficient. A target-specific zero-pressure argument may be smaller; it needs the live hard-register/class relation. |
| Priority and overall costs | `ira-color.cc:3098+` `setup_allocno_priorities`; `ira.cc:2640+` `calculate_allocation_cost`; signed priority subtraction/multiplication and aggregate cost counters | Transfer proved per-allocno cost/pressure bounds into priority expression evaluation, then bound aggregate additions by A. An int64 aggregate bound cannot repair an overflowing int term computed earlier. |
| Outer IRA equivalence and initial-value helpers | `ira.cc:2773+,3079+,5499+,5564+,5791–5873,5976–6016`; `ira_reg_equiv`, temporary `reg_equiv`, `reg_equivs`, scratch sets, initial-value records | Derive actual register growth/reserve sequence and zero-SCRATCH/initial-value creator paths from the literal schedule. Reconcile GGC-owned `reg_equivs` without recharging it; ordinary equivalence arrays still need a literal-specific lifecycle. |
| Reginfo/regstat interfaces | `reginfo.cc:858–909` init/resize, `regstat.cc:234+` and n-set/ref initialization; `reg_info_size`, `reg_info_p_size`, per-register counts | Establish exact number of init/resize/recompute calls and narrowed growth arithmetic under K; transfer accepted referenced-pseudo counts rather than substituting old null-program totals. |
| Remaining LRA helper storage | `lra.cc:719–1161,1386,2270`; `lra-lives.cc:489,1438`; `lra-constraints.cc:7548`; `lra-assigns.cc:170,277,353,1411,1639–1642`; `lra-eliminations.cc:1307` | Close dynamic instruction operand/duplicate/alternative/argument arrays, register-info growth, CFG worklist/rpo, bb_data, usage_insns, assignment arrays and elimination table with concrete element layouts and caller types. Reuse accepted K/U/B/P and the two-constraint-iteration schedule; do not recharge already owned bitmaps/live pools. |
| Actual-source integration and universal correspondence | New `arithmetic(C,N)` has only fixed-Hello read-only reconciliation | Bind source identity/configuration and the complete predecessor counts first; preserve nullable prerequisite failures and every older owner. Source reachability remains handwritten and full all-input assurance remains open. |

There is no aggregate ordinary byte total, native-capacity completion,
whole-literal-pipeline completion, new language requirement, or Oracle change.
The accepted LRA signed hard-register usage guard `10000C<=INT_MAX` remains
distinct; it does not close IRA cost/pressure arithmetic.

## Validation and round record

The new checker passed 192 checks in 0.030164259995217435 seconds on native
Linux 7.0.14 x86_64. It checked 15 C/N cases, 4096 vector lengths, 288 pool
stride/edge cases, 60 prime boundaries, pre-hit hash growth, invalid domains,
source-pin mutations and fixed-input owner reconciliation. It verified 45 GCC
and 19 repository byte pins and 35 source excerpts. Finite boundary checks
support the formulas; they do not prove the handwritten source argument.

No compiler/build/capture, solver/prover, predecessor evaluator/checker,
aggregate or corpus replay was run. The selected subthread model was GPT-6
Astra / Extra High; runtime confirmation and token/cost measurements are
unavailable. The [round record](../evidence/retained-literal-ira-lra-ordinary-20261019/round.json)
records the retained inputs, elapsed evidence and review status. Integration,
independent review, issue status and publication belong to the parent stream.
