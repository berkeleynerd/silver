# Independent review: selected literal IRA numeric arithmetic

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Frozen implementation: `9ed466e07f5db96f7240b33bb5055ba434deb192`;
base: `3be5bf4baba95ff007667f53182d115dca0bfd05`.

**Accept the conditional named IRA numeric subset; no material findings.**
The argument covers the stated cost/frequency/equivalence/preference,
excess-pressure, fast-priority and allocation-cost arithmetic on the accepted
DI call-group/O0 route. Its 27 local predicates and two inherited point/ID
predicates do not replace other storage, source/configuration or LRA
requirements. Actual-source integration and complete native capacity remain
open.

## Inputs and review record

Reviewed all eight changed files: the
[source argument](../research/retained-literal-ira-numeric.md) and complete
[seven-file packet](../evidence/retained-literal-ira-numeric-20261019/README.md),
including `derive.py`, `check.py`, manifest, retained results and round record.
The author worktree is `tmp/literal-ira-numeric-20261019`. The accepted storage
implementation is `66da47daa2c433a0872e8bbc626e0bb18850426e`, with exact review
`3d00f8af990f45a537f7854e8c898d5c222ee394`. The pinned output-RTL, storage,
shared-bitmap and GGC arguments supply the unchanged selected route and owner
premises. The previous ordinary-attachment review is not replayed or expanded
by this report.

