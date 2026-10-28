# Independent response regression-applicability and records review

Reviewed 2026-10-28. Selected reviewer: GPT-6 Astra / Extra High (`xhigh`), confirmed by the lead's spawn record; runtime settings are not independently attested. Total review elapsed time and token/cost measurements were not exposed or instrumented; no numerical estimate is invented. Work was read-only except this `/tmp` report: no tests, native proof, Lean build, or governed-file edits were executed. Unittest discovery enumerated tests without running them.

## Disposition

The proposed regression composition is applicable, subject to the final 28-test reruns and final-input comparison below. It is not yet a completed validation claim. All remaining results from the existing #266 regression composition remain applicable to the bounded response changes. No full regression rerun is required by an identified dependency or coverage gap.

The independently enumerated final inventory is **542 unittest identity strings**: the previous 540 plus exactly `test_dev_runs.DevRunTests.test_rosetta_test_dependency_drift_cannot_finish_successfully` and `test_dev_runs.DevRunTests.test_test_command_captures_only_rosetta_test_dependencies`; none were removed. These are 542 unique strings; nine underlying shared-bindings methods occur under both package-qualified and unqualified module names, leaving 533 distinct underlying methods. Preserve the existing inventory convention; no cleanup is requested.

After the four M1 proof files are integrated and frozen, run:

```sh
python3 scripts/dev.py test --jobs 1 -- -p test_lean_source.py
python3 scripts/dev.py test --jobs 1 -- -p test_platforms.py
```

This deliberately selects complete relevant modules (12 + 16), including unaffected methods in those modules, rather than a fragile individual-method filter. The exact selected identities are appended below. Retain the successful 26 runner, one catalogue and three Rosetta tests already executed on the response tooling snapshot. Expected completed coverage is **484 prior applicable passes + 30 response tooling passes + 28 final proof-sensitive passes = 542**. Until those 28 passes exist, the response remains incomplete. If final proof changes exceed the four files listed below or other implementation/tooling/test inputs change, reassess before adopting this partition.

## Evidence and dependency accounting

Inputs initially reviewed were response commit `d3d0b710d7`, based on #266 `873f5910d2`, plus the four uncommitted M1 proof files in `tmp/constant-array-source`. Later read-only reconciliation includes response HEAD `a0b126f9398c0aaf6f5f34bd056ae452588cc28e` and the lead's stack/evidence integration. The reviewed governing requirement is `development.md`'s full-suite-plus-reviewed-repair reuse provision. The external finding retention summary is `docs/reviews/review-10cdcd274c.md` (SHA-256 `e921a022145180b50c68eaed3e632c41b0006d9f3ab29d5a8349576a8c5efeec`).

The original complete run `20261028T110929-97e25e5a798e` has all 540 inventory identities and remains **failed**: 539 passes, one unchanged 180-second symlinked-TMPDIR fixture timeout. Existing #266 applicability records account for its successful repair runs. Against current response inputs, 771 nongenerated in-worktree captured paths match; the nine changed captured paths are the four previously reviewed `PredicateLoop*` proof files, `catalogue/silver.json`, `src/silver_catalogue.adb`, `scripts/dev.py`, `tests/test_dev_runs.py` and `tests/test_silver.py`. M1 will add the four proof deltas below. The original inventory and applicability hashes are respectively `cf6cc40a38850be5d21ced571548a42e67817a69461bbe45cad891cb5a101a60` and `ff902af1995fc5d4779a7f4c90d6ab0f0de17b623ee3ecb426db05cdd0db7a40`.

