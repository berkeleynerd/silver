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

### Unchanged local-source platform fixture fails with nested errors retained

After the first fixture's actual success, cleanup, postflight and evidence
retention, the coordinator authorized exactly one unchanged local-source
platform attempt. Native Linux managed run `20261108T071906-6ce712a8a90c`
failed at the original 180-second outer deadline: one test, one TimeoutExpired
error, zero failures/skips and no reporting errors. Unittest took 181.156
seconds, observation/cleanup/postcheck 186.468 seconds, and managed execution
204.808 seconds. No retry or watchdog change followed.

The original 866 source/helper/config files and modes, complete 821-file Lean
set, normal imports, four-host concurrency and every original assertion/mock
were preserved. Source/root placement moved to overlay; no binary/install,
selector or project object was copied. The explicit scoped TMPDIR/TMP/TEMP
change was recorded, and the method still created its original physical/alias
pair. Observed nested/worker environments all used the same live symlink alias.
Original outer180/worker60/barrier15 remained unchanged. This is Linux evidence
for mocked platform routing, not native macOS or project proof assurance.

Actual partial TimeoutExpired streams are retained: 999 bytes stderr and
701 bytes stdout. The nested stderr reports cached-audit `ok`, concurrent-host
setup `ERROR`, development-command routing `ok`, output-overrides `ok`, then
an `ERROR` for linux-aarch64 inside the each-host case. The fifth whole case did
not report completion and the remaining seven methods were not established as
executed. The nested suite was killed before its final traceback section, so
the two inner exception types are not established by their ERROR labels.

Observed worker spans were approximately 44.9 seconds for the first worker,
59.1-60.2 for the four concurrent workers and 58.8 for the first sequential
host. These are one-second samples, not exact exit times or proof of timeout
causality. A newly started linux-x86_64 worker survived the outer fixture exit;
the observer killed only that verified owned descendant afterward and recorded
its reaping. No descendant remains, the scoped temporary directory is empty
and the four-worker lease is released. No signal changed the running fixture's
original execution budget.

All 866 copied bytes/modes and the 821-file Lean set matched afterward. Explicit
postflight rehashed all 884 captured managed inputs, because the failure path
skips the runner's normal success-path check; all matched. A separate recheck
of all 866 original governed-source bytes/modes against `47fe4003c0` also matched.
Minimum sampled available RAM was 42.673 GiB. No broad scheduling or storage
cause is inferred from these observations.

The exact output, process/alias observations, source/input checks, drivers and
managed records are retained in `tmp/local-platform-fixture-298/`. Its verified
902-member shareable bundle is 4,570,127 bytes, SHA256
`4ecc2c81635bf7c7cf4a5f613ecba5d3754b23849051038f3f883462fb1d9720`;
the private environment is excluded. The prior successful chunk-fixture bundle
was rechecked unchanged. Local source placement alone was insufficient, and an
outer-only increase cannot be assumed to repair already observed nested errors.
The coordinator requested a prepared diagnostic plan to expose one actual inner
exception under unchanged worker/barrier limits; no such execution is yet
authorized. No publication, merge or CLI memory update occurred.

### Prepared diagnostic for the first nested platform error

Read-only inspection confirmed the concurrent-host method already has the needed
bounded worker behavior: four Popen workers, original communicate(timeout=60),
zero-status assertions, and its existing finally cleanup. Workers retain the
15-second barrier. Running that single existing method would let unittest print
its actual final traceback without the surrounding full-class watchdog ending
the suite first. It would be diagnostic evidence only, not a passing outer fixture.

The prepared plan retains the same copied ROOT, all 866 file bytes/modes, complete
821-file Lean set and exact earlier symlink TMP environment. Eight ordinary Python
cache files produced by the prior run are inventoried and would be declared as
existing inputs. No cache clearing, source reduction, new installation, deadline
change or subprocess/method replacement is proposed. A reporting-only result
callback would preserve actual exceptions/available streams and per-host records
before original cleanup, with process and managed duration reported separately.
No unavailable worker output would be reconstructed.

The exact plan and unchanged-method excerpts are retained in
`tmp/platform-inner-error-plan-298/`. Plan SHA256 is
`72ab0ff21f3c1b3a68ed3b9e8e36213e1f09f85b07d46a16499d69f24565a516`;
its four-member shareable plan bundle is 6,775 bytes, SHA256
`0ec05aa90a12d700cff06f775e45fbddb61f3c274d0546a09a1ade80e6b235a0`.
The plan requires separate coordinator authorization, fresh resource/lease
checks and stopping after one actual result. No diagnostic, source edit,
watchdog increase or additional fixture run has been performed.

### Single concurrent-host diagnostic establishes the inner 60-second timeout

The coordinator authorized the exact prepared single-method diagnostic. Native
Linux managed run `20261108T073911-6cec95e84ac5` failed with one actual
TimeoutExpired error, zero failures/skips and no reporting errors. Its complete
traceback identifies the original `process.communicate(timeout=60)` at
`tests/test_platforms.py:471` for the first linux-aarch64 --concurrent worker.
This establishes the missing inner exception directly. The required outer
fixture was not selected and no deadline changed.

Actual worker stdout (5,203 bytes) reached completed mocked bootstrap and the
Lean concurrency message; the exception's stderr value was absent. All four
retained per-host run records show successful preflight without a build/audit
phase. Late process observations still show real IO/arguments/runtime certificate
generators. Source review confirms generation and input verification precede
the mocked build phase. The watchdog interrupted unfinished fixture work; the
records do not show a prior policy or assertion rejection, and do not establish
that all later checks would pass. The 113 sampled generator processes are an
observed count, not a complete census of short-lived processes.

Unittest took 64.825 seconds, including 2.347 seconds of reporting-only
precleanup capture. Python launch through observed wait completion took
68.177 seconds, followed by 0.845 seconds of cleanup/postcheck; managed elapsed
was 82.657 seconds. Per-worker timing remains sampled at one-second intervals.
All four workers retained the exact symlink TMP environment, original 60-second
limits, 15-second barrier and unchanged source/mock/generator/assertion behavior.
The original method performed its existing unfinished-worker cleanup; the
observer sent no additional signal. No descendants, lease or temporary wrapper
remain. Minimum sampled available memory was 46.981 GiB.

All 874 retained-root files and modes (866 governed plus eight Python caches),
complete 821-file Lean set, 886 captured managed inputs and 866 original
governed-source byte/mode comparisons matched afterward. All 54 archived
precleanup records matched their captured hashes/sizes. The exact traceback,
available streams, inventory, phase review and managed records are retained in
`tmp/platform-concurrent-inner-diagnostic-298/`. Its verified 47-member shareable
bundle is 842,725 bytes, SHA256
`dda08150a42a2f0ea4f6ebaf987cadf2690fc17168861f74e734feab981ce6b2`;
the private environment is excluded.

