# Independent review: residual metadata and outcome interface

2026-10-20 UTC, Round 53; bounded continuation of #119 / #153.

**Accepted:** the negative metadata audit, acquisition rationale, all five J12
metadata/raw-graph captures, corrected conditional outcome protocol and direct
stock launch-diagnostic bounds. Ordered
residual producer transfer remains open. This checkpoint does not close the
parallel family, report-leaf attribution, full capacity rule or either issue.

## Review setting and exact inputs

Reviewer `/root/quiet_output_review` was selected as GPT-6 Astra / Extra High.
Runtime model/effort confirmation and token/cost telemetry are unavailable.
The actual host is Linux x86_64. The reviewer authored none of the inputs,
spawned no agents and ran no native target, solver, compiler, proof, capture or
predecessor checker. Parent integration, GitHub, memory and harness writes
remain outside this review's ownership.

The worktree is `tmp/quiet-output-review`, branch
`review/quiet-output-20261020`. The accepted R52 reviewer commit is
`c27f59754a9643acdcbb5b55cf8a0b77cbda0cd8`; the parent integrated it as
`d0a529ac0e866f8332cd46a3cb635d3d9c57684b`. R51/R52 evidence remains unchanged
and is reused without replay. The first retained R53 clock is 21:15:52 UTC.

| Component | Author freeze | Reviewer import |
| --- | --- | --- |
| Negative metadata coverage and acquisition specification | `0e7ce6ea890055ae30245a0f25406b8566d5e670` | `bb59486cb886e2f0e58c76feecccd3808e7223e1` |
| First-domain metadata acquisition | `f9c0b08b51be5c03657ab977eda63b3f99a2b3c5` | `37fab087faa691c080c84307c8bb422c02dcc3a3` |
| Initial outcome interface | `fbc95b00cb66a239a84e88bdddb20bb2056ecf38` | `089c49a2f4c549499cafbdd089e4bd5618712f06` |
| Direct stock launch diagnostics | `c12f036793f44f24c0b9a1d95996bf0b028d91f7` | `01dca2dd9899a76a65cb9188eee6dca1b2ae7a3c` |
| Outcome audit-seal correction | `3754303d5969b92364b4a19e356de6afc34f07ab` | `7cdad3702cb5ae783b77ce6e148dea6e1334186c` |
| Remaining-domain metadata acquisition | `d5ba99bdb0db48e062d327ec541f3647cec385a8` | `9d168f53a18fcc0b45cc5ba30bc474f7f613ba24` |
| Historical first-domain wording | `43bbaf6805d7dc10269f9efe1b2394663bf0feee` | `3af18711fe8c5a64a5305373bed74d45ac70815e` |

The [review packet](../evidence/retained-metadata-outcome-interface-review-20261020/README.md)
retains exact input hashes, source excerpts, command output and observed time.
The metadata and outcome authors were selected as GPT-6 Astra / Extra High.
The parent-owned launch work reports the project's Astra / Extra High baseline;
actual lead selection/runtime confirmation is unavailable. These are not
runtime-confirmed telemetry or a model comparison.

## Missing retained metadata

The audit visits the retained raw task chains, decodes every Meta node and Use
node, then checks each Meta record, non-immediate argument-list root and Use
theory root against every retained memory-read interval. The checked window
is `[pointer - 8, pointer + 40)`: the header and first forty payload bytes.
The reviewer checked the source constructor order (`Decl`, `Use`, `Clone`,
`Meta`), the Meta record fields and the audit's interval boundaries. Its
`bisect_right(lo - 40)` and `bisect_left(hi + 8)` filtering implements exactly
the strict overlap conditions; touching endpoints are correctly excluded.

All five archive sizes and SHA256 identities match the frozen specification.
An independent member inventory confirms that every `*memory-reads.jsonl`
member in those archives lies within its audited case prefix. The new focused
audit passed in **18.044 seconds**, reading **5,918,792 rows** and reproducing
the frozen zero-overlap results. No audited Meta record or argument-list root
is retained in `session-blocks.jsonl` either.

| Domain | Meta tdecls | Distinct Meta records | Distinct Use roots | Read rows |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 334 | 10 | 65 | 1,600,769 |
| Put | 334 | 10 | 65 | 1,469,491 |
| First_Or_Default | 132 | 9 | 54 | 1,039,410 |
| Is_Message | 96 | 9 | 23 | 840,069 |
| Input_Is_Valid | 110 | 9 | 34 | 969,053 |

