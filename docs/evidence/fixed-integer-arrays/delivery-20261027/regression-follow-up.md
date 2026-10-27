# Array regression follow-up evidence

Updated 2026-10-27T13:32:52.901609+00:00. Task #260; selected inherited Sol Extra High, live runtime setting and token/cost measurements unavailable.

## Inputs and execution

Original full-suite snapshot: clean 726465447c11d8826164fdca343d71178dc53fdf in fixed-arrays-regression. Compared with final integration 899a15a5a0 across src/, scripts/, tests/, silver.gpr and Alire files: only tests/test_lean_source.py differs. Native compiler and both timeout cases' test dependencies are identical.

The original run reserved 3 workers. At 2026-10-27 11:37:02.191828 UTC its unittest and descendants were confined to CPUs 9,10,11, with inheritance; manager retained CPUs 0-11. Exact completed-test boundary was not captured. Both focused reruns reserved 5 workers and launched with CPUs 0-11. Existing deadlines and all prover flags were unchanged. Before each focused run, 7 of 12 workers were reserved by native4/cert2/Compose1; available memory was approximately 23-25 GiB.

## Original complete suite

Run 20261027T113223-c732210ca335: 530 tests in 6818.245 s; managed 6820.772 s; outcome **failure**, 3 failures and 2 errors. All 12 array tests and all 49 manifest samples passed. Exact five tracebacks: [full-regression-failures.txt](full-regression-failures.txt). Managed native.log and events.jsonl retain the complete original record.

| Original result | Exact finding | Successful follow-up |
|---|---|---|
| division native_dynamic_signs_and_minimum_integer ERROR | compile TimeoutExpired, existing 120 s test deadline | division module: 11 passed, 82.317 s tests / 84.795 s managed; run 20261027T132720-978e7f5308f1 |
| maximum_dynamic_expression ERROR | compile TimeoutExpired, existing 300 s test deadline | exact single test: 1 passed, 138.741 s tests / 141.495 s managed; run 20261027T132919-e15867ceed8c |
| dependency fixture FAIL | missing silver_array_bindings.ads and .adb | shared fixture inventory fix; parent's test_lean_evidence module: 49 passed, run 20261027T124456-035726160aa1 |
| embedded-source lists FAIL | 34 != 32 | parent's test_lean_source module: 12 passed, run 20261027T124103-ca072dcceb1a |
| include_str source confinement FAIL | 34 != 32 | same successful 12-test module |

Inventory fix 63b805fbe9 was integrated as ecd97be6ef and validated by the parent at 899a15a5a0. The 61 passing fixture tests were retained without repetition. Both focused reruns finished with managed outcome **success**. Their jobs5 leases are released. The original full-suite outcome remains failure.

## Preserved failed workspaces

- Division program-pbGNAR; main source SHA256 96161b1a4f084c2c86855c739f0a17ebf19d74550887b1ce5bbdb68a274d059e. Existing exact static/indexed-main report audit passed: whole summary 82 proved checks and 19 flow, zero unproved.
- Maximum-expression program-I9ugQa; main source SHA256 3dfeee525b935212f90c161d4eadc87ac1707aa1f33f347bcc008b2ef75ffbae. Existing exact argument/indexed-main report audit passed: 5 units, 110 proof checks and 19 flow checks.

These original failed workspaces remain retained; successful focused tests created and cleaned their separate workspaces normally.

## Remaining thread obligation

Native full run 20261027T104107-f971342569f8 remains active in immutable fixed-arrays-native at ac9ce5e523. At about 171 minutes the active worker was observe_object_list; no diagnostic lines, but final native tool exit, source/report/provenance audits and managed outcome success remain pending. Lead owns final applicability review, assurance integration, documentation and publication. Arrays remain unsupported pending complete delivery.
