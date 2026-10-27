# Independent retained-evidence applicability review — #246

**Verdict:** retained complete native evidence remains applicable, and regression coverage is closed for implementation `80d5ec3e0e5224fe36c705f6be15e429b7fa7468` after the focused Rosetta rerun identified during this review. A new full suite or native proof is not required by this delta. This is composed regression coverage and reuse of a completed native proof/audit, **not** a new successful full-suite or GNATprove run. Complete C1 Lean/source validation and final measurement review remain pending and are separate obligations.

## Scope and settings

Reviewed the implementation against baseline `e94c8b4343f429c434900cc2a23e29e870f577bf` in `tmp/velocity-246`, plus its intervening dependencies on the retained guard delivery and #257 record corrections. The tracked implementation was unchanged from the earlier C1 review. Documentation/evidence work in progress was present and is outside test/native input scope.

Selected reviewer: GPT-6 Astra, Extra High. Independent runtime confirmation and token/cost measurements are unavailable. Review began 2026-10-26 21:12:04 UTC; substantive checking finished around 21:16 UTC (approximately four minutes). Only records, sources and hashes were read. This reviewer ran no tests, Lean or GNATprove and wrote no running snapshot. The lead ran the three-test Rosetta repair identified below during warm correctness, outside the timed pair.

Exact principal inputs: `tmp/velocity-246-plan/native-reuse.json`; `docs/evidence/scalar-guard-refinement/delivery-20261026/validation.json` and its referenced complete native input/provenance records, failed-suite transcript and two repair transcripts; `docs/reviews/review-22838bc809.md`; current test sources and shared tooling; the current `tests-lean`/`tests-platforms` command, result and output files under `tmp/velocity-246-measure/`; `tmp/velocity-246-plan/test-rosetta.log`; and the corresponding managed `events.jsonl` files. The adopted narrow reuse rule is `development.md:236` onward.

## Native reuse

Independently checked the retained successful full native run `20261026T121322-fc9f4056f886` against its archived capture and present original workspace:

- All **2,519** captured files still match; none are missing or different.
- All **141** captured tracked native inputs match the reviewed implementation.
- All **12** recorded tool executable identities still match their retained SHA-256 values.
- The provenance is marked complete, full mode, Linux x86_64. The retained audit records complete coverage/provenance success; no failed audit is being substituted.

The independent hash comparison took 1.924 seconds. `scripts/proof_provenance.py` includes recursive native/generated Ada, recursive Python scripts, project files and Alire/configuration inputs; the C1 diff changes none of these. In particular, `proof/silver_proof_containers.gpr` is unchanged: the changed `.lean` files are not native compilation/proof dependencies. This confirms the scope claimed by `native-reuse.json`, while extending its baseline target comparison to the exact C1 implementation. The native check is retained evidence, not fresh native execution.

## Inventory and dependency review

A static AST inventory, reconciled against actual named transcript entries, finds **503 unique current test methods**. The retained complete suite executed 511 entries representing 502 unique methods: nine `SharedBindingsTests` methods are discovered both in their own module and through the unchanged import in `test_integer_loops.py`. The sole inventory change is replacement of the old composition graph test with two graph tests, yielding **512 standard-discovery entries** today. Every current method is present in the union of retained and focused transcripts; no current method lacks an observed result.

The retained full run `20261026T110119-3b18a2302af0` remains **failed**: 511 entries, one Image auditor error, no skips. Its malformed-message auditor repair was covered by successful `test_image_reports.py` (5 tests, `20261026T120715-ae60c9d42d98`) and `test_evidence.py` (60 tests, `20261026T120722-6e5bfb5dcbea`). The completed external review and retained exact delta review establish applicability of the unaffected results. The repaired auditor is unchanged here.

Independent search/read of test dependencies confirms that the C1 proof-tree discovery changes affect `test_lean*.py` and `test_platforms.py`. The latter copies the real recursive Lean inventory into its mock platform roots, so its rerun is necessary even though its own source is unchanged. Other references to `proof/` select the unchanged native `silver_proof_containers.gpr`; native report, source, fixtures, samples and compiler consumers do not discover the changed Lean modules. Shared Python fixtures/tooling and generated-native-source inputs are unchanged. The complete prior captured input comparison has only the known repaired auditor, changed composition proof and changed graph-test source as differing existing captured files; the new candidate is the one added Lean input.

| Current affected result | Managed run | Passed / skipped |
| --- | --- | --- |
| `test_lean*.py` | `20261026T210049-2ab535275e87` | 73 / 0 |
| `test_platforms.py` | `20261026T210647-cd87af06ed83` | 16 / 0 |
| `test_rosetta.py` | `20261026T211417-46cee0b78d17` | 3 / 0 |

The first two ran in the correctness worktree at the exact implementation commit. For all three runs, all **740** captured repository inputs match the reviewed tree, the captured external Python executable matches, and managed completion is success. The Rosetta run took 5.339 test seconds.

The third row closes a concrete finding from this review: #257 changed `rosetta/coverage.json`, which `test_render_is_identical_across_hash_seeds` reads in full. Its historical result therefore needed refreshing, despite unchanged test/renderer code. The prior response's single rendering did not exercise the test's two hash seeds. The lead reran the smallest affected module successfully; no broad suite repeat was needed. Rosetta data are not included in the general managed input manifest, so this applicability judgment additionally relies on the exact #257-to-C1 diff, the unchanged renderer/manifest, and the observed current-root rerun. The two test runs per hash seed exercised current metadata and generated outputs in isolated temporary directories.

All final inventory entries now have either applicable retained success or successful focused coverage. Keep the original suite labelled failed, retain the auditor repair and these 92 current focused tests as separate evidence, and report the complete C1 Lean checkpoint only after that independent pending work succeeds.
