# Selected literal LRA arithmetic and automatic storage

2026-10-19. Owner-resumed native-build research checkpoint
[#145](https://github.com/berkeleynerd/silver/issues/145), within
[#119](https://github.com/berkeleynerd/silver/issues/119).
This closes the named **selected-route** elimination-offset, remaining LRA
cost/preference, constraint/recognition recursion, automatic-array and fixed
parameter arithmetic residuals, conditionally on the accepted source route.
Independent review is pending. The [packet](../evidence/retained-literal-lra-arithmetic-completion-20261019/README.md)
exports the arithmetic and preserves false/unknown source premises. It is not
an actual-source adapter or a claim of all-LRA or whole-native capacity.

The source base is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
All coordinates below are literal LF positions; form feeds do not advance
them. The accepted helper source/review are `b795c8f745`/`4d7100e7fb`, the
367-guard attachment/review `71624df232`/`ac4694d0f7`, the numeric source
`9ed466e07f`, and recognition source/review `b341b7f33a`/`df9ada3f10`.
The [output RTL argument](retained-output-rtl.md) supplies the call-group,
allocation, unchanged-assignment and frame facts; the
[recognition argument](retained-literal-lra-recognition.md) supplies lifetime
and rounded-pool counters. No existing owner, pool, bitmap, GGC event or
finalizer is charged again. Oracle, admission and toolchain pins are unchanged.

## Exact domain and imported representations

The domain is Linux x86-64 LP64, SysV, generic O0 with wide splitting, the
selected no-debug/no-checking/no-statistics invocation and unchanged target
options. C>=1 is the number of output calls and N>=0 the null count. A call's
seven-instruction group has four distinct whole-DI pseudos, each defined and
used once; no pseudo crosses a call, group or block boundary. There are two
constraint iterations, one live scan and assignment, and at most one
inheritance and undo pass. No reload, spill, scratch, asm, debug, equivalence,
coalescing or rematerialization transformation occurs. There are no new
instructions or pseudos beyond the already accepted unused Pmode pseudo and
terminal deleted note. Ordinary register-copy moves are included. These facts
come from the source theorem, not from O0 or equal C/N counts alone.

Retain K=99+5C, B=2N+10, M=7C+5N+20, U=M+2, P=2M+B and
R=floor(3K/2)+1. The imported guards include 3K<=INT_MAX, U<=INT_MAX,
B<=INT_MAX, 2(P+1)<=INT_MAX, 600C<=INT_MAX and 10000C<=INT_MAX.
They cover register growth/values, UID narrowing, block/epoch indices,
live-range sums/successors, notes and the separate hard-register usage sum.
All other accepted storage/recognition guards still apply. The new local
arithmetic adds **no C/N restriction**. Each pseudo's current frequency is
0..2000 and each instruction's frequency 1..1000. Retained source/configuration
and the complete older guard maps must be joined before applying the result.

## Elimination is executed with a fixed frame

`lra_eliminate(false,true)` initializes elimination and calls
`update_reg_eliminate`; the latter calls `targetm.compute_frame_layout`
**before** examining changed-offset instructions (`lra-eliminations.cc:
1180–1293,1504–1563`). An empty bitmap does not remove this call.

The output-RTL frame argument applies already at LRA: no local/spill slots,
stack arguments, varargs, static chain, alloca, DRAP, TLS descriptor call,
extra saved GPR/SSE register or stack realignment is introduced. Frame pointer
retention is fixed, and the accepted allocator uses only caller GPRs. Therefore
`ix86_get_frame_size` is zero; both alignments are 16 bytes, ordinary register
save counts are zero, and the function is nonleaf. In `i386.cc:7020–7377`,
the frame starts with the return address 8 and adds saved RBP 8. The save,
hard-frame, local-frame and stack-pointer offsets are all 16. The nonleaf
roundings are `ROUND_UP(16,16)`; their pre-mask addition is at most 31. All
other size additions are zero. `to_allocate=16-16=0`; red-zone use is zero.
The slow/fast-prologue choice does not change any of these numbers.

Its cost query is safe too: nregs=0 makes the `FAST_PROLOGUE_INSN_COUNT`
multiply unreachable and calls `expensive_function_p` with threshold zero,
if that query is needed (`i386.cc:7117–7153`). In `predict.cc:3866–3900`, an
unknown/zero entry count returns immediately. Otherwise limit is zero.
Before the first positive block contribution the running sum is zero; that
first addition stores one representable block count and returns. Zero-count
blocks add zero. Thus this helper does not accumulate C or N profile counts.
`save_regs_using_push_pop(0)` succeeds in its first clause and does not evaluate
stack-probe shifts (`i386.cc:6999–7015`). Save-register loops have 92 iterations
at most, and SysV skips the SSE-save loop.

The four eliminations are ARG_POINTER to SP/HFP and FRAME_POINTER to SP/HFP
(`i386.h:1789–1793`). Their offsets from `ix86_initial_elimination_offset`
(`i386.cc:6919–6937`) are respectively 16,16,0,0. All from/to numbers are
within the 92-element hard-register arrays. With frame_pointer_needed true,
the two SP substitutions are disabled and the HFP substitutions remain
stable (`:6904–6912`). `init_elim_table` starts previous/current offsets at
-1. Thus the first selected HFP offset differences are 17 and 1, **not**
merely 16 and 0. The second constraint iteration recomputes the same frame
and yields zero differences.

`mark_not_eliminable` visits the four accepted patterns and sees no SP update,
pre/post increment, or elimination-source/target use (`lra-eliminations.cc:
767–901`). Each block's `curr_sp_change` starts zero and every record receives
zero (`:1345–1375`). CALL/MEM/SYMBOL_REF nesting contains no explicit SP
assignment; the runtime call instruction's balanced stack effect is not an
RTL SET of SP here. No caller inserts a reload sequence requiring
`lra_update_sp_offset`. Elimination availability cannot change, so the
negation/self-restoration and switch-to-another-elimination branches are absent.
The map's source-register instruction bitmaps are empty: all explicit hard
references are RDI/RSI, and the nonoperand lists are empty.

The first 17/1 differences are nevertheless passed to
`lra_update_reg_val_offset` (`lra-int.h:529–538`). Register values were freshly
initialized uniquely over the complete capacity and no selected value-copy
writer runs (`lra.cc:1354–1375`; the value-copy callers create reload pseudos).
Thus no pseudo has an elimination hard register's value. Its guarded `offset +=
incr` is not executed; pseudo offsets stay zero. The helper's K-bounded loop
still runs. `spill_pseudos` sees no assigned register newly prohibited by these
eliminations and adds none. Initial and final changed-offset instruction sets
are empty. Consequently the complex PLUS/MULT/SUBREG offset arithmetic and
the two automatic operand arrays in `eliminate_regs_in_insn` are not reached.
No claim about their safety on arbitrary addresses is needed. The selected
one-coefficient poly_int64 operations here fit int64 before every subtraction.

## Costs, preferences and the unsigned alternative marker

LRA preference profits are initialized to zero and reset by the sole live
scan (`lra.cc:1364–1367`, `lra-lives.cc:1387–1395`). The live scanner's writer
requires a source or destination at/above `lra_constraint_new_regno_start`
(`:814–862`). That interval contains no referenced pseudo; the unused Pmode
pseudo was created **before** recording the boundary. The only other caller
is assignment preference propagation, reached from the excluded allocation
loops. Hence both preferences stay -1 and both profits stay zero.

`assign_by_spills`'s initial list is empty, its nfails=0 branch exits its
two-iteration loop immediately, and its optional nonreload list is empty
because every referenced original pseudo is assigned (`lra-assigns.cc:
1394–1609`). Empty inheritance/split/subreg/optional sets make
`improve_inheritance` empty too. Therefore find_hard_regno_for, spill_for,
assign_hard_regno, recursive preference propagation and their frequency/cost
products, accumulations and generation counters do not run. Copy threads
remain singleton because the accepted copy pool is empty. The correctness
scan **does** run; whole DI gives biggest_nregs=1 and nregs_diff=0. Its
comparators subtract frequencies in [-2000,2000] and IDs in (−K,K); its
point loops and inclusive lengths use the inherited P guards. The accepted
unchanged-allocation argument excludes its spill-side subtraction. This
closes selected LRA costs; the separately accepted IRA numeric argument is
still required for the incoming assignment and DI move primitives.

Constraint scores cannot be discarded merely because the final winner needs
no reload. Four register copies per group take `simple_move_p`, whose DI GPR
cost is 2 (`lra-constraints.cc:4233–4255,4354–4362`). Nop/blockage return at
zero operands. For a symbol definition, the x64 movdi alternatives 0 and 1
are **disabled**; the first candidates are 2 (`r/Z`), 3 (`r/rem`), then 4
(`r/i`). Alternative 4 is enabled and preferred in both size and speed modes
and accepts the selected DI symbol; earlier successful candidates may end the
search sooner (`i386.md:2594–2598,2656–2673,2746–2765`, enabled/default
attributes `:921–926,1002`). The direct LP64 call has `rBwBz` and an
unconstrained size operand (`:20469,20495–20500`); Bz accepts its direct symbol.
No commutation, matching digit, early clobber, in/out, address or asm retry is
selected. The winning case breaks the search (`lra-constraints.cc:3587–3590`).

The following deliberately loose interval also covers failed candidates.
At each alternative, all score variables are reset. At most two operands,
28 movdi alternatives (the inherited envelope is 35), and DI widths one are
used. Every static operand rejection is at most 6: a selected constraint
alternative has at most one `?` and no `!`. Thus static_reject<=12. There
are no `$` or `^`, so op_reject=0. In the nonmatching, non-early-clobber
operand path, sum **all** positive rejection sites, even mutually exclusive
ones: their total is below 1024 per operand (the largest is 600; the others
are 1,2,3,6). The only permitted subtraction is bounded by three per operand;
allowing it even for these assigned operands gives reject in [-6,2060].
There are at most three loser increments per operand (ordinary, constant
through memory, secondary memory), hence losers<=6. reload_nregs,
all_used_nregs and all_reload_nregs are each <=2, and their starvation
comparison's `+1` is at most 5. last_reload and bb_reload_num stay zero
because their writers generate reloads, so reload_sum=0. The two post-loop
penalties each add at most 600. Consequently every intermediate score fits:

```
losers * 6 <= 36
abs(losers * 6 + reject - optional_static_reject) <= 2108
abs(overall after both 600 penalties) <= 3308 < 4096 < INT_MAX
```

This bound precedes comparisons with INT_MAX; no saturation is used to
excuse an overflowing expression. Early-clobber follow-up loops are empty.
The -1 alternative/matching sentinels and valid indices 0..34 fit signed
char/int; `nalt*n_operands+nop<=69` fits before table access. Alternative
masks use the retained uint64 type and shifts below 35.
The retained generated header has NUM_REGISTER_FILTERS=0, so generic
constraint preprocessing's filter-ID shift is absent (`recog.cc:3013–3015`);
it is not justified merely by the independent 64-bit alternative mask.

`curr_small_class_check` is process-persistent unsigned int and increments
per visited alternative (`:2137,2306`). It is not reset per function. Its
selected consumers are nevertheless inactive: the above candidates expose
only GENERAL_REGS or NO_REGS to `update_and_check_small_class_inputs`.
GENERAL_REGS contains at least the nine accepted usable caller GPRs and
`ix86_class_likely_spilled_p` returns false for it (`i386.cc:21202–21223`);
NO_REGS is empty. Both fail `SMALL_REGISTER_CLASS_P` (`:271–274`). The
cached epoch/input-count body is never read or written. Therefore even an
incoming UINT_MAX marker and unsigned wrap have no selected semantic or
capacity effect. This is not a false claim that this global marker starts
zero at Main or that unsigned wrap is always harmless. There are at most
7C selected increments here (three candidates for each of 2C definitions,
one for each call); no guard on their historical total is needed.

## Automatic objects and recursive traversal

The named LRA source files have no variable-length automatic array or alloca.
The relevant fixed arrays and the generic recognition scratch are:

| Client | Object/indices on the selected route |
| --- | --- |
| `curr_insn_transform`, `:4342–4344` | One 30x30 signed-char matrix (900 bytes), two 31-char vectors. Initial matrix writes use rows 0,1 and column 0. Matching/reload construction is absent, so later matrix/vector append paths do not run. |
| `process_alt_operands`, `:2215–2242,2305` | Fourteen 30-element arrays; each element is bool, int/enum, pointer or 16-byte HARD_REG_SET. Each individual object is at most 480 bytes. Operand indices are 0,1; early-clobber/dont-inherit arrays receive no selected append. |
| `lra_set_insn_recog_data`, `:1135` | Existing 92-int argument scratch, 368 bytes; two hard DI USEs and the -1 sentinel occupy indices 0,1,2. The accepted recognition packet owns the heap copy. |
| `preprocess_insn_constraints`, `recog.cc:3072` | The only selected dynamic automatic request, two pointers, 16 bytes. Zero-operand codes return before it. |
| `constrain_operands`, `recog.cc:3142–3147` | Four 30-element arrays, each at most 240 bytes. nop<=2; matching and early-clobber lists are empty. Its sole recursive retry changes strict=0 to -1 and cannot repeat: at most two invocations (`:3453–3463`). |
| negative-code asm arrays in `lra.cc:1034–1035,1263–1264`; reload-combine vector `lra-constraints.cc:5456`; elimination arrays `lra-eliminations.cc:928–929` | Excluded respectively by recognized nonnegative codes/no asm, no reload combination, and empty elimination instruction sets. Their declarations have fixed dimensions regardless. |

The 90-entry input-reload/to-inherit arrays are **static**, not stack objects.
Their appenders require the excluded reload/inheritance transformations.
Hard-register arrays have 92 entries; class arrays have 34. No object above
is a new ordinary heap owner. Individual object sizes and pointer products
fit PTRDIFF_MAX. A sum of stack frames is not exported as an allocation or
RAM gate.

Recognition's RTL visitors (`collect_non_operand_hard_regs`,
`add_regs_to_insn_regno_info`) and elimination's initial
`mark_not_eliminable` follow only proper `e`/`E` expression children. Their
selected patterns are SET(REG,REG/SYMBOL_REF), CALL(MEM(SYMBOL_REF),CONST_INT),
CONST_INT, and UNSPEC_VOLATILE([CONST_INT]). Their maximum expression path
has three nodes and the only vector has length one. Operand-boundary stops
can shorten that traversal. They do not follow instruction chain links or
the declaration pointed to by SYMBOL_REF. Nested scalar field loops use
fixed RTX lengths; zero length's `length-1` produces the valid -1 sentinel.
Call usage is a two-element list traversed iteratively. Repetition for C/N
instructions does not nest these calls. A recursive RTL comparison/hash, if
used on these operands, likewise descends these proper expression children,
not source-string length or the instruction chain.

The substitution/equivalence/debug, address decomposition/reload, split and
rematerialization recursion families require absent transformations. In
particular process_address_1 returns at `:3904–3905`: the extracted operands
are REG, SYMBOL_REF or CONST_INT, **not** the enclosing CALL's MEM, and none
has an address constraint. Its outer ten-attempt loop returns on its first
test. Dead-predecessor recursive deletion in the live scan is absent because
each pseudo definition has its retained later use. Final self-move deletion
invalidates one record; it does not invoke that live-scan recursion.

Final rewriting does call `alter_subregs` for each extracted operand
(`lra-spills.cc:729–764,849–863`). Those operands are whole REG, SYMBOL_REF
or CONST_INT leaves. None is SUBREG or has an `e`/`E` child, so the helper
returns without transformation or a recursive child call. The selected route
therefore excludes its subreg conversion arithmetic by actual operand shape,
not by excluding the whole final rewriting pass.

Generated recognition is kept distinct from a recursive walk of source
statements. `genextract.cc:378–403,478–501` emits a switch and fixed operand
assignments; the selected codes write only operand 0/1 and no duplication
entry. `genrecog.cc:3384–3481,4799–4852,5123–5158,5221–5285` splits a finite
decision tree into proper-subtree calls; subroutines are created after their
descendants. Thus generated calls decrease the fixed tree rank, while their
locals are scalar rtx/int values, not C/N-sized arrays or a runtime depth
counter. Common-pattern factoring remains a fixed target decision graph,
independent of program size. Selected predicate arguments have the shallow
shape above; register/general/immediate/direct-call predicates either test
the leaf or take their fixed wrapper path. The accepted four-code extraction
and generated-tool interpretation premise is reused. No generated compiler
was run, no unavailable insn-recog.cc artifact is claimed checked, and this
does not establish new source-to-binary correspondence for the installed tool.

These are finite control/index/object-size arguments. Physical stack, RAM,
OS and allocator failure retain the existing external execution assumptions.
No C/N ceiling is invented from an assumed native stack size.

## Fixed parameters and application interface

`params.opt:464–478` supplies the defaults: inheritance cutoff 40,
max-considered-reload-pseudos 500, preference log2 30. The complete accepted
Main invocation has no --param or target/optimization override; no selected
attribute or pragma changes them. A source inventory finds their runtime
uses only in the named LRA sites; target/optimization adjustment code has no
additional assignment to these variables. Therefore:

* `REG_BR_PROB_BASE*40/100=4000`; the predivision product is 400000, within int.
  The edge probability conversion independently returns 0..10000.
* `1U<<30` is defined in 32-bit unsigned. The division by
  `lra_live_max_point+1` has a positive representable denominator under the
  inherited P guard. The left count is zero. If the quotient is also zero,
  the early return is allowed; it is not assumed that the comparison is false.
* The 500 limit is only read in the excluded spill-search loop. Iteration
  limits 30,10,2,2 and operand/reload constants 30/90,6,600 are fixed source
  constants. They are not substituted for the accepted convergence theorem.

`arithmetic(C,N)` computes exact mathematical extents and local/imported
representation checks. `apply(C,N,premises)` requires the six named joins;
false or unknown leaves `derived=null`. The joins include the complete
accepted 367-key source/configuration/owner guard transfer and generated
target semantics; equal C/N counts alone cannot supply them. The fixed-Hello
reconciliation checks the complete existing recognition owner, source identity,
counts, successful guard maps and exact selected options without executing
any predecessor. It is a fixture, not a general join algorithm. A future
adapter must retain every older false/null prerequisite and owner.

The new packet tests arithmetic boundaries, unknown/false premises, fixed
parameter mutations, selected-alternative exclusions, unsigned marker wrap,
frame sentinel differences, automatic indices and exact input/excerpt pins.
Finite tests support the handwritten argument; they do not establish its
universal source claim. No compiler/native build/capture, prover/Lean,
predecessor evaluator/checker, corpus or aggregate replay ran. Outer IRA,
actual-source attachment, imported sort/execution contracts, production
correspondence and whole-tool capacity remain separate. The
[round record](../evidence/retained-literal-lra-arithmetic-completion-20261019/round.json)
records selected Astra Extra High, actual elapsed time, unavailable runtime
confirmation/token/cost data and review status.
