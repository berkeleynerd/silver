# Proof-literal repair regression refresh

All 28 affected proof-source/platform identities passed for `d4e2be67b5de7fcc2919cf9eac6efb217e5ca672`.
The governed delta from `6020416906b5fc3d2bd10d012e70937c80f0617c` is exactly the [five Lean proof files](coverage.json);
Ada, scripts, tests, samples, catalogue, GPR/toolchain and native compiler bytes
remain unchanged. No native build or native proof was repeated by this round.
Selected model/effort: GPT-6.1 Sol / Extra High; runtime confirmation and token/cost
measurements are unavailable. The independent [terminal source/applicability review](../../../reviews/review-named-integer-subtypes-terminal-evidence-20261030.md)
confirms this exact proof-only delta and 28-test refresh.

| Run | Result | Managed duration | Unittest duration |
| --- | --- | --- | --- |
| `20261030T013443-d9556926db16` | 12 passed | 82.157 s | 79.349 s |
| `20261030T013608-6b001884b330` | 16 passed | 253.865 s | 250.766 s |

`test_lean_source.py` scans actual Lean sources/imports, and `test_platforms.py`
copies the complete actual Lean tree into its shared fixture. Those are the
only test families consuming these five changed files. Other Lean tests use
unchanged audit modules, bindings, Lake/toolchain inputs or synthetic fixtures.
The 18 recently refreshed compiler-fixture tests consume unchanged Ada and GPR
inputs and remain applicable, as do the earlier 509 original results under the
existing feature/Body_Tail reviews. Platform behavior is mocked host/tool routing,
not native macOS execution or complete Lean source assurance. Certificate/witness
regressions are small native Lean fixtures, not the whole project checkpoint.

The 28 new outcomes replace the same 28 identities; final regression accounting
therefore remains 509 original +46 refreshed =555 identities (546 distinct
methods), with no missing/failing identity. The 52 sample sources and 108
application executions retain their prior reviewed results. Prior reconciliation
and inventory bytes are preserved, alongside original managed events/logs and
hashes. All captured tracked inputs were compared with the reviewed implementation.
External/generated/tool input hashes also match both retained compiler-fixture
runs, including the unchanged native compiler binary.
The final three Rosetta refreshes remain deferred until delivery metadata.

Each test run reserved four workers; unittest and descendants used CPUs 8–11,
with managed runners retaining host affinity. Exact observations are retained.
Complete native/Lean assurance and source semantics have separate evidence;
regression results do not substitute for those obligations.
