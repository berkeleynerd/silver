# Selected literal bitmap, finalizer and MEM/SSA attachment review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept each of the three frozen targets for its stated bounded scope.**
There are no material findings. Target A has one nonblocking element-type
wording correction, documented below; it changes no request bound or guard.
These acceptances do not establish complete collector, native, proof, parent
or full-current-grammar capacity.

| Target | Frozen implementation | Disposition |
| --- | --- | --- |
| A: shared ordinary bitmap and selected pool lifetimes | `86d50fa7ec32c8f57e66d3c07286ba881d311b80` | Accept; point-frequency wording erratum below |
| B: selected array finalizers, context depth and outer vectors | `2b16ef1814d5c668590dc9728fef94d46ea549cd` | Accept; no findings |
| C: actual-source MEM/counter and SSA lifetime attachment | `e28fef05f2eb5948ceffbc2b8d2e7b09b1a0b511` | Accept; no findings |

## Exact inputs and review record

The review inputs are the complete additions at those commits: A's
[source note](../research/retained-literal-shared-bitmap-pools.md) and
[seven-file packet](../evidence/retained-literal-shared-bitmap-pools-20261019/README.md),
B's [source note](../research/retained-literal-finalizer-lifetime.md) and
[five-file packet](../evidence/retained-literal-finalizer-lifetime-20261019/README.md),
and C's [source note](../research/retained-literal-mem-ssa-attachment.md) and
[seven-file packet](../evidence/retained-literal-mem-ssa-attachment-20261019/README.md).
I inspected the new arguments, implementations, checkers, manifests, retained
results and round records, together with the accepted source arguments and
exact source portions needed for the joins. GCC remains revision
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

The accepted dependencies include MEM/counter target
`9d24cab8cf9ba9fa6148ed21d340926444cbdd31` and its review
`cf5d72b6760a196fc348b6ada7b1ce6dd955accb`, initial-to-later SSA target
`e0c24340e86f4ae90c9de0794bab6797a0bd1563` and review
`c63c6088f91d00e4224c7cf96fe1367e20861e83`, and the 149-guard attachment
`b9b94f26ffb4770dc22c76b45c2c56d3368c3ccb` and review
`ad0b400815c0275ab89cc75316f2aede66f9c45e`. Their retained successful
evidence is reused. A and B are separate arguments; C consumes neither
pending target. This report accepts the three scopes without claiming an
already implemented three-way evaluator composition.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime confirmation, token usage and monetary cost are unavailable.
Inspection began **01:32:06 UTC** and reached the completed source/evidence
checkpoint at **01:38:38 UTC**, **392 seconds** at one-second resolution,
excluding report preparation and commit. Actual host: Linux 7.0.14 x86_64.
Separate sparse worktrees freeze all three targets. Only this new report is
committed. The continuing owner-authorized #119 research, unchanged Oracle,
installed-source correspondence, selected configuration and successful
ordinary-allocation premises remain in force. The live subthread goal was
null. CLI memory was not updated; the lead owns integration and issue records.

## A: shared bitmap and ordinary pool representation

The crucial distinction between links and stored counters is supported by
the source. `bitmap_obstack` has freelist pointers and an obstack; ordinary
header/element allocation completes each 32/40-byte object. `obstack_alloc`
finishes it, leaving zero unfinished bytes for the next growth. Thus the
largest candidate `40+7+100=147` remains below the configured 65,536-byte
chunk (`bitmap.cc:102–145,733–807`, `include/obstack.h:375–415`,
`libiberty/obstack.c:188–235`). Release and the shared block cache traverse
links. The latter stores no cumulative block count and its trim counter
counts only the requested prefix (`memory-block.h:25–78`,
`memory-block.cc:36–91`). Unknown lifetime chunk counts therefore do not
hide a growing individual request or a representation counter. This does
not supply an aggregate memory bound.

The argument correctly distinguishes ordinary `bitmap_alloc(NULL)`, which
resolves to the default obstack, from a GGC bitmap initialized with a null
obstack. I checked the selected DF scan/LR/shared scratch and register-obstack
families against their actual block, postorder, register, instruction-UID and
program-point keys. `X+127 <= UINT_MAX` covers sparse element rounding and
iterator reconstruction for those domains. The initial SSA `.MEM` key uses
the separately bounded declaration UID; it is not treated as a small SSA
version. The assigned-hard-register private sets may be populated, whereas
reload/inheritance intervals are empty under the accepted no-new-reload
argument. Excluded DF problems and optimizing passes cannot silently donate
their different key domains to this claim.

Default depth is a nesting counter. The eight `cgraphunit.cc` initialization
sites and `symtab.cc:1454` have balanced releases. The accepted generated-body
frontier excludes recursive lowering, nested functions, thunks and clones
that could revisit an active site. The separate callgraph-info and selftest
initializers are gated out (`toplev.cc:1920–1938,2274–2288`). The fixed unit
IFUNC scan remains a real default-bitmap client; its bounded function-UID
population follows the accepted unit frontier, and no variable number of
generated functions is inferred from C or N. Explicit private obstacks do
not increment the default depth.

