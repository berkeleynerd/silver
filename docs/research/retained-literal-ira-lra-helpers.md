# Selected literal outer IRA and LRA helper storage

2026-10-19, owner-authorized research [#119](https://github.com/berkeleynerd/silver/issues/119).
This packet closes the **named** outer IRA equivalence/scratch, common reginfo,
regstat, and selected LRA register/live-scan/inheritance/assignment **storage
and index** obligations below. It is a source theorem with pure count
arithmetic and fixed-Hello reconciliation, not a new actual-source adapter.
Independent review is pending. Other helper interfaces and all-native capacity
remain open; Oracle, admission, toolchain pins and production #88–#94 do not
change.

The [evidence packet](../evidence/retained-literal-ira-lra-helpers-20261019/README.md)
uses GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and the same selected
Linux x86-64/LP64, SysV, generic `-O0 -fsplit-wide-types` invocation. It reuses
the accepted actual-source ordinary adapter `aa838b8fc9f8fe038d7f3dff7044d1365687fc44`
and its [acceptance](../reviews/review-literal-ordinary-attachment-aa838b8fc9.md),
whose report commit is `df0859818d`. The accepted IRA storage argument and
shared bitmap/live-pool argument remain dependencies. The separate IRA numeric
packet is **not consumed**, whether subsequently reviewed or not.

## Source domain and chronology

The accepted route has C>=1 output calls and N>=0 null statements. Every call
has four distinct DI pseudos, each defined and used once in its indivisible
seven-instruction call group. None lives at a call or block boundary or across
groups. There are no loops, spills, new reload/inheritance pseudos, scratch
operands, asm, debug instructions, local EH, partial or multiword pseudo
references, or optimizing equivalence transformations. The existing source
theorem, rather than an `-O0` label alone, supplies these shape premises.

```
A=4C       K=99+5C         B=2N+10
M=7C+5N+20 U=M+2          P=2M+B
R=floor(3K/2)+1
D=17690C+368N+19076        (accepted DF reference-creation ceiling)
```

K bounds the final first-unused register, B the block-slot endpoint, U the LRA
UID endpoint, and P the program-point endpoint. R is a capacity bound, not a
number of referenced pseudos. D is the unchanged accepted DF owner, including
its two scan generations and call/artificial-reference refresh history; it is
not a new reference census.

`ira.cc:5791–5873` initializes equivalence state, calls the two regstat
initializers, resizes common register info, scans temporary equivalences, frees
that temporary array, and prepares reload equivalences before graph building.
No selected SCRATCH means `remove_scratches` returns false; no new IRA pseudo
means the second max-register recompute condition at `:5992–5993` is false.
There is one regstat initialization and no recomputation on this route.
`ira_destroy` runs before LRA (`:6074–6076`). Regstat lives until LRA teardown
(`lra.cc:2666–2667`), ordinary IRA equivalences until `finish_reg_equiv`
(`ira.cc:6127`), and common reginfo until final emission (`final.cc:4290`).

LRA creates its one unused Pmode pseudo **before** `init_reg_info` and records
the new-pseudo boundary after initialization (`lra.cc:2428–2462`). The accepted
schedule has two constraint iterations, one live-range construction, one
assignment, **at most one inheritance pass and one undo pass**. The
`lra_simple_p` decision is size-dependent (`ira.cc:5746–5752`); `-O0` does not
make it true. `lra.cc:2532–2533` can therefore invoke inheritance for small
selected inputs. No inheritance transformation does not mean no inheritance
initialization or scan. All bounds below cover both size branches.

## Individual requests and layouts

These are separate request ceilings, never a simultaneous byte sum or lifetime
request total. Each must fit PTRDIFF_MAX. Unless explicitly marked retained,
the table names the helper allocation being discharged, not a new ledger event.

| Allocation | Individual request ceiling | Source/lifetime |
| --- | --- | --- |
| Ordinary IRA equivalence | 40R | `ira.cc:3065–3084`; IRA initialization through reload finish |
| Temporary equivalence | 32K | `ira.cc:3095–3124,5828–5847`; prescan/scan only |
| Common renumber and preference arrays | 2R and 3R | `reginfo.cc:858–927`; freed by final emission |
| Regstat sets/refs and register info | 8K and 16K | `regstat.cc:49–92,234–277`; IRA entry through LRA finish |
| Empty scratch pointer reserve | 8+8U | `ira.cc:5498,5552–5555`; length remains zero |
| LRA register records | 144R | `lra.cc:1380–1422`; **same accepted core backing owner** |
| LRA block gen/kill records | 72B | `lra-lives.cc:403–417,485–518`; live subsystem init/finish |
| LRA reverse-postorder | 4B | `lra-lives.cc:1438–1451`; one live scan |
| Optional inheritance usages | 24K | `lra-constraints.cc:5969–5994,7548,7592`; at most one pass |
| Six assignment integer arrays | each 4K | Two sorted arrays, classes, live lengths, saved renumber, preference checks; `lra-assigns.cc:353,1411,1639–1642` |
| Assignment threads | 12K | `lra-assigns.cc:118–129,170–192`; one assignment |
| Assignment range-start chains | 8P | `lra-assigns.cc:277–294,311–318`; one assignment |
| Persistent elimination table | 192 | Four 48-byte entries; `lra-eliminations.cc:74–115,1307`; retained cold helper owner |
| Empty pointer-equivalence hash | wrapper 48; backing 104 | `lra-constraints.cc:520–540`, `hash-set.h:35–41`; init/finish once |
| LRA constraint pointer reserve | 8+8U | **Same accepted core backing owner**, exposed for reconciliation only |

The retained layouts are checked against their source definitions, not borrowed
null-program totals. `ira_reg_equiv_s` has three booleans and four pointers,
giving 40 bytes; `equivalence` has three pointers, a short and char bitfields,
giving 32. `reg_pref` has three chars; regstat records have two/four ints.
`bitmap_head` is 32 bytes, so one pointer and two embedded heads make
`bb_data_pseudos` 72 bytes. The selected generated `insn-modes.h` has one
`poly_int64` coefficient. Including the x86 STACK_REGS boolean, the lra_reg
fields at `lra-int.h:70–115` occupy 144 bytes; its embedded bitmap is not a
second separately allocated header. Three ints, a bool, alignment and one
pointer make `usage_insns` 24 bytes. Assignment threads contain three ints.
The elimination record has two ints, two 8-byte offsets, two bools and two
pointers, giving 48; `i386.h:1789–1793` supplies four entries. It is allocated
only when its process-persistent pointer is null; no per-iteration charge is
introduced, and this packet does not claim it is freed at Main's end.

## Growth, equivalences and scratch/initial-value gates

`ira_expand_reg_equiv`, common `allocate/resize_reg_info`, and LRA
`init/expand_reg_info` all evaluate signed **`3 * max_reg_num()` before `/2+1`**.
The packet requires `3K<=INT_MAX`, separately from R and byte-size guards.
For actual pre-LRA extent k>=2, `floor(3k/2)+1 > k+1`; IRA's original reserve
therefore covers the one unused LRA pseudo. Later `ira_expand_reg_equiv` calls
from LRA initialization/constraints return without resizing. LRA initializes
after that pseudo and has no subsequent register creator, so its immediate
`expand_reg_info` also returns. The `last_reg_value` counter increments once
per initialized **capacity** slot, at most R. The unique-value reset callers
are coalescing or new reload-pseudo paths, excluded by the accepted route.
Common reginfo capacities from any earlier selected initialization/growth are
also bounded by R; no lifetime allocation count is inferred for that helper.
Classes 0..33 fit char and renumbers -1..91 fit short.

There are no incoming REG_EQUIV notes in the accepted call-group RTL. At
`ira.cc:3685–3712` that excludes the pre-optimization INSN_LIST creator, then
`if (!optimize) continue` excludes new equivalence discovery. `setup_reg_equiv`
iterates empty initializer lists (`:4203–4207`); memory, constant and invariant
equivalences remain null. The temporary loop-depth short is not assigned on
that optimizing path; the root-only CFG has depth zero in any case.
`setup_reg_equiv_init` copies null entries within the pre-LRA register domain.

The two `grow_reg_equivs` calls reserve **additional slots**, not desired
length (`reload1.cc:644–657`). They retain the accepted GGC owner, including
56-byte records and both rounded capacities; no ordinary or GGC recharge is
made. LRA's later unused pseudo does not cause a new call to this old reload
vector. LRA uses `ira_reg_equiv`, whose capacity already covers it. The old
regstat arrays likewise need no new unused-pseudo slot: selected LRA reads its
own register information, then frees the regstat arrays. The selected LRA
source has no REG_N_SETS/REFS/DEATHS/CALLS_CROSSED accessor for that pseudo.

`ira_remove_insn_scratches` creates a record only for a non-VOID SCRATCH operand
(`ira.cc:5462–5481`). There are none in the selected patterns, and no later
reload creator adds one. The vector's exact U reserve remains allocated but
empty, its two bitmap heads remain empty, and restoration releases the vector
and clears the heads. No `UID*MAX_RECOG_OPERANDS+nop` insertion is reached.
The initial-value hook is NULL for this selected x86 target: `target.def:4236–4256`
supplies the default and the selected i386 target has no override. Thus
`allocate_initial_values` returns without inspecting initial-value entries
(`ira.cc:5564–5566`); it cannot add an allocation or a new register here.
This conclusion is target-specific, not an assertion about arbitrary hooks.

LRA's pointer-equivalence hash is still constructed. With no equivalences,
`get_equiv` returns its input (`lra-constraints.cc:566–590`), so the primary
insertion at `:602` is unreachable. Other insertion sites require an existing
pointer-equivalence hit, so an initially empty set stays empty. The default
13-slot non-GGC hash therefore never expands. The 48-byte wrapper comes from
four pointer/size_t fields, three unsigned fields and two booleans on this
no-checking/no-statistics layout. Unsigned diagnostic search counts do not
control capacity; no new lifetime lookup-count claim is needed.

## Regstat and selected LRA indices/counters

In the no-debug regstat initializer, current DF definitions and uses are
distinct reference objects. Their per-register sum is bounded by the accepted
**total** reference-creation ceiling D, even when old scan generations have
been released. `D<=INT_MAX` therefore bounds each narrowing and the actual
use-plus-set intermediate in `regstat.cc:79–82`. This uses the reviewed DF
owner rather than assuming that two pseudo references also bounds hard-reg
references. The accepted 600C DF/LRA note-creation ceiling conservatively bounds
each regstat death counter; `600C<=INT_MAX` covers all increments. Call-crossing
counts are at most C, and zero for the local pseudos. Block IDs are below B,
with the valid -1/0 sentinels retained.

`REG_FREQ_FROM_BB` uses REG_FREQ_MAX=1000 and BB_FREQ_MAX=10000. Its fallback
is 1000; otherwise `profile_count::to_frequency` returns a value in 0..10000
(`profile-count.cc:296–307`), so the pre-division product is at most 10000000
and the resulting frequency remains at most 1000. Each addition before
saturation is at most 2000, and the stored value is at most 1000
(`regs.h:125–138`, `regstat.cc:193–224`). This is a local regstat argument,
independent of the pending IRA numeric packet. It is not a new bound on all
IRA costs or all LRA frequency arithmetic. The already accepted signed
`10000C<=INT_MAX` hard-register usage guard remains unchanged and separate.

LRA gen/kill records are indexed by actual block index, hence need B rather
than the number of live blocks. Reverse-postorder has one int per actual block;
the accepted CFG traversal helper provides its permutation contract. The
exception-receiver worklist at `lra.cc:2270` is genuinely unreachable here:
`has_nonexceptional_receiver` returns immediately at `!optimize` before the
allocation, independently of `lra_simple_p` or whether the caller needs it.

The inheritance usage array is **included**. `curr_usage_insns_check` starts
zero, increments once per EBB, and sees at most B disjoint block groups
(`lra-constraints.cc:7091,7547–7585`). Require B<=INT_MAX. UID markers are
`-(int)INSN_UID`, so U<=INT_MAX guards narrowing and negation. `calls_num`
starts zero in each EBB and is at most C; its stored copies and `calls_num-1`
at calls are safe. Every `reloads_num` increment requires a register at or
above the new-pseudo boundary (`:7149–7200,7437–7455`), an empty interval here;
that counter remains zero. No debug instruction means usage lists store direct
instruction pointers and do not create INSN_LIST chains. Register/ORIGINAL_REGNO
and hard-register accesses retain the accepted below-K/92 domains.

Assignment integer arrays and thread entries are indexed below K, and sorted
lists contain each eligible pseudo at most once. The correctness scan really
does run on the first constraint iteration; it is not discarded as a checking
build path. It uses the selected whole-DI/no-spill allocation argument.
Thread links stay self/-1 because the accepted copy pool is empty. The
reload-assignment interval is empty, the inheritance/split/optional sets are
empty, and original referenced pseudos already have hard registers. Therefore
the spill/retry/preference-update loops do not execute. The non-reload
comparator uses differences of pseudo frequencies (at most 2000) and register
IDs (below K). Generic libc sorting workspace remains an imported interface.

The live-length initialization at `lra-assigns.cc:1649–1651` executes even when
no reload pseudo needs assignment. It sums **one pseudo's** list at a time.
Each selected pseudo has at most two instruction-register references (one
definition, one use), also retained explicitly as
`core_result.selected_native_backing.LRA_register_and_recognition_backing.referenced_pseudo_nrefs_upper`.
The scan offers a USE_POINT once to each non-OP_IN record at
`lra-lives.cc:870–875`, or once to each OP_IN record at `:954–960`; those cases
are disjoint, including the handling of OP_INOUT. `update_pseudo_point`
(`:257–283`) creates at most one range per such opportunity; its DEF_POINT
branch only changes the finish. There is no pseudo live-out to enter the
boundary creator at `:683–686`, and the accepted no-copy/no-rebuild route
excludes other creators. Thus **each pseudo has at most two ranges**. Each
nonnegative `finish-start+1` is at most P+1, giving the sufficient guard
**`2(P+1)<=INT_MAX`**, including every partial sum. This argument needs neither
disjoint ranges nor a guessed within-group timestamp span. The global 10C
live-pool bound remains unchanged and is not substituted for a per-pseudo
count. The retained 5,000-call/N=0 comparison passes this new guard and all
other local helper guards; its length ceiling is 140102. A still tighter
within-group span is not required by this packet.
Range starts/finishes are valid indices below the actual live-point count,
which is at most P; `P+1<=INT_MAX` covers inclusive-loop successors and the
preference-threshold denominator at `lra-assigns.cc:422–424`. The fixed shift
parameter is 30 (`params.opt:472–478`), within the unsigned 32-bit width.
Sparse-set arithmetic, the two P-entry bitmap header arrays,
their ordinary elements and initial chunks retain the accepted bitmap owner.
No term of those owners is added again.

## Reconciliation and remaining obligations

`retained_interface_check` reads the frozen accepted adapter result; it does
not import or execute that adapter or any predecessor script. It compares
complete Hello source identity/counts, A/K/B/M/U/P/R, the exact existing LRA
register/constraint/DF owners, shared bitmap/live-pool owners, and the accepted
LRA schedule. All 305 retained prerequisite values must already be true for
this **fixed successful fixture**. The 50 distinct GGC rows still sum to
47,054; reload-equivalence capacities remain 146 and 292. Those literal
numbers are not a general-source transfer rule. No old owner record is
modified, replaced or recharged. The pure arithmetic accepts arbitrary C/N
but does not turn equal counts into source/configuration correspondence.

| Still open | Concrete interface / next question |
| --- | --- |
| Full dynamic LRA recognition lifetime | `lra.cc:719–1161`: accepted core backing already retains dynamic/static record, operand, argument, alternative and pointer-map bounds; join every invalidation/recreation lifetime and its container counters to that existing owner. Do not re-add its pools or arrays. |
| Other outer IRA callers | Complete indirect-jump/alias/loop/DF/target helper and external sort interfaces; this note closes the named arrays and regstat counters, not every helper reachable from the whole IRA pass. |
| Other LRA arithmetic and automatic storage | Constraint/recognition recursion and stack arrays, elimination offsets, general preference/cost paths and fixed parameter/source correspondence. Selected storage bounds alone do not close these operations. |
| IRA numeric theorem | Costs, pressure and priority remain owned by the separate packet; no pending result is used here. |
| Actual-source successor | Bind accepted complete invocation/source owners, preserve all nullable and false prerequisites, then add these local guards without rewriting existing leaves. This packet supplies no such adapter. |
| Whole pipeline | Other native/producer/proof/parent interfaces and source/binary correspondence remain distinct. No aggregate RAM gate or complete-native claim follows. |

The packet's flags deliberately keep all-outer-IRA, all-LRA, all-ordinary-native
and whole-pipeline completion false. All new excerpts use literal LF positions,
exact sliced text and operative fragments; the accepted IRA predecessor's
form-feed coordinate erratum is preserved as history, not copied here.

## Evidence and round

The packet passed **116** focused arithmetic/boundary, ownership-mutation and
exact source-interface checks in **0.1171619369997643 seconds** on native Linux
7.0.14 x86_64. It verified **36 GCC / 25 repository** byte pins, **72** operative
literal-LF excerpts and the retained generated mode header. Their finite success exercises the
new formulas and reconciliation; it does not mechanically prove the handwritten
source argument. No compiler, capture, native tool, prover/solver, predecessor
evaluator/checker, aggregate or corpus replay is run. The selected subthread is
GPT-6 Astra / Extra High; runtime confirmation and token/cost measurements are
unavailable. The [round record](../evidence/retained-literal-ira-lra-helpers-20261019/round.json)
records elapsed evidence, the corrected size-dependent inheritance reading,
and review status. Root integration, review, issues, durable memory and
publication belong to the parent stream.
