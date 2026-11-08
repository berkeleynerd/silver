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