No further diagnostic ran. The coordinator requested an unapplied test-only
watchdog patch and complete affected-coverage plan, preserving the barrier and
all checks. An outer-only adjustment cannot fix the now-established worker limit.
No source/deadline change, publication, merge or CLI memory update occurred.

### Unapplied platform watchdog repair and affected coverage

The coordinator requested a concrete minimal test-only proposal after the inner
exception was established. Both worker60 sites are present in earliest retained
commit `32d50d68e9`, with fifteen Lean files. The outer watchdog grew to 180 in
`3fdda42dc1b` when there were thirty-three Lean files and seven candidate mappings;
current target `47fe4003c0` has 821 Lean files and thirty certificate roots.
No inspected elapsed-time assertion or performance contract requires those
inherited numerals.

The exact proposal adds one named 180-second setup-worker budget, uses it in
both the shared helper and concurrent communicate call, and sets only the
complete symlink wrapper's watchdog to 900 seconds. The startup barrier and
unrelated command timeout remain fifteen seconds. Every case, assertion, mock,
generator, source/input check, proof setting and cleanup remains unchanged.
These are finite engineering budgets, not established completion bounds. The
outer estimate accounts for eleven serial workers plus one four-worker group,
with additional copying/snapshot work; no automatic retry or later increase
is proposed.

The shared helper serves six methods and eleven invocations; concurrent setup
adds one method/four workers. The other five class methods have no worker-budget
change. All twelve methods together run fifteen setups and, on their complete
passing path, 450 generator invocations. A single successful final-input original
symlink wrapper executes those same twelve bodies with the complete current
input set and required alias environment. Its actual result, unchanged selection,
no-skip code paths and input applicability must be verified before composing
coverage; no fresh non-symlink invocation is claimed. The wider 637-result reuse
assessment and mandatory native/Lean assurance remain separate final review.

The proposal and exact invocation map are retained in
`tmp/platform-watchdog-repair-298/`. Patch SHA256 is
`3ea1a76ed86604f7ecf4c71da7f7a26e7f2524f67df320b040dc51f15537496f`.
The candidate parses/compiles without execution; removing its new constant and
reverting the three timeout keywords reproduces the entire original AST.
All four live test copies remain identical, and git apply --check succeeds
without applying the patch. The verified nine-member proposal bundle is 28,703
bytes, SHA256 `56e861a8ec210c8345dbe1597c08cf6dd02ce092866ccb4a7c7947327a84257a`.
No test/source edit, changed-timeout execution or additional diagnostic occurred.

### Approved platform repair and successful final-input wrapper

The coordinator authorized the exact proposal above and one complete wrapper.
The source-only repair is `92412ec75f4b1bcf5ab99022ac378801a3d16763`, integrated
as `9e89c80f82`. The final test SHA256 is
`92e107283974c2f905f5a7c96eab3fc306c51df5ec4034b06148a2ffd8773a30`.
Only the approved worker 180 / wrapper 900 watchdogs changed; the barrier remains 15.

Native Linux managed run `20261108T075522-000e545aebc8` succeeded. The original
outer method passed once with zero errors, failures, skips or reporting errors:
unittest 622.698 s, observer 626.778 s, managed 647.801 s. Normal imports and the original
wrapper selected all 12 PlatformIsolationTests. Its unchanged assertion establishes
successful nested exit; the class contains no skip or conditional-selection path.
The nested successful stdout remains internal to the original method. Neither
the collector nor observer replaced its subprocess or reconstructed unavailable
output. This freshly exercises the twelve bodies under the symlink environment;
a separate fresh non-symlink run is not claimed.

The observer saw one nested suite and 15 setup workers directly parented by it,
matching eleven serial calls and four concurrent calls. Its raw command-substring
filter counts 16 observations because a worker child was briefly sampled with
its parent's command line. The supplemental worker review records the parentage
and preserves that raw count. The nested suite and all matching observations
used the same verified symlink for TMPDIR/TMP/TEMP. Sampled short-lived processes
are not a complete generator invocation census.

Postflight explicitly rehashed all 884 managed inputs unchanged and verified all
866 governed/copied byte/mode identities and the complete 821-file Lean set.
The only input difference from the prior fixture is the approved test repair;
the other 865 source files match 47fe4003c0. No descendants, owned lease or temporary
entries remain, and the observer sent no cleanup signal. Minimum sampled available
memory was 43.962 GiB. Four workers were reserved, with preflight total 17/22.

The complete result and source inputs are retained in
`tmp/final-platform-fixture-298/`. The verified 903-member shareable bundle is
4,555,596 bytes, SHA256
`26f9b37bbca5b48f00416079aa6c7672dcd8138de60e482078260bc80009c623`;
private inherited environment is excluded. The report's review target is
`5aa1509fc5ac2d6f2dc02c5803d94da7e201aaf1`, production 47fe4003c0. Earlier failures
remain failed. Separate 637-result applicability review and complete native/Lean
assurance remain mandatory. No retry, further timeout change, publication, merge
or CLI memory update occurred.

### Independent composition of the final regression results

I accept regression-result composition for integration
`5aa1509fc5ac2d6f2dc02c5803d94da7e201aaf1`, with production proof/src/scripts
`47fe4003c0` and native source `560144172c`. This acceptance covers regression
applicability only. Complete native proof/audit, complete Lean/source
correspondence and any future Rosetta promotion remain separate requirements.
The original full run `20261108T021923-5ef7f9b81de7` remains failed: 635 passes,
two errors and zero skips. No new test ran during this read-only applicability
review, and no source or test change was made.

Independent AST inventory reproduces all 637 unique original IDs in discovery
order, including five inherited Array-report definitions and nine imported
`tests.test_shared_bindings` aliases. Current tracked test files match the target
and there are no additional Python test files or dynamic discovery hooks. Raw
log extraction independently reproduces the original census and every outcome,
including fifteen cases with intervening docstrings or subprocess output.
The coordinator's preparation matrix was a lead, not the acceptance evidence.

| Applicable evidence | Required IDs | Actual run |
| --- | ---: | --- |
| Retained original successful results | 619 | `20261108T021923-5ef7f9b81de7` |
| Fresh affected source-policy methods | 4 | `20261108T072619-eca79cdaf440` |
| Fresh repaired chunk fixture | 1 | `20261108T065724-7d260468ca14` |
| Fresh platform bodies through the original wrapper | 12 | `20261108T075522-000e545aebc8` |
| Fresh original platform wrapper | 1 | `20261108T075522-000e545aebc8` |
| Total, with one disposition per original ID | 637 | |

