# Factual changed-function inventory for Claude

Collected read-only by GPT-6.1 Sol / Extra High (selected), no test/proof execution or implementation verdict. Target 8dc409b303, base a412827d6c. Independently verify these pointers; they are review navigation, not an acceptance argument.

- check_evidence.py:310,315,530: extracted coverage_summaries/audit_unit_coverage shared between full and focused audits. Check extraction equivalence and source-bound imported/vendor exceptions.
- focused_proof.py:25,36,40: filename/line selection, managed scope, canonical option derivation and spec-to-body whole-unit resolution.
- focused_proof.py:48: producer completion/skip/assumption fields, full selection coverage, successful unsuppressed flow/proof records, matching successful SARIF invocation; contextual inlining rejection.
- focused_proof.py:101,106: policy-digest namespace and focused-state initialization marker.
- dev.py:109,152: reserved namespaces and separation from exploratory sessions/cache, including resolved aliases.
- dev.py:315: help/version query scopes.
- dev.py:406,453,540,558,594,603,633: focused routing, source inventory, lock-keyed cache, forced invocation, prior-summary removal, audit, retained reports and policy summaries.
- run_history.py:141,167,194: legacy zero-worker query exclusion, selector/compiler fallback family normalization, helper/check-kind recurrence and exact-vs-family success/diagnosis resets.
- run_history.py:268,490,499: helper identities plus exact failure keys from changed reports; missing metadata fallback.
- run_history.py:338,345,403,452,548: allocation accounting, reduction-reason gate, recurrence checks and status.
- check_lean.py:414,476,519: reasons/reporting for Lake workers versus process threads; memory reported without an automatic baseline.

Changed tests are concentrated in test_dev_runs.py:107,233,678,752,824; test_run_history.py:201,531; test_lean_run_history.py:82; test_platforms.py:300 and test_proof_provenance.py:295,410.

Questions worth examining (not findings):
- Whole-helper meaning depends on producer declaration sloc/coverage semantics and len(selected)==len(coverage); zero emitted checks can be accepted.
- final-policy reports option compatibility, not complete assurance; distinguish focused source/freshness auditing from the complete full manifest/source-policy path.
- Focused state survives source/selection changes, relies on a policy marker and existing lock-derived cache key; assess ordinary path/selection interactions within the trusted-local-tool boundary.
- Helper identity is name+rule, so equal names may collide; family-wide holds/resets infer scope, not a dependency graph. Canonical/direct-tool/compiler scope shapes differ.
- Only changed/new reports feed recurrence; malformed records contribute no invented keys. Trace zero-exit unresolved handling and strict focused auditing through terminal outcomes.
