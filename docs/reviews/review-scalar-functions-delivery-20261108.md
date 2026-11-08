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
