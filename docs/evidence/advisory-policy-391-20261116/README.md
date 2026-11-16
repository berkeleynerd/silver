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
One explicit Boolean-module import was needed; the first failed focused attempt
is retained. No source pin or certificate changes are introduced.

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
| Auditor implementation and mutations | Inherited subthread settings not exposed in recovered context; project policy applies | Exact predicates and source inventory implemented; focused native helper/caller verification in progress. |
| Full-route twins | Inherited subthread settings not exposed in recovered context | Complete static capture and source-preservation checks pass; actual toolchain run awaits integration. |
| Token lemmas and docstrings | Recovered selection/runtime unavailable; project requires Astra Max for this proof work | Focused seven-target cached build and fresh 162-module / 22,708-declaration axiom audit pass; first missing-import attempt retained. |
| Independent critical review | Explicitly selected GPT-6 Astra / Max; runtime confirmation unavailable | Acceptance predicates, mixed/raw proof, capacity and finite token proofs reviewed; closing integrated target pending. |

The [Lean packet](lean/README.md) retains exact phase/terminal timing, memory,
input/tool/object hashes and the failed attempt. Whole-team token and monetary
cost totals are unavailable. Focused results do not establish final assurance.
Outstanding checks are the complete auditor unit, genuine accepted-report
additivity controls, refreshed complete native and Lean checkpoints, and the
owner-required complete suite in one invocation on the stable repaired inputs.
The published repaired head then returns for the required external check.
