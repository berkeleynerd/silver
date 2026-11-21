# Independent Claude review of Silver PR #406 (reduced #373 proof-iteration package)

## Verdict

**No blocker. 1 medium, 2 low, 6 info. The PR is ready for the owner's merge decision.**

The medium (C406-M1) is a recurrence-bookkeeping defect with no effect on assurance. A follow-up issue is enough; I would not amend and re-validate this PR for it.

I found no ordinary way for a focused check to report an incomplete or incompatible result as ready. The complete native and Lean paths are unchanged in substance, and the retained final records support the delivery claims.

## Review record

| Item | Value |
| --- | --- |
| Target | `8dc409b303ac8bd9a836ed169467064441a76d8d`, PR #406 |
| Base | `a412827d6c54f925cf4e55cac128eb4ef48647ad` (verified as the merge-base; 19 commits) |
| Date | 2026-11-20; session started 19:05:30 UTC, report written about 19:40 UTC (roughly 35 minutes elapsed) |
| Selected reviewer | `claude-fable-5-2`, effort `max` |
| Observed settings | Every assistant event in the session stream reports model `claude-fable-5-2`. Effort is the CLI flag `--effort max`; no server-side effort field was visible to me. |
| Harness | Direct Claude CLI 2.1.329, not Worca, no subagents, no OS sandbox |
| Usage | Token totals are not reliably exposed in-session (stream usage fields are in-flight partials). The harness's final result record holds elapsed time and usage. |
| Scope | Proof-runner tooling and delivery evidence only; not Silver's unchanged language or theorem corpus |

Source freeze verified: base to target changes only `scripts/` (5 files), `tests/` (5 files), guidance and evidence. Scripts and tests are byte-identical from `f0a773fbcb` to the target. No Ada, Lean, catalogue, sample or project file changed. `salient.diff` is byte-identical to the Git diff for its 14 files.

## Findings

### C406-M1 (medium, newly introduced): spec and body spellings of one unit are separate recurrence scopes

- **Where:** `scripts/focused_proof.py:36-38` builds the scope from the typed filename, while `:40-46` maps a spec to its body. `scripts/dev.py:461` records that scope; `scripts/run_history.py:137-138` and `:167-181` compare it.
- **Trigger:** `dev.py prove --unit silver_numbers.ads` and `--unit silver_numbers.adb` both run `-u silver_numbers.adb`, but record scopes `["compiler", "silver_numbers.ads"]` and `["compiler", "silver_numbers.adb"]`. The retained real unit run already shows the first scope with the body command.
- **Reproducer:** `probe_unit_spellings_split_recurrence` in `probes/probe_focus.py`. Alternating spellings allowed five failed attempts on the same helper and check kind before any hold; three attempts with one spelling are held as designed.
- **Consequence:** Exact-location and helper recurrence both split by spelling, and a success under one spelling does not reset failures recorded under the other. This contradicts the documented "normalized ... unit family" (`docs/proof-iteration.md:249-250`). It weakens a workflow prompt only; no proof result or audit is affected.
- **Minimal fix:** Record one label per unit, for example the unit stem, in `FocusedProof.scope()`, and add one regression. Any script edit changes hashed proof inputs, so file this as a follow-up rather than amending the validated PR.
- **Recheck:** I considered whether recording the typed text is intended. The runner already normalises equivalent selector spellings elsewhere (`test_equivalent_selectors_share_diagnostic_scope_and_distinct_targets_do_not`), and the guidance presents `--unit` as selecting one unit, so I retain this as a defect at the low-consequence end of the band.

### C406-L1 (low, record): retained-test applicability for auditor-dependent modules is a judgment the packet does not enumerate

- **Where:** `docs/evidence/proof-iteration-efficiency-373-20261120/README.md:34` and `final/README.md:15` in the same packet call the 282 reruns the "affected" tests. `docs/reviews/review-proof-efficiency-373-20261120.md:24-26` gives the rationale.
- **Fact:** 16 retained modules (111 retained IDs) import `scripts.check_evidence`, whose `audit_reports` path was refactored in this PR (`scripts/check_evidence.py:315-342`, `:530-535`). They are `test_arguments`, `test_branching`, `test_command_line_greeting`, `test_common_expressions`, `test_composed_results`, `test_copy_values`, `test_greeting`, `test_image_reports`, `test_image_setup`, `test_main_discovery`, `test_named_output`, `test_output`, `test_samples`, `test_shared_bindings`, `test_silver` and `test_string_assignment`. They were not rerun.
- **Consequence:** Under `development.md`'s wording ("affected ... through shared ... tooling") these are arguably affected tests. The delivery instead relies on the implementation reviewer's equivalence judgment, supported there by three positive comparisons.
- **What I verified:** I ran the base and target auditors side by side on the retained 78-unit final reports and on six real application report sets from the #391 packet (`docs/evidence/advisory-policy-391-20261116/auditors/accepted-reports.tar.gz`), including 240 mutated variants. 247 of 248 outcomes were identical, and the six application results match their recorded statistics. The one difference is an exception type (`KeyError` instead of `EvidenceError`) when a caller names a trusted unit that has no entity table; no production caller or retained test call site can reach it. I also ran 14 of the 111 IDs fresh at the target (`test_image_setup`, and the two pure-Python classes of `test_image_reports`); all passed. The other 97 need the native toolchain and were not run.
- **Minimal fix:** Add two sentences to the regression README naming these modules and the equivalence basis. Rerunning them is optional; my comparison supports the applicability judgment.

