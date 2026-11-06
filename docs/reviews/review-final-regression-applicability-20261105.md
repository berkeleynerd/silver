# Final regression applicability — 2026-11-05

## Decision

**The final 595-test inventory is covered by 594 reusable full-suite results
and one successful focused replacement. No additional regression rerun is
required for the exact source and settings reviewed here.**

The replacement is
`test_lean_evidence.LeanNativeDependencyTests.test_changed_resource_settings_apply_without_discarding_cached_objects`
from `20261105T132715-c4a22b58c2d9`. Its implementation acquired additional
assertions after the full suite; the original execution cannot cover those
assertions. The focused run passed the final method against the final Lake
configuration. Its other six successes supplement the retained full-suite
results; they do not add six new required test IDs.

This composes regression results under `development.md`'s independent-review
reuse provision. It does not relabel the original aggregate fingerprint as a
fresh final-input run, establish universal assurance from examples, or replace
the mandatory complete native proof/audit and Lean/source-correspondence
checkpoints. The native checkpoint was still active at this review's handoff.

## Exact inputs and review record

- Final governed source: `ddb183a918c78c8636b94961172dc923e7d88d30` in
  `tmp/string-review-repairs`. Inspection began at `cc3243b726` plus the exact
  four-entry helper simp cleanup; the lead committed those same bytes during
  review. All 892 captured repository paths were checked against the final
  commit; none differs.
- Original full regression: `20261105T111005-483650d69229`, frozen
  `fb89b3653accef6c08a49f88625144c108ad2432` in `tmp/string-admission-repairs`.
  Managed terminal outcome is `success`, test phase return code is zero,
  and the retained log reports **595 tests in 3919.144 seconds, OK**.
- Focused CPU regression: `20261105T132715-c4a22b58c2d9` in
  `tmp/lean-cpu-defaults`; terminal outcome is `success`, test phase return code
  is zero, and the retained log reports **7 tests in 59.176 seconds, OK**
  (63.215 seconds including managed preparation).
- Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort
  confirmation, token usage and cost were not exposed to this reviewer.
  Inspection began **2026-11-05 19:45:06 UTC**; structured inspection completed
  **19:51:55 UTC** and the report was finalized **19:53:50 UTC**.
  Observed review/report interval: **8 minutes 44 seconds**.
- Scope: independent read-only source/evidence review, plus this report and its
  [inspection evidence](../evidence/interim-review-response-20261105/regression-final-applicability/summary.json).
  No test module was imported or executed; no native build, test, proof,
  GitHub operation, commit or publication was performed by this reviewer.
  The [inspection script](../evidence/interim-review-response-20261105/regression-final-applicability/inspect.py)
  reads ASTs, Git blobs, source bytes and retained run records only.
- Governing inputs read: `AGENTS.md`, the Oracle, the development checkpoint,
  regression-reuse and review-bookkeeping rules, and the
  [earlier one-line argument-budget review](review-argument-proof-regression-applicability-20261105.md).
  User authorization and the PR #307 open/draft/no-merge constraint were supplied
  in the lead's bounded assignment. The live harness reported no active goal.

## Final input relation and inventory

All **900** original captured inputs still match their original files; all
**892** repository captures also match the frozen suite commit. The final
selected repository input set has exactly those same 892 paths, including
untracked-file discovery and excluding Python caches as the runner does.
Exactly five repository files differ:

| File | Complete relevant change |
| --- | --- |
| `proof/Silver/ComposeEquations.lean` | Declaration-local 3M heartbeat option before `interpreted_argument`; previously reviewed |
| `proof/Silver/ReviewedOutputShape.lean` | Declaration-local 10M heartbeat option; every other byte, including the output token literal, is unchanged |
| `proof/Silver/ComposeHelperSourceCandidate.lean` | Four unused simp entries removed from private `string_helper_guarded_at_ordinary`; statement and surrounding source unchanged |
| `proof/lakefile.lean` | Absent `silverThreads` now supplies no `-j` override; explicit settings, memory behavior, semantic options and library/dependency declarations remain unchanged |
| `tests/test_lean_evidence.py` | Only the resource-setting method changes; adds return-to-automatic settings and cache-preservation assertions |

The structured evidence retains every old/final hash. In particular, the final
helper SHA-256 is
`3b8248b88f3974725510f85537252cd4bcfd0dd71455957f033c2263e575ff62`.
Native source, scripts, samples, catalogue, Rosetta inputs, project files,
certificate generator and toolchain pin are unchanged. Documentation/evidence
changes are outside the runner's selected input set and the reviewed test readers.

All **893** focused-run captures still match their original files. Its 892
repository inputs differ from final source only in the later helper cleanup and
output-pin budget; its Lake configuration and expanded test are exact final bytes.

