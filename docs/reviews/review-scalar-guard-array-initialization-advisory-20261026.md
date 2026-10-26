# Compiler array-initialization advisory assessment — 2026-10-26

Recommend a strict compiler-only classification of this exact diagnostic. Do not alter the five source loops merely to remove it, and do not add a general warning exemption. The pinned producer loses an initialization fact; it neither skips a required check nor assumes safety. This fits the existing Oracle and GNATprove trust boundary without a new premise.

Selected reviewer: GPT-6 Astra, Extra High, requested at spawn; runtime model/effort are not independently attested by a tool. Started 10:47:18 UTC on Linux x86_64. Token/cost measurements unavailable. This was read-only source/report analysis; no validator, compiler, prover, Git mutation, or GitHub mutation was run. Only this scratch directory was written.

## Exact inputs

Canonical `tmp/scalar-guard-refinement`, HEAD observed `e0f11e30fe252a7641e5fef748ec2f44f09faf93`; compiler source final d039e68dba remains byte-identical to native `tmp/bounded-mutable-integers-native`:

- `src/silver_output_profile.adb`: SHA256 `ec2f0a72dcbdcf1ff6dadc9fb8ec2975653a8c0c11db2bf3d53b7a5b8dec3a3d`.
- Native `.silver/linux-x86_64/compiler/obj/gnatprove/silver_output_profile.spark`: SHA256 `5c9b5c8e040a97824340f9f87bb7060a63618180efde5093c511cdd4ce76aeff`.
- Native `gnatprove.sarif`: SHA256 `494a844e55631ab9590b6366434e58f6fea0863543e2eec18829a0b7c4dd2393`.
- Both reports exactly match `.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/20261026T084316-ffe7696c9a8a/reports/0/`.
- Governing AGENTS.md, Oracle, development audit rules, trusted-boundary audit and GNATprove premises, assurance report requirements, current `scripts/check_evidence.py`, retained SPARK 16.1 references.