The production/test delta from `c437a41d30` is exactly 80 added Lean components,
eight modified Lean files and the two reviewed watchdog repairs. Native source,
scripts, samples, catalogue, Rosetta data/render tooling, projects, configuration,
Lean pin, lakefile and generator are unchanged. Remaining changes are evidence,
review/design documentation and roadmap, which these tests do not consume.
Of the original 1,031 captured test inputs, 1,021 still match; the other ten are
exactly the eight modified Lean files and two tests. Added Lean paths are checked
against the complete current tree. All 2,588 original native build inputs and
the recorded native tool binaries, compiler, adapter, Lean and Lake identities
also match. This retains the original build's applicability, not full-proof
acceptance. The retained sample manifest is byte-identical and contains all
72 samples exercised by the original successful sample methods.

The shared `LeanModuleTests.lake` default remains 60 seconds; only the selected
chunk method supplies 180. The other two test methods and their shared build
and audit calls forward the same default and use unchanged synthetic modules,
AxiomAudit/Audit and pin. Reversing the new parameter/forwarding and selected
keyword produces the original whole-module AST. The platform module likewise
normalizes exactly to its original AST after reverting its constant and three
watchdog keywords. Assertions, inputs, generator behavior, proof settings and
cleanup were not weakened.

All twelve platform methods need fresh coverage because their setUp copies the
complete proof tree, including five methods whose worker timeout did not change.
The original wrapper provides that coverage under the symlink environment, with
normal imports, unchanged selection and no skip paths. Its successful nested
exit establishes those body results; no second non-symlink run or unavailable
nested success log is claimed. Other installation methods do not call the
changed worker helper or read changed production Lean modules.

Dependency review distinguishes actual production reads from synthetic or native
proof reports. The four fresh source-policy tests traverse the full proof tree
or affected import closures; their exact launcher, raw success log and all
847 declared inputs match, including all 824 production proof files. Other
source/generator tests read unchanged bindings, certificates/output chunks,
source bytes and generator, or synthetic strings. The native certificate probe
uses only six unchanged helper modules. Lean evidence/runner/history fixtures
construct temporary synthetic roots and mock tools; their native probes copy
only unchanged AxiomAudit, source bindings, lakefile and pin. Other native,
report, provenance, dev and sample tests use unchanged compiler/tool/configuration
inputs, synthetic reports, application GNATprove output or the unchanged native
proof-container GPR. The altered production Lean graph is not an indirect input
to those retained methods. Shared helper imports and inherited definitions are
accounted for in the per-ID matrix.

The successful chunk fixture copies seven production Lean modules, nine helpers,
lakefile/pin/generator and the test, all equal to the target; its original generated
17-module cold closure and edit cases do not exercise all 821 production modules.
The successful platform fixture instead copies all 866 target input files and
all 821 Lean paths. Both scopes match their test semantics. Their existing
verified bundles remain byte-identical. Successful repair results supplement
the failed original run; they do not rewrite it or establish universal assurance.
No required regression ID remains uncovered, so another identical full-suite
execution is unnecessary under the development.md composition rule.

The complete independent matrix, source/dependency rationale, raw outcome
extraction, AST and input comparisons are retained in
`tmp/regression-applicability-review-298/`. Its verified 18-member bundle is
432,596 bytes, SHA256
`fb1900bcca3685f8d7dc2083e75e46eb7c167f22c6067050c68b253015f3c239`.
At handoff integration is `d396db2aeb498cd132bbe4b9f0ea3f0fb93687f8`; an explicit
comparison shows only four platform-evidence/review documentation paths changed
since the target, so this disposition extends to that observed follow-up.

The three currently unchanged Rosetta tests are included among the 619 retained
passes. Their future promotion has not been applied or accepted here: all three
must run freshly after that patch. Other later changes require ordinary
applicability review. Selected reviewer remains GPT-6 Astra / Extra High, with
runtime telemetry unavailable. No publication, merge or CLI memory update occurred.

### Four failed native postconditions: independent diagnosis

Complete native Linux run `20261108T040128-2651963b8574` actually failed at
08:23:26 UTC, exit 1 after 15,717.688 s. The coordinator requested diagnosis
without another run or source change. Review of the frozen source, generated
Why3 tasks and recorded outcomes establishes a concrete full-domain defect in
`Parameter_Frame`, plus specific modular-contract gaps in the other three
obligations. Increasing prover budgets or repeating the unchanged complete run
would not repair the demonstrated false postcondition.