### C406-L2 (low, record): one stale status sentence in the roadmap

- **Where:** `roadmap.md:222-223` says the reduced package is selected "with the recovered implementations awaiting reconciliation and final validation". It dates from the first PR commit (`b1f55e5126`).
- **Consequence:** It contradicts `roadmap.md:42-56`, which records the package as complete for review with validation passed.
- **Minimal fix:** Reword to "delivered for review in PR #406".

### Info (optional follow-up)

- **C406-I1, rejection branches of the focused checker have no regression tests.** Tests cover partial unit coverage, contextual expansion, missing selection, stale summaries and a foreign workspace. No test asserts the analysis-completion, skip/assume, flow/proof classification or SARIF-identity conditions (`scripts/focused_proof.py:51-54`, `:83-93`), the trusted-import and vendor branches (`:61-69`), or input drift during a focused run. My probes show all of them fail closed (21 mutated conditions in each mode). A compact table-driven test would keep that true.
- **C406-I2, selecting a subprogram by its body line is rejected with a generic message.** GNATprove's selector matches the declaration or the body location (upstream `Check_Limit_Subp`; the installed 16.1.0 binary carries the same symbols). The checker matches only the declaration location (`scripts/focused_proof.py:76-79`), so the run is rejected after the proof work with "no fully analyzed entity at the requested focused selection". The guidance does say "declaration line"; a hint in the message would save a rerun. I did not run GNATprove to confirm this; the rejection was reproduced on a simulated report shape.
- **C406-I3, `--subprogram` on an outer subprogram does not cover nested contract-bearing helpers.** By GNATprove's selection rule, only the requested entity is analysed. `src/silver.adb` nests `Execute`, `Same_Source`, `Compile`, `Read_Proof`, `Prove`, `Build` and `Publish` inside `Silver`; `src/silver_image_adapter.adb` nests `Failure`, `Native` and `Process_Input`. The focused report names only the selected entity, so the human coverage review can see this, but one sentence in `development.md:162-171` pointing to `--unit` for such helpers would help. Derived from the upstream source and consistent with the retained `Decimal` run; not exercised on a nested example.
- **C406-I4, documented conservative holds, confirmed.** Three `--subprogram` failures hold plain `prove` and `prove --full` for that task, but not `--unit`, `build` or another task. Two failures, then a containing-unit success and a moved-line success naming the same helper, then one later failure, produce a hold. This matches `docs/proof-iteration.md:254-263`. Since `focused_report.subprograms` already names the proved helper, clearing on a name match is a possible later refinement.
- **C406-I5, focused checks omit the complete audit's advisory and assumption-dependency classification.** This is by design and consistent with "focused success never substitutes for complete assurance". A unit can pass focused and still fail the complete audit on an unreviewed advisory.
- **C406-I6, records created by this review.** Two managed `test` records exist under task `#406-external-claude-review`. Run `20261120T192655-0a719b502bc8` failed because two toolchain-dependent test classes cannot set up in the unbootstrapped review worktree; run `20261120T192916-8dbc8ff09f96` excluded them and passed 195 tests. Neither affects recurrence or any proof record.

## Answers to the prioritised questions

### 1. Focused proof correctness and coverage

`--subprogram` uses the complete policy options plus `--limit-subp`; `--unit` replaces `-U` with `-u` on the body, or on the spec for spec-only units. Both force analysis and use the isolated `focused/4a9057104dad17e3` namespace, whose name I recomputed from the policy options. The two retained real commands match this exactly.

- **Coverage:** I ran the unit-mode checker over all 78 retained real unit reports. All were accepted, including the 6 trusted-import and 2 vendor-instance units, and the totals equal the complete audit (1,252 entities, 1,751 flow, 17,975 proof). Spec and body selections gave identical results.
- **Contextual inlining:** The upstream GNATprove source confirms the behaviour the internal review described. For an always-inlined local helper the selector is cleared and the whole unit is analysed in a line region, so the coverage map holds every unit entity and the equal-length check rejects it.
- **Freshness and identity:** Prior summaries are deleted before the run and kept under `previous-reports`. Inputs are hashed before and after; an edit during the run is rejected. The SARIF command must equal the effective command.
- **Promotion to complete evidence:** Not possible. A focused run writes no manifest, and the provenance validator rejects its command shape.
- **Shared auditor refactor:** Behaviour-preserving for the complete audit (see C406-L1). Re-auditing the retained final reports with the target code reproduces the recorded statistics.

