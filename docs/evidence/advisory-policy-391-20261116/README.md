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
unit tests and the complete capacity module and boundary tests passed on Linux
ARM64 in the final suite. The historical function-only
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
| Lead integration, documents and capacity | Live lead model/effort not independently exposed | Authorization, synchronized records and capacity derivation complete; focused and complete-suite capacity tests pass. |
| Auditor implementation and mutations | Inherited subthread settings not exposed in recovered context; project policy applies | Complete helper/caller gates pass; all 19,515 native checks and the complete report/source/provenance audit pass on final implementation `d60bd8a89`. Native auditor tests: 42 methods; Python auditor tests: 79 methods. |
| Full-route twins | Inherited subthread settings not exposed in recovered context | All 88 unchanged sources compile and run successfully with all 196 output/status cases in the single complete suite. |
| Complete suite and evidence collection | Inherited coordinator settings not independently exposed | One 699-ID invocation: 697 passes and two expected skips. Original child exit 0; collector exit 1 retained and exact-ID reconciliation independently accepted. |
| Token lemmas and docstrings | Recovered selection/runtime unavailable; project requires Astra Max for this proof work | Focused gates and complete cached refresh pass: 1,009 modules, 162,274 declarations. One worker/default 12 threads after measured memory interruptions; no replay. |
| Independent critical review | Explicitly selected GPT-6 Astra / Max; runtime confirmation unavailable | Native and Lean evidence independently accepted; the [closing review](../../reviews/review-advisory-policy-391-20261117.md) records final suite reconciliation and material finding dispositions. |

The [native packet](auditors/README.md) retains complete run
`20261116T232749-c8fb976a6d5c`: 1,724 flow and 17,791 proof checks, zero unproved,
with 2,606 captured inputs, 12 tool identities and 80 report hashes independently
verified. It reused retained sessions/cache (19.090 seconds); the following
incremental build passed in 1.699 seconds. Both phase exits and the original
supervisor exit were collected. All 30 unchanged genuine reports from six
previously successful
programs retain their old native and Python verdicts; Python statistics also
match. These reports were re-audited, not claimed as fresh program runs.

The [complete Lean packet](lean/complete/attempt-3/README.md) records run
`20261116T233445-6dce1a7dbb80`: all 1,009 modules and 162,274 declarations,
including 40 candidates and 32 authoritative source bindings, with only
`propext`, `Classical.choice` and `Quot.sound`. All 1,116 repository inputs,
1,011 workspace inputs, 6,046 artifacts, both tools and the log were independently
verified. The original terminal exited 0 after 3,029.938 seconds. Peak aggregate
RSS was 8.601334 GiB, with at least 7.725693 GiB host memory available. This was a
cached build and fresh whole-project audit, not a clean build or kernel replay.

The [single complete suite](suite/README.md), run
`20261117T002818-40d684ec306c`, ran on
`e8921bd091a4b0552de45d8205277008c236ba7a` with the same frozen implementation
`d60bd8a899fcc66e5ef40112423b7f94b2e4becc`. All **699** expected test IDs completed
in 1,111.461 seconds: **697 passed and two expected Linux-x86-64-only cases
skipped**. All 88 twins / 196 execution cases and all 85 samples / 148 execution
cases passed. This is one fresh full invocation with retained build/prover
caches, not a composition of earlier results. All 1,307 frozen source/test/fixture
hashes, native inputs and both compiler binaries remained unchanged.

The managed test process exited 0. The separate evidence supervisor exited 1:
its post-run parser stripped `tests.` from nine imported IDs and confused them
with nine distinct top-level IDs. The unchanged original launcher and failure
are retained. Offline exact-ID reconciliation of the original complete log finds
all 699 unique expected IDs, with no missing, unknown or duplicate result.
No test or assertion changed, and no test was rerun to repair collection.

The failed native proof/source-policy attempts, initial corpus-reader defect,
Boolean import failure and Lean memory interruptions remain linked in their
packets and dispositioned in the closing review. Whole-team token and monetary
cost totals are unavailable. Later documentation/evidence commits preserve all
governed inputs. Local validation is complete; publication stops for the owner's
required external check of the repaired head, without merge or #373 work.
Issue #391 carries status; the project-board credential lacks `read:project`.