Independent AST reconstruction confirms **53 test files, 581 locally defined
methods, five inherited executions and nine imported SharedBindings executions**:
595 distinct runtime-qualified IDs, exactly matching the retained census and
raw full-suite log. Each retained ID has one `ok` status. No IDs were added or
removed; no failed, skipped, missing or unresolved IDs remain. AST comparison
identifies only the resource-setting method as changed; module fixtures and
other methods in its file are unchanged. The seven focused IDs and the one
required replacement are listed in the structured evidence.

Passing parent methods retain their sample/subtest coverage: unchanged sample
inputs include the 59-source manifest and its 115 application cases. Successful
subtests are not individually enumerated by unittest, so no invented subtest
count is added to 595. The symlinked-TMPDIR wrapper's 12-method child suite is
also kept separate from top-level IDs.

## Dependency review

The proof edits were not classified as harmless merely by their file extension.
The actual readers and their observations determine applicability:

| Reader | Observation and disposition |
| --- | --- |
| `CompilerSourcePolicyTests.test_include_str_is_confined_to_the_source_bindings` | Same 627 `.lean` paths, including Lake configuration; every `include_str` count is unchanged. Reuse. |
| `test_only_audit_roots_use_legacy_full_imports` | Every module marker and the legacy-root set are unchanged. Reuse. |
| Both composition import-closure tests | Imports are identical throughout the production graph. Candidate/check closures remain 85/115 modules; the authoritative output closure remains 39. Helper and pin modules are in the relevant closures, but changed text introduces neither an import nor `include_str`. Reuse. |
| `test_embedded_source_lists_and_lake_dependencies_agree` | Reads Lake input-file/library declarations and ordering; that entire declaration suffix is byte-identical. It does not inspect the changed default-thread expression. Reuse. |
| All 12 `PlatformIsolationTests` methods and the symlinked-TMPDIR wrapper | Shared setup copies the changed proof/Lake bytes. Real Python runner logic transports/hashes them and applies the unchanged kernel-bypass policy. Lean/Lake are mocked; mock module/audit output depends on source filenames, not theorem elaboration or Lake configuration evaluation. Current-fixture relationships, snapshots, names and policy classifications are unchanged. Reuse. |
| `test_changed_resource_settings_apply_without_discarding_cached_objects` | Evaluates the actual Lake configuration with explicit and then absent settings, checking invocation arguments and retained artifacts. Changed test assertions and changed default branch require the focused replacement, which passed with zero skips. |
| `test_lake_tracks_embedded_ada_bytes_and_preserves_unchanged_objects` | Evaluates the actual Lake configuration, but explicitly passes `-K silverThreads=1` on every build. Both old and final configurations therefore supply the same `-j1`, no memory override, and the same semantic flags/library graph. Source bindings and witnesses are unchanged. The changed absent-setting branch is unreachable in this test. Reuse; no extra native-Lake run is needed. |

The shared platform fixture also covers the focused CPU run's platform method;
the later helper/pin edits do not invalidate that success. The mocked runner
selects explicit resolved thread counts, and its predicates do not interpret
Lake text. The new proof texts contain none of the prohibited kernel-bypass
strings, so their changed hashes do not alter the checked relationships.

The remaining Lean-labelled tests use synthetic proof/Lake workspaces, unchanged
source-binding modules, or direct native Lean compilation of unchanged
Lexical/Admission/Cursor/SourceLexer/CertificateWitness/AxiomAudit modules.
They do not elaborate the three changed production modules. The imported
generator and runner modules are unchanged. Native/sample tests call the native
Silver executable and do not read these Lean proofs. The original review's
remaining dependency classification therefore continues to apply after the
explicit Lake/source-reader reassessment above.

## Installation and assurance boundaries

The retained full suite used its recorded compiler build and binary SHA-256
`9073495eaf5c326000fc141a8783efe3764f093129844316f88909cb9591e75c`.
The integration installation has a different compiler binary. Its generated
`silver_build.ads` and `silver_image_config.ads` differ from the suite's only
by substituting the worktree root; their normalized bytes are equal, including
the pinned native `gnatwhy3` digest. The generated selected-library bytes and
captured Alire context files are identical. The Python interpreter capture is
unchanged. Installed Lean/Lake launcher digests agree across the original,
focused and integration worktrees.

Consequently this decision retains the original tested installation/build
identity while applying its results to the reviewed final repository source.
It does not claim byte equality or fresh verification of the integration
compiler executable. No source-dependent native input changed in this final
delta, and no additional native/compiler rerun is prescribed by this review.

The three changed production proofs are checked by the separate complete Lean
checkpoint `20261105T192530-524a4096ef8f`: retained evidence says complete scope,
626 modules, successful build and fresh axiom audit. Its 741 recorded shared
input hashes match the final source. It is an incremental complete checkpoint,
not a clean rebuild or a `leanchecker --fresh` replay. The lead owns the full
assurance evidence audit and the still-running native checkpoint.

**Disposition:** final regression coverage is complete through the recorded
594+1 composition. No new regression obligation was found. Any further source,
test, configuration or toolchain change needs its own applicability assessment;
this is not blanket reuse approval for later edits.
