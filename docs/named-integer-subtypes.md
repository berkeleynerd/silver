# Named Integer subtypes and bounded array components

Status: implemented and validated on Linux, 2026-10-30, in
[PR #289](https://github.com/berkeleynerd/silver/pull/289).
[Milestone 13](https://github.com/berkeleynerd/silver/milestone/13)
contains one coherent work package, [#286](https://github.com/berkeleynerd/silver/issues/286).
The [2026-10-29 authorization](session-memory.md#2026-10-29--named-integer-subtypes-and-bounded-array-components-authorized)
covers implementation through complete assurance, validation, independent review
and feature PR publication. The owner
[authorized the ordered subtype and Boolean merge on 2026-10-31](session-memory.md#2026-10-31--named-subtype-and-boolean-validation-and-merge-authorized).

## Selected scope

The driver is Rosetta [Sum of squares](../rosetta/s/sum-of-squares/task.wiki).
The admitted declaration is `subtype S is Integer range staticLo .. staticHi;`.
Require nonempty static bounds contained in Integer, and permit earlier named
subtypes in initialized scalar objects and the component indication of existing
anonymous fixed arrays. Subtype declarations name Integer directly; subtype alias
chains remain excluded. An optional scalar object-local range may further narrow
the named subtype to a nonempty subset. Preserve the inherited Ada/SPARK meaning: a subtype
constrains Integer values; it does not create a distinct Integer type.

Every initialized or subsequently stored value must respect its declared subtype.
The declared component bounds inform array reads and constant-array foreach
body reasoning, so arithmetic such as a bounded component square can be admitted
without silently widening the component to the full Integer interval. Establish
these invariants for every permitted composition, including existing guards,
scalar and indexed assignment, loops and name hiding. Preserve the author's
actual source bytes through proof and build.

Retain the current 4,096-byte source, 63-operator and 64-leaf budgets, existing
array index rules and constant-iterable restriction. Conversions, derived types,
functions/procedures, dynamic bounds and general arrays are outside this package.
The exact admitted rules are defined by [language.md](../language.md).

## Original design and completion obligations

The following checklist guided implementation; the completed results are in the
[delivery section](#delivery-assurance-and-validation).

Settle the exact static-bound grammar, declaration identity/order and visibility,
scalar initializer/assignment rules, component interval propagation and permitted
compositions before declaring support. Inspect actual native producer obligations
and any new report routes, advisories or feature-local report-capacity effects.
An accepted obligation class needs its semantic and automatic-discharge argument;
report acceptance and passing examples alone do not establish that guarantee.

Extend native Bronze/Silver verification and Lean decidable membership,
composition, semantic preservation, termination, automatic-discharge and
actual-source correspondence across the resulting admitted language. Reuse
applicable existing proofs and evidence while discharging every newly affected
obligation. Keep the Oracle and trusted-boundary claims accurate; do not suppress
checks or narrow domains to make proof succeed.

Add boundary, rejection and interaction regressions and a faithful Sum of squares
sample. Update language, catalogue, sample manifest, capability and roadmap
records together. Reconcile the exact fragment with broad stages #11/#12 in the
Rosetta assessment, supported identifiers, current-language description and
rendered progression. Their broad remaining scope stays Open/Backlog.

Complete the required native proof/coverage/provenance, build, Lean/source/module/
axiom and full regression validation on identified final inputs, followed by
independent review and feature PR publication. This checklist was recorded before
implementation and made no validation claim at that time.

## Planning round

Authorization recording used selected GPT-6.1 Sol / High for this bounded planning
subthread. Runtime model confirmation and token/cost measurements are unavailable.
The deliverable is the authorization-only planning PR and one milestone/package;
feature design, implementation, proofs and validation belong to #286.

## Implementation decisions and validation history

The checks below record each development round and its state at that time.
The [delivery section](#delivery-assurance-and-validation) gives the current
validation status.

Subtype declarations use a separate compact metadata table, preserving existing
scalar cell identities and static-value invariants. Five operation-hiding flags
enter recursive body contexts; the whole subtype table stays in declaration
state. The source-derived subtype capacity is `4096 / 32`, from the shortest
accepted declaration. Scalar capacity becomes `4096 / 7` because `A:S:=0;` is
seven bytes; String capacity stays `4096 / 12`, and array capacity stays
`4096 / 24` (the shortest complete new array declaration is 25 bytes).

Array descriptors carry declared component intervals. Initialization and writes
must establish interval containment; reads and constant-array iteration use that
interval. Ordered, disjoint array allocation and initialized-value containment
are explicit proof obligations. They cannot be assumed for arbitrary native
metadata merely because actual source allocation is ordered.

The native draft builds. Managed build `20261029T144300-6c3cefd20c62` rebuilt the
compiler in the reused regression workspace `tmp/constant-array-iteration` on
branch `validation/named-integer-subtypes`, preserving the preceding delivery's
branch and retained records. Run `20261029T144520-fb1a3732d7f3` passed all ten new
subtype tests in 61.773 s, including native proof/build/execution for snapshots,
narrow stores, nested loops, argument composition and contradictory guards.
The separate Sum of squares driver has independently derived expected lines
`0` and `133`; Sum and product expects `55` and `3628800`.

Focused Lean checks have proved the component semantics, ordered metadata/read
model, complete predicate grammar, and lower native helper/adapter chain with
fresh axiom audits. These are partial checks, not a delivery claim. The new typed
source trees have passed mechanical render comparisons; the interpreted helper
proofs and complete authoritative-source checkpoint remain in progress.

The first deepest foreach probe under 8 MiB exposed a larger native stack frame.
The native repair removed a redundant binding-array copy. The retained
[stack observations](evidence/named-integer-subtypes-20261029/stack/README.md)
now pass admission, compilation and execution for 4,096-byte programs with
158 singleton foreach levels, 141 counted-loop levels and 208 conditional levels
under an actual 8 MiB process stack. An earlier two-element foreach probe passed
admission and compilation but its exponential execution was terminated; its
interrupted outcome remains separate. No source limit or environmental stack
assumption has been changed.

| Round | Selected settings | Result and remaining work |
| --- | --- | --- |
| Native implementation, producer and resource checks | GPT-6 Astra / Extra High | Draft build, producer-route review and three bounded 8 MiB execution observations passed; compiler proof and complete audit remain pending. |
| Array semantic proofs | GPT-6 Astra / Extra High | Core component and ordered-metadata checkpoints and the complete predicate grammar passed focused audits; actual-source checkpoint remains. |
| Tests, specification, catalogue and driver | GPT-6.1 Sol / Extra High | Eight admission methods passed in 2.836 s; native integration and delivery rendering remain. |
| Declaration and source correspondence | GPT-6 Astra / Extra High | Subtype declarations, lexical domains and concrete changed model equations passed focused audits. Interpreted helper integration remains; no complete-source result claimed. |
| Integration and focused regression round | Lead settings unavailable in resumed context | Ten subtype tests passed; Rosetta metadata prepared for two drivers; typed helper proof repair continues. Shared successful ScalarDenotations artifacts are reused after source/tool/dependency comparison, with ordinary Lake rehash and fresh audits. |

Runtime settings and token/cost measurements are not independently available.
The integration proof workspace reuses a copied complete Lake artifact family
from `tmp/constant-array-source`, whose final successful baseline is run
`20261029T084327-720db926b71b` in the preceding delivery packet. The managed runner
synchronizes source inputs and freshly audits each selected import closure;
this is ordinary incremental reuse, not a clean build or kernel replay.

The [bounded tests and driver review](reviews/review-named-integer-subtypes-tests-1b3596b521.md)
found one minor record correction: the String-initializer paragraph had described
the enlarged scalar capacity as generic binding storage. The specification now
distinguishes the unchanged 341 String slots from 585 scalar slots. No test or
driver defect was found in that slice. Managed driver run
`20261029T145959-ad36e50b8dc3` separately admitted, proved, compiled and executed
both new samples with byte-identical source and the exact manifest outputs.
The run and its retained workspaces remain local pending the final packet.

The [critical correspondence review](reviews/review-named-integer-subtypes-critical-4224e6caf2.md)
found no actionable mismatch in the changed expression trees, precedence guards
or native domains at `4224e6caf2`. Its capacity/annotation follow-up confirmed
the 31,822,336-byte Main envelope and the ghost-only visibility equality repair.
It found a stale capacity regression using the predecessor's `/13` declaration
allowance; [#288](https://github.com/berkeleynerd/silver/issues/288) records the
`/7` correction in `ad2bb41d47`. Managed run
`20261029T153154-c4df9862d2d0` passed all three capacity tests. The same review
corrected an evidence-summary error: the focused native report contains 50
warning entries, not zero; its original report is preserved and the categories
are disclosed in the [annotation record](evidence/named-integer-subtypes-20261029/native-logical-equality/README.md).

That annotation repair passed focused native run `20261029T151702-6fc5f2e5c88c`:
both targeted logical-equality obligations and 287 unit flow checks passed.
This restricted check is not a complete native audit. Build
`20261029T153109-c0a06d180fd0` rebuilt the compiler after the repair. The five
changed generated certificates and the reviewed output pin were refreshed with
the actual source change; run `20261029T153446-d943972d9cb8` confirms byte parity
for all 28 certificates. Kernel checking of the final authoritative-source
closure remains outstanding.

Helper interpretation run `20261029T152349-f75d7ed9d693` passed the focused
`Silver.ComposeHelperEquations` build and a fresh 10,591-declaration axiom audit.
The repair normalizes Boolean conditions and local aliases without changing
the theorem statements or endpoint premises. Its retained preceding attempts
remain failed. Array/composition callers and the shared Sequence model are the
next focused checks, before complete assurance and the full regression suite.

| Round | Selected settings | Result and remaining work |
| --- | --- | --- |
| Helper normalization, native annotation and capacity follow-up | Lead runtime settings unavailable; native worker and independent reviewer selected GPT-6 Astra / Extra High | Helper build 365.821 s plus fresh audit 43.968 s passed; native restricted check 507.443 s passed its two proof and 287 flow checks. Capacity regression 3/3 and certificate parity passed. Complete checkpoints remain pending; token/cost measurements unavailable. |

The shared composition checkpoint `20261029T153928-8c628fb8b8bb` subsequently
passed a fresh 10,653-declaration audit. Its termination proof now counts all
four declaration kinds and their respective capacities. Source-model run
`20261029T154650-8200a2184daf` then passed `ComposeModelEquations`,
`ComposeRecognitionEquations` and `SequenceModel`, with 128 build jobs and a
fresh 20,836-declaration audit (665.771 s build, 20.681 s audit). The two
initial-state proof repairs explicitly establish the empty subtype environment.
The [model-cache transfer](evidence/named-integer-subtypes-20261029/model-cache-transfer.json)
records reuse of that checked closure in the integration workspace; complete
source checking is still outstanding.

Complete native run `20261029T154107-1e953acac4e4` and regression run
`20261029T153819-5626949ad567` started on stable compiler inputs. The native run
was subsequently interrupted in favor of the retained-workspace run identified
below; the regression run passed. At this round, the remaining scalar-native
correspondence repairs used the existing valid-metadata and component-bound
facts without changing endpoint domains.
Focused run `20261029T154909-06ffd07f35c4` was interrupted when an inherited-model
target unexpectedly pulled in the expensive source chain; completed lower
objects are retained, but no successful focused audit is claimed for that run.
The replacement target set excludes that source dependency.

That replacement check, `20261029T161019-1954ab856759`, passed the scalar-array
recursion and native Predicate helper/library targets with a fresh audit of
35,005 declarations (77.000 s build, 12.643 s audit). The two repaired internal
array helpers receive the metadata already established by their caller; public
array/scalar correspondence endpoints keep their statements and domains.
The [focused record](evidence/named-integer-subtypes-20261029/native-predicate-closure/README.md)
retains preceding failed and interrupted checks. The
[cache transfer](evidence/named-integer-subtypes-20261029/native-predicate-cache-transfer.json)
records the matching 206-module closure reused by integration. These results
close the known focused proof repairs and permit the complete checkpoint;
they do not themselves establish final authoritative-source assurance.

## Delivery assurance and validation

**Complete on Linux, 2026-10-30; merge authorized on 2026-10-31.**
The final implementation and code-review target is
`d4e2be67b5de7fcc2919cf9eac6efb217e5ca672`. Subsequent changes retain evidence
and synchronize delivery records and Rosetta metadata. Ada sources remain
identical to `6020416906`; the five later proof-literal corrections are reviewed
against the existing authoritative source and semantic models.

The [final packet](evidence/named-integer-subtypes-20261029/README.md) records:

- Complete native run `20261029T211041-a76eb6753f23`: **16,825 checks**
  (1,432 flow + 15,393 proof), 76 units / 1,075 entities, followed by complete
  coverage/provenance auditing. All 143 tracked native inputs match. Forced full
  analysis used four workers and existing sessions/cache; it was not cold.
- Native build `20261029T210150-1086727daf3c`: passed in 13.114 s on unchanged
  final compiler inputs.
- Complete Lean run `20261030T020720-944618f28c05`: **538 modules / 115,128
  declarations**, all 653 captured inputs matching, with foundations exactly
  `propext`, `Classical.choice` and `Quot.sound`. Build 3,584.991 s, fresh audit
  10.826 s, managed duration 3,608.781 s. The module inventory includes the root
  `Silver` module and all 537 modules beneath it. This was an incremental build
  with applicable successful objects retained from prior runs, not a clean build
  or independent kernel replay. All 28 regenerated certificates have separate
  parity coverage in run `20261030T013443-d9556926db16`.

Final [regression reconciliation](evidence/named-integer-subtypes-20261029/test-reconciliation.json)
covers **555 test identities**: 506 applicable original full-suite results,
28 latest proof-tree passes, 18 applicable earlier compiler-fixture repair passes
and three final Rosetta passes. These represent 546 distinct methods; nine
shared-binding methods are still executed under two imported module names.
Final Rosetta run `20261030T031457-868467f2105b` passed all three tests on
metadata snapshot `1d6d1b4ffd`, taking 8.008 s managed / 4.499 s unittest time.
Its 792 tracked hashes match that snapshot; the eight workspace/tool hashes
match the repaired proof-tree runs. No result is missing or failing.

The full suite's 52 sample sources / 108 executions remain applicable under the reviewed Static-erasure argument; they
were not all executed again after the repair. Scoped independent reviews cover
implementation, domains, precedence, resource capacity and both assurance repairs. The [terminal evidence confirmation](reviews/review-named-integer-subtypes-terminal-evidence-20261030.md)
checks the retained outcomes, exact input binding and complete regression
partition; it is a closing confirmation, not an additional broad code review.
No native macOS, hosted CI or external approval is claimed.

Finding [#288](https://github.com/berkeleynerd/silver/issues/288) is repaired by
the source-derived `/7` capacity regression and its successful tests. Finding
[#290](https://github.com/berkeleynerd/silver/issues/290) is repaired by the
reviewed five-file literal correction and successful focused and complete source
checks. The unsuccessful earlier native/Lean runs remain recorded as failures;
no unresolved assurance finding is carried into this delivery. Issues #286,
#288 and #290 and milestone 13 remain open until the completing commit reaches
`main`. Broad stages #11/#12 remain Open/Backlog at stages 2/3.

### Historical checkpoints and repairs

The following chronology preserves each earlier outcome and the work remaining
at that time. The final packet covers repaired target `d4e2be67b5`, extending
`6020416906` with five proof-literal corrections. Its Ada sources are unchanged
from that preceding reviewed target. Complete Lean run
`20261029T161817-0a8089cd7dc3` captured 653 matching inputs but was deliberately
interrupted at 20:40 UTC after the native failure required a source repair.
Its completed artifacts and original outcome are retained; no complete Lean
success or whole-project audit is claimed for that run.
Native full run `20261029T165015-c6b111fb4f2a` uses the preceding delivery's
validated workspace after synchronizing six changed source files and comparing
all 143 tracked native inputs. The earlier full run was deliberately interrupted
to avoid re-proving unchanged units in a fresh workspace; its original outcome,
sessions and evidence remain preserved in the
[reuse record](evidence/named-integer-subtypes-20261029/native-full-reuse/README.md).
The native run finished unsuccessfully at 20:29 UTC after 13,129.891 s. Its
76 unit reports contain 15,385 proof entries, with exactly one unresolved
postcondition: `Body_Tail'Result = Body_Tail_Model (Text, Context, Scan, Stop)`
at `silver_output_profile.adb:3414:20`. All 1,432 flow entries passed, but the
complete coverage/provenance audit did not run and no success manifest exists.
The [failed native packet](evidence/named-integer-subtypes-20261029/native-full-reuse/failed-full/README.md)
and [diagnostic](evidence/named-integer-subtypes-20261029/native-full-reuse/body-tail-diagnostic/README.md)
retain that outcome and the exact failed equality. A focused ghost-equality
repair passed in an isolated workspace without changing contracts or
prover settings. The repair changes the complete output source pin, invalidating
both expensive source-candidate checks. Finishing the old-input Lean run would
not establish repaired-source correspondence, so it was stopped before
integration. Unaffected completed objects remain available for the next managed
complete checkpoint.

Source repair `5e836b27d6` adds only Static ghost equality guidance; the
authoritative output pin/certificate refresh is `6020416906`. Focused run
`20261029T203414-0517c9b1e3dd` passed all 62 proof and 287 flow checks, including
all 330 Body_Tail session goals, in 1,179.240 s. The
[repair review](reviews/review-named-integer-subtypes-body-tail-equality-20261029.md)
confirms unchanged endpoints and runtime behavior, the exact source refresh,
and the corrected retained focused reports. No new recursive scan copy enters
the runtime build under the pinned Static erasure rules.

Complete Lean run `20261029T205735-bb72d0625415` checked all 653 matching
`6020416906` inputs and subsequently finished failed as recorded below.
Native build `20261029T210150-1086727daf3c` passed on matching
governed inputs. Complete native run `20261029T211041-a76eb6753f23` passed at
2026-10-30 00:32:43 UTC after 12,119.996 s with four workers: 16,825 checks
(1,432 flow and 15,393 proof), 76 units and 1,075 entities, followed by the
complete coverage/provenance audit. All 143 tracked inputs match the repaired
target. The [native packet](evidence/named-integer-subtypes-20261029/native-full/README.md)
retains original reports, warning classifications, input identity and existing
session/cache reuse. The [46-test refresh](evidence/named-integer-subtypes-20261029/repair-regression/README.md)
passed. That Lean run finished failed at 2026-10-30 02:01:47 UTC after
18,249.514 s managed time. Seven source-shape propositions in four modules
still expected predecessor literals. Independent review confirmed completion
blocker [#290](https://github.com/berkeleynerd/silver/issues/290) and reviewed
the five-file proof-only repair `d4e2be67b5` against authoritative source and
existing typed semantics. The [repair packet](evidence/named-integer-subtypes-20261029/source-literal-repair/README.md)
retains the failed run and exact changes. The output certificate (9,606 s),
composition source candidate (5,694 s), scalar-body candidate (426 s) and
other independently completed modules remain available for normal Lake reuse.
All 28 newly affected regressions passed again; native/build and the other
18 earlier repair results remain applicable. Focused run
`20261030T020329-280326d88dbd` then passed all four formerly failing modules and
a fresh audit of 139 modules / 25,036 declarations (168.692 s managed duration).
Complete run `20261030T020720-944618f28c05` subsequently passed at 03:07:31 UTC
on all 653 matching repaired inputs, closing the complete source/module/axiom
requirement. Its `PredicateSourceCandidate` check completed in 3,529 s.

Full regression run `20261029T153819-5626949ad567` passed all 555 test identities
in 5,255.763 s, including 52 sample sources and 108 executions. The
[independent integration review](reviews/review-named-integer-subtypes-final-integration-97312a790f.md)
identified two test modules affected by the final five proof edits. Runs
`20261029T170712-d9dc75fa5629` and `20261029T170846-5ccd1f3667b8` passed their
12 and 16 tests. The pre-repair inventory was therefore covered by 527 applicable
full-suite results and 28 refreshed results. The repair review requires
46 refreshed identities and permits retaining the other 509; all 46 new reruns
passed, with no missing or failed identity. There are 546 distinct methods
after excluding nine previously disclosed duplicate executions through separate
shared-binding import names. The later literal repair refreshes those 28
proof-tree tests again and retains the 18 compiler-fixture repair passes. Final
Rosetta coverage and terminal confirmation are recorded in the delivery summary
above.

| Round | Selected settings | Result and remaining work |
| --- | --- | --- |
| Final regression reconciliation and native workspace reuse | Lead runtime settings unavailable; native worker GPT-6 Astra / Extra High; delivery documentation GPT-6.1 Sol / High | Full suite passed in 5,259.531 s managed time; both affected modules passed. Native reuse preserves prior sessions and exact input comparisons; complete native and Lean checks remain active. Token/cost measurements unavailable. |
| Complete-native failure diagnosis | Native continuation selected GPT-6 Astra / Extra High; source-impact assessment selected GPT-6.1 Sol / Extra High | The full native run ended after 13,129.891 s with one static result/model equality unresolved. Original reports and inputs are retained; focused repair and affected-source validation remain required. Earlier provisional session-progress observations were incomplete, not successful full validation. |
| Body_Tail equality repair and reviewed applicability | Native repair and independent reviewer selected GPT-6 Astra / Extra High; regression refresh selected GPT-6.1 Sol / Extra High | Focused native proof passed in 1,179.240 s; the eight-line Static-only repair and mechanical pin/certificate refresh are reviewed. Repaired complete native/Lean runs are active; native build and all 46 affected tests passed. An empty focused-report archive was corrected and independently verified without a proof rerun. |
| Repaired complete native checkpoint, 2026-10-30 | Native continuation selected GPT-6 Astra / Extra High; lead runtime settings unavailable | Full native proof/coverage/provenance passed in 12,119.996 s; retained reports recount to 16,825 checks. The native agent hit a model-capacity limit, but its OS proof and retention processes continued unchanged and the lead integrated the result. Lean's output certificate passed in 9,606 s; remaining source checks and final evidence confirmation continue. Token/cost measurements unavailable. |
| Source-literal completion repair, 2026-10-30 | Implementation/regression refresh selected GPT-6.1 Sol / Extra High; independent review selected GPT-6 Astra / Extra High | Complete Lean run failed on seven stale-source propositions after 18,249.514 s, with independent successful modules retained. #290 records the reviewed five-file literal repair; all 28 affected tests passed. Native assurance and runtime sources are unchanged. Focused source checks and complete Lean remain pending; token/cost measurements unavailable. |
| Final complete assurance and delivery, 2026-10-30 | Delivery documentation selected GPT-6.1 Sol / High; regression refresh selected GPT-6.1 Sol / Extra High; independent terminal reviewer selected GPT-6 Astra / Extra High; lead runtime settings unavailable | Complete Lean passed in 3,608.781 s managed time with 538 modules / 115,128 declarations. Three final Rosetta tests passed in 8.008 s managed time; final coverage is 506 + 28 + 18 + 3 = 555 identities. The terminal review confirms retained evidence and applicability. PR #289 is ready for owner review and remains unmerged; token/cost measurements unavailable. |