This supports the stated absence of directly decodable root bytes. The audit
does not inspect Clone roots or driver metadata roots, search arbitrary
unreachable memory, or prove reconstruction impossible. Those stronger claims
are unnecessary: even the raw Meta names, types and physical argument payloads
are absent. Fixed sources alone do not supply the omitted parser/typing/clone
execution and physical-symbol correspondence. The older inlining result
quantifies the exclusion set instead of determining its actual members.

`Driver.update_task` folds the actual driver maps and task clone sets before
its transformation list; `Theory.clone_meta` depends on the local identifier
set and symbol maps, and can omit a Meta on `Not_found`. The acquisition spec
therefore requests ordered containers, typed Meta argument closure and the
selected Z3 driver, with logical graphs only for the physical-symbol join.
It is a focused new-input acquisition; a full Hsdecl recapture is not needed
to settle the demonstrated omission. The first domain contains all four
residual families. A specification is not evidence that the capture succeeded.

The spec preserves the registration endpoint and guards, uses one worker with
sequential targets and zero solvers, and leaves the process-wide two-callback,
three-save, `e <= 2` budget intact. Its recorded headroom is a snapshot; the
author must still check live resources at launch.

Introduction remains a separate obligation. Its private Hsdecl compares
prsymbol **name, attributes and location**, together with formula strict
equality; it does not require physical prsymbol equality. Attribute separation
can exclude a returned residual key only after every candidate path, including
the `Theory.MApr` reuse branch and returned representatives, is covered. The
spec appropriately defers initial Introduction-table acquisition while that
source/attribute argument is attempted. No all-fresh-head conclusion is
accepted at this checkpoint.

## First-domain capture

The new successful native run is First_Or_Default with client and server J=12,
stopped at registration. The author retains its 4.938-second managed run and
both earlier failures. The first failure copied the extra configuration into
the base configuration slot and stopped before registration; the second
reached registration but rejected the driver's set representation. Their
reported native durations are 0.354 and 4.082 seconds. The successful archive
contains the exact `attempt-3-plan.json`; the separately named
`first-domain-plan.json` and headroom file are initial-attempt records.

The corrected projection follows actual task clone/meta histories, Meta typed
arguments and Use/Clone theory names, paths, local identifiers and symbol maps.
Controller field 3 supplies the prover table; driver field 8 supplies the
selected Z3 metadata. Source layouts and the selected thirteen transformation
names agree. `Task.mli` hides its implementation's `Stdecl` alias: task sets
use Patricia leaves/branches, whereas driver sets use `Theory.Stdecl`'s unit
AVL maps. The reviewer independently checked both layouts and their fold order.
The reader rejects missing or incompatible bytes; it does not treat an omitted
set as empty.

The independent audit verifies all **103 retained archive members**, successful
plan/collector identities, actual argv and environment, mapped executable,
read-file identities, endpoint controls and forbidden-call counters. It then
replays the new typed reader from retained reads. All **nine projection files**
match exactly: 322,796 rows, 134,646 distinct reads and 322,784 replay requests.
The reader reports 4.602 seconds; the full independent audit took 7.062 seconds,
including archive checks and correspondence. No native target or predecessor
checker was rerun.

The reviewer checks the frozen address map as a relation, independently of the
author's stack-walk construction: it is injective, every stored field edge
commutes, immediate operands match, and opaque payload bytes agree. All 334
raw declarations across 33 task chains attach to the relation. Its **42,481
blocks** preserve physical sharing and **48,769 immediate edges** match.
This establishes the relevant raw logical graph relation, not equality of
unobserved mutable global tables, entire task allocations or arbitrary J>1
launches.

The completed projection has 22 Meta records and 66 selected-driver theory
metadata entries. `introduced_prsymbol` is absent from this captured raw/driver
domain. This does not yet establish absence after every producer or finish the
Introduction return-key argument. Complete Hsdecl and initial Introduction
table captures remain absent by design.

There are zero protected guard, preparation and solver entries. Four inherited
startup GC observations occur before protection starts; they are retained and
must not be described as zero startup activity. The successful managed launch
has its own fresh headroom record. A later `/tmp` capacity failure during
review is unrelated to capture correctness: the overlay was full while the
repository filesystem had free space. An automatically cleaned temporary
directory on that filesystem allowed replay to finish.

Reviewer rework is retained explicitly: the first independent checker assumed
the plan had an `executable` key and stopped before replay. It was corrected to
use the observed argv, plan identity map and acquisition specification. The
next invocation hit `/tmp` exhaustion, also before replay. Both failure logs
remain; no successful reader replay was duplicated.

## All-domain capture attachment

The remaining four captures pass the same independently checked source layouts,
controls, exact nine-file reader replay and edge-by-edge sharing relation. Their
new manifest accounts for **186 archive members**. The four-domain audit took
**37.535 seconds**; successful First_Or_Default evidence was reused.

