# Admission Repairs

Authorized 2026-10-14 after independent assessment of
[review `e2c4fc2`](reviews/review-e2c4fc2.md), against
baseline `e2c4fc29f843e635c106f49112d732236cc00f8a`. This corrective milestone
completed on Linux x86-64 on 2026-10-15, before further language features.
The original reviewer report is preserved unchanged in this delivery.

## Scope and dispositions

- **B1 confirmed and fixed:** a static target assigned a longer static prefix concatenated
  with input can prove yet fail GNAT code generation in an unreachable arm.
  Require the RHS static contribution not to exceed a static target, and equal
  it when no dynamic occurrence exists. Apply the rule to either operand order;
  retain reachable-path length equality. This intentional pre-1.0 restriction
  avoids making membership depend on GNAT's operand-order/folding behavior.
- **B2 confirmed and fixed:** GNAT always recognizes bracket wide-character encoding.
  Reject a literal ending in decoded `[` when its closing quote immediately
  precedes an ASCII letter, digit or underscore. Whitespace, comments and
  parentheses remain permitted; there is no general bracket ban.
- **L1–L3 fixed:** clarified initializer visibility and restriction purposes;
  added compact accepted/rejected siblings and representative compile/run checks.
- **L4 bounded response complete:** checked equality of the duplicated Names and
  Compose lexical helpers in the existing source bridge. This is a drift guard;
  it does not eliminate the documented lexical interpretation premise. A larger
  call-record adapter is deferred because no behavior or consistency defect was
  found and the existing premise remains explicit.
- **Capacity recorded:** retained the 785-assignment result without another dense
  compilation. The 32-minute timing is attributed to the reviewer; the repaired
  compiler still admits the exact retained source.
- **Python provenance:** the reported interpreter mismatch does not reproduce
  on this host; all current hashes validate. Retain the interpreter hash check.
- Corrected the current complete Lean evidence link in the assurance document.

Independent assessment evidence is retained in
`tmp/review-e2c4fc2-assessment.md` and the linked native probe records. The B1
assessment reproduced 46 proved checks followed by failed code generation;
the reversed operand control built. B2's twelve probes split into six codegen
failures and six successful close siblings.

## Completion criteria and validation

Complete native and Lean rule/source changes together with specification,
catalogue and tests. Use focused development checks; freeze captured inputs for
one shared Linux checkpoint. Run full GNAT object code generation over available
admitted differential corpora once: frontend-only `-gnatc` misses B1. Record the
actual recovered corpus scope; the review's corpus totals are not local evidence.
Do not add corpus-wide GNATprove, a new testing framework or a per-edit gate.

The updated native compiler builds and its exported catalogue is byte-identical
to the checked-in JSON. All 29 focused tests passed (231.767 seconds while other
checks ran), including real proof/build/execution of the new admitted siblings.
The B1 focused Lean check passed its model invariant, exact path-source checks
and bridge; the shared literal model and decoding checks passed separately.
Those focused results preceded the complete checkpoint below.

The full native Linux audit passed with 3,172 proved checks (572 flow and 2,600
proof), 20 units and 313 entities. Its completed provenance binds 2,408 inputs
and 22 reports. This was forced complete analysis with existing sessions/solver
cache available, not a cold timing experiment. The complete suite passed
**307/307 tests**, with no failures or skips, in **1,959.439 seconds** while Lean
and corpus compilation ran alongside it. Its 343-file source/proof/script/test/
sample/catalogue inventory was identical before and after the run. No late proof
edit or focused repair is being substituted for that complete stable-input result.

Independent read-only cross-review found no correctness issue in B2's native,
relational and typed-expression guards, B1/B2 regression pairs, the catalogue,
restriction purposes, equality guard or corpus runner. The implementation
review examined semantic changes together with their source-shape pins;
regeneration alone was not treated as correspondence evidence.

The recovered corpus contains 269,622 unique candidates from older differential
records, sequencing JSONL, current regressions and the independent assessment
fixtures. All were rechecked without filtering on old verdicts: **93,007 admitted**,
176,615 rejected, with **all 93,007 admitted programs passing full GNAT object
code generation** and zero failures or timeouts. The pass took 2,691.300 seconds
alongside the other checks. It used `gcc -c -gnat2022 -gnata -gnato -g`, verified
each source hash, removed stale objects before compiling, required a new object,
and confirmed unchanged compiler/source hashes at completion. It did not run
GNATprove across the corpus. The
latest reviewer's private session corpus was unavailable from the supplied paths
and a bounded local search, so its reported counts are not claimed as this run.

The complete canonical Lean 4.34.1 check passed all **252 modules**, with a fresh
audit of **56,876 declarations** and only `propext`, `Classical.choice` and
`Quot.sound`. That declaration count is an axiom inventory, not an independent
kernel replay. The runner used 12 Lake workers, 12 threads per process and a
16,384 MiB per-process Lean threshold. Its incremental build took 2,075.408 seconds,
the audit 3.789 seconds and the complete invocation 2,084.086 seconds.
`ComposeSourceChecks` dominated the build at 2,059 seconds; this is a concurrent
repair measurement, not a matched performance comparison with the earlier tree.
The new Names/Compose identity guard and the complete concrete source-model
witnesses passed as part of this check.

The completed isolated B1/B2 caches were integrated with their private/server
sidecars and Lake metadata intact. The normal canonical runner synchronized
inputs, regenerated certificates and applied dependency invalidation; no trace
was changed to claim an unchecked reuse. The three changed source certificates
were validated in the focused runs and reused at integration. Earlier canonical
artifacts were preserved separately. The final source digest and native provenance
were checked against the actual tree after all runs:

```text
2dd2bc19dc72d01352b7f1f987e70072d45986a706e18d8e256eb2ed97b87109
```

## Evidence and handoff

Local records are under
`.silver/linux-x86_64/admission-repairs-20261014T234242Z/`, located by
`tmp/admission-repairs-active.json`. They include the native reports/provenance,
full-suite input/result records, focused and complete Lean evidence/logs, original
cache backup, cache-integration record, and corpus manifest, per-source results
and summary. The corpus manifest SHA256 is
`db7b2953777de00c8bd18126661914812d3f66ec2a01f1d62202c0ce8c195c80`.
The original assessment and independent probes remain in `tmp/`; they are not
substitutes for the complete checkpoint. The review target remains `e2c4fc2`;
Git identifies the subsequent repair commit containing this record.

All approved repair work is complete. Existing caches, source evidence and
unrelated scratch remain preserved. The larger Names lexical-call adapter stays
deferred as described above. No new language feature, Oracle amendment or recurring
full-corpus gate was introduced. Independent replay, macOS proofs and hosted CI
were not run. No next capability or replacement harness goal is authorized by
this completion.
