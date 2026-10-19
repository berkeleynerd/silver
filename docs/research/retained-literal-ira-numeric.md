# Retained literal IRA numeric arithmetic

2026-10-19, issue #119. Candidate pending independent review.

This packet closes the named IRA cost, frequency, equivalence-gain,
preference, pressure, fast-priority and allocation-cost arithmetic
conditionally on the selected literal route and explicit representation
guards. Per-allocno bounds are independent of the number of calls. The
only new count-dependent sum here is the int64 allocation-cost aggregate.
It does not close outer IRA helper capacity, remaining LRA arithmetic or
complete native capacity, and does not change language admission.

The [evidence packet](../evidence/retained-literal-ira-numeric-20261019/README.md)
uses retained GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`
and repository base `3be5bf4baba95ff007667f53182d115dca0bfd05`.
It builds on storage commit `66da47daa2c433a0872e8bbc626e0bb18850426e`,
accepted in [review `3d00f8af99`](../reviews/review-literal-ira-storage-66da47daa2.md).
The accepted storage packet is unchanged, including its documented excerpt
erratum. Every new excerpt uses literal LF coordinates, checked against its
text and named operative fragments; form feeds do not advance line numbers.
The source argument remains handwritten, not a universal machine-checked proof.

## Selected input and inherited facts

Use the same Linux x86-64 LP64 generic O0, wide-splitting, no-debug/checking/
statistics route as [output RTL](retained-output-rtl.md) and
[IRA storage](retained-literal-ira-lra-ordinary.md). There is one physical
Main, one IRA build and cost pass, one root region, fast allocation and
`ira_emit(false)`. There are no loops, caps, regional merges/shuffles, spills,
reload pseudos, scratch, asm, partial pseudo definitions, local EH or
abnormal incoming edges. Target setup is fixed and is not repeated for Main.

Each output call has this indivisible seven-instruction group after splitting:

```text
d0:DI := literal SYMBOL_REF
d1:DI := bounds SYMBOL_REF
x:DI  := d0
y:DI  := d1
RDI   := x
RSI   := y
call direct output operation
```

The four pseudos are unique to their group, each defined once and used once.
No pseudo crosses a call, another group, or a block boundary. Null statements
and layout-edge nops do not occur between these seven instructions. All
pseudo-bearing instructions are the two-operand `*movdi_internal` pattern.
The fixed argument-register copies take `record_operand_costs`'s direct
hard-register shortcut. The other pseudo instructions have one pure output
and one pure input, with no matching digit, `%`, `+` or `&` constraint.
Calls/nops/blockage have no pseudo operands; the direct call's symbol wins
its call constraint and its size operand is unconstrained. Address traversal
sees a plain symbol and records no pseudo address cost.

For `C>=1`, `N>=0`, retain `A=4C`, `K=99+5C`, `B=2N+10`,
`M=7C+5N+20`, and `P=2M+B`. The storage owner supplies A's signed extent
and `P+1<=INT_MAX`; these two prerequisites are exposed again by the numeric
API because they bound comparator IDs and absolute live-point arithmetic.
Its other storage guards still apply independently. Counts and source
identity must come from the accepted source/configuration route before an
actual-source caller can use this packet.

## Frequency, reference and primitive cost bounds

`REG_FREQ_MAX` is **1000**, not the separate LRA frequency ceiling 10000
(`regs.h:125–138`). `REG_FREQ_FROM_BB` either returns 1000 or rescales
`profile_count::to_frequency`, which returns a value in 0..10000; a zero
rescaled value becomes one. `profile_count.h:1302–1336` clamps an oversized
ratio to the maximum probability; `profile-count.cc:296–307` and
`profile-count.h:295–299` perform the fixed-scale conversion. The multiply
before division is at most `10000*1000=10000000`, within signed int.
Thus `1<=f<=1000` regardless of C and N.

`create_insn_allocnos` increments `ALLOCNO_NREFS` and adds the block frequency
once per pseudo occurrence in the actual PATTERN (`ira-build.cc:1865–1866,
1922–1927`). It does not rescan notes as occurrences. From zero initialization
(`:498–499`), each selected allocno has two references and frequency sum at
most 2000. No regional propagation or merge adds another allocno's counts.
Call frequency, calls-crossed and cheap-calls-crossed remain zero because
`objects_live` is empty at every call. In particular the live-object ABI
bit-shift/cost loop is not executed for a pseudo at a call.

The following primitive bounds concern DI and the selected target:

| Quantity | Bound and source relation |
| --- | --- |
| Memory move cost | 6..100 before NO_REGS minimization; 1..100 suffices afterward. `inline_memory_move_cost` returns the generic load/store entries, at most 6 for DI GPR/SSE/MMX/mask moves, or the fixed unsupported-FP value 100. DI is one 8-byte word. The maxima over subclasses do not increase 100. NO_REGS starts SHRT_MAX but gets a valid GPR minimum before use. |
| Register move table | 2..65535. Target DI moves cost 2, a generic inter-unit entry, or at most `1+100+100+20=221`; the non-fitting fallback in IRA is at most `(100+100)*2=400` or sentinel 65535. Taking maxima over subclasses preserves positivity and the unsigned-short ceiling. |
| May-move tables | 0..65535: IRA can replace a register-table value with zero for a subset relation. |
| `copy_cost` for the non-pseudo symbol | 0..100 suffices. `ix86_preferred_reload_class` can narrow to NO_REGS; `ix86_secondary_reload` returns NO_REGS with extra cost zero for a DI symbol. The resulting value is the memory-table value or `COSTS_N_INSNS(1)=4`, with no recursion. |
| Direct RDI/RSI move factor | One. `choose_hard_reg_mode` chooses DI for these one-word GPRs; `initial_regno_reg_rtx` uses that mode. Both operand and natural modes are eight bytes. |

These relations use `x86-tune-costs.h:4158–4196`,
`i386.cc:21013–21204,21382–21400,21479–21714,21725–21742`,
`ira.cc:567–634,1544–1645`, `reginfo.cc:489–498,600–649`,
`emit-rtl.cc:6258–6281`, and `rtl.h:2074`. They prove the selected DI
operands' arithmetic; they are not a new proof of all target initialization
arithmetic for every machine mode.

## Products before MIN and saturation

The actual movdi pattern has 28 alternatives. Each of its two constraint
strings contributes at most one `?`, so raw alternative penalty is at most
four (`ira-costs.cc:765–780`). There is at most one non-pseudo symbol
operand requiring `copy_cost<=100`. The first pass has `pref=NULL`; there
are no matching, commutative or in/out operands. Therefore:

```text
alt_cost <= 100+4 = 104
op_cost_add = alt_cost*f <= 104000
qq_class <= 65535*f <= 65535000
qq_memory <= 100*f <= 100000
scale = 1
(qq_class+op_cost_add)*scale <= 65639000
(qq_memory+op_cost_add)*scale <= 204000
```

All additions and products fit signed int **before** the `MIN` expressions
at `ira-costs.cc:1051–1080`. Negative memory discounts cannot escape below
zero: the memory primitive is positive and at least six before subtracting
the 0/1 `allows_mem` flag. OP_INOUT's two-direction and doubled-scale paths
are not selected. The two generic stored operand costs start at 1000000
(`:2573–2575`) and are only minimized, giving a safe `[0,1000000]` interval
even without assuming a particular alternative won.

The hard-register shortcut evaluates `cost*=cost_factor` with factor one,
then `cost*frequency`, at most 65535000 (`:1411–1446`). A dying source's
singleton class can replace that value with `-f`, at least -1000. Its memory
cost is nonnegative and at most 100000. The two contributions to an allocno
are therefore bounded conservatively by:

```text
class cost in [-2000, 131070000]
memory cost in [0, 2000000]
```

`scan_one_insn`'s accumulated additions (`:1625–1650`) fit those intervals;
the positive-overflow saturation tests do not repair an earlier overflowing
expression. The tests' `INT_MAX-add_cost` subtraction is evaluated only for
positive `add_cost<=65535000`, so it also fits. No selected instruction has
a REG_EQUIV memory load or pseudo in an address; the negative memory-saving
and address-cost routes are absent.

There is only one allocno per register in the root region. The per-register
aggregation in `find_costs_and_classes` adds that one allocno to zero and
does no parent propagation. Its initial best-cost sentinel `(1<<30)-1` fits
int and exceeds the entire cost interval. The accepted allocation-class
argument supplies an eligible class containing general registers; class
selection and tie maxima therefore retain the interval. Later singleton
preference normalization copies an existing class cost, preserving it.

`calculate_equiv_gains` requires `pass==1` (`:2068–2072`); the sole O0 pass
is zero. `regno_equiv_gains` stays zero from initialization. The earlier
`update_equiv_regs` finds no existing REG_EQUIV note and its `!optimize`
branch skips creating a new replacement (`ira.cc:3686–3712`). There is no
gain multiplication, negation of an extreme saving, or memory-cost reduction
on this route. Ordinary equivalence helper arrays retain their separate
lifetime/capacity obligations.

For the optional singleton preference (`ira-costs.cc:2342–2360`), the
subtraction is bounded **before division** by
`131070000-(-2000)=131072000` in either direction. The denominator is the
positive register-move table, at least two; this is not a possibly-zero
may-move table. A stored positive preference frequency is at most 65536000.
There is at most one creation attempt per allocno in the sole pass; prefs
start empty and hard-move/conflict/region creators are absent. Thus the
existing-record `pref->freq+=freq` branch at `ira-build.cc:1237` is never
taken for these allocnos.

As an auxiliary fixed-size arithmetic check, `ira_setup_alts` uses at most
two `?` rejection entries of six plus at most two six-point reload penalties:
`this_reject<=24` (`recog.cc:2975`, `ira.cc:1804,1904`). Its alternative bit
indices are 0..27 within the 64-bit mask. No tied-operand index parsing or
commutative extra pass is selected.

## Pressure with repeated cross-class updates

The proof does **not** assume zero pressure, disjoint threshold intervals or
that `high_pressure_start_point` resets at a call-group boundary. That saved
class timestamp can predate the group. The operative source relation is:

```text
start = max(high_pressure_start_point[cl], object_live_range->start)
excess += curr_point - start + 1
```

(`ira-lives.cc:139–162`). Every live-range record for this object starts
within its own seven-instruction group. `make_object_live` can reuse an
adjacent range for the same object, but there is no earlier group containing
this pseudo. Callbacks address either a currently live object or the object's
own just-finished range. No callback sees it after its group or at a block
boundary. With two point increments per instruction and no pseudo
early-clobber/tied extra increment, every callback satisfies:

```text
0 <= curr_point - max(high_pressure_start_point[cl], range_start) <= 14
0 < summand <= 15
```

A threshold timestamp from an earlier group is clipped by `range_start`;
its age never enters the summand. A threshold started later still lies at or
before `curr_point`. The inherited P+1 guard establishes representability
of the absolute point fields, subtraction and successor before applying the
stronger local difference bound.

Count every possible callback, including overlapping intervals from other
classes. `dec_register_pressure` performs at most one all-live-object update
traversal per call, even if several classes cross a threshold (`:245–280`).
For each selected instruction:

1. Its ordinary definition-death scan can clear at most 92 distinct hard
   registers. `mark_hard_reg_dead` tests the live bit, decrements and clears
   it; duplicate DF references cannot cause another decrement in this scan.
2. Its separate MUST_CLOBBER live/dead scan can clear up to 92 hard registers
   again. It is included even though the selected pseudo operands have no
   early-clobber constraints (`:820–845,1523–1527`). Call MAY_CLOBBER effects
   are filtered from the ordinary scan (`:1403–1405,1510–1512`). Counting all
   92 in both scans safely overallows the selected call behavior.
3. Allow four pseudo-death decrements, one for each group pseudo, even though
   the selected SET instructions define only one. The early-clobber/tied
   pseudo-conflict path is absent. Allow one additional direct
   `make_object_dead` update for the particular object in this instruction.

Each decrement can update this object at most once. Thus there are at most
`7*(2*92+4+1)=1323` calls of the excess updater for this object. Every such
call can add up to 34 class summands. The class-superclass list contains no
duplicates: `setup_reg_class_relations` considers each `cl2` once before
appending it (`ira.cc:1207–1250`). Even if **all** these summands repeatedly
cover overlapping point intervals, the accumulation from zero is at most:

```text
1323 * 34 * 15 = 674730 < INT_MAX
```

This count includes the object's own death callback separately from the
callback caused by its pressure decrement. The end-of-block live-object
cleanup is empty for pseudos. No regional propagation/merge subsequently
adds another object's pressure count.

Each pressure class's current and maximum live counts also fit int. At most
92 hard live bits and four group pseudos can contribute, each with width
one, so the count is 0..96. Initialization filters eliminable/no-allocation
hard registers (`ira-lives.cc:1325–1352`); `ira_no_alloc_regs` contains
`no_unit_alloc_regs` (`ira.cc:2493`). On the remaining hard registers,
`setup_hard_regno_aclass` uses the same class translation as initialization
(`ira.cc:1421–1431`). Live-bit guards ensure each increment/decrement is
balanced; pseudo sparse-set guards do likewise (`ira-lives.cc:322–333,
451–462`). The DI class-width hook returns one, and class lists are stable
through the scan. Root pressure propagation takes maxima, not sums.
The `too_high_register_pressure_p` comparison with 10000 performs no growing
arithmetic. None of this requires the exact target pressure-class partition.

## Priorities, comparators and aggregate costs

`setup_allocno_priorities` (`ira-color.cc:3098–3153`) uses
`floor_log2(nrefs)+1<=2` and DI register width one. Crucially its subtraction
precedes the checked multiply, and is separately bounded:

```text
memory_cost-class_cost in [-131070000, 2002000]
first multiplied priority in [-262140000, 4004000]
```

Both fit signed int. The selected execution does not need the builtin
overflow fallback or long-long saturation. Neither branch can produce
INT_MIN, so taking the priority's absolute value is safe.

Let Q be the maximum absolute first priority. If Q=0, every priority is zero
and the multiplier is one. Otherwise `t=floor(INT_MAX/Q)` and every priority
q satisfies `abs(q)<=Q`, hence `abs(q*t)<=Q*t<=INT_MAX`. This proves the
**multiplication before division** in the second loop safe, including negative
q. The divisor is excess pressure (at most 674730), replaced with one when
nonpositive; there is no zero divisor or INT_MIN/-1 case. The result stays
within `[-INT_MAX,INT_MAX]`. `allocno_priority_compare_func` uses `SORTGT`,
not `pri2-pri1`; its only growing subtraction is the allocno-ID tie break,
bounded by `A-1`. The static-chain boolean difference is in -1..1.

The accepted fast assignment chooses a hard register for every allocno and
leaves hard-cost vectors null. `ira_emit(false)` returns before shuffle cost
updates. `calculate_allocation_cost` therefore reads one bounded class cost
per allocno and adds it to `int64_t ira_reg_cost` and `ira_overall_cost`
(`ira.cc:421–423,2640–2672`); promotion occurs for the compound assignment.
Any prefix sum is bounded in absolute value by:

```text
A * 131070000 = 524280000*C
```

The new explicit guard is `524280000*C<=INT64_MAX`. It is implied by the
inherited signed allocno-count guard, but recorded independently to bind the
actual aggregate client and its type. Memory cost, load/store/shuffle cost,
move-loop and additional-jump totals stay zero. Copying overall cost to
`overall_cost_before` is safe. A 64-bit sum is never used to excuse an earlier
overflow in its int term.

## API, evidence and remaining obligations

`arithmetic(C,N)` rejects non-integer/bool or out-of-domain counts, and
otherwise returns unbounded mathematical values, 27 local numeric checks,
two inherited point/ID checks and `failed_predicates`.
`conditional_selected_IRA_numeric_arithmetic` is their conjunction; failure
is represented by false predicates rather than narrowing. The separate LRA
`10000C<=INT_MAX` guard remains separately exposed and owned by its accepted
packet. The new conjunction can pass where that LRA guard fails; an actual
source adapter must preserve both.

The new checker passed **111 checks** in **0.09544452698901296 seconds** on
Linux 7.0.14 x86_64. It covered all 1000 legal IRA frequencies, 20000 raw
candidate corners, priority normalization before division, adversarial
overlapping pressure updates (including an old timestamp with a group near
INT_MAX), 13 C/N cases, exact aggregate boundaries, invalid domains and
source/coordinate/operative-fragment mutations. It verified 29 GCC and 18
repository byte pins and 39 literal-LF excerpts. The fixed Hello reconciliation
preserves the old storage owners and 47054 GGC events. No predecessor module
was executed and no actual-source adapter was created.

This closes the specified arithmetic residual of the accepted IRA storage
packet conditionally on the inherited route. The following remain distinct:

| Obligation | Concrete next client |
| --- | --- |
| Outer IRA helper lifetime/capacity and any associated unjoined counts | `ira_reg_equiv`/`reg_equivs`, `reginfo.cc` init/resize, `regstat.cc` n-set/ref and RI arrays; transfer K and the single-definition/use counts into their actual caller growth rules. |
| Remaining LRA numeric/helper obligations | Instruction/register/assignment/elimination/CFG helper interfaces identified in the accepted storage note; preserve the separate signed hard-register usage guard and established two-constraint-iteration schedule. |
| Actual-source integration | Bind complete counts, source/configuration and storage prerequisites before applying this API; preserve failed/null prerequisites and exact older owner projections. |
| Universal correspondence and whole native capacity | The source argument is handwritten and does not close other compiler phases, all target-mode initialization, physical allocation failure assumptions, or the whole literal pipeline. |

No native compiler/build/capture, solver/prover, predecessor checker/evaluator,
aggregate suite or corpus replay ran. No GGC/finalizer/bitmap/ET owner was
recharged, and there is no aggregate RAM gate. Selected model: GPT-6 Astra /
Extra High; runtime confirmation and token/cost measurements are unavailable.
The [round record](../evidence/retained-literal-ira-numeric-20261019/round.json)
records timing, achieved scope and review status. Parent owns independent
review, integration, issue status and publication.
