# R54 review: parallel representatives, attribution and completion fields

2026-10-20 UTC; independent bounded review for #119 / #153 on Linux x86_64.
**Accept the three frozen results at their stated conditional scopes.** The
completion-source clarification below was repaired before acceptance. None of
these results establishes the prospective parallel/logging startup state or
whole-rule capacity. Production remains unstarted; this is not approval to
change the Oracle, tools, admission, solver limits or the draft PR's status.

Reviewer selected model/effort: **GPT-6 Astra / Extra High**. Runtime confirmation
and token/cost telemetry were unavailable. This subthread used no subagents.
The [review packet](../evidence/retained-parallel-attribution-completion-review-20261020/README.md)
retains exact inputs, one focused check per component, observed timings and
supplemental source excerpts. R53 evidence is reused, not replayed.

## Frozen inputs and validation

| Component | Exact author freeze | Local review import |
| --- | --- | --- |
| Completion initial | `e8b08def7914fda139abe85f9c28650bf401d2dc` | `ccdbf7fd29c41db9cb26dd040e0c0ae7fdda362e` |
| Completion repaired | `c5c854f2706c4fb0f0216372d791bb33679866a4` | `ef83dced84d1830d3e09102cc9c53699bcdd7780` |
| Metadata/symbol exclusion | `f9141bc8f620333c02526f13b2ac5f2e573b8942` | `29d2ce87448132216220a50654d3bc9b00312dcd` |
| Fixed-goal attribution | `149cf729e952fbb537768caa32c898a8843933ed` | `019067291d3b84fbaf3ee42327c8910d6dfdd4e6` |

R53 reviewer base is `86ce9851689c5a8fd93218abc839fca98eea5209`; its published
integration is `8044180011293f59bb4c17b28edf3891ece0a248`. The input manifest
identifies exact current files and verifies author-owned paths against the
specified freezes. These identities do not make the source arguments formal
proofs or establish installed kernel correspondence.

| Focused check | Result | Observed subprocess elapsed |
| --- | --- | ---: |
| Completion | 19 retained kernel files; 13 boundary cases; native byte identities; arithmetic | 0.124 s |
| Exclusion | 28 repository inputs; 21 source files / 46 excerpts; ten exact regenerated files; all 13 keys | 4.842 s |
| Attribution | 378 counted assertions plus internal graph/layout checks; 48 source slices; 118 roots | 6.584 s |

All passed. Author packet bytes remained unchanged. The exclusion check's
summary write and temporary-directory root were redirected into the reviewer
packet; its computation and exact-output comparisons were unchanged. No native
target, capture, compiler, solver, proof or broad predecessor replay ran. The
three subprocesses took 11.551 s in total; this is not the full review duration.

## Completion formatting: accepted after source clarification

The [completion note](../research/retained-server-completion-format.md) correctly
starts from **signed nanoseconds**, including INT64_MIN. The retained helper's
64-bit branch uses unsigned quotient/remainder. With the explicitly selected
wrap/conversion semantics, `-n-1` produces 2^63-1 at the minimum input and the
negative unsigned expression converts to the signed floor quotient. The helper's
remainder is below 10^9 and hence also representable in the signed `rem` object.
This gives seconds in [-9,223,372,037, 9,223,372,036] and microseconds in
[0,999999]. The generous binary64 rounding envelope and C-locale `%.6f` then
give at most **18 time bytes**, including sign and signed zero.

The selected exit fields need at most three decimal bytes. Counting the flag,
separators and LF gives **D+P+29 wire bytes**, while **D+P+31 allocated bytes**
leave room for NUL and one spare byte. The proposed caller guard
`D+P+31 <= INT_MAX` prevents the relevant length arithmetic overflow and makes
negative `snprintf` results fail the source's unsigned comparison. Under the
separate positive/no-wrap request-ID premise, D<=19 gives **B_F<=P+48**.

The original packet omitted the selected `div_u64_rem` definition and did not
separate flag presence from compilation semantics clearly enough. The repaired
freeze supplies the direct helper and width headers, and names CONFIG_64BIT,
signed wrapping, unsigned modulo and low-bit-preserving u64-to-s64 conversions
as interface premises. The Makefile flag does not prove those semantics or the
running kernel's build. The retained libc disassembly/bytes support the ordinary
single-thread syscall route without rusage rewriting; the trusted OS/service
and selected-source correspondence premises remain explicit.

The signed64-**seconds** counterexample is material: its formatted field needs
26 bytes, so a generic rusage representation would not justify this allocation.
Neither observed short solver times nor a matching kernel release string closes
that gap. P, request-counter no-wrap, queue storage and whole q are not supplied
by this acceptance.

## Thirteen residual keys: accepted producer exclusion

The [exclusion note](../research/retained-why-parallel-symbol-exclusion.md) now
closes R52's finite producer obligation under its inherited input/ownership,
valid-cache, freshness and initial-table premises. The review checked actual
Driver.update_task ordering, clone argument mapping and exclusive replacement;
Task.HStdecl's Patricia fold is distinct from Theory.Stdecl's AVL fold. The
actual two MAty arguments per domain use the retained type translation rules;
no actual MAid argument requires an unmodeled generic equality case. Metadata
addition does not itself synthesize logical axioms. R53's physical graph joins
supply symbol identity; names are only labels.

Every residual CE candidate visibly contains its certified marker: five
`index_I1_one`, five integer `>`, two result invariants for argument-count, and
one result invariant for argument-post. The selected definitions precede their
uses, are nonrecursive singleton Dlogic entries and are outside actual
`inline:no`. The argument dependency's conjunction stays ineligible while the
application bodies inline. Actual full stored closures lack `inline:trivial`;
this absence is needed because strict equality alone would not justify an
attribute claim about an old delayed replacement.