`evidence.json` preserves all five exact SPARK/SARIF records and fetched vendor-file hashes. Pinned vendor sources were retrieved from `AdaCore/spark2014` commit `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, already identified in the repository's trusted-boundary document. Fetched `vc_kinds.ads` and `.adb` are byte-identical to the retained references. This is source review under the existing pinned-tool premise, not binary-source attestation.

## Meaning and producer route

1. Retained `references/spark/16.1/docs/ug/en/source/flow_limitations.rst:1` says these constructs “can be used safely but might lead to unprovable checks”; line 7 identifies loop array initialization. This belongs to **flow** limitations, absent from `proof_limitations.rst`.
2. Pinned `src/common/vc_kinds.ads:445–451` explicitly classifies `Warn_Init_Array` under “Flow limitations not impacting soundness.” Lines 775–776 supply the exact message; `.adb:1903` supplies `array-initialization`. `.ads:620–630,665–668` makes this an optional information warning disabled by default.
3. Pinned `src/flow/flow-control_flow_graph.adb:3179–3183` calls `Variables_Initialized_By_Loop` a conservative heuristic. `Get_Array_Index` (3672–3890) recognizes supported array/index shapes; `Fully_Defined_In_Original_Loop` (3896 onward) additionally rejects explicit reads and incomplete definitions. `Potentially_Defined` (4015–4032) inserts a variable into `Fully_Initialized` only when recognition succeeds; otherwise it calls `Emit_Warning`. The warning path does **not** insert the variable. Only recognized facts later create the synthetic initialization vertex (4307–4323). Failure therefore withholds a positive initialization fact; the ordinary CFG/analysis remains.
4. `Emit_Warning` (3648–3665) checks type/default initialization, in-out parameters, relaxed initialization, and phase; it does not check all earlier executable assignments. `flow_utility-initialization.adb:699–776` confirms the default-initialization test. Thus a warning can be emitted even though executable initialization already establishes safety.
5. `src/utils/errout_wrapper.ads:101–121` defaults warning-record fields to trivial proof category, empty check tree and unknown status. `Warning_Msg_N` in `.adb:874–916` appends the diagnostic to `Warnings_Errors`, with those defaults. The warning's `unproved_status: unknown` is not an unproved VC.
6. Disabled warnings become `suppressed: ""` (`errout_wrapper.adb:117–130,881–916`); `spark_report-generate_sarif_report.adb:63–108` translates that to `suppressions: [{"kind":"external"}]`. Warning severity maps to SARIF `kind: open`, `level: warning` (377–401). This representation is also used for source warning suppression, so the existing source-policy ban on `pragma Warnings` and fixed command/project policy remain necessary.

## The five sites and retained proof evidence

| Assignment site | Initialization already established before the loop |
| --- | --- |
| `silver_output_profile.adb:1161:16`, Initial_Flow | `Result.Values := (others => Scalars.Empty)` at 1156 |
| `:1283:16`, Joined | Whole `Result := Left` initialization at 1275 |
| `:2060:32` and `:2061:33`, Read_Relation_Into negation | `Read_Primary_Into(..., Result)` initializes its out result at 2033 before swapping its initialized arrays |
| `:2883:29`, Loop_Body | `Inner_Scan.Facts.Values := (others => Scalars.Empty)` at 2878 before copying the prefix |

These loops have invariants and/or read initialized arrays; the final loop copies only the old prefix into a larger already initialized array. They need not satisfy the producer's special full-array-initialization heuristic. Exact trigger tracing from expanded frontend trees was not performed; it is unnecessary for the documented conservative classification.

The unit's retained JSON has 247 `info/flow` and 1,842 `info/prover` records, empty assume/skip lists and `STOP_REASON_NONE`. Every warned assignment has proved index checks; the nearby loop invariant initialization/preservation checks are proved. Initial_Flow also has an explicit `UNINITIALIZED`/`info`/`flow` record saying initialization of Result proved. The complete native summary records 16,357 checks, 1,374 by flow and 14,983 by provers, with zero justified/unproved. These are observations from retained reports, not a fresh successful managed audit; the parent must still perform the repaired complete audit and source/provenance checks.

## Classification requirements and Oracle applicability

Use a distinct compiler advisory class, enabled only for the reviewed compiler unit/file (not application Main or library report acceptance). Require `warn_error`, exact rule and message, warning severity, `how_proved: trivial`, `unproved_status: {status: unknown}`, empty check tree, exact empty warning suppression, positive integer coordinates, and no justification, annotation, entity/VC metadata or other inconsistent fields. Match the corresponding SARIF exact `open/warning` record, filename/location/message and single external suppression, retain the SPARK/SARIF multiset equality, and count these separately from discharged obligations. Ensure mutated info/proof/flow forms cannot bypass the classifier through the general info allowance. Five observed sites are evidence, not a reason to hard-code a historical diagnostic total as coverage.

All actual flow/proof checks, complete entity/source coverage, zero skipped/assumed/justified checks, fixed invocation, source policy and fresh provenance remain mandatory. The Oracle forbids suppressing obligations and requires compiler Bronze/Silver verification; classifying this proved-safe tool limitation does neither. Source rewriting is an alternative engineering choice, but it would incur renewed source correspondence and proof work without resolving a missing safety obligation demonstrated here. No new language feature, trust premise, Oracle amendment or application advisory permission is warranted.

## Conditional auditor patch review

Reviewed latest scratch patch `../guard-array-advisory-patch-20261026/array-initialization-advisory.patch`, SHA256 `411a203575d4e4ebb8ab6cde793f1b535b6ff21c3feecaf8fca600edc8b4a987`. Proposed `scripts/check_evidence.py` SHA256 `7d8bb865f97e419ec5c3b6466964151feb3cd5ba8233fd80ae521af4525f268e`; proposed `tests/test_evidence.py` SHA256 `fe2bdb6287f64ece29a4b66e4c414f72a4e421a561f59f0d0e2f6c9244b90dd6`.

No blocking findings. The final patch restricts the diagnostic to compiler audits and unit `silver_output_profile`, enforces exact JSON/SARIF metadata, prevents the ordinary info path from bypassing the new classifier, counts advisories separately, and retains actual flow/proof checks plus cross-format coverage and obligation totals. Its focused mutation fixtures cover metadata, lists/status, another compiler unit, application policies, failed/assumed/skipped work, and missing/duplicate SARIF. Tests were inspected but not executed; the parent owns validation. Documentation should retain the distinction between flow limitation and proof limitation and preserve the full source/provenance policy.

Assessment/review completed 10:54:44 UTC, elapsed 7 minutes 26 seconds from first inspection (including source retrieval and patch coordination). This is observed elapsed time, not isolated model compute time; token/cost evidence remains unavailable.

## Lead integration and focused validation

The [retained failed native run](../evidence/scalar-guard-refinement/array-advisory-20261026/index.json)
contains the complete reports and transcript. The [assessment input capture](../evidence/scalar-guard-refinement/array-advisory-20261026/assessment.json)
retains the exact warning records and vendor hashes. The pinned
[conservative producer branch](https://github.com/AdaCore/spark2014/blob/42554fc241fcd1fdf08d3a2feccb3f86912acbc0/src/flow/flow-control_flow_graph.adb#L4015)
withholds the initialization fact on its warning path.

The lead applied the exact reviewed patch. Managed run
`20261026T105625-c89ba43031eb` passed all 60 tests in `tests/test_evidence.py`;
[commands, inputs and results](../evidence/scalar-guard-refinement/array-advisory-20261026/tests.json)
retain its scope. This is focused validation, not a claim that the repaired
complete native audit has finished. The active Lean source check remains frozen;
no native source or proof file changed in this auditor repair.

## Follow-up #245: malformed-message guard and evidence reuse

Selected reviewer remains GPT-6 Astra Extra High; runtime confirmation and token/cost measurements remain unavailable. This independent follow-up began 2026-10-26 12:06:36 UTC. Scope is solely the classifier delta and applicability of retained validation; no exporter, paused, successor, source or proof work was inspected. No validators were run.

Reviewed canonical HEAD `e88a218c7e935be6d885a5d1c43f0d94e9ebf031` plus the uncommitted two-line replacement in `scripts/check_evidence.py:465`. The old marker's unconditional `record.get("message", {}).get("text")` becomes `(isinstance(record.get("message"), dict) and record["message"].get("text") == ARRAY_INITIALIZATION_ADVISORY_TEXT)`. The exact array-rule disjunct and strict classifier are unchanged. The complete file diff contains only this replacement. No `src/` or `proof/` working-tree difference from that HEAD was present.

Exact reviewed hashes:

- Previous auditor: `7d8bb865f97e419ec5c3b6466964151feb3cd5ba8233fd80ae521af4525f268e`.
- Repaired auditor: `1cfe226a5c86874b4cd574da5589f8b925599f009a8e784bd42242e9da2b0060`.
- Saved `classifier-message-shape-245.patch`: `5ee4835f4ae706c81a1036bb0e33cb8b6223c034878a3fc5109870596af05f16`.
- Unchanged `tests/test_evidence.py`: `fe2bdb6287f64ece29a4b66e4c414f72a4e421a561f59f0d0e2f6c9244b90dd6`.
- Unchanged `tests/test_image_reports.py`: `65a14dd4c648218bcc4110b5d5fdf88ab3c715b36ef67d7a1042d276e2ebc96d`.

No blocking finding on this precise delta. If the rule is `array-initialization`, short-circuit evaluation enters the identical strict classifier, including its exact message object requirement. Otherwise, dictionary-valued messages yield the same marker result; an absent message still yields false. A malformed non-dictionary message now yields false at this marker instead of AttributeError. For the failing Image route, the already-existing `isinstance(..., dict)` requirement then raises EvidenceError. It remains rejected, with the intended error type. No valid report acceptance, warning permission, safety obligation, proof source or source correspondence rule changes.

Retained managed run `20261026T110119-3b18a2302af0` was independently inspected through `native.log` and `events.jsonl` under `.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/`. Its log SHA256 is `b7c531ce2d5e5d8e1d3f35588226ffada55170e016b5fb5f4dfafd51e76738c9`. It ran 511 tests in 3540.751 seconds, with one error: `test_image_reports.ImageEvidenceTests.test_mutated_advisory_fields_are_rejected`, subtest `changed message=[]`, raised AttributeError at the new array marker. The managed completion remains failure (return code 1), not full-suite success. This interaction was missed by the earlier read-only patch review and was exposed by the required full suite.

The remaining completed test methods and unchanged well-formed native report cases remain applicable: their marker decisions are unchanged by case analysis above. The existing Image mutation test already exercises the precise failed input, and the evidence test module exercises both marker disjuncts, strict array metadata, failed checks, policy boundaries, SARIF and totals. Running `tests/test_evidence.py` and `tests/test_image_reports.py` is sufficient regression scope for this delta, conditional on their passing and the reviewed delta remaining exact. No duplicate hour-long whole suite is justified solely by this error-type repair. This follows development.md:218–222 (repeat checks invalidated by changed inputs, failure or a concrete concern) and :335–343 (preserve successful work and choose the smallest remaining check).

The auditor is a captured provenance input, so final native/build/Lean records must still be refreshed as required under the normal cached workflow. Retained solver and build results are distinct from a fresh audit against the repaired auditor. Final reporting should identify the failed full run, the successful unaffected cases retained from it, and the separately successful targeted repair tests; it must not describe a fresh 511-test pass. Root owns those validation runs and final integration. Changes outside this exact delta require their own applicability assessment.

Follow-up review completed at 12:10:03 UTC, elapsed 3 minutes 27 seconds including awaiting the applied delta. This is separate from the historical 7-minute-26-second original review. Token/cost data remain unavailable.