The exact parser input is SHA256
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`, native snapshot
`560144172c`. The native owner retained the failed evidence in commit
`0e11f7f9dc7e38d2780366ece82976fad6feb7a3`; sources, caches and original outcomes
remain unchanged. All four ordinary-prover branches report timeout at their
30 s settings; their CVC5 counterexample branches time out at 10 s. No prover
counterexample was reported. The counterexample below is independently derived
from source, without compiling or executing a program or proof.

| Failed postcondition | Diagnostic location | Root check location / GP_Check id | Why3 leaf | Other split children proved |
| --- | --- | --- | --- | ---: |
| Actuals_Model | 4794:16 | 4794:16 / 2612 | def'vc.71 | 71 of 72 |
| Function_Local_At | 5615:19 | 5614:16 / 3154 | def'vc.50 | 50 of 51 |
| Parameter_Frame | 5709:20 | 5703:28 / 3207 | def'vc.98 | 98 of 99 |
| Function_Return_After | 5736:16 | 5736:16 / 3214 | def'vc.35 | 35 of 36 |

All locations are in `silver_output_profile.adb`. The retained identity matrix
includes exact task SHA256, source labels, session theory/goal names, report
entities, message IDs and complete prover check trees. Diagnostic subexpression
locations and enclosing check locations are deliberately distinguished.

For `Parameter_Frame`, take `Text = "x"` and
`Frame = (Invalid_State with delta First_Parameter => 1)`. Every written
precondition holds: position zero is within bounds, the empty metadata and all
empty environments satisfy their quantified validity predicates, the zero name
pair is explicitly valid, and first-parameter index 1 is positive and no greater
than parameter count 0 plus 1. Every field is initialized and well typed.
The function initializes Result to Frame; its loop condition `1 <= 0` is false,
so it returns Frame with First_Parameter equal to 1. The model tests Position
zero before its beyond-last test and returns canonical Invalid_State, whose
First_Parameter is 0. Thus the required static equality is false. The runtime
part still holds, matching the reported failing static subexpression. The
witness does not depend on array equality or a solver strategy.

A minimal candidate repair returns Invalid_State when Frame.Position is zero
before entering the loop. This preserves the entire declared domain and the
model's specified result. Restricting the precondition to positive positions
would exclude the witness by narrowing the domain and is not an authorized
repair. Actual callers avoiding this state would not establish the full-domain
subprogram contract. A focused proof of the candidate remains necessary and
could expose further proof-engineering work; no repair has been applied.

The other three findings are distinct from that actual behavior/model mismatch:

- `Actuals_Model` recurses at the comma token's result, which may be zero. Its
  recursive contract allows a nonzero result from zero input and supplies no
  relation back to the original positive position. The generated task has that
  weak induction contract and no self-definition axiom. Proved zero-input
  preservation in the induction contract, with the corresponding Actual_Model
  fact, or an explicit rejected-comma branch would supply the missing argument.
- `Function_Local_At` promises successful preservation of Functions,
  First_Parameter and Pure. Its scalar and Boolean declaration callees export
  validity/progress, but no such preservation facts; their generated program
  contracts do not expose bodies that could supply them. The source's successful
  scalar branch updates only Position/Scalar_Names, and the Boolean branch only
  Position/Boolean_Names. Add and prove the guarded frame facts in those callee
  postconditions before proving the wrapper. Do not weaken whole-record equality.
- `Function_Return_After` calls Actual_After at a possibly zero failed-keyword
  cursor. The latter's explicit range contract does not say an accepted result
  requires a positive input. Exposing that proved property, or explicitly
  returning zero for a failed keyword, makes the progress composition local.
  Its static link through Actual_Model offers a larger definition-based route,
  but the timeout does not establish that extra solver time would complete it.
  Lean's existing actual_post/return_post argument explicitly uses the stronger
  positive-input fact; that semantic proof does not replace native discharge.

Earlier run `20261107T231059-a9f0c12c8350` does not establish earlier success for
any of these four obligations. Its retained reports contain 66 units and
12,558 info flow/proof records, plus three flow warnings. They contain no
`silver_output_profile.spark`, no parser sessions or these four tasks, and no
parser-unit section in the retained final summary. Current evidence has 77
units and 18,524 records, including these four failures. The earlier total
applies only to its recorded checks; neither run completed the required audit.

The parser bytes and annotations, exact native command/options, 12-worker request,
cache location, tool identities and why3.conf are identical between these runs.
The prepared input maps differ only in `src/silver_library_reports.adb`, from
SHA256 `700e6fb94d4d722cb3d95a8c145c03bee44dd36a6384bb693772dd6bc8531459` to
`3254d7d3236cbaa689e61a4dc13478d29ab9cafe6cfdd5f0ba8b2ecff4d13b25`, the retained
unused-formal/ineffective-initializer repair. There is no older parser task to
compare, so no task equivalence or prover nondeterminism is inferred. This
review does not establish why the eleven additional units were absent earlier.
The examined prior focused parser-equality packet addresses other functions;
no matching earlier attempt for these four was found in the supplied evidence.

After all four findings were consolidated, the recommended smallest experiment
is an isolated focused native proof of the Parameter_Frame entry guard under the
original settings and full domain. Then prepare and prove the other three
repairs with their affected callees, retaining exact input/task outcomes before
another complete native run. No experiment, source/test/proof/script edit,
process signal or source-domain restriction occurred during this diagnosis.

Active Lean checkpoint `064001` must keep its captured inputs. Any eventual
parser repair changes authoritative source and requires regenerated source
certificates/chunks, corresponding body/contract checks and semantic proof
review, followed by complete native and Lean/source-correspondence validation.
Parameter_Frame's loop text is checked by FunctionDeclarationSource and
FunctionSourceParts/DeclarationLoopParameterFrame; FrameEquations relies on its
static contract as a premise. Updating source pins alone cannot resolve a false
native premise. Preserve completed unaffected objects and the running checkpoint's
actual outcome. The existing regression acceptance remains valid for its
unchanged snapshot; a later repair needs ordinary affected-input review.

The detailed diagnosis, complete witness, exact source delta, task/session
identities and selected generated-theory readings are retained in
`tmp/native-postcondition-diagnosis-298/`. This reviewer independently verified
301 consumed retained artifacts by decompressed size/hash. Its verified
103-member bundle is 4,032,648 bytes, SHA256
`8e778022d872a81092910454bc9c6f23fc5ad790209fea593b2833307f530df1`.
Selected reviewer remains GPT-6 Astra / Extra High; live runtime telemetry is
unavailable. No publication, merge or CLI memory update occurred; goal is null.

Separately, read-only review found no issue with the coordinator's proposed
CallsIncludedImpl qualification patch `fcf1698abd92167b5438846c0c8c59a6cb6708ac4cc7c04895add0f1bddd8974`.
It selects the same expectedTokens namespace used by Checked.included_impl;
both competing definitions are `(Source.lexLine text).getD []`. It was not
applied or validated here and still needs its affected proof after lease release.

### Minimal remaining native repair plan and bounded reader review

The separately owned Parameter_Frame entry guard is now source commit
`b8365c0606e0d2e185e89a73264b10cf72530e06`, parser SHA256
`e23559aa4b480bb4f69df99fb9c28c590ef9320388dc48c44e2604dd5226918c`.
Focused run `20261108T084757-1036cb8a0958` passed with actual exit 0 after
82.341 s: 27 proof records, 2 flow records, all 82 proof-tree branches and all
14 postcondition branches proved. Evidence commit
`5a92be1916ae1d748c354a4ced9ad59102eea13d` retains the complete selected scope.
This reviewer independently verified all 155 indexed gzip artifacts by
decompressed size and SHA256. The outcome establishes that full selected
subprogram contract on the guard base, not a complete native audit. The native
owner's subsequent ledger search found no earlier completed focused scope for
these four failures; interrupted run 014042 has no completed parser report.

The coordinator requested a concrete plan for the remaining three gaps without
source edits or native/Lean execution by this reviewer. The resulting unapplied
patch changes five sites: guarded successful frame preservation in the scalar
and Boolean declaration contracts, failed-comma rejection in Actuals_Model and
its executable Actuals_After loop, and failed-return-keyword rejection before
Function_Return_After calls Actual_After. Every precondition, existing post fact,
assertion level, loop invariant and variant is preserved. The matching executable
comma guard is necessary to keep the existing static model-equality proof aligned.

Patch SHA256 is
`a6c87808887548b8723e7febfce0823a6679312b55fb3b21da5873d27355ee21`, against the
exact guard base above. Static reconstruction in memory independently yields
candidate parser SHA256
`036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`; no candidate
Ada file was written here. The proposed six full-subprogram selections are
Scalar_Declaration_At, Boolean_Declaration_At, Actuals_Model, Actuals_After,
Function_Local_At and Function_Return_After, at candidate body lines 1512, 4457,
4803, 4828, 5628 and 5747. Keep original native proof settings and use a separate
managed exploratory scope with four workers. A failed focus requires its exact
diagnostic checkpoint before another attempt.

The detailed plan identifies each direct Lean/source file and proof obligation.
Keep the existing semantic models and domains; prove unconditional
actualAfter_zero and actualsAfter_zero in PredicateCallAdmission, add the matching
typed-tree guards, and update actuals_model, normalized_actuals_at,
returnAfter_model and returnAfter_imports to split the rejected cursor branch.
PredicateBodyProperties.readCondition_zero corroborates the Boolean fact, but
importing that module into PredicateCallAdmission would cycle through
PredicateFunctionCallReadings; use the direct foundational argument there.
Both exact scalar header lists and the Boolean specHeader must reflect the
stronger native contracts. Integrate the separately owned Parameter_Frame loop
shape, regenerate authoritative source/chunks, and rebuild the affected source
leaves and complete import closure. Actuals_After remains linked by its unchanged
complete native static-equality postcondition; no unrelated new loop-shape checker
is proposed. Pin updates alone establish none of these semantic obligations.

The existing 637-ID regression acceptance remains scoped to its previously
reviewed inputs. Changed compiler/source/Lean bytes require per-ID applicability
review for native/compiler/sample behavior, source policy/provenance, and the
platform fixture's complete production-tree copy. Synthetic methods and the
synthetic chunk fixture may retain evidence only when their actual dependency
sets are unchanged. Do not carry forward the old 619 passes as one presumed
unaffected group. The three fresh Rosetta tests remain required after promotion.
Focused successes must be followed by complete native obligation/provenance and
Lean/source-correspondence validation on identified final inputs.

After completing that plan, bounded read-only review found no objection to the
two-line Callee_At reader patch, SHA256
`34b2aeb798af54caa06e0005e1f164ee40e7209be5bcde88a6391ef15bea2c4c`.
Source.expressionBodies requires a single-token result type; the actual header
returns Functions.Function_Count. Existing SourceBridge.qualifiedExpressionBody
matches that qualified shape and retains balanced-body, trailing-semicolon and
singleton-match checks. Both complete exact callee headers remain required.
The patch changes only Checked.callee_at_body and its CallsCalleeAtBody source
leaf proposition; typed tree, render, denotation and native source are unchanged.
It was not applied or Lean-tested by this reviewer and needs its fresh affected
leaf/import closure.

The plan, exact patch/inventory, static reconstruction, guard-packet verification
and bounded reader review are retained under
`tmp/native-postcondition-diagnosis-298/remaining-three-plan/`.
PLAN.md SHA256 is
`14f1ec6affe467855ae04df84f29dd7ed3ca33a34aaee431f891f898d77dace3`.
The separately verified 9-member bundle is 18,848 bytes, SHA256
`197e15b7cb32f70cf5b13b42cd5ea5af4d2558cdb8ebc2179c2effe388439b63`.
The original four-obligation diagnosis bundle remains unchanged.

At this handoff the coordinator reports Lean run 064001 ended and its lease was
released, accepts the bounded proposal, and has authorized the native owner to
apply the five sites and run the six focused checks. Integration semantic/source
edits are separately owned and in progress; their proof outcomes are not claimed
by this review. Selected reviewer remains GPT-6 Astra / Extra High, with runtime
telemetry unavailable. No source/test/proof/script edits, native/Lean execution,
signals, publication, merge or CLI memory update occurred here.
The live harness goal was rechecked and is null.

### Integrated repair review: 68c4fd259b and normalization follow-up

Bounded review of `0c7ed70356..68c4fd259b` found no mathematical or source-linkage
defect in the integrated repair. This is not acceptance of a completed checked
result: its focused Lean compilation failed, and complete final native/Lean
evidence remains outstanding. Native parser bytes independently match the exact
approved candidate `036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`.
The original domain and every precondition/assertion/invariant/variant are retained.

The 14 handwritten changes implement the planned semantic bridge without changing
existing Lean model definitions or native input-domain predicates. actualAfter_zero
is unconditional and covers Boolean and scalar readers, including both array
metadata cases; actualsAfter_zero follows from the first rejection branch.
The actuals tree's comma guard preserves the original model through that lemma,
and normalization retains existing import/definition hypotheses, totalization
and induction on last - first. The return command guard likewise preserves the
existing return model through actualAfter_zero, keeping ReturnImports unchanged.
All four affected semantic theorem statements were independently compared and
are identical. The stronger native header requirements, Parameter_Frame expected
loop and both previously reviewed reader/name repairs align with the exact source.

Static reconstruction checked all 6,021 ordered line occurrences, including the
final empty line, through 3,913 unique certificates and all 6,020 joins. They
reproduce the exact native bytes. The ordered certificate tokens equal both the
generated complete token list and outputImplementation: 62,191 becomes 62,309;
every other source pin is unchanged. Generated buckets 0, 1, 2, 4, 5 and 7 change;
3 and 6 remain byte-identical. Both scalar header lists, the Boolean header and
Parameter_Frame's expected loop independently match complete source tokens.
Line lexical proofs and character equality witnesses still require actual kernel
checking; static reconstruction alone does not discharge source correspondence.

Retained run `20261108T090716-23e8e3641bc7` failed at 09:10:38 UTC with exit 1
after 200.406 s managed and a 172.551 s build. This reviewer independently verified
all three indexed packet artifacts and read the actual error goals.
PredicateCallAdmission, PredicateFunctionCallNative and PredicateFunctionCallEquations
compiled. returnAfter_model retained apply2/apply4 in its goal; the comma
normalization retained modelCalls.actual and did not match its hypothesis.
Consequent unused-simp and recursion diagnostics remain part of that failed run.

The separately reviewed follow-up `f630819154` adds only apply2/apply4 in the
return-model simplification and modelCalls in the two comma-branch simplifications.
It changes no statement, model, domain, native source, source tree, header, pin or
certificate, and disables no checker/linter. The structural disposition extends
to that follow-up; successful affected compilation is still required, followed
by the complete native and Lean/source checks. The failed outcome is preserved.

Detailed reasoning, exact handwritten/follow-up patches, static inspection script
and results, and verified failed-run evidence are retained in
`tmp/integrated-native-source-review-298/`. Its verified 10-member bundle is
136,244 bytes, SHA256
`65bf37df8fe1c3322c90296f2996c106e136912b192db9f9fd4b9820c7cf82ae`.
No production edit, native/Lean/compiler/fixture/generator execution, signal,
lease/cache change, publication or merge was performed by this reviewer. Selected
reviewer remains GPT-6 Astra / Extra High; runtime telemetry is unavailable.
The requested per-ID regression applicability preparation is separate next work.

### Focused semantic success and exact regression preparation

The normalization follow-up now has actual focused success. Retained run
`20261108T091153-a212a5bfebc3` completed successfully at 09:13:32 UTC in
98.938 s managed. The log records a successful 50.621 s build, newly completing
PredicateFunctionCallHelpers, FunctionDeclarationDenotations and
FunctionDeclarationImports, followed by a fresh 13.123 s axiom audit. Its closure
contains 101 modules including AxiomAudit, and the audit checks 16,853 declarations
with only propext, Classical.choice and Quot.sound. Actual settings are four Lake
workers and four threads per process on Linux x86-64. This reviewer independently
verified all four retained gzip artifacts and read the log/events/evidence;
copies are under `tmp/integrated-native-source-review-298/focused-followup-success/`.
This is incremental focused semantic validation, not complete source closure or
complete native assurance. Run 090716 remains failed.

The requested read-only regression preparation compares previously accepted
5aa1509fc5/d396db2aeb with 68c4fd259b, extends through the two proof-body reductions
in f630819154, and checks the docs-only follow-up 6b6969187e. Exactly 22 tracked
non-documentation inputs change: the parser and 21 Lean files. Tests, scripts,
samples, catalogue, Rosetta inputs, project files, generator, lakefile and pin
remain identical. Reusing the prior independently resolved inventory by exact
test-module identity accounts for all 637 unique IDs, inherited methods and
imported aliases, without another discovery/test execution.

The exact per-ID matrix identifies 286 reusable outcomes and 351 IDs requiring
fresh evidence: 331 compiler/build/sample consumers, seven source-policy methods,
the original platform wrapper and its twelve nested bodies. The selected top-level
commands contain 338 compiler/policy IDs and one wrapper ID. Their unittest -k
matching was checked statically against the complete census to exclude extra or
missing selections. The wrapper's unchanged twelve-body selection supplies
nested coverage; it is not counted as twelve fresh top-level outcomes.

Both sample tests require fresh execution through the repaired compiler. Pure
task-oracle and capacity-envelope methods remain reusable, as do the two
adapter-only methods on unchanged adapter/native identities. Standalone argument,
report and image probes have unchanged explicit inputs/dependency closures that
exclude the parser. Synthetic evidence, history, runner and provenance fixtures
remain reusable on their unchanged actual dependencies; the matrix states the
basis for every ID rather than retaining the old 619 as one group.

All 20 inputs copied by the successful chunk fixture remain byte-identical,
including its seven fixed Lean helpers and synthetic-source test. No repeated
chunk run is indicated. All 22 changed inputs occur in the full platform fixture
copy, so its wrapper must run freshly. FunctionDeclarationDenotations and
PredicateFunctionCallHelpers are also recorded with their changed f630 hashes
in that platform-copy set. The three other installation methods remain reusable.
The three unchanged Rosetta passes apply to this target only; promotion still
requires all three tests freshly after its own patch.

The plan supplies exact unexecuted managed build/test commands and complete argv
arrays. Execution requires stable final inputs, a successful repaired compiler
build, matching retained tool/configuration identities, and coordinated resources.
An outer four-worker test reservation alone does not cap application -j0 children.
The coordinator proposes a separate synchronized regression worktree and an
inherited four-CPU affinity mask; bounded review finds that can enforce CPU
allowance without changing tests/options, but it cannot cap native process count
or RAM and does not reserve exclusive cores. Capture actual masks, descendants,
memory, inputs, argv/CWD and postflight. The tool launcher starts under host.context
and must invoke unchanged discovery from the regression root. Keep it outside
scripts/. Serialize if actual resource capture/headroom cannot support overlap.
No such launcher, build or test was executed by this reviewer.

The full matrix, source/fixture comparisons, exact commands, follow-up hashes and
resource assessment are retained in `tmp/regression-delta-68c4-298/`. Its verified
15-member bundle is 134,494 bytes, SHA256
`ad4f4058781822e1cedb9ac73c31c7903854e1353aab8923ae91558e26087740`.
This is applicability preparation, not final acceptance: fresh outcomes and final
tool/input stability must still reconcile all IDs. Complete native proof/provenance
and Lean/source correspondence remain separate obligations. No production edit,
native/Lean/test execution, signals, publication, merge or CLI memory update
occurred here. Selected reviewer remains GPT-6 Astra / Extra High; runtime
telemetry is unavailable.
The live harness goal was rechecked and remains null.

### Bounded four-CPU regression launcher review

Read-only review found no remaining launch blocker in the final prepared launcher
SHA256 `c5cffd2d7b2c1a5421c60ce62901a485b0cbc6e4c2eac5f5abdab756e426208c`
and concrete managed command SHA256
`d3ccf094f5e897ccb0b9684bb4a79c70792f83f6a981d05f2e6732c257ece22b`.
The prepared commands.json exactly matches the prior reviewed vectors and selects
338 compiler/policy IDs or one platform wrapper through unchanged unittest
discovery. The actual working directory is the regression root. The selected
input-tree comparison of regression commit 4281f71171 with f630819154 is empty.

The initial launcher dropped the inherited ManagedRun lease at its unittest
Popen boundary. The coordinator corrected that concrete lifetime gap before
execution: the final launcher inventories inherited descriptors, requires the
single existing managed lease, explicitly passes it to unittest, and continues
waiting for the actual child after observer errors. Interruptions are recorded
and forwarded to the owned child process group. Observer failures, interruptions
or recorded affinity violations make the wrapper nonzero even if unittest exits
zero; the actual unittest exit remains separately recorded.

The managed command reserves four workers and leases the entire regression
host-artifact tree plus its mode-specific observation directory. Its 16 declared
input categories cover launcher/selector files, src/proof/tests/samples/catalogue,
the three Rosetta inputs, project configuration, generated/toolchain context,
compiler and adapter. dev.py tool additionally captures scripts, Python/custom
executable and native tool identities and performs declared-input postflight.
No missing stable-input category was identified for the selected scope.

The launcher sets its affinity to four actual allowed CPUs before starting
unittest, which inherits the mask. It records original/selected masks and samples
descendant process-leader masks and RAM every 15 s. This is not continuous
all-thread/short-lived-process observation, exclusive-core allocation, a native
process-count cap or a memory limit. Those limits remain explicit in the
coordinator's resource monitoring and acceptance of actual evidence.

The coordinator reports the corrected launcher has now started; this reviewer
performed no execution or signal. Actual test results, input postflight and
resource observations remain pending. Exact reviewed files and inspection
metadata are retained in `tmp/regression-launcher-review-298/`. No production
file was edited. Selected reviewer remains GPT-6 Astra / Extra High, with runtime
telemetry unavailable; live harness goal is null and CLI memory was not updated.

### Three affected-regression errors: bounded diagnostic checkpoint

Reviewed regression inputs are commit 4281f71171, matching f630819154 for the
selected tree, parser SHA256
`036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`,
and compiler SHA256
`807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`. This
checkpoint concerns run `20261108T093645-d959cfabae08` and its three exact error
methods, not another broad implementation review. The run actually finished
failed at 12:21:44 UTC, after 9,898.123 s managed;
unittest took 9,885.693 s. Driver, managed run and actual unittest exits are all 1.
Final tracebacks independently confirm subprocess.TimeoutExpired in each compile
call at the deadlines below. These are not failed application-output assertions
or proof-obligation verdicts. No observer error, interruption or sampled affinity
violation was recorded.

Independent final-log reconstruction resolves all 338 selected IDs exactly:
335 passed, three errored, no failures or skips. The apparently missing
PathRefinementTests.test_counted_loop_definiteness_decides_required_rejection
uses unittest's normal two-line docstring display at lines 2727–2728 and is `ok`;
its output was not lost or interleaved. Imported `tests.test_shared_bindings`
aliases are retained as their distinct discovered IDs. All 72 manifest samples
passed before the maximum-expression error. This reviewer verified all 34 indexed
coordinator packet payloads and reconciled its independent postflight table with
the exact 1,115-key original prepared map: every recorded hash is unchanged.
The coordinator performed the live file rehash; this reviewer did not repeat it.
The retained packet is
`docs/evidence/scalar-functions-20261107/final-regression/repaired-compiler-policy-093645/`.

| Method | Compile deadline | Preserved author input |
| --- | --- | --- |
| `test_samples.SupportedSampleTests.test_maximum_dynamic_expression` | 300 s | 395 bytes, SHA256 `3dfeee525b935212f90c161d4eadc87ac1707aa1f33f347bcc008b2ef75ffbae` |
| `test_scalar_functions.ScalarFunctionTests.test_native_boolean_and_integer_self_actuals` | 120 s | 312 bytes, SHA256 `4cb9e12d0ce7114ee42ae51d2d7cf2a541935ba502ea1feccc5de3d3e403cbbd` |
| `test_scalar_functions.ScalarFunctionTests.test_native_ordered_calls_snapshot_and_full_unused_coverage` | 120 s | 631 bytes, SHA256 `3d58f122f47611646d6ef54794100ec89ab94bb6daea301a8ec76e1f369ee9da` |

All 515 archived files independently match their recorded sizes and hashes:
181 for maximum expression, 161 for self actuals and 173 for ordered calls. The
maximum packet has no completed Main .spark report. Each scalar packet omits
silver_io.spark and has no bin/ executable. Their later GNATprove reports list
only four analyzed units, with 20 and 23 total checks respectively and no listed
unproved checks; five units and the application's function coverage are required.
The ordered Main report contains its proved division and termination records.
SARIF executionSuccessful values do not establish complete application coverage,
the compiler's audit, a completed build or either test's output assertions.
These summaries were written after the error windows, at 11:47:52–53 UTC and
11:50:20 UTC respectively. They remain diagnostic artifacts, not passing results.

The three methods are `ok` in independently hash-verified raw evidence from
`20261108T021923-5ef7f9b81de7`. That earlier run itself failed on two different
fixtures. Both test modules and both shared helpers are byte-identical to its
c437a41d snapshot; parser/compiler inputs changed. The earlier command ran
unittest discovery directly with a two-worker reservation, without the new
affinity wrapper. No actual old affinity or per-method elapsed times were
retained. Its successful methods are useful comparators, not acceptance of the
repaired compiler or a controlled performance comparison.

All three current workspace windows show Why3 `-j 22` under CPUs 18–21, despite
the four-worker managed reservation. The maximum-expression capture also records
native gprbuild `-j22`. No sampled process-leader affinity violation occurred;
that says nothing about sufficient CPU service for each timed test. The
coordinator's preserved maximum tree was reparented to PID 1 and continued on
those four CPUs across both scalar-error windows until recorded cleanup at
11:51 UTC. Once reparented, it left the launcher's ancestry-only sampling tree,
so later descendant process/RSS counts omit that competing work. The cleanup
record reports no remaining live owned processes at 11:51:05 UTC; this reviewer
issued no signals and did not audit the cleanup helper. Sampled host available
memory stayed above 50 GiB across these three workspace windows. Oversubscription
and orphan contention are supported hypotheses; resource causation and a general
runtime bound are not established by this evidence.

The coordinator's post-exit process readout at 12:23:50 UTC found no matching
regression process-group members or reparented regression-artifact commands.
It still records 14 of 22 workers reserved for productive native and Lean runs;
this snapshot does not replace the required prelaunch recheck.

The smallest next check retains every test and production option. After true
completion, exact final-input reconciliation and clean relevant process/lease
state, wait for the productive dense native/Lean runs to release capacity. Use
the full actual CPU allowance with a matching managed reservation, first for the
maximum method alone, then each scalar method in a separate invocation. At
preparation the unrestricted mask was CPUs 0–21 and budget 22; recheck those facts
before execution. Keep the 300/120 s compilation deadlines, 10 s execution
deadlines, production timeout 0 and steps 100000, prover selection, full domains,
source checks, report coverage and all output assertions unchanged. Retain and
diagnose a repeated failure before any further attempt, including orphan state.
A passing retry supplies fresh evidence but does not retroactively classify the
original failed run or prove its cause.

The remaining full platform wrapper should follow those three methods under the
full then-available allocation, using its existing ordinary managed `--jobs 0`
command without the four-CPU restriction. Its unchanged current outer deadline
is 900 s; it runs eleven sequential setup workers and one four-worker group,
generating current certificates with mocked native/Lean tools. This is scheduling
of the already-required twelve-body wrapper, not a new fixture or deadline edit,
and not native cross-platform assurance. Extra cores do not imply proportional
speedup for sequential work. Keep successful unaffected results only after exact
final applicability review; complete native and Lean/source evidence remain
separate requirements.

Inspection script, verified archive copies, source/report extracts, resource
window, prior-run comparison and exact unexecuted commands are retained under
`tmp/regression-failure-diagnostic-298/`. Each retry selector independently matches
exactly one of the 637 previously resolved IDs; no new discovery was executed.
The verified 49-member bundle is 1,566,585 bytes, SHA256
`45ce1a148c1b7f70cfe7ecd918c3d769392d340779a47f99048a5ef3beec68fe`.
Selected reviewer remains GPT-6 Astra / Extra High; runtime model/effort telemetry,
token/cost data and complete elapsed review time are unavailable. No production,
test, proof or launcher edits, builds, native/Lean/test execution, signals,
lease/cache changes, publication, push or merge occurred here. The live harness
goal was rechecked and is null; CLI memory was not updated.

### Lake-only scheduling hold assessment: active complete run 094147

A stop of only the verified Lake process can defer further Lake launches. The
proposed stronger guarantee, that active children will finish while Lake is
stopped and then headroom will return, is unsupported. A stop frees no current
RSS, also stops the child-output readers, and is not an urgent memory-reclamation
measure. The qualified contingency below preserves the existing interruption
policy. No intervention is indicated by the healthy inspected headroom, and
this reviewer performed no signal or process-control experiment.

Scope is complete Lean run `20261108T094147-fb5330310904`, with frozen f630/parser036a
inputs at integration checkpoint `1aaa381dd3`, and only its actual runner/Lake
control path. Python driver PID 691106 and Lake PID 691697 have start identities
6220611 and 6223303; tool session 65188 is not an OS PID. Native run 094547 is
another owner's twelve-worker run and is outside any signal target. Current
Lean/Lake executable hashes match the managed preflight for pinned v4.34.1.
Recorded and observed settings agree: two reserved workers, Lake environment
LEAN_NUM_THREADS=2, child -j2, no memory cap. Observed OS thread counts exceed two;
these settings are scheduling controls, not a process or aggregate memory limit.

| UTC | MemAvailable | OutputBodyCertificate PID 834812 | Helper sibling PID 881336 |
| --- | ---: | ---: | ---: |
| 13:45:57 | 25.43 GiB | 26.34 GiB | 1.47 GiB |
| 13:50:39 | 26.31 GiB | 24.19 GiB | 1.52 GiB |

The earlier Boolean-array sibling had completed successfully in 351 s before
these captures; the current sibling was ComposeHelperSourceCandidate. Both
children had running compute threads in the first capture. A sleeping process
leader alone is not a stall. The old 15.418 GiB dense-leaf observation bounds
neither this certificate nor future siblings, and its remaining work and peak
are unknown. The later decrease also prevents a monotonic-growth claim. These
are non-atomic Linux x86-64 observations on a 62.87 GiB host without swap.

The pinned source explains the critical distinction. Lake Build/Actions calls
rawProc, then IO.Process.output at Init/System/IO.lean:1544. That function connects
both child output streams to pipes, drains stdout on a dedicated Lake task,
drains stderr on the job task, and waits for exit. Actual fd links show both
Lean children connected to Lake; four Lake reader threads were in anon_pipe_read.
The Python driver drains only Lake's outward pipe. Stopping every Lake thread
therefore stops scheduling and those readers together. Quiet children can
continue and exit, releasing their address spaces; finite output pipes can
instead fill and block a child. No reviewed output-volume bound proves that
these children will finish silently. Resume/stop pulses cannot selectively
drain output without also permitting new launches.

A child can write its own artifacts while Lake is stopped, but child exit or an
.olean file is not a completed Lake result. Module.buildLean computes output
metadata after the subprocess returns, and buildAction writes its successful
trace afterward. Those steps await continuation; killing Lake meanwhile can
lose reusable completion bookkeeping. check_lean.py's run_logged waits without
a phase deadline, and driver, Lake and children retain the actual managed lease.
The stopped process therefore keeps its workspace exclusion and reservation;
no lease removal, replacement writer or cache manipulation is justified.

The minimal contingent procedure is a monitored preventive hold, not a new
automatic scheduler or memory bound:

1. Keep the existing triggers: 15 s observations below 12 GiB, reassessment for
   two successive low/falling samples or a sustained projection to 8 GiB within
   60 s. At or below 8 GiB promptly use the existing evidence-preservation and
   targeted interruption procedure for the verified current dominant owned Lean
   child. A Lake-only hold cannot replace or delay that response; never target
   native work.
2. At a nonurgent reassessment, the coordinator may choose a hold to defer
   replacement jobs. First preserve UTC, headroom/trend, exact run/lease, target
   executable, argv/CWD, PID/start identity, parent/group and current descendants.
   Recheck identity immediately before acting; abort on mismatch or completed
   run. Target only the positive Lake PID, not a process group, driver, child or
   tool-session identifier. Verify every Lake thread stopped and rescan for a
   child launched just before the stop took effect.
3. While held, inspect memory and per-child RSS, aggregate thread CPU/state and
   available wait channels every 15 s. Pipe-write waits, progress needing Lake,
   further falling headroom or cancellation require reassessment. Do not assume
   children will disappear or use a sleeping main thread as a liveness verdict.
4. Continue only the same verified Lake process once ordinary two-worker
   scheduling is acceptable again. Child exit and recovered headroom are useful
   observations, but a bare crossing above 12 GiB or the old leaf measurement is
   not a sufficient universal resume threshold. Continuation immediately enables
   readers, bookkeeping and new ready jobs together; continue monitoring them.
5. If progress and safe continuation cannot both be maintained, the hold has
   reached its limit. Apply the existing targeted child-interruption policy as
   resource conditions require. Do not improvise external pipe consumers, altered
   prover settings, live scheduler changes or process-group cleanup. A separate
   launch gate with independent drainage would require separately authorized
   implementation and validation, outside this frozen run.

All required modules, exact-source checks, full domains and the fresh axiom audit
remain mandatory. A pause/continuation alone is neither a proof pass nor a proof
failure; preserve the actual later exits, module records and final checks. No
assurance checkpoint or successful complete run is claimed here.

Detailed source references, ten retained runner/Lake source files with hashes,
matching executable identities, managed settings, two /proc snapshots and the
unmodified Lean log snapshot are retained in
`tmp/lake-scheduler-resource-assessment-298/`. The verified 21-member bundle is
81,120 bytes, SHA256
`f8f87d34fd70fec0ddc91da3fbe4172515835fcfb963177c65cfe10e8ef0696f`.
Selected reviewer remains GPT-6 Astra / Extra High; runtime model/effort and
token/cost telemetry are unavailable.
No signal, process-control experiment, native/Lean/test execution, production or
tool/config edit, lease/cache change, publication or merge occurred here. The
live goal was rechecked and is null; CLI memory was not updated.