| Change | Regression effect and disposition |
| --- | --- |
| Five catalogue condition strings, paired Ada emitter/JSON changes and assertions in the existing catalogue test | One affected identity: `test_silver.SilverIntegrationTests.test_catalogue_is_json`. The compiler's catalogue branch alone calls `Silver_Catalogue.Export`; admission/compile/run logic is unchanged. `test_samples` reads only construct IDs from the catalogue, and that projection is identical. No sample rerun is required by these description edits. |
| Three explicit Rosetta capture paths added in `dev.py` and two runner methods | All 26 `test_dev_runs` methods have passed. The added block only extends the test-run input inventory; command construction and execution are unchanged. `test_proof_provenance` uses fixture inputs and unaffected proof branches. Platform fixtures import `dev` and will also receive a fresh full-module pass. No other fixture/tooling behavior is changed. |
| Four M1 proof files | `test_lean_source` scans the actual proof tree/import closures, so rerun its 12 methods. `test_platforms` copies all actual Lean files into its shared fixtures, and its TMPDIR test reruns that fixture suite, so rerun all 16. `test_lean_evidence`, `test_lean_modules` and `test_lean_run_history` use synthetic fixtures or unchanged concrete source/binding/audit modules; none reads these four changed proof implementations. |
| Documentation and `rosetta/assess.js` prose | No regression dependency. The three Rosetta tests read `refresh.py`, `manifest.json` and `coverage.json`, all byte-identical to the successful response run. They do not read assessor prose, assessment Markdown, language Markdown, or generated checked-in pages. |

For the three retained response runs, all retained compressed hashes, decompressed hashes, byte counts, commands, pass logs and successful terminal events were independently checked:

| Managed run | Covered identities | Managed elapsed |
| --- | ---: | ---: |
| `20261028T182607-8b55cdee57a3` | 26 runner | 4.197 s |
| `20261028T182645-200a4889f24e` | 1 catalogue | 2.555 s |
| `20261028T182657-152f444d7d05` | 3 Rosetta | 8.203 s |

Each captures 783 matching non-generated in-worktree paths against the reviewed response state, with no mismatch. Generated installation/compiler paths and external Python are separately captured; the earlier runner run preceded the catalogue rebuild, but its tests invoke only synthetic tools and do not depend on that binary. Catalogue and Rosetta runs captured rebuilt compiler SHA-256 `6f977ee2455d80af6522bf7a5454c27bbd6048666f861711b59372e93af4850d`. All three runs bind the Rosetta inputs:

- `coverage.json`: `55fdacf919477bf09dc8c4ce52341e84ff9f40809780ce7ab481be62b57a2294`
- `manifest.json`: `c007b4a67439be22b242e6104f5e41998d5aa3ca1a7174cfe3cc6de7927b452f`
- `refresh.py`: `a7dafee2207484e09b6d9e5e4c74c4414950a2cdae6b0ed2a6c8adb06eeb018e`

Pending M1 inputs reviewed for regression dependencies, **not semantic correctness** (the latter belongs to the separate independent reviewer):

| File under `proof/Silver/` | SHA-256 |
| --- | --- |
| `ArrayBindingsNativeExpressions.lean` | `7a59c90c66c6c4bdd187177dff733bfa2c8edfa5166dcc1bfe568608f419610b` |
| `ComposeExpressions.lean` | `732ab33404b83821025553c7a6125cec04c60cec31c2f27d3027b2947f879e51` |
| `PredicateArrayBodyNative.lean` | `3194c329e11058b58946b09a6f7bd5b12aa4e38086faa8d35f3b8407ff1ef067` |
| `PredicateArrayBodySource.lean` | `6a9a50d00a16485334dc598b3a987f995de4bcfffa975b280ad760c92d87080a` |

## Record corrections and remaining conditions

- **Corrected during review:** L7's new cache paragraph initially described 527 reused modules as disjoint groups of 261 and 270 (sum 531). The lead revised it to distinguish 257 + 270 reused modules from the overlapping origin count of 261 = 257 + four recorded output modules. This fixes the accounting presentation; historical seed origins remain explicitly external-review observations, not newly proved provenance.
- **Unnecessary rerun wording identified:** the response packet originally said final metadata required another Rosetta rerun. No changed tested Rosetta input exists; the existing three successes remain applicable. A future actual renderer/manifest/coverage change would invalidate that conclusion.
- L3 now explains pinned-frontend rejection for some dead/null-loop subscripts, explicitly acknowledges the uniform rule excludes some frontend-accepted shapes, and explains conservative body intervals and aggregate restrictions. L16 defines the recursively restricted subscript grammar. No language membership change is introduced by those explanations.
- L13 now records caller-domain, source-memory/header, Sequence and final delivery rounds, replacing stale present-tense pending claims with dated intermediate status. Missing historical implementation selections and runtime/cost measurements are labelled unavailable. The closing review's reliance on prior scoped reviews and missed M1 are disclosed.
- L1/L2/L5/L6/L9/L10/L14/L15 have matching bounded source/document corrections. L4's new README/trusted-boundary/old-N3 updates distinguish later array-frame growth and two successful 8 MiB counted/foreach observations from universal stack claims. The retained stack records show separate check, compile and execute exits of zero at 8192 KiB, source/binary identities, and the unchanged production `-j0` expansion to 12 workers despite CPU affinity. No frame-size measurement or universal maximum is invented.
- I1/I3/I7/I8/I9/I14/I15 are reflected in assurance, proof-iteration, retained advisory evidence, provenance distinctions, assessment prose and producer-file identities. Optional items remain dispositions/follow-ups. L11/L12 and #4/#6/#12 posting actions were reported complete by the lead; this subthread did not independently query GitHub.
- The complete native refresh was reported passed by the lead and has a retained packet; this review did not independently re-audit its full obligations. Final complete Lean/source assurance, final proof review, the 28 affected regression results, and final input applicability remain the lead's completion conditions. Regression composition cannot substitute for native or Lean assurance.

