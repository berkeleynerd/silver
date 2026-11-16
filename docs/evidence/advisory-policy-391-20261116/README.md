# PR #371 external-review repair: issue #391

The owner authorized the bounded repair on 2026-11-16, recorded in
[session memory](../../session-memory.md#2026-11-16--external-review-repair-of-pr-371-authorized).
The lead read [issue #391](https://github.com/berkeleynerd/silver/issues/391)
and both complete November 16 PR comments
([interim review](https://github.com/berkeleynerd/silver/pull/371#issuecomment-6922358697),
[premises follow-up](https://github.com/berkeleynerd/silver/pull/371#issuecomment-6927559652))
before implementation. The reviewed base is `877c382f6d`.
The reviewer's untracked archive directory remains outside the commit.

## Repair and boundaries

The existing Ada report-auditor body and Python evidence auditor gain only the
two exact formal-dependence advisories. `INOUT_ONLY_READ` requires a declared
procedure `in out` formal; `UNUSED_INITIAL_VALUE` requires procedure `in`/`in out`
or function `in`. Both bind the exact declared formal spelling to its local
owner, never Main, and require the corresponding exact template, warning/flow
provenance, `main.adb`, positive location and no suppression/justification.
Columns and record order do not identify formals. Existing accepted verdicts,
required checks and the admitted language are preserved.

One detail in the brief differs from the base: `scripts/check_evidence.py:311–315`
receives function names and procedure `out` names, not the complete formal/mode
inventory available to the native auditor. Its optional `application_formals`
argument now supplies that trusted source inventory independently of report
bytes. Omitting it preserves the old policy. The test helper passes source-side
metadata for the new full-route cases. The embedded function/procedure binding
packages are unchanged.

[The fixture inventory](full-route/README.md) retains all 288 original
source/verdict pairs and covers every one of the 88 positive admission-only
subprogram fixtures: 24 function and 64 procedure cases. The twins compile,
audit, build and run the unchanged source with 196 independently derived
output/status expectations, including all 18 fixtures reported to fail. The
expected-output derivations and mapping are retained separately from real
toolchain validation.

[Five finite Lean lemmas](lean/README.md) check all 53 token-table name/shell
pairs, with two docstring corrections and no changed existing theorem statement.
The Boolean theorem lives in the existing domain module, which already imports
both tables. An initial new import caused a downstream ambiguity and was removed;
the failed attempts and focused relocation success are retained. No existing
theorem, source pin or certificate definition changes are introduced.

The diagnostics are synchronized across the language, assurance, trusted
boundary, development policy, auditor spec comment, capability records and
capacity records. The mixed declaration trace and both `kernel_exact` and
`kernel_join` witness paths are described accurately. The Python policy claim is
limited to genuine reports of the pinned producer. JSON handling, AoRTE-claim
requirements, procedure termination, deep-safety packaging, driver summaries,
the Oracle and CI remain outside this change. No merge is authorized.

## Capacity derivation

The [producer account](../../scalar-procedures-report-capacity.md#formal-dependence-advisories--repair-391)
derives at most one new advisory per scalar formal: an unwritten `in out`
formal's initial value reaches its final export, so it cannot also have an
unused initial value. The inherited `UNUSED_VARIABLE` allowance remains
separate, including its co-occurrence with `INOUT_ONLY_READ` on an unmentioned
formal. At least seven disjoint bytes per explicit-mode formal gives 585 new
records at 1024 schema bytes, plus at most 4096 bytes of disjoint formal-name
payloads: **603,136 additional bytes**.

The combined envelope is **49,279,744 bytes**, leaving **17,829,120 bytes** in
the unchanged 64 MiB allocation. Both maximized new schemas serialize to
524 bytes before separately charged names. The two direct schema/envelope
unit tests passed on Linux ARM64; the complete capacity module and boundary
tests remain part of final suite validation. The historical function-only
32 MiB allocation is not claimed sufficient for the new allowance; today's
combined allocation covers function and procedure programs.

## Validation state and work rounds

All work runs locally on Linux ARM64, host `silver-m4pro`, 12 available CPUs,
approximately 15.8 GiB RAM and no swap. Native compiler/test checks use the
documented 16 MiB process stack. Original terminals and managed reservations
remain owned through completion; dense native and Lean jobs are serialized.
Retained caches are preserved. A complete audit may reuse native solver or
Lean objects; no cold build or independent kernel replay is selected.

| Work | Settings evidence | Current result |
| --- | --- | --- |
| Lead integration, documents and capacity | Live lead model/effort not independently exposed | Authorization recorded; documents and capacity derivation prepared; two direct capacity schema tests pass. |
| Auditor implementation and mutations | Inherited subthread settings not exposed in recovered context; project policy applies | Complete helper/caller gates pass; all 19,515 native checks and the complete report/source/provenance audit pass on final implementation `d60bd8a89`. Native auditor tests: 42 methods; Python auditor tests: 79 methods. |
| Full-route twins | Inherited subthread settings not exposed in recovered context | Complete static capture and source-preservation checks pass; actual toolchain run awaits integration. |
| Token lemmas and docstrings | Recovered selection/runtime unavailable; project requires Astra Max for this proof work | Initial focused batch and final Boolean relocation gate pass. Complete refresh is running with one worker after measured dense overlap exceeded the aggregate RSS guard at two workers; default 12 threads/process retained. |
| Independent critical review | Explicitly selected GPT-6 Astra / Max; runtime confirmation unavailable | Acceptance predicates, mixed/raw proof, capacity and finite token proofs reviewed; closing integrated target pending. |

The [native packet](auditors/README.md) retains complete run
`20261116T232749-c8fb976a6d5c`: 1,724 flow and 17,791 proof checks, zero unproved,
with 2,606 captured inputs, 12 tool identities and 80 report hashes independently
verified. It reused retained sessions/cache (19.090 seconds); the following
incremental build passed in 1.699 seconds. Both original terminal exits were
collected. All 30 unchanged genuine reports from six previously successful
programs retain their old native and Python verdicts; Python statistics also
match. These reports were re-audited, not claimed as fresh program runs.

The [Lean packet](lean/README.md) retains exact phase/terminal timing, memory,
input/tool/object hashes and failed attempts. Whole-team token and monetary
cost totals are unavailable. Outstanding checks are the complete Lean refresh
and the owner-required complete suite in one invocation on frozen implementation
`d60bd8a899fcc66e5ef40112423b7f94b2e4becc`, followed by closing evidence review.
Later evidence-only commits preserve those governed inputs. The published
repaired head then returns for the required external check.
