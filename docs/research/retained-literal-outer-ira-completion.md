# Selected literal outer IRA interface completion

2026-10-19. Owner-resumed research #145 within #119; source correction #146.
Candidate pending independent review. This packet completes the remaining
selected **outer IRA source interfaces**, conditional on the accepted literal
shape, schedule, configuration and representation guards. It supplies the
alias, root-loop/DF, target and imported-sort joins left open by the accepted
IRA storage, numeric and helper packets. It also identifies **four omitted
cold target-probe GGC requests**. The accepted 50-row ledger remains historical
evidence; its complete-partition claim is superseded for this route until the
new row and corrected collector transfer are attached to actual source.

The [packet](../evidence/retained-literal-outer-ira-completion-20261019/README.md)
contains pure arithmetic, exact input pins, literal-LF excerpts, the target
move-pattern audit, focused checks and a read-only Hello reconciliation.
It does not execute a predecessor evaluator, establish an actual-source
adapter, complete LRA or native capacity, or change admission or the Oracle.
The handwritten source argument, not the finite checks, supports universality.

## Domain and exact boundary

GCC is `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, Linux x86-64 LP64,
SysV generic `-O0 -fsplit-wide-types`, with the accepted no-debug/checking/
statistics/dump, no-PCH/LTO/plugins/instrumentation/reinitialization invocation.
There is one physical Main. For every C>=1 output calls and N>=0 null statements:

```
A=4C         K=99+5C          B=2N+10
M=7C+5N+20  U=M+2           P=2M+B
D=17690C+368N+19076          V=B+K(B-1)
```

The four distinct DI pseudos per call each have one definition and one use in
the accepted indivisible seven-instruction group. None survives a group, call
or block boundary. The CFG is an entry-to-exit acyclic chain, possibly with
location-preserving nops, and no indirect/control-output jump, asm, scratch,
local EH, setjmp/nonlocal transfer, spill, partial reference or reload pseudo.
These are source-derived premises, stronger than an optimization-level label.

The boundary is `pass_ira::execute`/`ira`, its graph/cost/live/fast-allocation/
no-region-emission work and destruction, and the **outer** `do_reload` wrapper
before and after its `lra` call. LRA internals are an imported interface:
the accepted shape/no-new-register and no-spill schedule is retained, while
remaining LRA arithmetic/elimination belongs to the separate packet. Backend
startup, frame generation and final emission retain their accepted owners.
Fixed libc allocator/memory contracts and the selected GCC implementation
contracts remain the existing trusted boundary; no binary attestation gate is
introduced. Source call depth below is not a machine stack-byte theorem.

Dependencies are storage `66da47daa2`/review `3d00f8af99`, numeric
`9ed466e07f`/review `7b702023dc`, helpers `b795c8f745`/review `4d7100e7fb`,
and actual-source helper attachment `71624df232`/review `ac4694d0f7` (367
guards). The accepted ordinary attachment owns CFG/dominance/dead-insn
storage; MEM/SSA owns DF pool/reference chronology; shared bitmap/ET and GGC
owners retain their existing domains and lifetimes. The new packet pins their
complete records and exact reviews; it does not rerun their successful suites.

## Complete outer dispatch and exclusions

`ira.cc:5654–6030` has the following selected disposition. The accepted
storage/numeric/helper arguments discharge the named imported families;
the sections below discharge the previously open interfaces.

| Outer operation | Selected behavior and owner |
| --- | --- |
| Hard-register reference census | Scan 92 chains, signed per-register count at most D; artificial/debug refs excluded. D already bounds all created refs. |
| Jump-output reload preparation | A selected block end is not a control-output jump. No USE creation, critical-edge insertion or commit follows. |
| Verbosity, block flags, leaf query | No dump; fixed flags are cleared; C>=1 direct calls make `leaf_function_p` false by its first real call. No allocation. |
| Target PIC/prohibited-mode setup | PIC initialization returns on selected non-PIC/small-PIC x86-64. The cold prohibited-mode probe below executes once. |
| Size-dependent LRA choice | `num_used_regs<=A`, unsigned register iteration within K. Division uses positive B>=10. The selected parameter is 1000, cast to uint64 before multiplication by 1000. Both branches are included. |
| IRA bitmap init / caller save / range decrease | Private bitmap initial chunk remains its owner; caller-save init requires `!ira_use_lra_p`; range decrease returns because expensive optimizations are disabled. |
| NOTE/DF, equivalence and dead-insn work | Up to three pre-LRA analyses; accepted equivalence, regstat and dead-insn requests plus DF scratch below. |
| Shrink-wrap split, extra pseudo-class pass | Conflict branch is false; no register growth plus disabled pressure scheduling/shrinkage excludes the extra class pass. |
| Alias / first root-loop setup | One alias lifetime and one fresh root-only loop lifetime; no optimizing combine/move/store-equivalence work. |
| SCRATCH and reload equivalences | Accepted empty scratch reserve and two additional-slot GGC reserves; no new pseudo or regstat recomputation. |
| Eliminable set / optional second root setup | Four target elimination pairs; root only, with optional empty exit hash. |
| Build, costs, live ranges, fast allocation, emission | One accepted build/cost pass, fast color and `ira_emit(false)`; no conflict graph, regional copies/caps/shuffles/flattening. |
| Renumber, allocation costs, initial values | Accepted renumber storage/numeric sums; no initial-value hook or regstat recomputation. |
| Reload wrapper | Destroys graph and optional root/dominance before LRA; releases equivalences/bitmap and resets DF after LRA. Old reload and optimizing cleanup/live-analysis/DCE paths are excluded. |

Indirect-jump optimization (`ira.cc:4144–4192`) requires a jump whose PC source
is a REG. There is none; `rebuild_p` stays false, so label rebuilding and edge
purge/unreachable-block mutation do not execute. Trivial dead-insn deletion
still allocates its accepted 4K count array. The selected definitions feed
argument copies and calls; all four pseudos are used, and hard argument moves
are retained. Keeping the accepted possible-deletion follow-up analysis bound
is conservative and avoids relying on an exact deletion count. `ndead<=M`
and the accepted use-count bound remain unchanged.

`generate_setjmp_warnings` may be called if its warning flag is set, but
`regstat_get_setjmp_crosses` is empty on this no-setjmp route; it returns at
`function.cc:4322–4326`. This excludes recursive declaration diagnostics by
shape, without assuming warning flags zero. `compute_regs_asm_clobbered`
scans patterns but its `asm_noperands>=0` branch is absent. Renumber values
remain -1..91, classes 0..33, and frame-pointer enumeration has width one.

The outer post-LRA wrapper (`ira.cc:6043–6186`) uses the accepted no-PIC
pseudo and no-old-reload route. No global hard-frame-pointer declaration or
generic stack-check option is selected, excluding the late diagnostics and
stack-check summation. It removes NOTE, frees old SCAN state and creates the
second SCAN generation; it does not run an extra O0 DF analysis. These are the
same two generations already charged, not an additional third generation.

## Alias and root-loop transfer

`alias.cc:3353–3567` initializes its two GGC vectors once, the new-base array,
two dense bitmaps and reverse-postorder output. The accepted MEM chronology
establishes empty incoming alias capacities and one call; ten iterations do
not allocate ten vectors. Ordinary ceilings are:

| Request | Individual bytes | Lifetime |
| --- | ---: | --- |
| New base pointers | 8K | Alias initialization to cleanup |
| Known-equivalence bitmap | `8+8ceil((K-92)/64)` | Initialization to `end_alias_analysis` |
| Seen bitmap | `8+8ceil(K/64)` | Initialization to cleanup |
| Reverse postorder | 4B | Initialization to cleanup |

These are already present in `alias_direct_helpers`; their explicit
PTRDIFF_MAX guards now complete the interface. Dense `bits+63`, stored word
and byte counts are unsigned32; K fits signed int for the final known-value
loop and `i+92`. A logical K-92 can use the larger K dense bound. There is no
negative subtraction because K>=104.

Each alias pass resets `unique_id=1`. No REG_NOALIAS means `unique_id++` and
`unique_base_value` are absent. Sources are symbols or whole registers, never
PLUS; known-value `plus_constant` is absent. `ix86_find_base_term` returns
those operands unchanged. `record_set` updates entries/bits and existing
pointers; selected destinations occupy one register. `pass` advances only to
10. Every instruction/reg/block loop has an existing K/M/B domain, with no
C-dependent scalar accumulation beyond those bounds. The reference-owning
vectors retain their two GGC events; no RTL allocation is hidden here.

The first loop lifetime surrounds equivalence scanning. It is finalized and
its dominance freed before the optional second lifetime. The latter is
finalized before LRA. `AVOID_CFG_MODIFICATIONS` is precisely
`LOOPS_MAY_HAVE_MULTIPLE_LATCHES`: no preheaders, latch splits or irreducible
marking. On the selected chain no predecessor is dominated by its successor,
so `bb_loop_header_p` always returns false. Each setup has root number zero,
`num_nodes<=B`, no natural child loop, 4B reverse-order storage and one empty
16-byte candidate reserve. `loops_list`'s one index fits its 16 inline slots.
Optional recorded exits create only the already owned wrapper/backing:
`rescan_loop_exit` returns before lookup because no edge exits the root.
All root/dominance ordinary requests, ten conservative GGC events, and shared
ET pool/depth bounds are retained once. The accepted 4B signed dominance and
8B relative-depth guards still apply. No old null-program byte totals are used.

## DF scratch, counters and imported sort clients

The selected active problems remain SCAN, LR, LR_DCE and temporary NOTE.
`df_analyze_1` skips SCAN and checking, so analysis does not recreate scan
pools. LR_DCE returns without `DF_LR_RUN_DCE`; NOTE has no iterative solver.
Only LR enters `df_worklist_dataflow`. It initializes IN from USE and OUT
empty, then monotonically adds register bits. Each successful change adds a
previously absent bit at a block and can enqueue only along an edge. Thus
`age,dcount<=V=B+K(B-1)`, the accepted bound. NOTE has up to three analyses;
whole backend DF has at most four, including later frame threading.

New explicit literal scratch transfer from `df-core.cc:1019–1166,1286–1335`:

| Request | Individual bytes / multiplicity |
| --- | --- |
| Forward/backward order | Two arrays, each 4B; previous arrays freed before replacement |
| Block-to-order map | 4B per LR solve, freed at its return |
| Considered dense bitmap | `8+8ceil(B/64)` per solve |
| Last-visit ages | `8+4B` per solve |
| Last-change ages | `8+4(B+1)` per solve |
| Added NOTE dataflow control | <=64 bytes (actual LP64 fields occupy 56), once |
| LR private control, retained | <=128 bytes: two pointers plus bitmap-obstack control |

Both age vectors start null, `safe_grow(...,true)` is exact, and neither grows
again. B+1 must fit both the signed caller expression and 31-bit capacity.
No geometric-growth intermediate belongs here. Their shared worklist/pending
bitmaps retain the accepted bitmap owner. The NOTE control's allocation is
`df_add_problem`; its `df_note_alloc` merely sets optional status and does
not allocate a scan-sized block array. Removal frees that control.

All ordinary SCAN/LR block arrays, register/instruction arrays, collection
vectors, typed pools, scan/LR/private chunks, register/deferred/NOTE bitmaps,
reference counters and 600C note events retain their accepted owners. D
bounds each hard-register `ira_hard_regno_nrefs` accumulation as well as DF
reference-order casts and subtraction. `num_used_regs` counts each pseudo
once, at most A. The CFG is already reachable; postorder cleanup adds no new
unreachable-block or DF compaction scratch. Optional reference tables, subset
analysis, loop-local solve, verification arrays and other problems are absent.

Four-argument `qsort` is a macro redirect to **GCC's `gcc_qsort`**, not an
unknown libc implementation (`system.h:1204–1212`). `vec::qsort` also calls
it. The selected nontrivial clients are:

| Client | Maximum n, element size | Comparator range |
| --- | --- | --- |
| Conflict-ID object map | A pointers, 8 bytes | Live endpoints differ by <=P; allocno IDs by <=A-1 |
| Fast priority order | A pointers, 8 bytes | Accepted `SORTGT` priority comparison; ID difference <=A-1 |
| DF per-collection refs | <=94 pointers, 8 bytes | Class/type/flag constants, register difference <=K-1, order difference <=D |
| Earlier important-class setup, retained | <=34 enums, 4 bytes | Class/order difference <=34 |

Root removal's sort has n=0 because root is explicitly skipped. Rebuilding a
register's allocno list, if reached during root cleanup, has at most one
entry. `gcc_qsort` returns before scratch for n<2. Optimizing color/coalescing/
spill sorts and regional/loop-body/sibling sorts are excluded by their entry
conditions. DF's multiword vector is empty; its compression sort is absent.
The two actual A-pointer sorts run sequentially, each with scratch
`8floor(A/2)=16C`, allocated only above 256 bytes. DF may need 376 bytes for
94 refs; do not infer that all DF sorts use the inline buffer from a witness
that happened to arrive sorted. Constant-class scratch is <=68 and inline.

`sort.cc:167–276` uses 2–5-element networks and halving merges. For n>5 the
two children have floor(n/2) and ceil(n/2), each at least three; thus no n=0/1
network is called. In networks, temporary e2/e4 can be one-past for n=2/4 but
are not dereferenced. Merge offsets and copies stay within the original
n-element array or its half-size scratch. `nl*size`, `n*size` and every
same-array pointer difference fit when the source span fits PTRDIFF_MAX.
Require 8A and scratch to fit separately. C++ pointer/integer round-trip and
arithmetic right-shift behavior are the selected LP64 implementation contract
used by GCC's sorter; XOR selects an original pointer, never a newly offset
address. Comparator values are signed int and all subtraction operands have
the bounds above. No comparator is negated. Halving yields a conservative
`1+ceil(log2(max(A,94)))` active merge frames (<=32 under the signed A guard),
plus fixed helper frames and one 256-byte scratch array. A machine stack-byte
budget is not inferred. No aggregate ordinary-memory or allocation-work total
is needed for this interface.

## Cold target probe and the GGC correction

`setup_prohibited_mode_move_regs` has exactly one caller, `ira.cc:5773`.
Its zero-initialized persistent flag allows at most one execution; there is
no selected target reinitialization. It is **not** called by `ira_init` during
first RTL setup. At `:1730–1733` it creates:

| Constructor | Count | Each raw/rounded ceiling |
| --- | ---: | ---: |
| REG(word_mode, LAST_VIRTUAL_REGISTER+1/2) | 2 | 24 / 32 |
| SET(existing probe registers) | 1 | 24 / 32 |
| Detached INSN(existing SET) | 1 | 72 / 128 |

Pseudo numbers 98/99 do not hit `gen_rtx_REG`'s special hard-register returns;
`gen_raw_REG` allocates. `gen_rtx_INSN` directly constructs an object: no
`emit_insn`, UID allocator, `gen_reg_rtx`, DF insertion or Main-chain insertion
is invoked. Changing modes/register numbers later mutates these same two REGs.
There are four positive requests, raw sum <=144 and rounded sum <=224. A
single new ledger row can safely use per-request raw72/rounded128. This is a
constant correction, not four events per C, mode or register.

The loop tries at most 124 modes times 92 hard registers. The mode-ok hook
reads fixed mode/register/target flags. `set_mode_and_regno` computes fixed
hard-register widths and changes fields; it creates no attributes. The
recognition probe receives only `SET(REG,REG)` with same mode/register number.
The retained MD audit identifies the 37 direct SET/leaf patterns across all
x86 `.md` files. Push/pop and memory destinations reject REG before address
work; ternlog rejects its code; AVX-only cases are gated; remaining cases are
register moves, LEA's register address, or the fixed flags self-set. Root
wildcards are all `match_parallel`, incompatible with SET. Split/expander/
peephole bodies are not entered by `recog`; missing-clobber recovery is disabled
because `recog_memoized` passes a null clobber-count pointer. Mode/attribute
substitution preserves these operand forms or adds structure incompatible
with the probe. The audit is evidence of the source case split, not a new
GCC generator implementation or executable recognition test.

For the accepted register cases, `general/register/nonimmediate_operand`
check mode, hard-register masks and class membership. `nonimm_or_0` and
`nonimmediate_or_sse_const` first test the ordinary REG case; constant-only
fallbacks cannot construct a constant from a REG. `ix86_hardreg_mov_ok`
returns before constant costing because its source is REG. Floating move
conditions short-circuit on `!CONST_DOUBLE_P`. LEA's `address_operand`/
`ix86_decompose_address`/`ix86_legitimate_address_p` handle a lone REG using
fixed local fields and base-register tests; no displacement normalization or
address construction is entered. `recog`, `insn_extract` and attributes read
existing nodes/table fields; output templates and split code are not executed.

`get_enabled_alternatives` fills a fixed cached mask by at most35 shifts,
indices0..34 within uint64. `constrain_operands(strict=1)` has fixed arrays
of 30 entries, at most35 alternatives and fixed constraint text; the reached
move constraints contain no matching/earlyclobber/auto-inc/SUBREG operand.
Class constraints use fixed masks; memory/constant constraints reject REG;
LEA's address constraint uses the same lone-REG path. There is no strict-zero
recursive fallback, no funny auto-inc match, and no generated operand change.
`preprocess_insn_constraints`, which would allocate cached operand alternatives,
is **not called** by this probe. The probe adds no ordinary allocation or
GGC object beyond the four constructors. Main's later recognized operand
tables retain their separate accepted ownership.

The 50 accepted GGC rows were reconciled individually by owner identity and
scope. `first_RTL_setup` is the earlier437-event interval (fixed175 + cold120
+ sequence10 + dummy11 + hash121); its source decomposition omits this later
probe. `operation_nonchain_RTX_through_first_unshare` owns operation expansion
and first-unshare occurrences, not detached IRA nodes. `whole_final_instruction_chain`
owns Main chain nodes; this probe is detached. DF/LRA notes, alias, reload,
root-loop and unused-pseudo rows name distinct constructors. Remaining rows
are earlier frontend/graph/shared storage or later frame/CFI/emission, never
this callsite. None can absorb the probe by relabelling its existing allowance.

Add exactly one disjoint owner `IRA_cold_prohibited_mode_probe`, retaining
all 50 rows unchanged. Hello's historical envelope47054 becomes47058 and
51 owners **before collector recomposition**. The packet exports the row,
constructor split and explicit required attachment. It does not mutate the
accepted result, assert its current collector guard remains valid, or call
the fixed Hello reconciliation a general source adapter. #146 remains open
until the actual-source correction and independent review are integrated.

## Executable exports, validation and limits

`arithmetic(C,N)` rejects booleans/invalid domains, returns mathematical
integers even when guards fail, and exports 18 local representation checks
plus their conjunction. Inherited checks are still required, including
rounded GGC capacities, IRA graph/pools/numeric/helper and CFG/ET bounds.
The source-coverage flag reports the completed case split; it is **not** a
substitute for prerequisite truth or the pending actual-source/collector
attachment. Aliases and DF/CFG/IRA storage are never recharged. Scalar/array
finalizer and shared bitmap/ET deltas are zero; new GGC delta is four.

Focused validation passed **442 checks in 0.7689414600026794 seconds** on
Linux 7.0.14 x86_64, checking69 GCC and58 repository pins and66 literal-LF
excerpts. The packet retains the result and exact checked artifact identities.
Checks cover the 16/17-call sort heap threshold, dense rounding, exact DF
vector requests, signed counter boundaries, sort recursion and buffer spans,
invalid inputs, input/excerpt mutations and the historical50/new51-owner
partition. Successful predecessor tests are reused. No compiler, native
build/capture, prover/Lean, census, predecessor evaluator/checker, full suite,
aggregate or corpus replay ran. Native host is Linux x86-64. Selected model
was GPT-6 Astra / Extra High; runtime confirmation, token usage and monetary
cost are unavailable. The round record separates checker time from elapsed
work. Parent owns review, actual-source integration, root docs, issues and
publication. No GitHub or CLI-memory write was made by this subthread.