## Exact identities selected for the two final reruns

- `test_lean_source.CompilerSourcePolicyTests.test_all_bytes_have_the_explicit_compiler_alphabet`
- `test_lean_source.CompilerSourcePolicyTests.test_authoritative_bindings_are_not_generated`
- `test_lean_source.CompilerSourcePolicyTests.test_checked_in_certificates_equal_regeneration`
- `test_lean_source.CompilerSourcePolicyTests.test_compose_candidate_has_no_authoritative_source_dependencies`
- `test_lean_source.CompilerSourcePolicyTests.test_compose_source_checks_retain_authoritative_dependencies`
- `test_lean_source.CompilerSourcePolicyTests.test_current_compiler_sources_satisfy_byte_policy`
- `test_lean_source.CompilerSourcePolicyTests.test_embedded_source_lists_and_lake_dependencies_agree`
- `test_lean_source.CompilerSourcePolicyTests.test_hidden_declarations_fail_before_certificate_generation`
- `test_lean_source.CompilerSourcePolicyTests.test_include_str_is_confined_to_the_source_bindings`
- `test_lean_source.CompilerSourcePolicyTests.test_only_audit_roots_use_legacy_full_imports`
- `test_lean_source.CompilerSourcePolicyTests.test_unsupported_literal_syntax_cannot_hide_declarations`
- `test_lean_source.NativeCertificateTests.test_generated_certificates_and_witnesses_remain_kernel_checked`
- `test_platforms.InstallationEnvironmentTests.test_bootstrap_requires_complete_bounded_runtime_sources`
- `test_platforms.InstallationEnvironmentTests.test_bootstrap_reserves_the_library_evidence_precondition_suffix`
- `test_platforms.InstallationEnvironmentTests.test_generated_tool_command_anchors_and_quotes_installation`
- `test_platforms.InstallationEnvironmentTests.test_symlinked_tmpdir_preserves_platform_setup_and_routing`
- `test_platforms.PlatformIsolationTests.test_cached_build_log_cannot_replace_fresh_lean_audit`
- `test_platforms.PlatformIsolationTests.test_concurrent_different_host_setups_do_not_collide`
- `test_platforms.PlatformIsolationTests.test_development_commands_keep_project_outputs_and_audit_in_native_host`
- `test_platforms.PlatformIsolationTests.test_development_output_overrides_fail_before_invoking_tools`
- `test_platforms.PlatformIsolationTests.test_each_host_setup_preserves_other_hosts_and_shared_inputs`
- `test_platforms.PlatformIsolationTests.test_failed_proof_invalidates_only_its_host_evidence`
- `test_platforms.PlatformIsolationTests.test_foreign_execution_is_rejected_before_side_effects`
- `test_platforms.PlatformIsolationTests.test_lean_auto_and_explicit_resources_are_recorded_and_isolated`
- `test_platforms.PlatformIsolationTests.test_lean_full_and_clean_modes_record_their_actual_checks`
- `test_platforms.PlatformIsolationTests.test_legacy_archives_are_read_only_inputs`
- `test_platforms.PlatformIsolationTests.test_platform_aliases_and_disjoint_paths`
- `test_platforms.PlatformIsolationTests.test_unchanged_context_setup_preserves_generated_file_mtimes`
