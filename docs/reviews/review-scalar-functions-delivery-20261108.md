# Scalar-function delivery review — bounded repair, 2026-11-08

The proposed outer-scanner assignment-flag repair has no material defect found
by this static review. It corrects a real mismatch with the existing native
source and predicate model. This is not delivery acceptance: the patch has not
been applied or kernel-checked at this review checkpoint, and complete native,
Lean/source and regression validation remain pending.

## Target and authority

The review target is integration `6358ab866e169c1ae91f546381f92e8366ed66a7`
plus its prepared `tmp/predicate-function-assignment-flag.patch`, SHA-256
`f31ad8d9001095122035cbb7907edeb7af3675ab73d9f97149375818a39ab02f`.
The integration has unchanged `proof/`, `src/` and `scripts/` inputs relative
to `eb72b5217e`. The native snapshot is `9469d5632b`; the inspected
`src/silver_output_profile.adb` has SHA-256
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.

The [owner authorization](../session-memory.md#2026-11-07--small-nonrecursive-functions-selected)
selects [#298](https://github.com/berkeleynerd/silver/issues/298) through
reviewable publication in [PR #339](https://github.com/berkeleynerd/silver/pull/339).
Implementation merge remains held. This subthread owns only this report in a
separate review worktree. It has made no implementation edits or external
publication and launched no proof, build or test run.

The review applies the [Oracle](../../oracle.md),
[development requirements](../../development.md#proof-loop-and-validation),
[function rules](../../language.md#small-nonrecursive-scalar-functions),
[function plan](../scalar-functions.md),
[assurance argument](../assurance.md#small-nonrecursive-scalar-functions) and
[trusted boundary](../trusted-boundary.md#small-scalar-function-boundary).
The existing native-admission, capacity and #340 raw-source reviews retain their
separate scopes; this review does not repeat or supersede them.

## Finding and proposed resolution

The retained focused-run log for `20261107T230910-a15a07ea6dd4` reports
`PredicateOuterEquations.lean:64` failing `rfl`: its interpreted helper step
retains only `scan.assigned`, whereas `Predicate.scanStep` also includes
assignments discovered in functions. This prevents the required correspondence
proof from completing; it is not evidence of unsafe native admission.

The three-file patch is the minimal source-faithful repair:

- [PredicateOuterExpressions](../../proof/Silver/PredicateOuterExpressions.lean)
  computes the helper's next parser state once, then returns that state with
  `assigned := scan.assigned || next.assignedInFunctions`. This agrees with
  native `Scan_Step` at `silver_output_profile.adb:5865` and
  [Predicate.scanStep](../../proof/Silver/PredicateBodyAdmission.lean). It
  preserves previous assignments and output, including when Main itself has
  no assignment. The function flag already accumulates local-body assignments
  in [PredicateFunctionFlags](../../proof/Silver/PredicateFunctionFlags.lean).
- The same expression's rendering and
  [candidate](../../proof/Silver/PredicateOuterCandidates.lean) reproduce the
  native `declare Next : constant Parser_State := Step (...); begin ...`
  expression, including the `Assigned` delta. Within the outer expression
  language, `scanStepBody` is the sole constructed use of `helperStep`.
- [PredicateOuterEquations](../../proof/Silver/PredicateOuterEquations.lean)
  changes only the helper-case proof term to this result. Its existing
  `helpers.step` equality supplies the complete next parser state. The theorem
  statement, helper meaning, native readiness domain and contracts stay intact;
  the statement-body branch is unchanged. No input restriction, assumed
  assignment invariant, obligation suppression or authored contract is added.

## Evidence limits and handoff

The scratch `prepared-outer-candidate-check.json` records lexical occurrences
only. The required stronger check remains
`PredicateBodySourceCandidate.candidate_scan_step_body`, which extracts the
named `scan_step` body from authoritative `SourceShape.bodyTokens` and checks
equality to the rendered expression in the kernel. Rendering equality,
`interpreted_scanStep`, the concrete outer model and their actual-source
consumers must all compile on the applied patch. A matching pin or lexical
occurrence alone cannot close this finding.

The coordinator should preserve the active focused run and its completed source
objects before applying the patch, then check the changed outer modules and
source-dependent consumers. Complete native obligation coverage/audit, complete
Lean source correspondence with fresh module/axiom audit, and complete applicable
regression coverage remain mandatory for delivery. The current native run
`20261107T231059-a9f0c12c8350` is pending, and this bounded review does not assess
its eventual outcome. No delivery-ready or support-completion claim is made.

Selected reviewer configuration: GPT-6 Astra / Extra High. Independent runtime
model/effort telemetry and token/cost measurements are unavailable; none are
inferred from configured defaults. The inspected host is Linux 7.0.14 x86_64,
and `scripts/dev.py paths` reports `linux-x86_64`. The live harness goal is null.
No CLI memory was updated. A later review needs the exact final target and its
completed evidence; this report alone does not accept that future target.

## Supplemental static review — Boolean context and report warnings

This second bounded review found no material defect in either additional repair.
Its targets are integration `454e99da25` plus the prepared two-file
`tmp/boolean-initializer-context-repair.patch`, SHA-256
`2b1d29146438835b8e2b3bcf87d87796af0cf1c25d4e2d721b42578afa26bdb2`, and
the separate native source-only commit
`560144172c3bcef4d831ab2c9a584cce40613c60`. Integration's `src/`, `proof/`
and `scripts/` still match `eb72b5217e`; the prepared Lean changes remain
unapplied while the frozen source check runs. The native commit changes only
`src/silver_library_reports.adb`, from SHA-256
`700e6fb94d4d722cb3d95a8c145c03bee44dd36a6384bb693772dd6bc8531459` to
`3254d7d3236cbaa689e61a4dc13478d29ab9cafe6cfdd5f0ba8b2ecff4d13b25`.
Both report hashes and the prepared patch digest were independently checked.

### Boolean context and proof domains

[ComposeBooleanDeclarationDomain](../../proof/Silver/ComposeBooleanDeclarationDomain.lean)
now copies `pure` and `integerHidden` in both `toNative` and `fromNative`.
Both context structures already contain these fields, both `.model` projections
use them, and the existing native/body adapter obtains them from parser state.
The repair therefore preserves all fifteen fields, including both values of
each Boolean flag, in the initializer and condition-reader equations. It does
not alter either context structure, the native source, the evaluator, or the
theorem statements and source-link hypotheses.

The readiness proof reassociates the existing conjunction and selects its first
fact, `newNameAllowed ... = true`. No readiness clause is removed. The tuple
patterns in this file and
[ComposeBooleanInitializerLibraries](../../proof/Silver/ComposeBooleanInitializerLibraries.lean)
now match all twelve conjuncts of `Compose.Expressions.ValidState`, selecting
the Boolean environment fact before the three existing function-metadata/formal
bounds. The caller still supplies the complete `OuterReadiness.ValidState`;
unused facts in this particular context proof are not removed from that domain.
`Native.ValidContext`, flow validity, masks, source-name bounds and imported
condition contracts remain unchanged. The observed constructor/projection
failures explain this repair, but its successful kernel compilation and
downstream source correspondence remain pending.

### Native cleanup and source-name matching

The complete diff of
[silver_library_reports.adb](../../src/silver_library_reports.adb) removes
`:= Unknown` from `Entity_Name`'s local `Result` declaration and removes `Source` from
six private profiles and 23 calls belonging to `Expected_Entity`,
`Expected_Coverage`, `Map_Policy`, `Advance_Map` and `Finish_Map`.
Every branch of `Entity_Name`'s complete conditional assigns `Result` before
the location check or return. The fallback still calls `Function_Name` with
the source and metadata, and the exact functional postcondition remains.

The two expected-policy expressions never inspect `Source`; the three map
helpers only passed it to these source-independent expressions and contracts.
The removed formal is an unconstrained `String` with no additional precondition,
and each removed actual is the existing variable `Source`. Removing those
actuals removes no effectful evaluation or domain check. The entity ranges,
required coverage strings, uniqueness predicates, map traversal, variants,
metadata and remaining pre/postconditions retain their meaning.

Source-dependent resolution remains intact in `Map_Name`, `Map_From`,
`Map_Spec`, `Map_OK` and their raw/mixed paths. In particular, the nested
`Map_From` and `Raw_Map_From` calls still receive `Source => Source` inside
calls to the shortened `Map_Policy`. `Mixed_Map_Name` retains the same source
actual on its nested `Raw_Entity_Name` call inside `Expected_Coverage`.
`Function_Spelling` still checks source-span validity and compares the reported
`Main.<function>` spelling against the actual source bytes. No warning exception,
proof suppression or assumed source-name equality is introduced.

### Evidence boundary for this supplement

The earlier full native run `20261107T231059-a9f0c12c8350` has since finished
with failure: the retained native-checkpoint record at integration `454e99da25`
reports 12,558 proved checks and 585 proved roots, but three compiler flow
warnings and no completed provenance certificate. That outcome remains failed.
The cleanup's inspected focused log `20261108T014000-e499f2abc850` reports 306
successful flow checks without warnings; the retained continuation record and
build log identify successful build `20261108T014016-bd4b52349efa`. These
limited observations do not establish a complete native audit. The corrected
full run `20261108T014042-81a35c010d1f` remains pending at this checkpoint.

Final review must assess the integrated bytes, affected actual-source checks,
complete native obligation/coverage/provenance evidence, complete Lean
module/axiom audit and regression applicability. No validation run was launched
by this reviewer. The selected setting remains GPT-6 Astra / Extra High;
runtime model/effort telemetry and token/cost measurements remain unavailable.
The live harness goal is null; no CLI memory was updated. This supplement
authorizes no merge and makes no delivery-acceptance claim.

## Supplemental static review — body candidates and wrapper projection

No material defect was found in the five-file proof delta from
`c437a41d30dbdbd174773cab1f5d647dc6e7bbf3` through
`f00205b5f85812df9e9ba1932d2762d69cb0407b`, or in the prepared
`tmp/predicate-wrapper-projection.patch`, SHA-256
`e17b7aa08e94b4f7cdd19343da042e300bf75123caa045366aac8e7dba9f8c44`.
Published documentation target `c9f2dd0d3188c46681ad27779ff677e1bae3fb85`
has the same governed inputs as `f00205b5f8`. The delta changes no native,
script or test inputs. The inspected output-profile body retains SHA-256
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`;
its specification has SHA-256
`b24b61c1c147f0ad46d0dd15565daa7733c86f8417236f95d56ce8977dbf0862`.
The annotation remains unapplied during the active frozen-input run.

The [basic-body candidate](../../proof/Silver/PredicateBasicSourceCandidate.lean)
now records the existing native purity guards, scalar/Boolean call-assignment
attempts and pure-context rejection before the String/Character fallback.
Inspection of `Basic_Body` and `PredicateBasicExpressions` confirms the same
branch order, one call-assignment evaluation, successful-call selection and
ordinary-assignment fallback. The typed evaluator and renderer already contain
these choices; this delta changes their candidate token list only.
The [loop candidate](../../proof/Silver/PredicateLoopCandidate.lean) adds the
existing `Catalog` actual to its recursive `Read_Body` call, forwarding the same
catalog rather than constructing a different environment.

The twenty changed entries in
[PredicateSourceRequirements](../../proof/Silver/PredicateSourceRequirements.lean)
record the existing native declarations and contracts: body-helper catalog
formals and `Functions.Valid_Metadata (Text, Catalog)`, `Expand_Body`'s
`Original : Parser_State`, the `Pure`/`Integer_Hidden` context fields,
`Return_Only`, and function/return token kinds and word-token classification.
The catalog-validity condition already occurs in native preconditions and the
quantified body equations; it is not a new restriction introduced by this
repair. Those equations retain every valid catalog and native context, including
both purity values. The existing adapter uses the original parser state to
preserve metadata outside its explicit delta. The typed tail/read postcondition
renderers remain in the requirements, with the same catalog-bearing calls.
No semantic model, contract, termination variant or formal-input domain changes.

The change to
[ComposeBooleanDeclarationLibraries](../../proof/Silver/ComposeBooleanDeclarationLibraries.lean)
reduces the existing local `let p := booleanDeclarationParts ...` after
introducing `mark`, then introduces the existing `p.typeAfter ≠ 0` hypothesis.
The complete name-mark meaning and caller domain are unchanged. The four-field
record-update repair in
[ComposeSourceBridge](../../proof/Silver/ComposeSourceBridge.lean) changes layout
only; `imageMinimum`, `imageMaximum`, `functionLookup` and `formalHides` retain
the same derived proofs and dependencies.

The prepared [PredicateEquations](../../proof/Silver/PredicateEquations.lean)
annotation gives `definitions.wrappers` the explicit type
`Adapter.Wrappers.Refinement calls.bodyWrapperModels calls.bodyWrappers`.
`Calls.bodyCalls` copies those exact two fields into `BodyLibraries.Calls`;
the inherited refinement therefore already has this type by reduction.
The annotation selects the direct wrapper projection when instantiating the
existing `adapter_interpreted` lemma. It adds no wrapper equality assumption,
model inhabitant, callee substitution or new premise. The same scalar-count
`BodyDomain` fact from `sv` is supplied, and the subsequent body interpretation
and uniqueness lemmas remain unchanged. This is an adequate static repair for
the observed projection mismatch; its actual elaboration still needs checking.

The retained failed runs `20261108T021648-bb06ac912aef` and
`20261108T022400-531d5c89d319` contain the diagnosed token/header differences.
Their comparisons are diagnostic evidence. The latter log confirms compilation
of both refreshed candidate renderings and the Boolean import proof; the active
`20261108T032945-867186df7c99` log confirms compilation of the source requirements
and Compose bridge, then reports the wrapper-projection rewrite failure.
These individual module successes do not establish a successful source audit.
The unchanged named extraction checks for `basic_body`, `loop_body` and
`scan_step` in `PredicateBodySourceCandidate` remain mandatory, together with
all other actual-source checks and the complete module/axiom audit. No pin-only
acceptance is inferred from this review.

The complete corrected native audit, complete Lean checkpoint and final
regression applicability remain pending. The coordinator reports an unresolved
error in the active full regression run; its cause and disposition are outside
this static review and must be established before delivery acceptance. This
review launched no validation and changed no active inputs. Selected setting:
GPT-6 Astra / Extra High; runtime model/effort and elapsed/token/cost telemetry
are unavailable. The live harness goal is null and CLI memory was not updated.
Implementation merge remains held; this supplement is not delivery acceptance.

## Supplemental static review — Boolean declaration candidate

No material defect was found in the prepared
`tmp/boolean-declaration-candidate.patch`, SHA-256
`55d3324ba5b7c7538ca50a3d5c17773c895208f2ea61738d61a6f5e44d554478`,
reviewed against `b2c48911207b709d5bbbc7052cdfae4bebf23590`.
The review worktree was synchronized to that target with all earlier report
text preserved. The patch remains unapplied in the frozen integration inputs.

The patch changes only the token list in
[ComposeBooleanDeclarationCandidate](../../proof/Silver/ComposeBooleanDeclarationCandidate.lean):
one insertion of 93 tokens expands the candidate from 402 to 495 tokens.
The inserted rejection checks are `Functions.Lookup`, `Formal_Hides`, and
the Integer, Boolean and Character hidden-mark/name comparisons. Independent
read-only tokenization of native `Boolean_Declaration_At` at lines 4451–4493
matches the proposed complete candidate exactly. The inspected native body's
file retains SHA-256
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.
This comparison confirms the patch scope; it is not a kernel proof.

All five checks already occur in
[ComposeBooleanDeclarationNative](../../proof/Silver/ComposeBooleanDeclarationNative.lean)'s
`rejected` tree, evaluator/render cases and `reject` equation, in the same
order and grouping as the native source. `booleanDeclarationReady` already
contains the corresponding acceptance conditions. The existing import-meaning
proof derives function lookup from valid function metadata, formal hiding from
the current native state, and mark comparisons at their established source
bounds. `reject_meaning` connects these imports to readiness. No additional
semantic/model gap was found in this bounded comparison: the patch changes
no executable behavior, evaluator, helper contract, state domain or obligation.

The active complete-run log reports
`ComposeBooleanDeclarationCandidate.lean:18` failing `candidate_matches` because
the old candidate differs from `rendered`. The corrected equality still needs
kernel checking. The unchanged
[source requirement](../../proof/Silver/ComposeBooleanDeclarationSource.lean)
also requires named `ordinaryFunction "boolean_declaration_at"` extraction,
scope/precedence and exact native headers. `candidate_boolean_declaration` in
[ComposeHelperSourceCandidate](../../proof/Silver/ComposeHelperSourceCandidate.lean)
and `actual_boolean_declaration` in
[ComposeSourceChecks](../../proof/Silver/ComposeSourceChecks.lean) retain that
authoritative-source connection. All these checks and the complete source,
module and axiom audit remain required before final delivery acceptance.

Selected reviewer setting remains GPT-6 Astra / Extra High; runtime telemetry
and elapsed/token/cost measurements are unavailable. No proof/build/test run,
integration edit or external publication was performed. The live harness goal
is null and no CLI memory was updated. Final evidence/applicability review and
any later owner merge decision remain separate from this static verdict.

## Resource assessment — complete Lean run, 05:01–05:04 UTC

The concurrent allocation growth created a concrete host-memory concern, with
no observed OOM event. Read-only inspection covered complete Lean run
`20261108T044143-17a94f7033eb` and concurrent native run
`20261108T040128-2651963b8574`. The Lean run reserves eight workers, uses 22
threads per process, and has `memory_mb: null`; the native run reserves twelve
workers. Process RSS/address-space limits and cgroup `memory.max`/`memory.high`
are unlimited. The Linux host has 62.87 GiB physical memory and no swap.
Worker reservations do not bound aggregate memory. The cgroup's large
`memory.current` includes reclaimable cache and is not itself a hard-limit
failure indication. Memory-pressure metrics were unavailable; cgroup OOM and
OOM-kill counters were zero at inspection.

| UTC | Host MemAvailable | FunctionSourceCandidate RSS | Observation |
| --- | ---: | ---: | --- |
| 05:01:14 | 22.54 GiB | 22.64 GiB | Source candidate remained CPU-active. |
| 05:02:27 | 16.64 GiB | 24.14 GiB | All Lean RSS summed to 42.71 GiB; native processes summed to 5.13 GiB. |
| 05:03:06 | 16.45 GiB | 25.09 GiB | ComposeExamples held 5.79 GiB; PredicateNativeHelpersCandidate held 6.42 GiB. Other workers released some memory. |
| 05:04:02 | 15.15 GiB | — | Coordinator's targeted preservation action below. |
| 05:04:36 | 22.87 GiB | 27.50 GiB | Source candidate remained alive; cancelled example worker had exited. |

These are non-atomic process snapshots. RSS totals double-count shared mappings;
host `MemAvailable` is the more useful headroom indicator. The initial
5.9 GiB/73-second decline justified intervention planning, while subsequent
releases demonstrate why extrapolating that slope is not a peak-memory or
completion prediction. The source module checks declaration, visibility and
call requirements against the complete reviewed token source in three kernel
proofs. Its terminal allocation and current theorem position were unavailable.
Its output object had not yet been produced; existing successful source-shape
and named-body objects were retained in the same workspace.

The recommended minimal action was to release the growing, shorter-running
`ComposeExamples` process while preserving the longer-running source candidate,
Lake and native work. After verifying its command line, the coordinator sent
SIGTERM only to PID 590345 at `2026-11-08T05:04:02.531499Z`. The retained
`tmp/complete-lean-memory-preservation-action.json` records that decision and
the pre-action process state. Lake records `ComposeExamples` after 287 seconds
with exit code 143 and continues other work. The post-action headroom includes
concurrent allocations/releases; no exact causal memory-saving total is claimed.
The coordinator also observed PredicateNativeHelpersCandidate fall from about
6.42 to 1.68 GiB and ArgumentsExamples exit by 05:04:31, when its sample showed
23.77 GiB available and the source candidate still using a CPU productively.
The reviewer sent no signals and launched no validation.

Continue 30-second memory observations while the source candidate grows, with
a fresh observation 15–30 seconds after any intervention. Reassess promptly if
`MemAvailable` reaches 12 GiB, or a recent sustained decline projects 8 GiB
within two minutes; 8 GiB requires an immediate preservation decision rather
than waiting for OOM. These are operational margins, not proved limits or
automatic whole-run cancellation rules. No further cancellation is recommended
at the observed 22.87 GiB headroom. Lake may schedule replacement jobs, so the
aggregate must continue to be observed.

The run already contains the known Boolean-candidate failure. The cancelled
example remains a failed required module and must succeed in the later complete
checkpoint. Frozen source, domains, contracts, exact-source checks and every
module/axiom obligation remain unchanged; no clean rebuild, limit change or
proof-structure optimization was requested. This resource assessment supplies
no assurance acceptance. Selected setting: GPT-6 Astra / Extra High; runtime
model/effort and token/cost telemetry are unavailable. Local scratch retains
the assessment snapshots; the live goal remains null and CLI memory is unchanged.

### Follow-up resource decision — 05:08–05:10 UTC

The watcher subsequently reported 11.13 GiB available at 05:07:51 and 9.92 GiB
at 05:08:21. Fresh inspection at 05:08:46 instead showed 15.54 GiB available:
the Helpers and ScalarBody workers had released allocations to 0.86/1.11 GiB.
At 05:10:10, available memory was 16.18 GiB and FunctionSourceCandidate's
RSS/high-water mark was 35.44 GiB. No second signal was sent at this checkpoint.
These oscillations justify preserving the current work after recovery, while
continuing to watch the candidate's sustained growth.

Refine monitoring to 15-second samples during each excursion below 12 GiB.
Two successive low/falling samples, or a sustained decline projecting 8 GiB
within 60 seconds, justify a fresh preservation decision; at or below 8 GiB,
act immediately. Verify the current process identity before signalling. If
another cancellation becomes necessary, target only FunctionSourceCandidate
PID 582544: it dominates resident memory, while cancelling Helpers and
ScalarBody would free much less and discard two other required ongoing jobs.
Keep Lake, the remaining source workers, native work and successful objects.
All cancelled checks still require successful completion; elapsed time supplies
no estimate of their remaining work.

Scratch-only inspection identified a possible retry decomposition if that
candidate must be stopped. Its three independent `Checked` proofs have 8, 11
and 30 fields, with whole-table checks among the declaration fields. The active
theorem/field and terminal peak are unknown, so a three-module split alone is
not a demonstrated memory bound. A contingent retry could separately compile
the unchanged exact components or individual named table requirements, then
assemble the original theorem statements and import facade. Such a retry must
retain every named source, tree, scope, header, body and domain check and run
serially under managed reservations to avoid multiplying allocation. No such
change or run was performed; healthy current headroom does not require it.
Selected reviewer configuration remains Astra Extra High with runtime telemetry
unavailable. The reviewer owns no active process and sent no signal.

### Targeted source interruption and concrete retry proposal

After renewed available-memory observations of 11.66 GiB at 05:11:22,
10.91 GiB at 05:11:30 and 10.38 GiB at 05:12:10, the coordinator verified the
command line and sent SIGTERM only to FunctionSourceCandidate PID 582544 at
`2026-11-08T05:12:10.541560Z`. Its RSS/high-water mark was 38.31 GiB. Lake
retains that module's failed outcome after 1,735 seconds with code 143; the
other source workers, native run and frozen inputs continue unchanged. The
exact action and samples are in integration scratch
`tmp/function-source-memory-preservation-action.json`. This was a resource
interruption, with all source obligations still mandatory.

The reviewer prepared a concrete uncompiled patch under the separate review
worktree's `tmp/function-source-decomposition/`, with `PLAN.md`, complete
`inventory.json`, proposed file bodies and `function-source-components.patch`.
Patch SHA-256:
`f018c845b443695879e59f4425042f5ba12a93c028a8e8c488283b856f931bd3`.
It changes only the existing FunctionSourceCandidate facade and adds 80 leaf
modules: 41 declaration requirements (25 headers, seven expressions, three
ordinary bodies, three iterative bodies and three declarations), ten visibility
requirements and 29 call requirements. Existing tree proofs remain included.

Each leaf keeps its exact full-source proposition and `decide +kernel`.
Declaration-table leaves refer to the existing table with a bounds-checked
`List.get`; the original complete forall domains are assembled from every row.
The original three exported theorem names and result types remain unchanged,
as does the actual-source consumer. Static inventory checking confirms each
leaf is referenced once; read-only patch applicability passed. No governed
proof file was changed and no compilation was performed.

The proposed first check is the single
`Silver.FunctionSourceParts.DeclarationHeaderFunctionTypeAtSpec` leaf, followed
by `Silver.FunctionSourceChecks` and then the required complete check, each
using `scripts/check_lean.py --workers 1 --threads 1` with the recorded memory
reason. The plan retains matching source certificates and unrelated objects,
allows required downstream rebuilding, and requests no clean deletion, optional
replay, changed memory cap or weakened obligation. It must wait for the current
workspace/input lease to be released and the actual failed outcome retained.

Separate processes and serial scheduling limit simultaneous transient proof
allocation and preserve successful components. A single component or the final
assembly/audit can still be large; no per-component size or successful outcome
has been established. The concrete proposal addresses the observed failure risk
without claiming a memory bound. The current monitoring thresholds remain in
force. Selected reviewer setting is Astra Extra High with runtime telemetry
unavailable; the reviewer sent no signals and owns no active process.

### Repeated regression timeout: isolated configuration observation

The full regression and unchanged focused follow-up
`20261108T053156-3a0a42e9d590` both exceeded the existing 60-second deadline in
the first chunk-reuse Lake build, before the audit and reuse/edit variants.
Review of the retained archive found the expected configuration options and
Lean identity, but pinned `Lake/Load/Lean/Elab.lean` writes and flushes
`lakefile.olean.trace` before elaboration. The historical trace's presence
therefore does not establish configuration completion. The two historical
process samples cannot establish a scheduling, I/O or configuration root cause.

After reviewing the pinned `lake env` implementation and sending a concrete
isolated plan, the coordinator authorized exactly one configuration-only
observation with the unchanged deadline and options. The reviewer used the
released regression toolchain context through managed `dev.py tool`, reserving
one worker and explicitly declaring its scratch workspace and inputs. Fresh
preflight showed 20/22 workers reserved and 51.1 GiB available. All 19 prepared
source/configuration hashes matched the retained failed-fixture inventory;
the recreated workspace began without `.lake` state. No test, harness,
production source, module, timeout or memory option was changed.

Native Linux managed run `20261108T054614-dc5613468a66` succeeded. Its exact
Lake prefix was `--rehash --reconfigure -K silverThreads=1 -K
silverMemoryMb=2048`; `env` and an immediate process/timing marker replaced only
the module build command. The command and marker exited in 22.878 seconds,
including spawn and exit confirmation, while the complete managed run took
62.554 seconds including preflight, preparation and evidence collection.
The trace was first observed at 1.067 seconds, configuration olean at 20.318
seconds, marker process birth at approximately 20.542 seconds (10ms Linux tick
precision), and marker Python entry at 21.607 seconds. No `.lake/build`
artifacts were produced. Stdout was empty and stderr contained only expected
manifest/toolchain information.

The 85 process samples recorded 21.14 seconds of aggregate Lake CPU growth and
834.7 MiB maximum sampled RSS. Per-observed-thread scheduler wait counters
totalled 0.220 seconds, a sampling lower bound; the last readable I/O sample
had zero storage-read bytes and approximately 1.05 MB written. This demonstrates
active configuration computation during this observation. It does not explain
the earlier build delay, whose ambient environment and OS cache/scheduling state
were not retained. The current environment was explicitly captured before
Alire and supplied through the unchanged `lean_environment` function. Relevant
values and other-value hashes are retained; its private complete snapshot is
excluded from shareable evidence.

All diagnostic inputs remained unchanged, no signal or repeat was needed, and
all diagnostic descendants exited. The managed reservation was released;
postflight returned to 20/22 reserved. Detailed evidence and exact observer
are retained in the separate review worktree's
`tmp/lake-config-diagnostic-298/`, including `ANALYSIS.md`, `PLAN.md`, streams,
250ms process/CPU/I/O/wait samples, command, tool/loaded-file hashes, artifact
inventory and managed events. This is a successful diagnostic, not a passing
fixture or delivery acceptance.

The smallest prospective check is one instrumented initial-build-only
observation from an identical cold fixture under the same 60-second deadline,
retaining individual module starts and streams. It would separate current
configuration cost from module compilation before selecting any repair or full
fixture rerun; it has not been launched. The original full fixture, its audit
and all reuse/edit checks remain mandatory. There is no evidence here supporting
a timeout increase. Selected reviewer setting remains Astra Extra High with
runtime telemetry unavailable. Live goal was null at resume; CLI memory was
not updated.

### Instrumented initial build: timeout after completed configuration

The coordinator separately authorized one initial-build-only observation after
the preceding configuration result. Native Linux managed run
`20261108T055144-283b5d488a27` used a new isolated scratch workspace, the same
validated 19 prepared files and recorded current environment, one reserved
worker, and the exact original build targets and options. The cold `.lake`
condition and unchanged inputs were verified. The successful configuration
observer and its evidence were preserved unchanged.

This observation timed out. Configuration's final olean was first sampled at
21.166 seconds; kernel process-start ticks place Lexical at approximately
21.219 seconds, CertificateWitness at 32.049, Admission at 43.569 and Cursor
at 55.289 (10ms tick precision). Captured stdout reports the first three modules
built successfully in 10, 11 and 11 seconds. Cursor remained active at the
60-second deadline. Its detection occurred at 60.282 seconds with sampling
and polling overhead. The reviewer verified session/start identities and sent
SIGKILL only to this diagnostic's Lake PID 602629 and Cursor PID 602805 at
60.329/60.330 seconds. The diagnostic subreaper reaped Cursor; all diagnostic
descendants had exited by 62.389 seconds. Driver status 124, Lake status -9
and the managed wrapper's failed status remain explicit. No external process
was signalled, no repeat was made, and the one-worker lease was released.

The initial build preserved completed Lexical, CertificateWitness and Admission
object families and the partial workspace. Last sampled aggregate CPU was
22.36 seconds for Lake (including build coordination), 9.59 for Lexical, 8.05
for CertificateWitness, 8.65 for Admission and 5.25 for interrupted Cursor.
The first three module processes accumulated 4.15, 5.22 and 5.13 system CPU
seconds, respectively. This establishes significant current configuration and
serial module-process cost; it does not distinguish every import, elaboration,
serialization and process-startup contribution.

The historical follow-up's lifetime-average observations were Lake at
32 seconds/58.1% CPU, defunct Lake at 61 seconds/61.7%, and Lexical at
10 seconds/57.5%. These differ from the separate configuration observation's
21.15 sampled CPU seconds in 22.878 observed wall seconds. Those historical
averages nevertheless cannot isolate configuration CPU, I/O or scheduling;
no historical contention cause is asserted.

A read-only comparison with successful real fixture
`20261106T145355-acbd4750fe92` at `524dbfbd40` found identical seven production
modules, test, toolchain, bootstrap/environment helpers and both Lean/Lake
executable hashes. The lakefile, generator and check_lean.py differ; exact
identity comparisons are retained. Matching those bytes does not establish
matching historical environment, host, libraries or cache state.

Detailed timings, counters, streams, identities, completed/partial objects and
managed records are preserved in the review worktree's
`tmp/lake-initial-build-diagnostic-298/`. The managed failed run lasted
94.409 seconds including setup, deadline cleanup and evidence collection.
Fresh postflight showed 20/22 workers reserved and no diagnostic descendants.
The original fixture and all audit/reuse/edit stages remain mandatory and
unpassed by this observation.

The smallest prospective execution is one isolated profiling compile of the
unchanged CertificateWitness module, whose three Lean meta imports require no
Silver dependency in its retained setup. Pinned Lean exposes import and
serialization measurements through `-Dprofiler=true -Dprofiler.threshold=0`.
With the existing thread, memory, warning and 60-second settings and distinct
scratch outputs, that could locate its import/startup versus theorem cost
before choosing any implementation change. It is proposed only, has not run,
and does not justify changing the fixture timeout. Reviewer settings and
runtime-telemetry limits remain unchanged; no CLI memory update was made.

### Direct CertificateWitness profile and imported-artifact identity

The coordinator authorized the single proposed direct profiling observation.
Native Linux managed run `20261108T060219-fd618279bf6d` succeeded with fresh
isolated outputs. Source and retained setup bytes were unchanged; original
-j1/-M2048/warningAsError and --json/output forms were preserved, adding only
`-Dprofiler=true -Dprofiler.threshold=0`. Pinned Lake's compiler-spawn code
sets only LEAN_PATH in its subprocess environment; this diagnostic reproduced
that override on the saved pre-Alire environment with relocated scratch paths.
The command exited in 9.604 seconds within the unchanged 60-second deadline.
No signal, repeat or remaining diagnostic process followed.

The pinned profiler's exclusive cumulative report attributes 6.870 seconds to
imports, 0.240 to initialization, 0.136 to olean serialization, 0.0469 to
elaboration, 0.00236 to type checking and 0.0303 to C generation. Last sampled
CPU was 8.34 seconds (3.17 user and 5.17 system), peak sampled RSS 460.0 MiB,
and sampled scheduler wait 0.147 seconds. Import work dominates this observed
module. The profiler does not account for every startup/teardown interval,
and observation/instrumentation costs limit strict timing comparisons.

Imported artifacts were checked separately from compiler executables. The
managed input capture hashed all 15,127 installed lib/lean files, among 15,168
inputs, and final checking confirmed input stability. Those reads warm file
caches and are an explicit measurement difference. All 4,966 sampled mapped
files, including 4,959 installed standard-library files, matched their hashes
from the preceding initial-build diagnostic, with no new or mismatching sampled
files. Briefly mapped files can escape sampling. No imported-artifact identity
inventory is established for the November6 successful fixture; its matching
Lean/Lake executable hashes alone do not establish historical library equality.

Read-only mount inspection found the resolved installed Lean library on the
repository's `virtiofs` mount, source `host`. Together with thousands of mapped
artifacts and substantial system CPU, this supplies a concrete filesystem
metadata/mapping-cost hypothesis. It does not prove that hypothesis or explain
the original failures. The coordinator's 06:03:38 resource update had only
PredicateNativeShapeCandidate still compiling alongside native12, roughly
43 GiB available and 20 managed workers reserved; these current facts are not
historical contention evidence.

Detailed evidence is retained in
`tmp/certificate-witness-profile-298/` in the separate review worktree, including
raw profiler streams, CPU/I/O/wait/start observations, complete managed input
identities, mapped-artifact comparison, source/setup hashes and fresh output
objects. Managed elapsed time was 128.499 seconds including before/after
library hashing, setup and retention. All diagnostic descendants exited and
the one-worker lease was released; postflight returned to 20/22 reserved. Both
prior diagnostic bundles and their drivers/results remain unchanged.

The smallest justified next action is a reviewed plan for a matched host-local
Lean installation observation using identical authenticated tool/library/source
bytes and settings, distinct managed workspace ownership and the applicable
bootstrap/platform-coexistence procedure. Preserve the live installation and
productive caches. Such a comparison could test the filesystem hypothesis
before selecting any fixture change; it has not been executed. This profile
does not justify a theorem rewrite or timeout increase, and it does not pass
the original fixture or its outstanding audit/edit stages. Reviewer settings
remain Astra Extra High with runtime telemetry unavailable. No CLI memory
update or publication was performed.

### Authenticated local-install comparison

The coordinator approved two sequential managed stages from the reviewed
storage-comparison plan. Run `20261108T061828-f176c7d39979` freshly bootstrapped
Lean in `/tmp/silver-certificate-witness-local-298-20261108` using the unchanged
installer/helper/pin and the authenticated cached release ZIP. Measured mount
information selected the writable root overlay, distinct from the repository's
virtiofs mount; disk/headroom checks passed. No download, existing-installation
relocation, native bootstrap or project proof-object copying was performed.
The native version was 4.34.1 at commit
`5045d0056413266e57c625dcd7c365b10e377c52`.

Complete original/local distribution inventories matched all 18,381 entries,
including relative file sets, bytes, sizes, permission modes, directories and
symlink targets. All 15,127 baseline profiler lib/lean identities matched too.
The bootstrap stage finished successfully in 181.102 managed seconds, including
installation, comparisons and input checks. Its descendants exited and its
lease was released before profile B began.

Run `20261108T062237-55f39cc9f940` then performed exactly one direct
CertificateWitness profile with fresh outputs. Normalized source/setup,
arguments and environment matched A; only installation/workspace paths changed.
The observer diff changed only frozen-input location, installation selector
and baseline-run identifier. Source/output storage remained virtiofs for both
profiling runs, while B's installation was on overlay. The original
-j1/-M2048/warningAsError/profiler settings and 60-second deadline remained.

B passed in 4.836 observed command seconds versus A's 9.604. Exclusive import
time decreased from 6.870 to 2.910 seconds. Sampled user/system CPU decreased
from 3.17/5.17 to 2.24/1.90 seconds, with similar sampled RSS (460.0 versus
461.1 MiB). Other categories varied: olean serialization rose from 0.136 to
0.461 seconds. The bounded observation supports storage-related import
overhead as a current hypothesis; it is not a repeated benchmark, complete
causal attribution or proof of the historical timeout cause.

All 4,966 sampled mapped-file identities matched A after documented installation
prefix normalization, including 4,959 lib/lean files. All 4,960 mapped
installation files came from the new local distribution; none came from the
old one. External mapped library identities matched. Managed B captured 17,751
regular distribution files among 17,795 inputs and passed final stability
checking. Managed elapsed was 49.534 seconds, including setup/retention, distinct
from compiler time. No signal or timeout occurred, all diagnostic descendants
exited, and the one-worker lease was released; shared status returned to 20/22.

Both runs deliberately warmed caches through identity checks; B also followed
extraction and complete distribution comparison. Host scheduling/peer work
was not fixed. The profiling A/B source/output paths were both on virtiofs,
whereas the original failed fixture used its separate /tmp workspace.
November6 imported-artifact identities remain unavailable. These limits prevent
substituting this observation for an actual passing original fixture.

The new installation and evidence are retained. Exact drivers/diff, complete
inventories, streams, timings, mapped-file checks, source/setup/environment
comparison, fresh module objects and managed records are under the separate
review worktree's `tmp/lean-local-comparison-298/`. All earlier diagnostic
bundles/drivers/results remain unchanged. The next bounded task is to assess
a separate test root selecting the authenticated local distribution through
normal ROOT derivation and running the unchanged original fixture. Its cold
17-module build plus forced configuration still presents a 60-second risk;
one module's improvement does not establish the complete budget. No fixture,
initial build, suite or additional profile was run. No source/test/harness,
live selector, deadline or acceptance condition changed; publication remains
outside this review stream.

### Unchanged original fixture with authenticated local tools still times out

The coordinator authorized exactly one complete original method through the
reviewed isolated-root route. Native Linux managed run
`20261108T064023-1bc9e7d6f89f` finished failed: one test, one TimeoutExpired
error, zero skips and no audit/edit subtests reached. The initial Lake build
exceeded its unchanged 60-second limit. Unittest took 64.277 seconds, the outer
observation/identity work 83.861 seconds, and the complete managed command
113.471 seconds. The failed outcome remains explicit.

The test, nine helpers, lakefile/pin/generator and seven proof modules were
byte-identical to current governed fixture inputs. Normal __file__ derivation
selected the copied ROOT/PROOF/imports; a new isolated selector used the
validated local installation without editing any existing selector. The
approved scoped TMPDIR stayed on the original /tmp overlay filesystem class.
All test assertions, subprocess calls, source, proof options, one-thread and
2048 MiB settings, 60-second limits and original cleanup remained unchanged;
no profiler was enabled.

Complete 18,381-entry distribution identity matched before/after. The prepared
workspace matched all 19 source/configuration hashes and copied inputs remained
unchanged. An explicit postflight rehashed all 17,792 managed input files with
zero differences, because the failed managed invocation does not itself execute
its normal success-path final stability check.

Actual TimeoutExpired stdout reports Lexical built in 5.9 seconds,
CertificateWitness in 4.9, Admission in 5.9, Cursor in 11 and
OutputProfileBodySource in 1.4. SourceLexer was first sampled at 46.2 seconds
after the fixture process started (Lake at 3.2 seconds), with no chunk-module
compiler observed before the deadline. A reporting-only result callback
preserved actual exception streams and the pre-cleanup workspace, including
the five completed object families. The snapshot is not an atomic completed
build; SourceLexer was still present when it was captured.

The observer later reaped the completed SourceLexer descendant with wait
status zero and sent no signal. That later child exit does not complete the
killed Lake build or unexecuted fixture stages. Original cleanup emptied the
scoped temporary directory; all owned descendants exited and the worker lease
was released. Minimum sampled available memory was 50.95 GiB. No historical
or current contention cause is inferred from that observation.

The isolated root, exact drivers and failed evidence are retained under
`tmp/local-original-fixture-298/` in the separate review worktree; the two owned
/tmp roots and authenticated installation remain available. No repeat or other
test followed. Local storage alone was insufficient to make this unchanged
fixture pass. The next bounded work is read-only assessment of the watchdog's
provenance/correctness purpose and preparation of any narrowly justified repair
for coordinator review. No timeout, fixture or acceptance change is authorized
by this failed result itself. Reviewer settings/telemetry limits remain
unchanged; no CLI memory update or publication occurred.

### Fixture watchdog provenance and unapplied repair proposal

The read-only assessment traced the unchanged `timeout=60` in
`LeanModuleTests.lake` to `15ca622139564b55e5e15f95b2e97a763e72ed9d`
(2026-10-12), when the helper served small module-boundary and audit probes.
The split-certificate fixture was added in `eebaab79f8c65f1b0306c07c24dc148e41ed7dc3`
and expanded through `0f3076d3da` and `524dbfbd4084c79f7048b1710dd3a7af76affe59`
on November 6 without changing that deadline. The current graph has 17 project
modules. The inspected history, code and governing documents contain no explicit
60-second compilation performance contract or elapsed-time assertion. The earlier
340.850-second whole-method success is a measurement, not an individual-build
bound. Related native Lake fixtures already use 180-second subprocess watchdogs.

The retained unchanged runs show material configuration/import costs and the
latest local-install initial build still timed out after five project modules,
with SourceLexer active before any chunk compiler was observed. That evidence
supports a narrowly scoped watchdog repair proposal: keep the class helper's
default at 60 seconds, add a keyword-only timeout argument, and pass 180 seconds
only from this fixture's local build helper. Broad edit/reset builds can rebuild
all chunks, so the proposal covers that helper rather than only its first call.
Fresh audits and other tests retain 60 seconds. This changes the execution budget;
all correctness assertions, source/object identities, stale rejection, eleven edit
cases, fresh axiom audits, proof options and kernel checks remain identical.

The 180 seconds is a proposed bounded engineering budget with related-fixture
precedent, not a measured completion guarantee or a whole-method deadline. It
allows a build more time to reach the same acceptance checks; timeout remains an
error. No production proof timeout, solver option, language restriction or Oracle
guarantee changes. Complete original-fixture success remains outstanding, and all
historical failures remain failed. The proposal authorizes no automatic rerun,
subsequent increase or weakened check.

The exact candidate and unapplied patch are retained separately under
`tmp/fixture-watchdog-assessment-298/`, with provenance, source identities and
static-review results. Parsing/compilation of candidate text succeeded without
execution; reverting exactly its three timeout-related AST changes reproduces
the entire original file's AST. All four live test copies (review, regression,
integration and isolated local root) remained byte-identical. `git apply --check`
accepted the scratch patch without applying it. Patch SHA256 is
`5b666993e70dae3672a83012ff96e45d09a870a463c3c9f356d8e1d60cb36c4f`.
No actual test/source/harness edit, changed-timeout execution, repeat or publication
was performed. The coordinator retains the regression context; this reviewer has
no native process or lease. Live harness goal is null and CLI memory was not
updated.

### Separate symlink-TMPDIR fixture: read-only assessment

The coordinator retained the final-input follow-up
`20261108T064731-9f1ab6dc731c` as failed: the complete nested
PlatformIsolationTests invocation exceeded its unchanged outer 180-second
watchdog. Its governed-input postflight matched `47fe4003c0`; no child remained.
This reviewer did not repeat that fixture or change its source/deadline.

The outer limit began as 60 seconds in `8b8619f3ad53895dbad2e8e14e767fa5e51de628`
and increased to 180 in `3fdda42dc1b058b54dc7c6c83054af85a2d6f574` on October 8.
It is a suite subprocess watchdog with no elapsed-time assertion. The tracked
Lean input set grew from 33 files at that increase to 821 at the current target.
Each of the twelve nested cases copies the complete production Lean set from
ROOT into an overlay-backed temporary project; ROOT remains on virtiofs. The
class also runs fifteen setup-worker processes, including the four-host parallel
case, with real Python certificate generators and existing mocked tool effects.
Those distinct costs cannot be assigned a measured total from the retained log.

All twelve direct class cases passed in the earlier complete run, but its log
contains no per-case start/end timings. Embedded run identifiers at 03:51:44
in the third case and 03:55:30 in a later module bracket mixed work and do not
establish a full class span. The coordinator's later four-worker process sample
is likewise a phase observation, not a root-cause diagnosis.

The prepared route recommends one unchanged selected method from a fresh local
source/test root, retaining outer 180 seconds, worker 60 seconds, concurrency
barrier 15 seconds, all twelve nested tests and every assertion. Its exact 866
required files (54,490,005 bytes), including all 821 Lean sources, nine helpers
and thirty certificate-bound sources, match `47fe4003c0`. No installed binary,
project object or live selector needs to move: external Alire/Lean effects are
already mocked in this platform-only fixture. The change would remove repeated
ROOT-side virtiofs copies while keeping the existing destination storage class.
Other generator/hash/snapshot work remains; fitting the deadline is unproven.

The concrete ownership/import/environment/reporting plan and input inventory are
retained in `tmp/symlink-fixture-assessment-298/`. It proposes a four-worker
reservation after the active chunk fixture releases the regression context,
subject to fresh resource review, and preservation of actual timeout streams
if the unchanged route fails. No execution or later watchdog increase is
authorized by the assessment. Shareable assessment bundle SHA256 is
`74b9bcb5916e73901567359819155fa2d7f92f63865d4998f83caab8f84ccc51`.

### Complete chunk-reuse fixture passes with the approved local watchdog

The coordinator authorized and integrated the exact reviewed repair. Source-only
commit `6b62dafb43e48556e7631190751cf0c5b39446c1` changes only the test helper's
keyword-only timeout parameter and the selected method's 180-second build budget;
class default and fresh audits remain 60 seconds. The coordinator verified this
test is outside the active production Lean input set. All other assertions,
proof settings, source and cleanup were unchanged.

Native Linux managed run `20261108T065724-7d260468ca14` passed: one test,
eleven successful edit subtests, zero errors/failures/skips and no reporting
errors. Unittest took 1,079.914 seconds, outer observation/identity work
1,100.613 seconds, and complete managed execution 1,141.938 seconds. The cold
initial build, initial fresh audit, no-op reuse, expected restored-timestamp
stale rejection, every edit audit and reset build completed. The observer
recorded all 25 build and 12 fresh audit invocations. Exact generated-source,
affected/retained object, Independent and eight-chunk audit assertions all passed;
all eleven original structured edit observations were retained.

The fixed empty-source variant changes seven buckets (0,1,2,3,5,6,7) and retains
bucket4. This corrects the earlier assessment's overly broad statement that its
broad rebuild cases could affect all eight. The actual code comment says only
"broad edit rebuilds" and remains correct. All eight are included in the initial
cold build and the unchanged exact reuse checks. No further test edit is needed.

Normal copied-root imports and all nineteen prepared workspace hashes matched.
Nine helpers, seven proof modules and lakefile/pin/generator matched `47fe4003c0`
and the earlier failed fixture; the only test delta was the authorized patch.
All 18,381 authenticated distribution entries and copied inputs were unchanged.
The successful managed postflight completed, and an independent rehash of all
17,793 captured managed inputs also found no drift. No signal or timeout occurred;
all descendants exited, original temporary cleanup completed and the worker lease
was released. Minimum sampled available RAM was 42.705 GiB; no historical timing
cause or universal performance bound is inferred.

Exact drivers, inputs, actual output, callback/printed edit observations,
identity checks and managed records are retained in
`tmp/local-watchdog-fixture-298/`. The verified 60-member shareable bundle is
3,032,373 bytes, SHA256
`b576f78b7ab40dc4dc3e618999e47f34fbcead11e904ffae89501c01082613e7`;
the private inherited environment is excluded. All earlier failed runs/bundles
remain failed and unchanged. This passes the one repaired regression, without
reclassifying the original full suite or replacing separate mandatory project
assurance. The separately authorized unchanged platform fixture is next after
this retention. No publication, merge or CLI memory update occurred.