For `M=7C+5N+20`, `B=2N+10` and `U=7C+5N+22`, the point bound
`P=2M+B=14C+12N+50` covers the selected two increments per instruction and
one per block. IRA's extra increment belongs to the excluded early-clobber
or tied-conflict routes. The vector starts with reserve at most `2U`; its
subsequent growth is bounded by `max(2U,2P)`, with the unsigned intermediate
and 31-bit capacity guards retained. `P+1 <= INT_MAX` covers the endpoint
uses. The two assignment header arrays, dense point bitmaps, compression
map and register sparse sets retain separate individual request checks.

The 10C live-range bound counts actual `USE_POINT` calls: the hard-register
early return, absent pseudo live-outs, and disjoint OP_IN/non-OP_IN cases
prevent another source of ranges (`lra-lives.cc:251–285,683–686,870–877,
954–960`). Copying ranges belongs to excluded spill/coalescing routes.
The copy and invariant pools have no selected insertion: their predicates
require new reload pseudos (`lra-lives.cc:835–846`,
`lra-constraints.cc:7173–7185`). Their initialization allocations remain
owned; empty pools do not erase those requests.

Unlike bitmap obstacks, typed pools store allocated/free/block counts.
They allocate a new block only after both returned and virgin slots are
exhausted, reuse returned slots, and reset counts on release
(`alloc-pool.h:208–226,308–327,348–426,445–457`). This supports retained
slots `capacity*ceil(peak_live/capacity)`, including free slots in the last
block. It does not substitute lifetime allocation calls for retained storage.
For ET trees, both directions together give at most 2B nodes and 4B
occurrences; relinking releases the old parent occurrence before allocating
the new one, and the transient new edge fits the one-parent allowance
(`dominance.cc:728–824,872–888,1000–1005`, `et-forest.cc:443–552,590–603`).
The accepted per-tree relative-depth argument is reused with the guarded
8B intermediate bound. Repeated queries do not accumulate a query count in
depth fields. Capacities 1023, 1365 and 2047 for 64-, 48- and 32-byte objects
are consistent with the fixed block layout. Existing conservative ET cold
owners are neither reduced nor charged again.

The two DF scan generations release their own obstacks and typed pools
before rebuilding (`df-scan.cc:146–195,229–278`). LR retains its distinct
lifetime and `ref_order` is not reset. Physical blocks may remain in the
common cache after either owner releases them; this does not create
simultaneous scan generations or a new common-cache counter.

### Point-frequency wording erratum

The note calls the point-frequency entries unsigned. The actual declaration
is **`static vec<int> point_freq_vec`** at `gcc/lra-lives.cc:530`, with
`int *lra_point_freq` at `:533`. Unsigned arithmetic governs the reserve and
capacity, not the element type. Replace that wording in the current
integration record while preserving the frozen packet bytes.

This is not an overlooked signed accumulation inside the vector.
`next_program_point` appends the supplied frequency (`:538–542`), obtained
from `REG_FREQ_FROM_BB(bb)` at `:693`. Compression uses **MAX** (`:1242`) or
copies an entry (`:1247`); it does not sum frequencies. Construction resets
the point and truncates the vector (`:1433–1437`), and finish releases it
(`:1557`). The four-byte element size, backing formula and capacity guards
are unchanged. Separate `lra_hard_reg_usage` additions at `:786,1411` are
different counters; this vector observation does not establish their
whole-native lifetime or the still-open complete counter ledger.

## B: array finalizers and depth

The zero-array result follows from registration routes and actual element
types, not from observing no array finalizer in a sample. The primitive
registers only a nonnull callback, with `n==1` going to the scalar vector
(`ggc-page.cc:1331–1344,1500–1501`). Typed wrappers use callbacks only for
nontrivial destructors; raw/no-dtor paths use null, and clearing forwards
the callback (`ggc.h:139–254`). The accepted complete raw-call inventory
includes the unselected JIT custom callback and no additional selected one.

I reused the retained 4,929-source census and inspected its array projection,
raw-call records and descriptor join. The 15 element spellings at 28 sites
reduce to arithmetic types, pointers, a trivial two-pointer
`initial_value_pair`, selected trivial hash entries, or excluded routes.
For generic tables, `value_type` is the backing element. The enumerated
pointer descriptors give pointer elements; map `hash_entry` stores only its
key and value (`hash-map.h:41–47`). The selected scalar pair and warning
value have no destructor (`cgraph.h:2507–2510`,
`gcc-diagnostic-spec.h:29–110`). A user constructor does not make the
implicit destructor nontrivial. In particular, a control's nontrivial but
nonallocating destructor is not used as proof that its entries are trivial.
The selected startup and later literal families are covered by the accepted
constructor/descriptor census, rather than only the source-varying arrays.

Consequently no selected array callback is registered and the inner array
vector remains null. This does not waive the original array size/product
guards. The scalar owner remains 39,275 registrations, capacity 58,911 and
an individual request of `8+16*58911=942584` bytes, with no second charge.
The accepted callback effect argument prevents dispatch from creating new
registrations behind this census.

