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