| Domain | Raw tasks | Declaration pairs | Bijective blocks | Equal immediates | Custom blocks | Reader replay seconds |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Input_Is_Valid | 5 | 248 | 16,106 | 17,833 | 0 | 2.389 |
| Put_Line | 65 | 638 | 115,020 | 142,849 | 7 | 11.367 |
| Put | 54 | 627 | 95,672 | 117,922 | 7 | 10.077 |
| Is_Message | 4 | 209 | 14,087 | 15,456 | 0 | 2.307 |

The seven custom blocks in each Put graph preserve executable-relative
operation pointers under the recorded old/new load biases, and their remaining
opaque words match exactly. Input's older capture has no symbol file or load
bias. Its joined graph contains no custom block, so the proof needs no invented
bias; the checker would reject a custom block without one. That older stop was
later than registration, but the immutable raw logical graphs match exactly.
The claim does not transfer mutable state from that later stop.

All selected driver metadata maps contain 66 theory entries, and no captured
raw/driver Meta record is named `introduced_prsymbol`. Every successful capture
has actual client/server J12, zero protected guard/preparation/solver entries,
and four retained startup GC observations. The reviewer inspected both managed
logs: each reserves one worker; the first completes Input and Put_Line, then
fails while creating Put's capture directory. The continuation launches only
the never-started Put and Is_Message. The post-batch records cover every
declared input in both plans with matching expected/actual identities; the
packager's rehash implementation was inspected. No successful native capture
was repeated. The author also clarifies the initial-attempt plan/headroom
aliases and protected/startup distinction requested during review.

Acquisition and raw-symbol correspondence are now closed for these five
captured J12 domains. Actual `Driver.update_task` evaluation, post-transform
monomorphism, ordered thirteen-key producer transfer, old returned
representatives/hidden saved maps and arbitrary intended parallel mutable-state
attachment remain open. No production adapter, Oracle amendment or admission
change is part of this review.

## Direct stock launch diagnostics

Author freeze `c12f036793f44f24c0b9a1d95996bf0b028d91f7` is accepted for its
explicit two-message scope under exact-libc, C-locale, noninterposed binding,
source/native correspondence and ordinary-service premises. The focused check
and independent comparison of all 92 disassembly byte rows to the ELF passed
in **0.096 seconds**. The reviewer inspected the native control flow, rather
than treating the table census alone as a universal bound on `strerror`.

The lookup rejects negative errors, bounds nonnegative indexes by the retained
count, and returns either a table pointer or null. The ELF's 134 slots have
payloads at most 49 bytes. RELR cursor/bitmap expansion and ordinary relative
RELA entries establish the selected pointer values. Null or out-of-range
errors take the alternate path: translated `Unknown error ` plus signed
32-bit decimal is at most 25 bytes under C-locale identity; failed formatting
falls back to the 13-byte string. The known/fallback paths restore the locale
and return through the inspected code. This is a manual native argument with
explicit library premises, not a machine-checked x86 theorem.

The C formats contain 38 and 23 fixed bytes. Thus process-group failure emits
at most **A + 87**, before redirection, and exec-return failure emits at most
**2*A + 72**, after redirection if that service succeeds. Each branch exits,
so they are mutually exclusive. The stdin diagnostic is excluded by the chosen
non-stdin route. The source does not justify treating failed redirection as
successful routing to the raw output file.

These bounds cover bytes from the explicit calls. They do not cover inherited
buffer flushes, exit hooks, fatal diagnostics, dynamic-loader messages or
adapter startup. Quarantining a raw file from semantic parsing does not bound
its storage. The packet correctly leaves complete startup/output `q` open.

## Corrected outcome interface

The initial outcome freeze is
`fbc95b00cb66a239a84e88bdddb20bb2056ecf38`. Its 42 source slices and 9,881
focused finite assertions passed in **0.278 seconds**. The reviewer invoked
the checker functions without running the entry point that rewrites author
`result.json`; all nine frozen author files still match. These finite examples
exercise the design and are not production refinement or a universal parser
proof. The accepted R51 recognizer and R52 configuration are reused, not rerun.

The source supports request-ID delivery to the actual Why3 attempt under
uniqueness/no-wrap and private-channel/runtime premises. A queued cancellation
returns ordinary-looking F0 with no S and an empty filename, so F0 alone cannot
witness launch. The design requires S, a nonempty launched F0, one exact
64-byte control record followed by EOF, and a newly created fully written,
successfully closed immutable canonical file before publication. The child
pipe EOF and exact child wait status are distinct prerequisites. Adapter status
and child status remain separate; a complete source Valid answer is not erased
merely by a later child signal, while abnormal adapter completion cannot open
the gate. These distinctions address the partial `unsat` failure identified
in R51 without imposing a new timeout or attempt limit.