Source was GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` in
`/tmp/silver-backend-compose-20261018/full-source`. Source inspection covered
the relevant frequency conversion, target DI memory/register cost hooks,
operand constraints and cost recording, reference creation, root-region cost
selection, equivalence/preference gates, pressure scan and callbacks, priority
construction/comparison, fast allocation and aggregate-cost clients. Reads
used literal LF positions. The accepted seven-instruction call-group and
no-spill arguments were reused for their unchanged inputs.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned. Runtime model
and effort confirmation, token usage and monetary cost are unavailable.
Inspection interval: **12:25:36–12:29:19 UTC**, **223 seconds** at one-second
resolution, excluding report preparation and commit. This is elapsed clock
time, not measured model compute time. Host: Linux 7.0.14 x86_64.

## Cost and frequency operations before saturation

`regs.h:125–138` distinguishes IRA's **1000** frequency unit from LRA's
10000. The profile-count conversion clamps to the fixed probability maximum
and returns 0..10000; rescaling therefore multiplies at most 10000 by 1000
before division, and replaces a zero result with one. Each selected pseudo
has exactly one definition and one use in the pattern traversal. The source
initializes NREFS/frequency to zero and visits PATTERN, so two references and
a frequency sum at most 2000 suffice without a C-dependent accumulation.
No pseudo is live at a call, so the call-frequency/crossing and live-object
ABI-update loop contributes nothing for these allocnos.

The selected generic DI hooks support memory costs at most 100 and positive
register costs at most 65535; may-move tables may independently contain zero.
DI occupies one word. The non-fitting register-table fallback computes at
most `(100+100)*2` or selects the 65535 sentinel; target/subclass maxima do not
overflow the stored table. NO_REGS receives a valid memory-cost minimum.
For a plain DI symbol, secondary reload returns NO_REGS without an extra
cost or recursive copy; `copy_cost` consequently fits the stated 0..100
ceiling. RDI/RSI's natural and operand modes both occupy eight bytes, keeping
the hard-move factor one. This review does not promote those DI facts into
a proof of initialization for every machine mode.

The two movdi constraints have 28 alternatives, no matching, commutative,
in/out or early-clobber modifier, and at most two question-mark penalties
per alternative. At most one other symbol operand incurs a copy cost. The
sole O0 cost pass has null preferred-class input during scanning. Thus the
raw class candidate is at most **65,639,000** and the raw memory candidate
at most **204,000**, before either `MIN` expression in
`ira-costs.cc:1051–1080`. Scale is one. Memory discounts subtract only the
0/1 allows-memory flag from a positive primitive, and the NO_REGS branch
uses frequency directly. The generic stored costs start at 1,000,000 and
are minimized; the direct hard-register shortcut instead has class interval
`[-1000,65535000]` and nonnegative memory cost at most 100000.

Accumulating the two contributions gives class **[-2000,131070000]** and
memory **[0,2000000]**. Both the additions and the positive-addend
`INT_MAX-add_cost` tests fit before the saturation decision. The selected
source has no REG_EQUIV memory-load or pseudo-address path introducing an
unaccounted negative saving. Root-region aggregation adds only one allocno
to zero. The best-cost sentinel exceeds this interval; the accepted eligible
general-register class argument ensures selection reaches a bounded cost,
and tie maxima preserve it.

The equivalence-gain pass requires pass 1, while the only O0 pass is zero;
gain storage stays zero. `update_equiv_regs` finds no incoming equivalence
note and skips new replacements at `!optimize`. For a singleton preference,
the numerator subtraction has absolute bound **131,072,000 before division**.
The divisor is the positive register table, at least two, rather than a
possibly-zero may-move table. Positive stored frequency is at most 65,536,000.
There is only one creation attempt per allocno in the sole cost pass, prefs
start empty, and the other creators are excluded by the accepted route.
The existing-record `pref->freq += freq` branch is therefore absent here.
The separate alternative-rejection budget of 24 and 0..27 bit indices fit.

## Pressure argument

The decisive relation is present in `ira-lives.cc:154–160`:
`start=max(high_pressure_start_point[cl], object_range->start)` precedes
`excess += curr_point-start+1`. A saved class threshold can predate the
current group. It is clipped to this object's range start, so its old age
does not enter the summand.

The accepted group has four unique whole-DI pseudos, each used and defined
once. The reverse scan opens and closes their ranges within that same
seven-instruction group. Reusing an adjacent range cannot import a range
from another group because that pseudo does not occur there. The updater
is reached for a live object through `dec_register_pressure` or for the
object's own just-finished range through `make_object_dead`. The object is
absent before/after its group and from block-boundary live-object cleanup.
The selected constraints exclude the pseudo-conflict helper that could
advance the point additionally; the ordinary scan has two increments per
instruction. Consequently the difference is at most 14 and each positive
summand at most **15**, including an old threshold and a group near INT_MAX.
The inherited P+1 guard separately protects absolute point fields and their
successor arithmetic.

The callback multiplicity is conservative and source-backed. An ordinary
definition-death scan can clear at most 92 hard live bits, and the distinct
MUST_CLOBBER live/dead scan can clear them again. Each clear guards on the
live bit, decrements once and clears it, so duplicate DF references do not
repeat a decrement in that scan. Call MAY_CLOBBER definitions are filtered;
counting all 92 twice still covers the selected behavior. Allowing four
pseudo deaths per instruction covers the group's pseudo decrements. Each
decrement can traverse the live-object sparse set only once, even when
several pressure classes cross their threshold. The object's direct death
update is counted separately from its decrement callback.

This yields `7*(2*92+4+1)=1323` updater calls per object. The superclass
list is duplicate-free because its constructor considers each class once,
so each updater contributes at most 34 summands. Repeated overlapping
intervals are deliberately counted repeatedly:
**1323*34*15 = 674730**, below INT_MAX. The proof requires neither zero
pressure, disjoint intervals nor a group-entry timestamp reset. One object
per allocno and the absence of region propagation prevent a later sum of
other objects' pressure totals.

Current pressure counts also fit: at most 92 hard live bits plus four
one-word group pseudos give 0..96 per class. Initialization excludes
eliminable/no-allocation hard registers and uses the same class translation
as later updates on the remaining registers. Live-bit and sparse-set guards
balance increments/decrements; parent pressure propagation takes maxima.
This establishes the arithmetic without relying on an exact pressure-class
partition.

## Priorities, aggregates and scope

The subtraction in `setup_allocno_priorities` precedes checked multiplication.
Its interval is **[-131070000,2002000]**. NREFS gives a logarithmic multiplier
at most two, and DI width is one, so the first product is
**[-262140000,4004000]**. Neither overflow handling nor saturation is needed,
and negating its negative values cannot encounter INT_MIN.

For the second loop, let Q be the maximum absolute first priority. If Q=0,
all stored priorities are zero. Otherwise the source chooses
`t=floor(INT_MAX/Q)`, so `abs(q*t)<=Q*t<=INT_MAX` for every stored q. This
justifies the multiplication **before division**, including negative q.
Pressure length is replaced by one when nonpositive; its divisor lies in
1..674730. The comparator uses `SORTGT` for priorities, avoiding subtraction
of potentially opposite signed endpoints. Its boolean difference is bounded
by one and its allocno-ID subtraction by A−1 under the inherited ID guard.
The two unconditional-true algebraic fields in the Python model rely on
these reviewed arguments; finite normalization samples alone do not prove them.

The accepted fast route assigns every allocno a hard register with null
hard-cost vectors. `calculate_allocation_cost` adds one bounded class cost
per allocno into the declared `int64_t` totals, so every prefix sum is bounded
in absolute value by **4C*131070000 = 524280000C**. This guard is implied by
the inherited signed allocno-count bound but is usefully explicit for the
actual aggregate client. `ira_emit(false)` returns before shuffle updates;
the other recorded totals remain zero. The wider total type does not excuse
any earlier int expression.

`arithmetic(C,N)` preserves mathematical values and failed guards, rejecting
invalid domains including booleans. The separate LRA `10000C` guard can fail
while this numeric conjunction passes; it must remain separate in a future
actual-source attachment. The fixed Hello reconciliation binds complete
counts and old extents and retains 47,054 GGC events only for that input.
It is not an actual-source adapter and modifies no earlier owner. GGC,
scalar/array finalizer and shared bitmap/ET deltas remain zero.

Outer IRA/equivalence/initial-value/reginfo/regstat helper capacity, remaining
LRA arithmetic/helpers, other native helper/stack and producer/proof/parent
obligations, universal correspondence and full-current-grammar #119 capacity
remain open. No aggregate RAM gate, production admission, toolchain or Oracle
change follows. Production #88–#94 remains unstarted.

## Evidence

Independent read/hash/record/arithmetic checks passed in
**0.14374063900322653 seconds**. They verified all **29 GCC and 18 repository
pins**, compared the 18 repository inputs with their base Git bytes, and
checked storage/review records against the named accepted commits. All **39
literal-LF coordinate/text/operative-fragment checks**, three recorded checker
input identities, two Python syntax trees and four JSON records passed.
Unlike the older storage excerpt erratum, these new coordinates actually
select their retained texts. Semantic coverage was assessed by the source
inspection above, not inferred from fragment presence.

Independent integer calculations matched the cost/preference/pressure/priority
envelopes, all 13 retained count-case failure lists, the separate LRA guard,
and the last-safe/first-failing aggregate boundary at
**C=17,592,454,483 / 17,592,454,484**. The inherited point boundary at C=1
is **N=178,956,965 / 178,956,966**. Hello's source identity, complete counts,
storage extents, GGC ownership and zero/false scope fields matched.

Reused the inspected author success: **111 checks in
0.09544452698901296 seconds**, including all 1000 IRA frequencies, 20000 raw
candidate corners, 61497 priority-normalization cases, nine adversarial
overlapping-pressure samples and 13 C/N cases. These test the arithmetic
model and source checks; they do not replace the handwritten reachability
and lifetime argument. No packet module, Context/evaluator/checker, native
compiler/tool, build, capture, solver/prover/Lean, census, aggregate suite or
corpus replay ran in this review. No implementation rework is required.

Only this report is committed, from
`tmp/review-literal-ira-numeric-9ed466e07f`. The subthread's live harness goal
was null. No issue, root index, session memory or CLI memory changed; the lead
owns integration and publication. `git diff --cached --check` passed before
the report commit.