Context depth remains zero: the later assignment and extra outer pushes
are in the excluded PCH reader (`ggc-page.cc:2724–2728`). Page allocation's
depth loop can therefore create at most the zero-depth boundary
(`:1376–1382`), so the initial ten unsigned entries remain a 40-byte request.
Each outer vector has length one and capacity four, independently requesting
40 bytes. The old-context mark-backup condition is false. The separate
`by_depth`/`save_in_use` page arrays, page counts and collector arithmetic
remain open. These ordinary initialization objects add zero GGC events.

## C: actual-source MEM and SSA attachment

The wrapper calls the accepted predecessor with the actual descriptor and
source override, re-recognizes the actual bytes, and checks the complete
count record. MEM receives that source's actual core and evaluated query
owner. Equal call/null counts cannot authorize another source's evidence.

SSA needs an adapter because its accepted packet has a retained-Hello
checker, not a general evaluator. The adapter calls the pinned
`native_initial_ssa_lifetime(C,N,core_context)` and compares its **entire**
result with the actual core owner, including ordinary requests, request
groups and local representation checks. It then reconciles names, defaults,
slabs and scalar ownership before applying the accepted later zero-increment
argument. For `u=3C+1` and
`L=1+[u>25]+ceil(max(0,u-127)/409)`, the retained initial owner remains
`6C+10+L`, including Hello's 17. The helper and scalar owners are not
charged again. No fixed Hello result substitutes for the general source
argument.

The only historical adapter is the already accepted pipeline **prose** at
`603e0feeaab329b6492c3cc8d82f90a7f095c070`, 157,004 bytes, SHA-256
`898ee62690d7fe58f639192198ff83aaa7a95a89a88c2a6658250699fa0bc3eb`.
The predecessor's exact allowlist and extension comparison are reused only
while constructing MEM's Context, and `finally` restores `REPO`. Executable
import roots remain actual. The current pipeline note is separately pinned;
no compiler source, callable, configuration or formal input is substituted.

All 149 inherited keys and values remain in both condition maps. The new
29 predicates are nine MEM/local, eight emission, one MEM conjunction, ten
SSA representation checks and one SSA conjunction. Their boolean types and
distinct names are checked; both success results are recomputed from the
conjunctions and failed predicates survive. The retained negative evidence
tests every inherited and new false guard, source/configuration mismatches,
complete initial-owner changes and duplicate charging.

The owner checks preserve `5C` MEM records and the 437-event setup envelope.
Only `q(99+5C)-q(98+3C)`, where `198*2^q` covers the extent, adds later GGC
pointer-array backings; the same number of alignment requests is ordinary
storage. C=20 gives one of each; C=34 gives zero additional requests because
the pre-split owner already grew. Hello's four newly priced DF rows retain
60 blocks per generation and request 120 over two noncoexisting generations.
Those quantities are not summed as simultaneous storage, and the existing
register-pool owner is excluded. Prior map 3, RTL-cache 4C, graph 14 and
query 0 owners remain unchanged. The historical open fields are preserved
and separately labelled; no complete event total is manufactured.

## Evidence and remaining scope

| Packet | Retained author evidence reused | Narrow independent identity/evidence checks |
| --- | --- | --- |
| A | 52 checks; 21 arithmetic cases; 11 bitmap and 18 pool boundaries; 0.0565760589997808 s | 38 GCC + 19 repository identities; 0.12270307599828811 s |
| B | 67 checks; 24 GCC + 8 repository inputs; 27 excerpts; 15 types / 28 sites; 0.028112546999182086 s | 24 GCC + 8 repository identities; 0.06470760299998801 s |
| C | 269 checks; five actual sources; nine count cases; 6.193662269997731 s | 25 frozen/current records; MEM 56 GCC / 19 repository; SSA 24 GCC / 8 repository and 26 LF-coordinate excerpts; retained guard/owner and five-variant arithmetic; 0.5853375459992094 s |

The C identity sets overlap and are not a unique-file total. Its independent
checks also matched the recorded implementation/result identities, the
149-to-178 retained guard extension, the exact accepted Hello MEM result,
predecessor owners, SSA allowance, register growth delta and DF generation
arithmetic. Source coordinates use LF splitting, preserving form feeds.
The finite evidence supports interface and arithmetic consistency; the
source lifetime conclusions rest on the inspected handwritten arguments.
No retained checker, predecessor suite, Context, runtime census, corpus
checker, compiler, prover, solver, capture or disassembly was replayed.
No expensive managed validation was started.
`git diff --cached --check` passed for this report.

The accepted results supply selected ordinary bitmap/pool representation,
array/depth/outer-finalizer closure and an actual-source MEM/SSA attachment.
They retain existing owners and zero added callback/SSA/MEM event deltas.
The complete disjoint positive GGC event/object/request ledger, remaining
ordinary helpers and stack, collector page/mark/order/epoch metadata and
counters, other required phases and current-grammar composition remain
required. Total GGC and complete imported allocation totals remain null;
whole-native and collector capacity remain false. Oracle, tools, production
admission and launcher are unchanged, and production #88–#94 remains unstarted.
