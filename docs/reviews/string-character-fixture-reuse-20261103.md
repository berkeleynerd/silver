# Independent installed-Lean fixture reuse review

**PASS for bounded reuse of the seven fixtures below. No fixture rerun is
necessary.** Complete native-suite outcomes, native proof/audit, whole-project
Lean/source correspondence and final delivery review remain separate obligations.

Reviewed lead commit `53e2572ab477d8451444bf2040916e0a2a4f7fa8` and current
native fixture inputs at `79b350912a839dc5aa46c30bea79dfb99b0e41b1`.

| Retained run | Successful methods used |
| --- | --- |
| `20261031T214130-1e0195247bd5` | `LeanNativeAxiomAuditTests.test_actual_audit_accepts_foundations_and_rejects_other_assumptions`; all three `LeanNativeDependencyTests`; `NativeCertificateTests.test_generated_certificates_and_witnesses_remain_kernel_checked` |
| `20261031T215153-7280a74a41c2` | Both `LeanModuleTests` methods |

The first run remains **failed**. Its log identifies the missing
`ComposeBooleanDeclarationCandidate.olean` as the failure. The repair adds and
builds that isolated fixture module; it preserves the assertions requiring
rejection of the hidden private axiom. Both repaired module methods subsequently
passed. The [fixture evidence packet](../evidence/bounded-string-characters-20261031/validation/installed-lean-fixtures/index.json)
retains the exact logs, evidence and original prepared reuse account.

## Dependency and input review

The independent reviewer inspected the actual fixture code and dependency paths:

- Audit fixtures copy `AxiomAudit.lean` and construct temporary modules.
- Dependency fixtures construct temporary Ada bytes and projects, using the
  production Lake configuration and 28 handwritten source bindings where applicable.
- Certificate fixtures import the generator and freshly compile the six-module
  dependency chain in temporary directories.
- Module fixtures copy the production audit drivers but supply their own
  `Silver` facade and candidate module. They therefore do not import the
  production composition-proof closure.

The later production proof changes, including the helper-banner removal, do not
enter those fixture projects. The four later nonfixture test repairs likewise do
not affect these seven methods.

The supplied 37-entry dependency comparison omitted the directly imported
generator. The reviewer independently checked it against managed capture
`20261031T204547-993c226abf2b`, current capture
`20261103T192928-ecb0a9199439`, Git history and both current worktrees.
`proof/generate_source_certificate.py` has SHA-256
`52f4ee2dca6ffe39218118143c20e072bba7bb49d1bf49009bd2a6886fc0e50b`.

The reviewed set contains **50 unique paths**: the repaired fixture record's
14 inputs, the comparison's 37 entries and the generator, accounting for two
overlapping paths. All 50 current hashes match across lead and native worktrees.
The [exact path-to-hash mapping](../evidence/bounded-string-characters-20261031/validation/installed-lean-fixtures/reviewed-inputs.json)
has SHA-256
`cd10b45c8f9e09a16745e5482ec4e64c14d552aeaadc9cc317984c053342f9c6`
when serialized with
`json.dumps(mapping, sort_keys=True, separators=(',', ':')).encode()`.

Installed Lean/Lake executable hashes match the earlier and current managed
captures. Exported compressed logs/evidence reproduce the originals, and
exported fixture events match the managed registry. Actual fixture execution was
Linux x86_64.

All seven IDs occur in both supplied 578-ID inventories. Those inventories were
historical at review time: four lead test-file hashes changed, and native
synchronization was explicitly pending before its suite. The planned refresh
does not invalidate this fixture conclusion. Complete final-suite accounting must
use the refreshed inputs and its actual results.

## Review identity and scope

Selected reviewer: **GPT-6 Astra / Extra High**; runtime model/effort confirmation
was not exposed. Review started **2026-11-03 19:37:31 UTC** and ended
**19:40:23 UTC**, **172 seconds**. Token and cost measurements were unavailable.
No files were edited, tests launched or caches copied by the reviewer.

This report approves only these seven retained results toward final regression
accounting. The lead transcribed the independent report without changing that
scope; it is not a final #296 delivery review.
