# Scalar-function source packaging review — 2026-11-08

No material defect was found in the exact scratch decomposition. Its static
argument preserves the original source requirements and public conclusions.
The proposal is suitable for the stated serial validation attempt after the
active workspace is released. Kernel acceptance, successful complete assurance
and acceptable peak memory remain unestablished; this is not delivery acceptance.

The exact target is `function-source-components.patch`, SHA-256
`f018c845b443695879e59f4425042f5ba12a93c028a8e8c488283b856f931bd3`, in
`tmp/scalar-functions-delivery-review-298/tmp/function-source-decomposition/`
relative to the main checkout. The review includes its `PLAN.md`,
`inventory.json`, `prepare.py` and all 81 proposed file bodies. The base is
integration `de9f2f61d1418910216dd6abc76ac849ae384cce`; its governed
`proof/`, `src/` and `scripts/` inputs match
`2a3badff5c1304291b1d583156d5b1449a327668`. The six original-source hashes in
the inventory independently match those frozen files. In particular,
`src/silver_output_profile.adb` remains SHA-256
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.
The separate native target is `560144172c3bcef4d831ab2c9a584cce40613c60`;
this review does not repeat its admission, semantic or report-policy reviews.

The coordinator's bounded authorization concerns completing
[#298](https://github.com/berkeleynerd/silver/issues/298) through validation,
independent review and reviewable publication in
[PR #339](https://github.com/berkeleynerd/silver/pull/339). Implementation merge
remains held. The reviewer owns only this report and independent scratch in
`tmp/scalar-functions-source-packaging-review-298`, branch
`review/function-source-packaging-20261108`, derived from the integration base.
The author of the proposal and this reviewer are distinct agents. No proposed
proof edit was applied, no governed proof/source input was changed, no proof,
build or test process was launched, and no external publication was performed.

This assessment applies the [Oracle](../../oracle.md), the
[small-function assurance requirements](../assurance.md#small-nonrecursive-scalar-functions),
the [validation workflow](../../development.md#proof-loop-and-validation),
[proof iteration controls](../proof-iteration.md) and
[review bookkeeping](../../development.md#goal-and-review-bookkeeping).
Every admitted domain and construct, including unused functions, retains its
required assurance. Packaging cannot remove source/header/body/tree/contract
checks, narrow domains, introduce project axioms, or substitute hashes for
the actual-source argument.

An independent read-only Python audit reconstructed the delivered unified diff
from the original and proposed bytes and obtained exact byte equality. It
confirmed 80 new files under `proof/Silver/FunctionSourceParts/` and exactly one
changed existing file, [FunctionSourceCandidate](../../proof/Silver/FunctionSourceCandidate.lean).
Read-only `git apply --check` also passed. The audit compared every leaf's
entire allowed module prelude, proposition and proof body, each facade field,
the original structures and tables, and the complete leaf import/use inventory.
It did not execute the proposal's generator or use Lean to accept the proposal.

| Original requirement | Exact proposed coverage |
| --- | --- |
| Declaration `headers` | All 25 rows, indices 0–24, in original order; specification and implementation headers stay separate. |
| Declaration `expressions` | All 7 rows, indices 0–6, including `append_parameter`'s existing trailing contract tokens. |
| Declaration `ordinary` | All 3 rows: `function_return_after`, `function_body_at`, `function_declaration_at`, including their original rendered endings. |
| Declaration `loops` | All 3 rows: `parameters_at`, `function_locals`, `parameter_frame`, including their existing iterative bodies and annotations. |
| Declaration direct fields | Exactly `typeResult`, `stepResult`, `parameterCursor`. |
| Visibility | All 10 non-tree fields: the body/declaration and header checks for `functionHides`, `formalHides`, `hiddenWord`, `hiddenOuter`, `hideName`. |
| Calls | All 29 non-tree fields: 2 `included` checks, 20 specification/implementation header checks, and 7 rendered body checks. |
| Tree requirements | All 3 original `checked_trees` proofs reused in the corresponding required fields. |

Thus the 38 table-row leaves plus 42 direct-field leaves give exactly
41 declaration, 10 visibility and 29 call leaves. Every leaf is publicly
imported and referenced exactly once by the facade. The originals are
[FunctionDeclarationSource](../../proof/Silver/FunctionDeclarationSource.lean),
[FunctionVisibilitySource](../../proof/Silver/FunctionVisibilitySource.lean)
and [PredicateFunctionCallSource](../../proof/Silver/PredicateFunctionCallSource.lean).
None is edited by this patch.

Each table leaf selects the original table using `List.get` with a concrete
`Fin` index and a `by decide` bounds witness. The indices are in range; there
is no default value for an invalid index, duplicated token table or shortened
source argument. The predicate after that selection is exactly the original
field predicate. Each direct-field proposition is the unchanged original with
`Output.SourceShape.outputImplementation` substituted for its token parameter.
The leaf proof body remains `decide +kernel`; both original depth and heartbeat
settings remain. No extra premise, local axiom, `sorry`, native decision tactic
or kernel-check bypass is introduced.

The four universal table fields still quantify over arbitrary membership in
their complete original lists. The facade expands only that list and the
listed membership rules, splits all 25/7/3/3 alternatives in order, and uses
the matching leaf in each branch. Selecting the same concrete row by `get`
reduces to the tuple obtained in that membership branch. This is a valid
finite-case reconstruction argument; Lean must still accept its exact syntax,
name resolution, reduction and proof terms. There is no sampled domain or
uncovered fallback branch. A later table change must satisfy the complete
assembly again and cannot be justified by these static counts.

The three exported theorem names, namespace and result types are unchanged:
`Silver.FunctionSourceCandidate.declarations`, `.visibility` and `.calls`
still establish their original complete `Checked` structures for the complete
reviewed output token list. The existing three tree proofs remain fields of
those structures. [FunctionSourceChecks](../../proof/Silver/FunctionSourceChecks.lean)
is untouched: its `checked_source` still transports all three results through
`Output.SourceBridge.actual_complete_shape.2.1` to `Source.outputBodyTokens`
and separately requires function-binding metadata. The actual-source binding,
reconstruction certificate, semantic bridges and native domains are unchanged.
Source identity here relies on that required certified transport, not merely
the unchanged source hash.

The nested modules fit the existing build and audit machinery. Each uses
`module`, public imports and `@[expose] public section`; each imports its
original requirement module and `ReviewedOutputShape`, without importing the
facade. The static import graph reaches all 80 leaves from both
`Silver.FunctionSourceChecks` and `Silver.Audit`, with no cycle through the
facade. Lake's existing Silver library resolves those imports. No separate
manual module registration or new generated-candidate exception is needed.

[check_lean.py](../../scripts/check_lean.py) discovers proof files recursively,
derives dotted module names from relative paths, includes every noncandidate
leaf in the captured shared inputs, creates nested workspace directories,
and hashes/checks the complete workspace inventory again between phases.
These leaves are outside its generated `CANDIDATES` set. New public import
edges affect normal Lake dependencies; the runner does not silently exempt
them from provenance. The legacy [Audit](../../proof/Silver/Audit.lean) and
[AxiomAudit](../../proof/Silver/AxiomAudit.lean) remain unchanged. The latter
uses actual origin modules, including private/generated declarations and the
entire `Silver` prefix, so nested modules receive transitive axiom inspection.
The complete runner requires exact actual-import coverage of its recursive
project inventory and permits only `propext`, `Quot.sound`, `Classical.choice`.
This static path analysis does not replace that fresh executed audit.

The serial retry has an appropriate evidence boundary. At the inspected managed
status, complete Lean `20261108T044143-17a94f7033eb` still owned the integration
workspace with 8 workers, and native `20261108T040128-2651963b8574` remained
active with 12 workers elsewhere. The retained log records the cancelled
`FunctionSourceCandidate` build after 1,735 seconds; the coordinator's preserved
action record reports 38.31 GiB RSS/HWM and falling available memory below
12 GiB before its targeted SIGTERM. These are observations of the old run,
not measurements of a proposed leaf. `ComposeExamples` also remains a required
cancelled module. The reviewer sent no signal and changed no running workspace.

After that run exits and its objects and failed outcome are retained, apply
the independently reviewed candidate repairs at one stable input checkpoint.
The smallest proposed check is the actual-source header leaf
`Silver.FunctionSourceParts.DeclarationHeaderFunctionTypeAtSpec`, with
`--workers 1 --threads 1` and the recorded memory-pressure reason. If it passes,
the focused `Silver.FunctionSourceChecks` run must build all remaining leaves,
the facade and unchanged actual-source transport, then freshly audit that
closure. The final complete run remains mandatory, including the separately
repaired Boolean candidate, `ComposeExamples`, all source requirements and
the fresh whole-project module/axiom audit. A focused success cannot discharge
that final obligation.

Serial scheduling limits concurrent fresh component work and lets each
successful module become reusable before the next process completes. It does
not bound one leaf's allocation, all imported objects, the facade's conversion
work or the complete legacy audit's memory. The old run did not identify which
field dominated memory. Additional imports and process starts also have costs.
The plan correctly withholds peak-memory, runtime and completion guarantees.
Monitor actual host headroom and competing workers; a repeated failure should
identify its exact leaf and diagnostic before another attempt, preserving its
requirement. The reduced counts address observed pressure and are not a new
default or an OS memory cap.

The patch leaves native source/tooling, reviewed source literals, generated
source certificates and unrelated semantic modules unchanged. Retain matching
objects, `.olean.private`, `.olean.server` and Lake metadata. The 80 new leaves
and rewritten facade require checking; public import changes can rebuild
consumers. Actual runner input and dependency checks determine reuse. No
successful native result is invalidated solely by this Lean packaging edit,
but the active native run has not yet supplied complete success. No clean
deletion, optional replay or identical-success expensive rerun is required
by this review. The cancelled source builds remain failed evidence.

Selected reviewer settings were GPT-6 Astra / Extra High, as supplied in the
bounded assignment. Independent runtime model/effort telemetry and token/cost
measurements are unavailable. The observed host is Linux 7.0.14 x86_64;
`scripts/dev.py paths` reports `linux-x86_64`. The measured review interval
began at 05:20:22 UTC; structural review and its final audit finished by
05:26:00 UTC, 338 seconds later, excluding subsequent report preparation.
The final static audit command took 6.558 seconds; this is not native or Lean
proof execution time. Intended result: independent claim/coverage/import review.
Achieved result: no material static finding; no proposal rework requested;
kernel/resource evidence remains pending. The live harness goal is null and
CLI memory was not updated.

Independent audit scratch is retained at
`tmp/scalar-functions-source-packaging-review-298/tmp/independent-source-packaging-audit/`
relative to the main checkout. `audit.py` has SHA-256
`fa1176e2d128b088214d5e741f10378ed810bf422fb5c9d0b2a9982cbc187c05`;
`result.json` has SHA-256
`cbdf1b4086f6c2360c0c935b56379012626eba1409eb4a4cba9640538d5ca2a5`.
They are local review artifacts, not required proof inputs. This report's
report-only commit is the handoff; the coordinator remains responsible for
integration and final evidence. No owned productive process remains.
