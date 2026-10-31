# Named Integer subtypes: final integration review — 2026-10-29

**Initial code/applicability verdict: no actionable defect found in the final
proof repairs. Final validation outcomes remain pending.** This report extends
the [earlier critical and capacity reviews](review-named-integer-subtypes-critical-4224e6caf2.md)
for #286; it does not authorize merging draft PR #289.

Implementation target: `97312a790fb11a83a9607ad48ddab491711f2c3d`.
Earlier critical input: `4224e6caf21bade207002051abaeea0230dbb44b`.
Selected reviewer: GPT-6 Astra / Extra High; runtime model/effort confirmation
and token/cost measurements are unavailable. Initial substantive review ran
16:20:18–16:23:28 UTC (190 seconds), followed by report preparation. Work used
the isolated `tmp/subtype-critical-review` worktree on
`review/subtype-final-97312a790f`; only this report was edited. No native, Lean
or test run was performed by the reviewer.

## Final code delta

Reviewed the changes in `0514f00782`, `2a4cdceb0c`, `ce645e1d10`,
`fcb4df55e3`, and `3707d2b824`, their callers and existing domain definitions.

- Helper interpretation repairs normalize Boolean association and local
  aliases. The array cursor repair exposes `typeMark.after`, definitionally
  equal to the existing `typeAfter`. Neither changes an endpoint statement,
  source expression or precondition.
- Declaration termination now counts String, scalar, array and subtype tables
  using their respective existing capacities. It uses the existing successful
  declaration count increment and validity bounds; it removes the obsolete
  identification of scalar capacity with String capacity. The two initial-state
  proofs explicitly establish validity of the empty subtype environment.
- Scalar-array helper lemmas now receive `ValidMetadata`, already required by
  the enclosing `arraysAtom_correspondence` endpoint. They derive per-binding
  validity and pairwise allocation order for `readBounds_correspondence`.
  `interpreted_arrayAtom` retains its existing domain and derives the additional
  `BindingType` component-bound fact from `ValidBinding`. This supplies required
  native/model facts without narrowing the endpoint's input domain.

No endpoint weakening, new project axiom, unfinished proof, kernel bypass or
removed obligation was found in these repairs. The production-source delta
since the earlier critical target is the already reviewed static logical-equality
repair. Updated certificates and the reviewed source pin still require the
complete final source/Lean check; their presence alone is not that evidence.

## Regression applicability

Full regression run `20261029T153819-5626949ad567` uses
`671a4e7931d25dc1d1bc3d2591c1f5bca25a646b`, whose tree is identical to
`2a4cdceb0c3f645d8b5f1b852fb33fbae6cec935`:
`4c48649cadcfc82b5fc0ce3090b73494452d4c64`.

The exact relevant input delta from that snapshot to the final target is:

- `proof/Silver/ComposeEquations.lean`
- `proof/Silver/ComposeRecognitionEquations.lean`
- `proof/Silver/SequenceEquations.lean`
- `proof/Silver/ScalarExpressionNativeArrayAtoms.lean`
- `proof/Silver/ScalarExpressionNativeEquations.lean`

Tests, scripts, native sources, samples and catalogue inputs are unchanged.
Source inspection supports rerunning `test_lean_source.py` and
`test_platforms.py` on final proof bytes: the former scans the actual Lean
module sources/import graph, and the latter copies the actual complete Lean
tree into its platform-routing fixtures. Together they contain 28 identities.
Other Lean test modules use unchanged audit modules, toolchain/Lake/source-binding
inputs or synthetic fixtures. Native provenance hashes do not include these
five Lean files. No additional test is affected by this exact delta; every
failed or incomplete identity must nevertheless receive a completed rerun.

The saved `tmp/constant-array-iteration/tmp/subtypes-test-inventory.json`
contains 555 unique identities. Read-only static source reconciliation accounts
for all of them: 541 explicit methods, five inherited array-report methods, and
nine imported `tests.test_shared_bindings` identities exposed by
`test_integer_loops`. Final reconciliation must cover all 555 identities,
retain each original outcome and identify the applicable replacement result
for every failed or affected test. A successful aggregate count alone is
insufficient.

## Pending evidence confirmation

At this review boundary, complete native run `20261029T154107-1e953acac4e4`,
full regression `20261029T153819-5626949ad567`, and complete Lean run
`20261029T161817-0a8089cd7dc3` were still active. The Lean run targets the exact
implementation commit above with one worker, one thread and 24,576 MiB per
process. No pending run is classified as passed here. The two affected-test
reruns and any failed-test reruns remain outstanding.

Final confirmation must inspect the retained outcomes and input identities,
complete native obligation/report/provenance audit, complete Lean source/module/
axiom evidence, and the reconciled test inventory. Cached focused successes
remain separate from those complete-run claims. No further broad code review
is requested unless final validation changes the reviewed inputs.

## Regression evidence confirmation — 2026-10-29

**Regression evidence confirmed; no actionable discrepancy found. Complete
native and Lean outcomes remain pending in this report.** Reviewed the retained
[regression evidence](../evidence/named-integer-subtypes-20261029/README.md) at
`ced8d0d799b489d987de3799d7dd72b7a8dd3d1c` against implementation
`97312a790fb11a83a9607ad48ddab491711f2c3d`, reusing the applicability analysis
above. Selected reviewer remained GPT-6 Astra / Extra High; runtime confirmation
and token/cost measurements remain unavailable. Evidence inspection ran
17:38:19–17:42:46 UTC (267 seconds), followed by report preparation. No tests,
native proofs or Lean checks were rerun by the reviewer.

Independently decompressed all three retained logs and event streams, verified
their SHA-256 values against `retained.json`, and checked their successful
terminal events and zero test-phase return codes:

- `20261029T153819-5626949ad567`: all 555 unique inventory identities have
  explicit successful outcomes, including entries with interleaved tool output
  or multiline descriptions. The original successful result is preserved.
- `20261029T170712-d9dc75fa5629`: all 12 proof-source identities passed.
- `20261029T170846-5ccd1f3667b8`: all 16 platform-fixture identities passed.

Recomputed input comparisons from the raw prepared events and Git blobs, rather
than relying on the reconciliation booleans. The full suite captured 800 inputs:
787 tracked files match final bytes, exactly the five previously reviewed Lean
files differ, and eight are workspace/generated/tool inputs. All 792 tracked
inputs in each rerun match final bytes; the eight other hashes agree across all
three runs. Implementation inputs under tests, scripts, sources, samples,
catalogue and proof are unchanged through the evidence commit.

The replacement identities are exactly the affected 12 plus 16, yielding 527
applicable retained results plus 28 refreshed results, with no missing, failed
or incomplete identity. The passing manifest test and its unchanged inputs
account for all 52 sample sources and 108 application executions. Platform
fixture source and evidence correctly distinguish mocked tool/host routing
from native macOS execution and Lean proof validity; these results are Linux
x86_64 evidence. Later changes to tested inputs still require applicability
assessment, including affected renderer tests for Rosetta metadata changes.

Complete-native confirmation now concerns replacement run
`20261029T165015-c6b111fb4f2a`; complete Lean/source/module/axiom confirmation
still concerns `20261029T161817-0a8089cd7dc3`. Neither outcome is established by
this regression-only confirmation. The earlier pending-state description is
retained as history; this update supplies only the completed regression evidence.