The monomorphism derivation is concrete. Put/Put_Line's remaining `acc` and
`well_founded` component has only the identified incoming declarations; the
four incoming axioms are removed, and neither the keep set nor builtin seeds
reach it. Internal deferred dependencies cannot seed themselves. Surviving
ignored signatures retain their ignore metadata. Therefore the selected
algebraic branch is compile-match/projection-sums, and the final discrimination
and encoding passes are identities.

The critical invariant is **visible physical-symbol absence**, following
Term.descend's bound-before-saved and remaining-outer-frame semantics. Strict
equality preserves that invariant even when a returned representative has extra
unused saved entries. Valid opening, closing and substitution cannot activate a
dead entry as a new application; bound-variable replacement and free-variable
restriction/composition matter here. This is not a bound on hidden saved storage.

The ordered review covered every same-key constructor prefix, including earlier
insertions in preparations that later fail. Literal/environment helpers are
accounted for; epsilon caches return their earlier fresh closure symbols;
projection/pattern paths cannot introduce these nonconstructor/nonprojection
markers. Introduction needed a separate argument: no introduced_prsymbol meta
is present, generated heads have `{introduced}`, and residual heads have `{}`
or `{useraxiom}`. Its private name/attrs/location/formula Hsdecl and Wdecl queues
therefore cannot return a residual head. Fresh prsymbol creation alone would
not have been sufficient.

Before a completed CE memo fill, CVC5/Alt-Ergo cannot run their downstream stages
for that context; their partial CE insertions stay in the deterministic candidate
family. Z3 now supplies no compatible foreign representation. After a successful
fill, R51's strongly live raw key and ephemeron memo result protect the selected
representative, including forced misses while the prior result remains live.
Thus the thirteen families join the 660 raw-protected and two Ttrue keys:
**675 fixed context Paxiom keys** under the stated premises. Their retained
stored envelopes remain concat 78/2/6, bool-reverse 52/2/0, argument-count
16/2/0, and argument-post 35/3/0 (terms/binders/saved entries).

Input's old table cut is after its first CE call; its three compatible objects
are CE-produced and are not mislabeled registration state. R53's five actual
J12 raw/metadata attachments are accepted evidence for those cuts. Neither
those observations nor this source induction attaches every mutable table to
an arbitrary parallel or logging launch.

## Goal and completion attribution: accepted conditional association

The [attribution note](../research/retained-fixed-goal-attribution.md) derives an
injective finite map on **118 registered roots, 116 nontrivial, in 47 checks**
from 161 captured forest nodes. Its 6,747 checked binder records support the
restricted variable-only alpha-opening lemma: typed variable images cannot
replace an untyped formula root; nonvariable reconstruction preserves the
searched constructor and attributes. It does not substitute a general binder
model for Why3. Per-attribute-set loop-invariant correction, already-proved
filtering and trivial labeled roots agree with the selected registration source.
Ordered GoalSet traversal followed by prepending gives descending goal ID within
each check. The ordinary fresh Per_Check route preserves that root set after
establishment; the prospective startup transfer is still missing.

The concrete Is_Message collision defeats name/location attribution: roots
2 and 1 share the same physical proposition, identifier, name, location and
check label, but occupy root indices 0 and 1. Full prepared payload equality or
inequality is not established by this collision, and no digest injectivity is
assumed.

The S→Running route fails because blocking fetch discards Started. The proposed
one-unacknowledged-F route survives source review: saved_data and controller
closures bind the original request to the exact goal/prover; the one-F gate
removes the otherwise unsafe multi-result sorting permutation. Interrupts do
not remove ordinary outstanding calls. The parallel GNAT callback logs before
testing `remaining=0`, so losing completions still log Done. Local unsent
cancellations log Interrupted; queued backend cancellations produce F/Done.
Trivial proofs and already-proved shortcuts are not independent Done producers
in the stated fresh, noninteractive, nonreplay, CE-off route.

The fresh formatter does have an initially unknown system box, so channel flush
alone is insufficient. Here every Done JSON has at least **91 bytes**, exceeding
the initial margin **78**. The selected serializer emits known-size text tokens
only. Once advance_left processes the system box, it drains those tokens before
raw LF and channel flush. This accepts visibility of complete successful Done
lines, not completeness of short Scheduled/other status records. The finite
protocol checker exercises examples; the request-to-callback and formatter
claims remain reviewed source arguments under their stated I/O/runtime premises.

Fresh exclusive file identity, complete parsing, no-wrap request IDs,
exactly-once delivery and event-loop/termination progress are essential. A goal
that is merely in range does not authenticate a forged log. After associations,
normal confirmation still requires the R53 seal plus normal writer termination,
final same-file EOF draining and reconciliation of extra Done or partial records.
Live-file EOF is not closure. All mapped attempt history must be retained;
a later resource result cannot erase an earlier relevant Unknown/failure, and a
Valid winner does not erase an independent identity/protocol defect.

## Remaining integration obligations

The accepted pieces reduce distinct obligations; they do not close #119 or #153.
The prospective `-j>1 --logging` startup/registration forest and IDs, allocation
and mutable-table attachment still require their own source/runtime relation.
Complete LeafMap/grammar coverage, native outcome refinement, launch/startup and
failure-path coverage, P, request-ID no-wrap, aggregate log/history/response/
control storage and production/proof correspondence remain outside this review.
A single pending acknowledgment does not bound completed backend backlog by J.
No generic retry history is recovered from the final report or short status logs.

The two save-entering callbacks, three saves and e<=2 remain one global budget
per process. No reset per solver/stage, solver serialization, synthetic time
identity, output truncation, tool modification or observation-only exception is
approved. Parent integration owns issue, memory, harness and publication records.
