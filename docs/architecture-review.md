# Architecture review, 2026-10-10

## Decision and scope

Retain Silver's main architecture. The division between a SPARK implementation,
Python development tooling and Lean assurance serves the
[Oracle](../oracle.md) and the [pre-1.0 policy](../development.md). No broad
parser, compiler, proof or build-system rewrite is justified for the current
seven fixed productions. Some focused refactoring is advisable; the strongest
candidates are eliminating executed proof-only I/O bookkeeping and tightening
the Lean runner's final input inventory.

The owner requested this review while final validation of
[fixed-length string assignment](string-assignment.md) was running. It assesses
the working tree based on `6403b5c`; the implementation commit is identifiable
by the addition of `samples/string_assignment.adb`. This document recommends
work, rather than authorizing or implementing it. It does not change the
language, Oracle, proof claims or application report policies. Completion of
the current capability remains separate from this architectural assessment.

The owner subsequently selected the input-inventory and phase-logging repairs
for the [review follow-up](string-assignment.md#external-review-disposition).
The other recommendations below remain proposals. The original review did not
run additional validation; subsequent runner validation is recorded separately
in the [concurrency record](lean-concurrency.md#runner-follow-up).

Three focused reviews covered all 24 native source files, all 75 Lean modules
and their import graph, all eight Python scripts, the organization of the Python
test modules and Ada probe, sample/catalogue consistency, build configuration, host
isolation and evidence handling. The root reviewed the goals, trust boundaries
and principal findings. Some reviewers authored parts of the active feature;
this is a combined author and independent review, not wholly independent
certification. Read-only object inspection corroborated executed ghost work.
No additional build, proof replay, runtime benchmark or refactoring experiment
was run for this review.

Detailed reports and the source/import inventory are retained locally under
`.silver/linux-x86_64/assignment-validation/architecture-*.md` and
`architecture-lean-inventory.json`. They include source locations, inspection
commands and artifact identities. This checked-in record is self-contained;
the ignored evidence directories are not part of a clone.

## Architecture against the goals

| Goal or responsibility | Present implementation | Assessment |
| --- | --- | --- |
| Actual Ada/SPARK author source; decidable membership independent of proof success | Bounded source recognizers, explicit side conditions and seven grammar productions | Appropriate for the current language. Keep author source unchanged through proof and compilation. |
| All compiler and owned runtime/library implementation verified in SPARK | Driver, recognizers, report checkers, platform/snapshot helpers and two small runtime bodies | Correct allocation of responsibility. Python remains setup and evidence orchestration. |
| Universal safety and permitted composition | Independent grammars, binding/event relations, typed semantic interpretations and `Current` assurance theorems | Distinct proof layers establish different claims. Do not merge specification and implementation merely to reduce duplication. |
| Actual-source correspondence | Embedded authoritative bytes, checked lexing/reconstruction, complete source-shape pins, expression renderings, GNATprove refinement and runtime source checks | Essential foundations. A matching digest or sample success cannot replace these arguments. |
| Complete automatic obligation handling | Exact application/library report policies and native coverage audit; Lean schemas and explicit tool premises | Retain precise policies. Faithful complete generation and physical solver completion remain external assumptions. |
| Specified effects and failures | Guarded I/O and argument wrappers, observed external results and modeled failure outcomes | Small interfaces fit current terminal-output compositions. Further sequencing or recovery would need new composition work. |
| One evolving language before 1.0 | Seven forms sharing lexical, name, output and semantic foundations | Keep intentional changes simple; no editions, compatibility adapters or historical profile maintenance. |
| Development speed and local work | Native proof caches, Lake reuse, all-core defaults, targeted iteration and one full capability checkpoint | Retain. Expensive source-certificate reductions and fresh kernel replay remain substantial serial costs. |
| Specification, catalogue and samples agree | Shared token arrays plus explicit metadata, JSON equality tests and complete sample manifest checks | Sufficient at present. No master schema or catalogue DSL is needed. |
| Honest native evidence and handoff | Host-specific tools/artifacts, input/tool/report fingerprints, current success markers and preserved historical records | Good basic design; address the narrow inventory issue below. Keep historical evidence distinct from current success. |

`Current` normalizes seven source forms into four semantic program classes only
after each form establishes its meaning. This avoids duplicating output effects
without erasing the initialization and assignment argument. Its semantic layer
does not import heavyweight source bridges. Those are useful boundaries to keep.

The [assurance record](assurance.md) and [trusted boundary](trusted-boundary.md)
remain the precise claims. No theorem here verifies GNAT, the OS, libc or every
Ada construct. Lean proves the modeled arithmetic schemas and a finite decision
procedure; it does not prove CVC5/Z3/Alt-Ergo finish within 10,000 steps.
Report completeness controls do not themselves prove faithful external VC
generation. These existing premises remain material and explicit. Refactoring
does not discharge them.

## Recommended bounded changes

### 1. Make the Lean input inventory complete at both ends of a run

**For:** `scripts/check_lean.py` captures selected source/script paths at startup
and rehashes those same paths at completion. Existing-file changes and deletions
are detected, but newly added files can escape that final comparison. The final
module-closure check likewise uses the original workspace inventory. This is
a concrete evidence-control gap, independently corroborated by two reviewers.

**Smallest change:** use the same enumeration helper at capture and completion,
compare path sets as well as bytes, and re-enumerate both shared and workspace
Lean modules. Preserve the distinction between handwritten inputs, regenerated
candidate modules and cache artifacts. Focused mocked-run addition/deletion
tests can exercise this without an expensive proof replay for each fixture.

**Against expanding it:** no such addition was established during the current
stable-input validation, so this finding alone does not invalidate its evidence.
It does not call for adversarial manifests, authenticated artifacts or narrowed
provenance. Finish the active run before changing its fingerprinted scripts.

**Recommendation:** a small correctness repair after the current handoff.

### 2. Erase proof-only platform observations from executable code

**For:** `silver_platform.ads` labels its observation buffers "used only in
verification", but declares ordinary `Ghost`, and `silver.gpr` enables `-gnata`.
The current executable copies 262,145 bytes for `Read_Bytes'Old` on each call to
`Observed_Get`; disassembly also shows a 262,144-byte write-observation copy.
Growing-prefix postconditions and loop invariants add repeated comparisons.
This is actual emitted work, not an inference from source size. No elapsed-time
speedup has yet been measured.

**Smallest change:** consistently migrate proof-only observations and their
dependent contracts/invariants to the existing `Ghost => Static` convention.
`Observed_Get` and `Observed_Put` remain ordinary executable procedures.
The driver's historical proof flags may need the same treatment where Runtime
contracts refer to them. Retain the actual libc calls, result/error checks,
length bounds, source and selected-library rereads/equality checks, admission,
report enforcement and all proof obligations. Do not disable assertions globally.

**Against careless conversion:** moving a ghost variable alone is insufficient;
its consumers must remain legal and all contracts must still prove. Some
assertions concern real executable values and deserve to remain executable.
The change needs the affected SPARK audit and I/O/source-identity regressions,
plus a small before/after measurement. Platform and driver sources are not among
the ten embedded Lean certificate inputs, so this need not cause an embedded
source-certificate rebuild; final evidence still needs to reflect changed inputs.

**Recommendation:** the best focused native refactor. Keep its scope limited to
proof bookkeeping and preserve the complete observable pipeline.

### 3. Stream Lean phase logs

**For:** the runner currently buffers subprocess output until each phase exits.
A long build or interrupted kernel check can leave no partial output in the
canonical log. The current run required a separate continuation observer.

**Smallest change:** tee merged output to the existing log and console, retain
the audit text, and record phase start/end, duration and exit status. Preserve
commands, success conditions and failure propagation.

**Against overstating the benefit:** this improves diagnosis and evidence
retention, not computation speed. It cannot report progress inside a Lean
reduction that emits none. No dashboard, scheduler or telemetry service is
needed. Avoid modifying the runner during the active checkpoint.

**Recommendation:** worthwhile small tooling follow-up, readily paired with
the inventory repair.

### 4. Extract the repeated catalogue token renderer when convenient

**For:** six output-token loops in `silver_catalogue.adb` use the same
`Token_Sequence` type and differ mainly in sequence, field name and final comma.
A local SPARK rendering helper would reduce ordinary implementation duplication.
The separate null token type can remain separate.

**Against prioritizing it:** no metadata mismatch was found and there is no
material runtime benefit. Keep the grammar arrays and independent catalogue
checks; do not turn the extraction into a schema framework. Native catalogue
tests and the affected audit suffice; this file is not embedded in Lean.

**Recommendation:** optional, preferably alongside the next relevant edit.

## Proof structure and the expensive rebuild

The current output recognizer body is 63,856 bytes; its generated certificate
is 4,990,478 bytes with 4,312 definitions. During this review its changed body
certificate had been computing for more than 100 minutes. This is a live,
incomplete observation, not a benchmark or successful full-replay duration.
The [capability record](string-assignment.md) owns final timings and outcomes.

The [concurrency measurements](lean-concurrency.md) established useful speedup
for handwritten modules, about 21% for the measured cached-certificate aggregate.
They did not establish a certificate speedup or eliminate sequential fresh
kernel replay. Increasing the per-process memory threshold supplies headroom;
it is not established as a throughput improvement.

There are two coupled sources of rebuild cost:

- Every new output production currently changes the same large authoritative
  recognizer body and therefore its certificate.
- All ten certificates import the common `AuthoritativeSource` module, and
  Lake also declares all embedded sources as dependencies of the whole library.
  Unchanged certificates can consequently be invalidated too.

Splitting stable lexical/name/literal helpers from production-specific SPARK
recognizers is a credible future design direction. Unlike merely moving Lean
bindings, it could reduce the amount of *changed* source requiring expensive
certification. It must be coordinated with per-file authoritative bindings and
correct dependency tracking. An Ada-only split or a narrower Lake `needs` list
alone does not establish useful or safe cache reuse.

**For:** smaller changing proof units and preserved certificates for stable
helpers could improve the development loop as the language grows. The existing
delay establishes a real cost worth investigating.

**Against doing it immediately:** this is medium-to-large assurance work across
SPARK package contracts, qualified calls, complete source pins, expression
renderings and source-equivalence theorems. It may add interface proof cost;
fresh whole-project kernel replay remains. Neither benefit nor acceptable cost
has been measured. The two earlier
[certificate-representation trials](certificate-performance.md) failed to
establish an improvement and remain closed; smaller generated text is not
evidence of faster checking.

**Recommendation:** consider a separately bounded design/measurement task only
after this capability is complete. A useful first experiment would isolate one
stable helper boundary in a separate workspace, retain the certificate
representation, and compare no-op, production-local edit, shared-helper/spec edit
and full-replay costs with source-change invalidation tests. Do not undertake a whole-parser rewrite,
adopt a candidate before complete checking, or discard normal caches.

## Maintainability changes to defer

| Opportunity | Reason for it | Reason to defer / smallest useful trigger |
| --- | --- | --- |
| Common literal-length proof module | Assignment imports guarded/argument machinery for generally useful decoded-literal facts. | Small-to-medium proof maintenance; no demonstrated whole-build gain. Extract when next modifying that shared theory. |
| Neutral current-language source facade | `GuardedExpressions` and `GuardedSourceBridge` now own union/selector/pipeline facts; `OutputSourceBridge` carries all-form catalogue translation and 62 transitive imports. Ownership follows extension history. | Correct today. A real extraction touches proof interfaces; a rename alone changes little. Consider when another authorized form makes these interfaces costly to extend, while keeping `Current` source-independent. |
| Shared helper interpretation interface | Named, argument and concatenation expression modules repeat related fields/adapters. | Independent grammar and implementation equations must remain distinct; dependent-record factoring can increase elaboration cost. Wait for a concrete repeated helper change. |
| Static null-grammar proof functions | Ordinary Ghost functions and recursive suffix invariants execute under assertions; existing objects contain their symbols. | Sources are bounded at 4096 bytes, no runtime measurement exists, and changing this embedded recognizer incurs substantial correspondence work. Measure after the platform change. |
| Closed compilation/report-mode type | Library selection, warning treatment and three report-policy routes are coordinated in the driver. | All seven routes are correct and traceable now. Add a small total mapping if another policy makes this coordination difficult; no general AST is needed for it. |
| Separate JSON scanning from report policy | The large library report checker already has logical scanning, interpretation and policy layers. | Package extraction causes substantial contract churn without a new consumer. Consider for a real producer-format change; preserve exact entities, coverage and diagnostics. |
| Shared selected-library registry | Six filenames recur in snapshots, generated projects, metadata and report expectations. | Independent identity/policy cross-checks are useful. Current set is small; do not generate every checker from one unchecked master definition. |
| Reuse fixed-runtime proof evidence per application | Re-proving unchanged runtime units may cost time. | Needs correct source/tool/configuration binding and complete report policy. Measure first; never skip obligations or transplant successful reports without that argument. |
| Automatic small evidence archives | Canonical logs/manifests are replaced; preservation currently needs explicit copies. | Manual preservation has worked. If it becomes burdensome, retain small per-run records while keeping live caches; no multi-gigabyte Git archives or evidence platform. |

The current same-host workspaces have one writer each. Preserve that practice:
parallelize reads, independent tool workspaces and explicitly isolated trials;
do not overlap two Lean runners or replace tools beneath an active run. Native
and Lean checks may overlap when outputs are separate, captured inputs are
stable and memory permits. A lock is only warranted if overlapping writers
become a real requirement. No link between concurrency and the historical
`DOC_END` failure was established.

## Changes not justified now

Do not introduce a general Ada parser/IR, arbitrary mutable-store semantics,
grammar engine, universal catalogue generator, plugin system, build service,
resource broker, automatic proof retries, additional solver/kernel, binary
attestation or deployment-provenance platform. Each would need a concrete
authorized use case or assurance gap. The current seven forms do not supply one.

Do not remove independent proof witnesses, duplicate-looking source/library
rereads at different pipeline stages, runtime failure checks, complete report
audits or source certificates as cleanup. Each carries an observable or logical
obligation. The earlier cleanup review's proposed removal of `bootstrap.ROOT`
was corrected: a platform test dynamically patches that binding.

Keep local validation and the lighter iteration cadence. GitHub Actions stays
disabled by owner instruction; macOS evidence remains optional. The historical
warm-state `DOC_END` failure and documented external-tool assumptions remain
unresolved by architectural review. No newly established logical soundness gap
or blocking architectural defect was found. This is comprehensive coverage of
the owned layers, not an exhaustive correctness proof of every execution path.

The advisable order is to finish and publish the current capability, then take
one bounded follow-up: the inventory/logging repair or the proof-only platform
bookkeeping refactor. Reassess their measured benefit before deciding whether
source/dependency partitioning warrants a larger task. No further language
expansion is proposed here.
