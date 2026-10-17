# Unbounded programs planning review corrections

This is a **planning-only** response to
[review-ec82b4e5f2](reviews/review-ec82b4e5f2.md), whose target is the merge of
[PR #95](https://github.com/berkeleynerd/silver/pull/95). It changes the proposed
scope and evidence descriptions, not the compiler, language membership, proof
sources or current assurance policy. No implementation of #88–#94, research
experiment, full proof run, Lean rebuild/replay or test suite is part of this pass.

## Authorization, publication and preserved history

The owner authorized publication of the full review, scope/issue/record repairs
and independent review, explicitly prohibiting implementation of #88–#94.
[PR #96](https://github.com/berkeleynerd/silver/pull/96) put that exact direction
and the verbatim report on `main` at commit
[`14b7d4e2eac2ad8cde2289f19f428f7050738760`](https://github.com/berkeleynerd/silver/commit/14b7d4e2eac2ad8cde2289f19f428f7050738760)
before findings #97–#104 were claimed. The original report's local/untracked
artifact descriptions remain review-time history. Its SHA-256 is
`fef62547866b531f908a1ecf7ae17a216338dc2f6a910ff48bf15cab808b3b11`.

The original scoping entry and original research remain historical evidence.
The [curated evidence](evidence/unbounded-programs/scoping-research.json) now
annotates inaccuracies and the retention limits; its verbatim track verdicts and
17-run corpus are preserved. The retained original research archive is available at
[evidence commit 0cd253d05b2](https://github.com/berkeleynerd/silver/tree/0cd253d05b2cb650cc8fca81255e9a711765e16a/tmp).
Small [independent-review records](evidence/unbounded-programs/review-ec82b4e5f2/README.md)
are published for arithmetic, run-summary and pre-publication reconciliation.
No omitted session files or giant inputs have been reconstructed or invented.

## Finding dispositions

These dispositions resolve planning defects. They do not mean that the future
mechanisms exist or that their feasibility research has passed.

| Finding | Corrective issue | Planning disposition |
| --- | --- | --- |
| M1 — outcome ambiguity | [#97](https://github.com/berkeleynerd/silver/issues/97) | Separate strict Confirmed audit from unsuccessful-evidence checks. Cover normally terminated nonzero runs, interrupted partial reports, all tool phases, attributable resources, unknown causes and independent-defect precedence in scope/#88. |
| M2 — arbitrary command cap | [#98](https://github.com/berkeleynerd/silver/issues/98) | Remove the OS-derived claim and specify growable command arguments and paths. #88 owns process observations; #89 owns coordinated storage/ghost/bootstrap changes. Fixed library capacities need fixed-input derivations. |
| M3 — unsupported necessity | [#99](https://github.com/berkeleynerd/silver/issues/99) | Make the uniform source envelope a candidate. #91 must establish soundness and justify expansiveness against a plausible alternative; separately specify later rule implementation. Include #91/#93 conditional stops. Research remains outstanding. |
| D1 — overstated confirmation | [#100](https://github.com/berkeleynerd/silver/issues/100) | Keep producer completeness and Main Image applicability as premises. Distinguish observable checks, build-input correspondence and executable attestation. Narrow the runtime-check claim; preserve the Oracle guarantee and stronger Lean theorems. |
| D2 — statuses/observation | [#101](https://github.com/berkeleynerd/silver/issues/101) | Forward application statuses, distinguish launch/build from execution, and never infer Storage_Error from exit 1 or OOM from exit 137/SIGKILL alone. Synchronize #88/#93. |
| D3 — only-resource headline | [#102](https://github.com/berkeleynerd/silver/issues/102) | State the conditional operational objective and explicit defect/infrastructure outcomes in scope, roadmap, milestone and affected issue summaries. |
| D4 — evidence inaccuracies | [#103](https://github.com/berkeleynerd/silver/issues/103) | Correct the Image projection, units, unsupported stack slope, Lean helper wording, finite-family wording, synthetic Trivial explanation and historical/current winning-step distinction. Annotate original raw discrepancies without rewriting raw evidence. |
| P1 — claim before main | [#104](https://github.com/berkeleynerd/silver/issues/104) | Acknowledge the original 13m26s ordering violation and omitted pre-publication process fix. This pass records authorization on main before corrective claims; no undo or new approval ceremony. |

The author's response based on the summary was treated as provisional. Repairs
were checked against the full report and source evidence. The proposed global
`/proc/vmstat oom_kill` delta is diagnostic context, not attribution to this run.
A direct SIGKILL likewise supplies a signal, not an OOM cause. `oom_score_adj`
biases eligible victim selection; it guarantees neither selection nor isolation.

The selected report set is explicit: the existing null project selects Main only;
output projects select Main plus the six runtime files and audit all four library
unit reports. This follows `src/silver.adb`'s project construction. It avoids
silently changing null-program dependencies while preserving every selected
obligation. No current report policy is changed by this record.

## Required outcome specification examples

These are reviewable requirements for #88/#94's future fixtures, not tests executed
in this pass. Statuses below belong to `silver confirm` unless stated otherwise.
Normal termination is distinct from exit status zero.

| Observed evidence | Required result |
| --- | --- |
| Every required check proved; selected reports pass the existing strict audit; identity matches | Confirmed, 0 |
| Same, with a losing prover's crash/resource answer but another prover's Valid for each check | Confirmed, 0; retain losing-attempt diagnostics |
| Normally terminated nonzero GNATprove run, complete structurally valid reports, unproved check with Unknown/Invalid | Defect, 3 |
| Complete valid unsuccessful evidence; each unproved check has only attributable resource answers | Inconclusive, 4 |
| Attributable gnatwhy3/adapter/frontend/report-I/O resource failure with no independent defect | Inconclusive, 4; identify the failing phase |
| Explicit confirmation interrupt with expected missing/truncated reports, no independently established defect | Inconclusive, 4; interruption is not called resource exhaustion |
| Earlier independently established definite defect, followed by interrupt or resource failure | Defect, 3; preserve both events |
| Validly observed required check remains unproved with Unknown plus resource failures | Defect, 3 |
| Missing/corrupt reports after ordinary completion without an observed explanatory interruption/resource cause | Defect, 3 |
| Generic High failure/signaled, exit 137 or SIGKILL, even with a host-wide OOM counter increase | Defect, 3 with cause unknown unless an attributable cause is independently established |
| Confirmed named producer capacity boundary reached, no independent defect | Inconclusive, 4; name the confirmation-only limit |
| All proofs valid but snapshot/provenance/build-input mismatch | Defect, 3 |
| Admission/build resource failure before a successful build | Resource status 4, no successful-build publication |
| Build succeeds, later confirmation is inconclusive or defective | Built executable remains; compile reports build and confirmation separately |
| Application exits with its own status, including 1 or 4 | `run` forwards that application status and identifies its origin; do not reinterpret it as compiler classification |

A full disk or parent death can also prevent a new diagnostic bundle. The proposed
contract is best-effort retention plus truthful fallback diagnostics and existing
workspace paths, not a promise to write files after resources are unavailable.
Known independent integrity defects retain precedence; incompleteness explained
by interruption is not itself such a defect.

## Research and implementation boundary

The present pass establishes the questions and criteria, not their answers:

- **#91:** inventory pinned source-position and table capacities, account for
  dependencies and mode/phase-specific expansion, and justify a decidable rule.
  Compare a uniform envelope with a source-sensitive candidate or record why the
  former is the best tractable option. A semantic-check sample cannot prove
  whole-build acceptance or worst-case table safety. Native/Lean rule changes are
  a later implementation phase, not work assigned to the planning agent now.
- **#93:** determine static-data compile/link feasibility before fixing the
  Integer'Last value domain and re-derive dependency allowances for changed runtime
  units. Non-resource failure unresolved within the intended design is a full stop.
- **Solver assurance:** an unfixable definite non-proof remains the existing
  conditional full stop. Removing budgets is not proof of universal solver
  completion; an interrupted run supplies no definite counterexample.

If a sound, appropriately expansive rule or intended build domain cannot be
established, report the unresolved condition for the owner. Do not silently adopt
a smaller arbitrary cap or reinterpret a failed check as success. The planning
pass authorizes neither an Oracle amendment nor an implementation fallback.

The future build-input record relates confirmation to captured source/library
bytes under the documented stable-workspace assumption. Adversarial modification
of the witness and executable attestation remain deferred; the scope must not
claim those properties. Existing library identity and same-source requirements
remain mandatory.

## Validation, review and publication

Validation is documentation-only on native macOS arm64. Required checks are JSON
parsing, numeric recalculation, preservation of original run/verdict records,
relative links/anchors, diff whitespace, issue/specification consistency, and an
independent read of the final correction set. No code/proof input changes justify
proof or test-suite reruns.

The [independent corrective review](evidence/unbounded-programs/review-ec82b4e5f2/corrective-independent-review.md)
found no remaining material planning defect. Its evidence-label nits were repaired:
14 scaling runs contain 11 fitted points (five mixed, four straight-line, two dense
String-copy points); the archive is described as retained rather than complete.
A final publication-delta review checks the completed record and issue wording.
The [validation record](evidence/unbounded-programs/review-ec82b4e5f2/correction-validation.json)
identifies checked inputs, issue-body hashes, calculations and actual host.

The original review is byte-identical; original track verdicts and scaling data
are preserved, with only the explanatory run-count note changed. JSON parses;
changed document links/anchors and whitespace pass. Nineteen stale anchors in
untouched historical memory entries also fail in the authorization baseline;
they are recorded as pre-existing and were not rewritten. Twelve fit exponents, five
report-envelope values and two Image projections were independently recalculated.
Issue bodies #87–#94 were published and read back exactly, retaining their labels,
milestone and open/closed states. #94's last-line wording explicitly distinguishes
closing the issue through its commit from subsequently closing the milestone.

Board readback confirms #87 Done and #88–#94 Backlog. Initial access lacked project
permissions; the owner's retries restored read and then write access. The eight
corrective findings are tracked separately and move through review to Done on
publication. Their claim comments retain the earlier access gap as history.
Publication handoffs cite the actual corrective merge commit; no implementation
package is closed or moved out of Backlog by this correction.

The primary session began at 18:28 UTC on 2026-10-17. Authorization/report publication
occupied about three minutes; parallel drafting/reconciliation and independent
review occupied about fifteen minutes; final record checks, GitHub readback and
publication followed. Activity intervals overlap because reviewers worked in
parallel; exact checkpoint times are in the validation record. Per-turn token
usage was not exposed by the harness and no token-budgeted goal was active.
No build, proof, Lean rebuild/replay, full test suite or proposed research experiment
ran. Side effects are documentation/evidence files, the two planning PRs, issues
and their comments, milestone text and board status records. Scratch tools remain
outside `scripts/`; shared unrelated tracked edits, local review worktrees,
research caches and other-host artifacts are preserved. No CLI memory was updated.
