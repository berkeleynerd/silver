# PR #412 external review response — 2026-11-22

The owner accepted the proposed response and authorized a focused proof review
alongside the existing findings' repairs. The original
[Claude report](review-pr412-claude-20261122.md) is preserved verbatim. It reviewed
`5a4b0ad8ac` and found no blocker, one medium, three low and six informational
items. The original report approximates its finish at 02:05 UTC; captured
launch/exit metadata instead records **01:09:13–01:59:56 UTC, 50m42.8s**.
The [response packet](../evidence/named-array-parameters-410-20261121/review-response/README.md)
retains that metadata and the repair evidence.

## Dispositions

| Finding | Response |
| --- | --- |
| C412-M1 | Repaired under existing #413: add function/procedure counted nests and a formal-array Range nest to the source-limit full-route test. All six families use exactly 4,096 bytes plus 4,097-byte rejection siblings. Linux explicitly uses 16 MiB and restores the previous limit. The stack record retains reviewer minima and qualifies old ARM64 evidence. Fresh full-route run `20261122T104947-be031f0bee17` passed. |
| C412-L1 | Remove Horner's unused `integer_array_bound_query` tag, retaining `integer_array_range`. No sample source or expected behavior changes. Independent review checks applicability to the manifest readers. |
| C412-L2 | Replace the capacity account's stale draft/pending introduction with links to completed delivery evidence and the separate ongoing external follow-up. Dated historical checkpoints remain history. |
| C412-L3 | Update the PR description to name CPU allocation/affinity changes, all-platform serial application proofs/builds, and the three-hour maximal-expression test deadline. This is a harness deadline; production prover steps, timeout, memory, portfolio and required discharge remain unchanged. |
| C412-I1 | Retain serial application proving/building for this response. It is a conservative policy expansion beyond an eight-CPU ceiling. Bounded allocation-aware application workers are a separate follow-up, not selected here. No matched old `-j0` timing establishes a slowdown ratio; the former 300-second deadline is not a measured baseline. |
| C412-I2 | Retain the tracked all-host `CPU_LIMIT = 8` for this response. It is conservative on other hosts. Host scope can be addressed with the separately selected application-worker follow-up, without adding a scheduling framework. |
| C412-I3 | Resolve the stack-test part through M1's explicit limit and restoration. Keep actual setting evidence with that test; no general runner schema is added. |
| C412-I4 | Optional additional full-route forms remain test improvements, not demonstrated semantic failures. The new formal-array Range fixture adds one relevant composition; the other listed forms remain optional. |
| C412-I5 | Defer affinity restoration for threads born during a run until a long-lived multiple-run launcher needs it. Current launchers exit after one run. |
| C412-I6 | Repaired the maximal-expression test's timeout path: use an isolated session, terminate its compiler and solver groups, and reap the compiler before re-raising `TimeoutExpired`. Independent repair review caught that Why3 gives solvers separate process groups; the first group-only repair did not cover them. Revised controls passed in `20261122T105339-12d0cd057611`; the independently reviewed repair is integrated as `3258c573a7`. The affected maximal-expression full route is running before closure. |

## Proof-review scope

The original review did useful independent source work, especially on #414, but
explicitly sampled proof roots, statements and trees. It did not examine every
new full-domain argument, freshly audit extended primitive-interpretation fields
or rederive report-capacity arithmetic. The follow-up is selected as **Claude
Fable 5.2 / Max**, with the runtime model confirmed as `claude-fable-5-2` and
effort confirmed only as the explicit CLI selection. Server-side effort is not
independently exposed.

Managed run `20261122T104651-c6826d4fd799` started the reviewer at 10:46:54 UTC,
on fixed source `5a4b0ad8ac`, reserving two CPUs with actual affinity 0–1. Its
remaining scope is full-domain array views/frames/calls; native preconditions
and primitive assumptions; actual-source imports on Main and callable-local
paths; preservation through safety **and automatic discharge**; and feature-local
report capacity. It must report explicit argument coverage and remaining gaps.
It is a read-only source/evidence review, with no repeated full proof computation,
200-probe sweep or broad record audit. The follow-up is still running.

## Validation boundary

These repairs change tests, one sample capability tag and records. They do not
change Ada, Lean, catalogue, runner scripts or sample programs. The complete
native and Lean checkpoints remain eligible for reuse after exact input checks;
their successful outcomes are not evidence for the changed test bodies.
The affected test identities need fresh results, and an independent applicability
review must account for the final discovery inventory and retained results.

The maximal-expression run previously took roughly 72–116 minutes under serial
application proving. Its rerun is necessary because this repair changes its
launcher. Preserve prior successful evidence and any new failure as recorded;
do not repeat the complete native/Lean runs merely for these test/record edits.
PR #412 remains open. No merge or next capability is authorized.

The [independent repair review](review-pr412-repair-applicability-20261122.md)
found 787 discovery identities: 783 retained
results (756 original full-suite, 15 proof-reader and 12 Rosetta), two changed
existing identities and two new controls. Horner's single tag deletion changes
none of the manifest test's source, expected-output or audit-policy decisions;
the other direct manifest reader uses three unrelated sample outputs.
The two corrected timeout controls passed; the final response still needs the
maximal-route pass and focused Claude proof verdict.