Two findings required a separate correction freeze before acceptance:

1. A duplicate control connection can be queued when the first record/F0 releases
   V and Why3 finishes. The proxy must seal its final protocol audit after all
   producers and writers are terminal and pending streams/backlog are validated,
   then deliver its complete monotonic defect ledger. Why3 report completion
   alone cannot exclude a late-discovered protocol defect.
2. The finite decoder's structural bounds admit values such as signal 200 or
   an oversized PID. Those are not established selected-Linux ABI facts. Its
   claim must distinguish structural schema checks from native decoding/range
   obligations on the future verified producer/refinement.

Both findings were accepted by the author and parent. Correction freeze
`3754303d5969b92364b4a19e356de6afc34f07ab` closes them at the design's stated
conditional scope. The seal orders request/queued-launch closure, reconciliation
of every admitted request, adapter termination and control-writer closure,
accept-backlog/stream draining to EOF, listener shutdown, response/ledger
reconciliation, and complete supervisor receipt plus ordinary successful proxy
completion. The argument explicitly requires source/refinement proof that no
future connector or writer can appear; idle time is not evidence of closure.
The new finite cases cover report-before-duplicate and each missing barrier.

The amended checker names `decode_structure` accurately and adds a separately
required `native_fact_ok` gate. It does not claim to compute that ABI predicate.
The amended focused run passed **9,898 assertions and 42 source slices in
0.265 seconds**. This new run is justified by the changed gate/seal model; it
does not replay R51/R52 or a native target. All five amendment files match the
new freeze, and the original result is retained as history. The conditional
protocol argument is accepted; production SPARK/native refinement remains
prospective work.

The missing report-leaf relation is real at this scope. Internal request-to-
attempt binding does not make that key externally observable in final JSON.
Automatic debug-save-vcs paths are not passed as `graft_proof_attempt ~file`,
so the fresh automatic session `proof_script` remains absent. Unknown's payload
can carry the proposed bounded ticket, but H's fixed payload and payload-free
M/S/T/V do not supply an equivalent unchanged-kind channel. A uniform cohort
with independently established cause and coverage can support attribution;
mixed resource/unexplained H assignments across proved and unproved goals
remain ambiguous. The proposed source-hook fields identify missing information
and are explicitly unavailable under the unchanged-tools constraint.

The AND/OR goal-tree policy preserves unsuccessful losers below proved goals,
while independent defects keep precedence. Earlier relevant failures cannot be
erased merely by overwriting the current prover slot. The report also preserves
the corrected warning fact: top-level Why3 warnings are printed by SPARK and
do not establish `.spark` `warn_error` rejection. No new warning policy is
inferred. Symbolic storage correctly distinguishes outstanding K and control
connections H from active adapters J; it does not claim a native layout,
request-ID no-wrap bound, completed LeafMap or complete capacity rule.

## Final validation and disposition

The final reviewed input is
`3af18711fe8c5a64a5305373bed74d45ac70815e`. The last amendment changes only the
historical acquisition-status wording; it requires no evidence replay. All
109 versioned manifest entries, spanning 99 distinct direct input paths, match
their exact author-commit bytes. Referenced source/native identities were also
checked by the focused packet checks; these counts are not a claim to enumerate
every transitive runtime input.

| New focused check | Observed seconds | Result |
| --- | ---: | --- |
| Negative metadata coverage | 18.044 | Pass |
| First-domain archive/control, reader and bijection audit | 7.062 | Pass |
| Four remaining-domain audits | 37.535 | Pass |
| Initial outcome model/source checks | 0.278 | Pass; two review findings subsequently corrected |
| Corrected outcome model/source checks | 0.265 | Pass |
| Direct launch source/ELF and disassembly-byte check | 0.096 | Pass |

Reader times reported earlier are included in their enclosing audit times;
they must not be added again. The reviewer accepted this bounded batch at
21:39:32 UTC, **1,420.231 seconds** after the first retained R53 clock. This is
an observed review interval, not total team work or native execution time.
Per-component token/cost telemetry is unavailable. The packet retains the
material review changes and two pre-replay reviewer failures rather than
silently relabeling them as first-pass success.

The missing metadata input has been acquired and attached for all five captured
J12 domains. The final audit-seal race and structural/native validation claim
are corrected in the conditional interface design. Direct launch diagnostics
now have their scoped terms. The remaining producer, parallel-state,
report-leaf, native-refinement and complete-output/capacity obligations remain
explicit; none is discharged by these finite acquisitions or protocol examples.
Parent integration/publication and issue bookkeeping remain separate.