### 2. Recurrence and diagnostics

Helper identity is the producer's fully qualified name plus rule, taken from `.spark` entities and SARIF logical locations, which agree in the retained reports. The compiler fallback normalises as described, queries have their own scope, and historical zero-worker query records are skipped. Missing or malformed metadata falls back to exact keys only. Success and diagnosis resets match the documentation. The only defect is C406-M1.

### 3. Resource behaviour

Requested, automatic and granted values are recorded on every run. The reason gate applies to `prove`, `tool gnatprove` and Lean only, and `--reason` does not satisfy it. A missing reason is refused before any directory, lease or record is created. Automatic grants reduced by reservations need no reason. The final records show 22 automatic workers and 22 Lean threads. Resource-only cache reuse holds in real evidence: the final Lean run built nothing after a preparation at 2 workers with a memory threshold, and its 6,202 artifact hashes equal the preparation's. No script or CI caller passes a reduced count that the gate would now refuse.

### 4. Evidence and regression applicability

| Claim | Result of my check |
| --- | --- |
| 757 IDs = 282 fresh + 475 retained, 33 added | Reproduced from both raw logs and discovery at the target. Both logs end `OK`; every ID has its own `ok`. |
| Final native: 78 units, 1,252 entities, 19,726 checks, warm forced audit | Manifest is complete, mode `full`, sessions and cache present. All 80 report hashes match. SARIF command equals the manifest command. Target-code re-audit passes with the same totals. |
| Final native inputs equal the target | All 148 tracked input hashes match the target tree. Build and native captured identical inventories. |
| Final Lean: 1,035 modules, 166,332 declarations, cached build, fresh audit, no replay | Build phase built nothing and replayed one cached module. The separate audit phase lists 1,035 unique modules equal to the evidence and the three permitted foundations. No kernel phase. All 1,143 input hashes match the target tree. |
| Build was an up-to-date invocation, not a recompilation | Log shows both binaries up to date. Root binary hashes match the record. |
| Preparation is old-runner work | Its captured script hashes equal the base scripts. The first Lean run ends in `phase_interrupted` with no completion event. |
| Focused CLI runs | Line 11 of `silver_numbers.ads` is `Decimal`. Coverage holds only that entity. Counts 2+6 and 4+14 match. |

### 5. Practical completeness

Guidance matches the tested interfaces. The older documents that show explicit reduced worker counts are dated measurement records, not current instructions. The gaps are C406-L2, C406-I1 and the wording suggestions in C406-I2 and C406-I3.

## Inherited versus newly introduced

- **New in this PR:** C406-M1, C406-I1, C406-I2, C406-I3, and the exception-type difference noted under C406-L1.
- **Inherited and unchanged:** flow-check failures produce no recurrence keys; exact-location recurrence is tied to the exact scope; every native prove, build and tool command leases the toolchain context, so focused and complete runs in one checkout serialise.

## Not examined, and residual limits

- I ran no GNATprove, Lean, gprbuild or bootstrap command and no full suite. Statements about GNATprove 16.1.0 selector behaviour rest on the upstream source at the commit the internal review cited, matching symbols in the installed binary, and the retained reports.
- I did not run the Lean-dependent or platform test modules, nor the 97 retained auditor-dependent IDs that need the native toolchain.
- I did not re-hash the 2,437 tool and generated inputs, the 1,037 workspace inputs or the 6,202 Lean artifacts, and I did not verify every archive-manifest entry.
- `check_lean.py` was reviewed through its diff and `main()` only. I read the changed Lean, platform and provenance tests but ran only `test_proof_provenance` among them.
- I did not consult GitHub, the board or issue state, and did not review macOS paths.

## Reviewer artefacts

All under `tmp/external-review-pr406-8dc409b303/`:

- `probes/diff_auditor.py`: base versus target auditor comparison.
- `probes/verify_regression.py`: regression census.
- `probes/verify_final.py`: final native, Lean and build records.
- `probes/probe_unit_mode.py`: unit-mode checker over the 78 real unit reports.
- `probes/probe_focus.py`: focused entry-point behaviour, including the C406-M1 reproducer.
- `probes/managed-test/`: logs of the two managed test runs.
- `scratch/`: extracted evidence copies and three public GNATprove source files fetched for reference.

Each probe's docstring gives its command line; `.out` files beside them hold the output I relied on.

The worktree is unmodified. No tracked file, proof workspace, tool installation or existing evidence was changed, and nothing was posted to GitHub.
