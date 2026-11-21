# Silver roadmap

Silver grows through small capabilities motivated by runnable examples. The
[Oracle](oracle.md) governs the guarantees; [language.md](language.md) and the
[catalogue](catalogue/silver.json) specify what is supported today.
This roadmap records intended work and unresolved decisions. It does not admit
new syntax or authorize weakening an existing guarantee.

Before 1.0, maintain one current language. Git records revisions; separate
profile maintenance and compatibility infrastructure are unnecessary. Intentional
changes to earlier rules and examples must be explicit and consistent. The
[development policy](development.md) prioritizes foundations needed for the
next capability while retaining full assurance for the current language.

## External review response — validated and accepted, 2026-11-09

Owner-authorized [milestone 22](https://github.com/berkeleynerd/silver/milestone/22)
and [#355](https://github.com/berkeleynerd/silver/issues/355) cover the
[external review of `74ea2edeaa`](docs/reviews/review-74ea2edeaa.md).
[PR #368](https://github.com/berkeleynerd/silver/pull/368) contains the completed
repairs and reasoned dispositions. The
[response record](docs/external-review-response-74ea2edeaa.md) links complete
Linux native/Lean/regression validation and final independent acceptance.

Function-tree prefix and discriminating controls (#356, #357), regressions
(#358–#360), and assessor/evidence/catalogue corrections (#361–#363) are complete.
The inherited-interface review (#364) maps the nine named files and records its
scope limits; the additional native-domain and formal-description repairs
(#366, #367) are included. The shared final checkpoint passed on frozen inputs;
no accepted repair or validation requirement remains unresolved.

The #345 / PR #354 Rosetta delivery is complete on Linux, with its merge
[authorized on 2026-11-09](docs/session-memory.md#2026-11-09--pr-354-merge-authorized-report-the-next-unit).
The next owner-authorized work is the bounded Rosetta refresh repair and
scalar-procedure scope below.
Its [2026-11-09 integration](docs/scalar-function-rosetta-batch.md#current-main-integration--2026-11-09)
preserves this response and uses its complete validation, with only the three
affected Rosetta tests rerun after resolving the session-history conflict.

## Near-term feature queue

**Selected language capability, 2026-11-21.** The owner instructed **“Proceed”**
with named constrained fixed-size Integer-array types, read-only array `in`
parameters in existing Main-local functions **and procedures** alongside scalar
arguments, and static `'First`, `'Last`, `'Length` and `'Range` bounds queries
on named arrays and existing anonymous Integer-array objects. Anonymous arrays
remain excluded as call actuals; Boolean-array types, parameters and queries are
unselected.
[#410](https://github.com/berkeleynerd/silver/issues/410), in
[milestone 27](https://github.com/berkeleynerd/silver/milestone/27), owns the
[capability plan](docs/named-array-parameters.md). Dot product and Horner polynomial
evaluation are the drivers. This is one coherent language batch with one shared
final checkpoint; no samples-only detour or separate agent-sized delivery is
selected. Its implementation, validation, independent review and feature PR are
authorized by the [dated instruction](docs/session-memory.md#2026-11-21--named-constrained-integer-array-parameters-selected).
The capability is not yet supported. Preserve full declared-domain checking,
complete native and Lean/actual-source assurance and precise Rosetta progression.
Writable, returned and unconstrained arrays and a separate expansion of array
locals remain outside this batch. The capability plan records nominal identity,
visibility, static-query and declared-domain rules; establish metadata/capacity
and source-proof composition before admission.
[Draft PR #412](https://github.com/berkeleynerd/silver/pull/412) retains the
[bounded native review](docs/reviews/review-named-array-native-20261121.md),
[feature-local producer account](docs/named-array-parameters-report-capacity.md)
and [two-task fidelity assessment](rosetta/assessment-named-array-parameters-20261121.md).
The native review resolves the measured 16 MiB invoking-shell stack prerequisite;
27 audited focused gates and the sample/source-limit routes are scoped evidence.
The seventeen supplemental direct-caller gates also passed; their current-input
comparison is retained in the capability record. The first complete native run
proved 19,994 checks but failed its final audit on an operator-reassociation
warning. The grouped Length calculation passed its focused check and the
[corrected complete native audit](docs/evidence/named-array-parameters-410-20261121/final-native/README.md).
The [complete Lean/source audit](docs/evidence/named-array-parameters-410-20261121/final-lean/README.md)
also passed on `7f449246ce`; final regression coverage and independent delivery
reconciliation remain pending. No completed support is claimed here. The prepared precise Rosetta construct
`named-integer-array-parameters` groups both drivers while leaving broad arrays,
unconstrained arrays and writable array parameters unsupported. Its supported
promotion, final render and stage bookkeeping wait for that shared checkpoint;
no issue is closed by this preparation.
[Stage issue #415](https://github.com/berkeleynerd/silver/issues/415) tracks
this precise construct and its two drivers in generated Stage 38, while milestone 27 remains the owner-selected coherent batch. These
stage numbers are generated positions, not authorization or delivery units.
No provisional successor is selected. Deferred #381/#382 and #398 remain outside
this queue; PR #385 stays held and Worca remains stopped.

**Reduced package complete on Linux, 2026-11-21 (PR #406).** The owner instructed
**“Approved. Proceed to completion and the accompanying PR”** for
[proof iteration efficiency #373](https://github.com/berkeleynerd/silver/issues/373),
[milestone 24](https://github.com/berkeleynerd/silver/milestone/24). The
[current package](docs/proof-iteration-efficiency.md#current-selected-package--2026-11-20)
selects recovered allocation reporting with mandatory reduction reasons only for
proof commands (#377), native helper/check-kind recurrence with the selector
fallback repair (#378), canonical whole-helper focused checks at the unchanged
30-second policy (#379), and minimal final-policy readiness reporting (#380).
Guidance #383 and validation/review #384 remain in this delivery with one shared
final checkpoint. The recovered patches and focused-policy/readiness changes
are integrated in [PR #406](https://github.com/berkeleynerd/silver/pull/406).
Complete Linux native and Lean/source/module/axiom validation and reviewed
regression coverage passed on 2026-11-20. The independent closing evidence
review accepted that checkpoint. On 2026-11-21 the owner authorized repairing
Claude's three material findings and then merging; the
[response](docs/reviews/review-8dc409b303-response.md) records their disposition
and refreshed final validation. Independent repair review accepted the final
candidate; merge is authorized.
The [delivery record](docs/proof-iteration-efficiency.md#delivery-evidence-and-rounds)
distinguishes host cache restoration from the final cached audits.

Standalone strategy comparison #381 is deferred until an unresolved current proof
or demonstrated hotspot warrants it; additional scheduling #382 is deferred
until a necessary run measures useful concurrent work and memory headroom during
a material underutilized interval. Both stay open in Backlog and do not block
this reduced delivery. Already-delivered context/representation and scheduling
improvements are retained, without claiming these experiments were performed.
The [dated authorization](docs/session-memory.md#2026-11-20--reduced-proof-iteration-package-approved-for-delivery)
revises the original all-eight completion scope. Full assurance and applicable
fresh audits remain required; cache reuse remains available, with no mandatory
cold rebuild or kernel replay. Codex handles the work directly after the owner's
stop-Worca instruction. The new PR is authorized; its merge is not. PR #385 stays
held. The later 2026-11-21 instruction above selects the next language feature.

**Samples-only delivery, complete on Linux, 2026-11-20 (PR #403).** The owner requested development
of [#400](https://github.com/berkeleynerd/silver/issues/400),
[Bounded text buffer samples](docs/bounded-string-building-samples.md), including
several-character append and prepend with whole-literal refusal, complete
99-bottles lyrics and repeat-five. The implementation composes existing String,
Character, loop and output rules. The precise Rosetta identifier
`bounded-string-building` describes initialized buffers; broad `string-building`
and [#395](https://github.com/berkeleynerd/silver/issues/395) retain their remaining
scope. Complete applicable validation, independent closing review and the scoped
external review are accepted. The owner authorized merge at reviewed head
`9cf913a3a4`, merged as `66659c70aa`. Issue and Stage-field closeout follows
the merge as instructed; [#404](https://github.com/berkeleynerd/silver/issues/404)
records the precise delivered identifier.
The [focused implementation packet](docs/evidence/bounded-string-building-400-20261118/README.md)
records the four successful sample routes, boundary/control probes and render:
Stage 1 grows from 85 to 89 task mappings, while existing construct Stage values
stay unchanged. The [delivery continuation](docs/bounded-string-building-samples.md#delivery-validation--2026-11-20)
records reviewed complete native/Lean reuse. The
[final complete x86 suite](docs/bounded-string-building-samples.md#merge-and-external-review--2026-11-20)
passes all 724 tests with no skips; the external review found no blocker or medium.
Its historical record gap is deferred under [#405](https://github.com/berkeleynerd/silver/issues/405).
This work chooses no successor queue order and preserves #373 recovery and the
PR #385 hold.

**Delivered selection, 2026-11-17.** The owner selected **named scalar
arguments** for existing functions and procedures, with reordered named calls
and positional-prefix/named-suffix calls, after confirming then that Worca's #377/#378
work was unavailable pending recovery. [#392](https://github.com/berkeleynerd/silver/issues/392),
in [milestone 25](https://github.com/berkeleynerd/silver/milestone/25), owns the
bounded [capability plan](docs/named-scalar-arguments.md), with precise Rosetta
[stage #393](https://github.com/berkeleynerd/silver/issues/393). Named parameters is the
faithful task driver. Defaults, new parameter types and effects are excluded;
full-domain checking, conservative aliases, exact-source assurance and one
shared complete validation checkpoint remain required. The implementation has
passed the complete Linux native and Lean/actual-source checkpoints; the
[capability record](docs/named-scalar-arguments.md#delivery-assurance-and-validation)
records the passed complete suite and independent closing review. Named scalar
arguments are supported; the precise mapping adds one Rosetta task (84 to 85). The
[dated selection](docs/session-memory.md#2026-11-17--named-scalar-arguments-selected-while-worca-recovery-awaits)
changed the immediate order then. The reduced #373 package above is now selected;
draft PR #385 stays held.

**Current delivery, merged 2026-11-17.** The owner authorized the bounded external-review
repair [#391](https://github.com/berkeleynerd/silver/issues/391) on PR #371:
two precisely bound flow advisories, full-route subprogram fixtures, five token
lemmas and record corrections. Focused checks, complete native and Lean refreshes,
and the single complete suite passed on Linux ARM64; the
[repair packet](docs/evidence/advisory-policy-391-20261116/README.md) records actual
cached/fresh scope and independent acceptance. The owner's
[subsequent merge instruction](docs/session-memory.md#2026-11-17--scalar-procedures-merged-next-work-assessment)
superseded the merge hold. PR #371 merged as `50b6e2a542`; its tree equals
validated head `45bebb50d7`. All six milestone-23 issues and the milestone are
closed. No new external-review result is claimed.

**Retained delivery, 2026-11-15.** Small nonrecursive scalar procedures
[#370](https://github.com/berkeleynerd/silver/issues/370) and the
[#29](https://github.com/berkeleynerd/silver/issues/29) companion have complete
Linux ARM64 validation in [PR #371](https://github.com/berkeleynerd/silver/pull/371),
milestone 23. The [delivery account](docs/scalar-procedures.md#delivery-assurance-and-validation)
records accepted proof, regression and final delivery evidence.
The owner selected proof iteration efficiency as the next unit on 2026-11-10.
Its 2026-11-17 handoff then recorded unavailable local Worca branches and the
named-argument detour. Both implementations are now recovered; the current reduced
selection above supersedes that recovery wait and the original all-eight
completion requirement. [Historical handoff](docs/proof-iteration-efficiency.md#historical-plan-and-handoff--superseded-on-2026-11-20)
retains the original account. Completed predecessor issues #8, #246 and #39 stay
closed; PR #385 remains held.

**Historical selection, 2026-11-09.** The owner
[authorized](docs/session-memory.md#2026-11-09--rosetta-refresh-repair-and-next-language-increment-authorized)
repairing [#29](https://github.com/berkeleynerd/silver/issues/29) and continuing
with the proposed small nonrecursive scalar procedures under
[#11](https://github.com/berkeleynerd/silver/issues/11), combining their delivery
when readily practical. Establish the procedure grammar, full-domain body and
call contracts, initialization/alias rules, report capacity and source-proof
reuse before implementation. Return multiple values is the first task driver.
This is selected development, not admitted language. The
[bounded capability plan](docs/scalar-procedures.md) and
[#370](https://github.com/berkeleynerd/silver/issues/370), in
[milestone 23](https://github.com/berkeleynerd/silver/milestone/23), specify one
language increment with a source-written leading `out` initialization prefix.
The #29 repair accompanies its final delivery. Focused native producer/helper
checks and semantic/source integration precede one shared complete checkpoint.
No successor sample batch or deferred capacity research is selected.

**Owner-selected planning order, 2026-10-30.** Prioritize useful Rosetta
expansion and reuse of the existing language machinery. Revisit the order after
each delivery; the linked issues hold scope and completion criteria.

| Position | Feature | Motivating Rosetta candidates |
| --- | --- | --- |
| Delivered 2026-10-31 | [Boolean scalar objects and expressions #291](https://github.com/berkeleynerd/silver/issues/291), stacked on the named-subtype delivery [#286](https://github.com/berkeleynerd/silver/issues/286) | Sequence of primes by trial division; Square but not cube; Common list elements |
| Complete 2026-11-06 | [Bounded String indexing and character operations #296](https://github.com/berkeleynerd/silver/issues/296) | Reverse a string; Palindrome detection; character replacement |
| Complete 2026-11-07 | [Fixed-size Boolean arrays #297](https://github.com/berkeleynerd/silver/issues/297) | Sieve of Eratosthenes; elementary cellular automata |
| Complete on Linux and merged 2026-11-07; PR #337 | [Sample-only expansion #300](https://github.com/berkeleynerd/silver/issues/300) | Ten programs covering eleven task mappings; [bounded plan](docs/rosetta-sample-expansion.md) |
| Complete on Linux 2026-11-08; merged through PR #339 | [Small nonrecursive functions #298](https://github.com/berkeleynerd/silver/issues/298) | Boolean `Is_Prime` for Primality by trial division first; GCD and numeric search helpers remain candidate uses |
| Complete on Linux; combined merge authorized 2026-11-09, PR #354 | [Scalar-function Rosetta batch, milestone 21](https://github.com/berkeleynerd/silver/milestone/21) | Twelve validated programs merged through [PR #351](https://github.com/berkeleynerd/silver/pull/351), [PR #352](https://github.com/berkeleynerd/silver/pull/352) and [PR #353](https://github.com/berkeleynerd/silver/pull/353); combined reconciliation is validated and independently reviewed in [PR #354](https://github.com/berkeleynerd/silver/pull/354). [Batch record](docs/scalar-function-rosetta-batch.md). |

The bounded String increment has completed repaired Linux native and Lean
assurance after the [interim review repairs](docs/interim-review-response-20261105.md).
The [closing delivery review](docs/reviews/review-interim-response-closing-20261105.md)
passed. Its [delivery record](docs/bounded-string-characters.md#repaired-delivery-checkpoint--2026-11-05)
connects interval and guard reasoning to index, slice and destination-length
checks while preserving actual bounds, mutation and dead-code frontend rules.
General dynamic-length indexing, resizing, Unicode processing and general String
libraries remain outside this fragment.

Boolean arrays reuse bounded array storage and scalar Boolean semantics.
Functions start with Integer/Boolean scalar parameters/results, an acyclic call
graph and no caller-visible mutation. The [bounded plan](docs/scalar-functions.md)
records the selected scope, complete Linux native/Lean/source checkpoints and
applicable behavioral results and final independent acceptance.

#296 is [authorized for implementation on 2026-10-31](docs/session-memory.md#2026-10-31--bounded-string-indexing-and-character-operations-authorized).
#297 is [selected next on 2026-11-06](docs/session-memory.md#2026-11-06--structural-guards-merged-boolean-arrays-selected-next),
under the owner's instruction to proceed after merging the ready structural
guards. Authorization reached main through PR #333; implementation is complete
on Linux and merged through PR #335. The separate sample-only
[#300](https://github.com/berkeleynerd/silver/issues/300) has now completed and
merged through PR #337 after its tutorial checkpoint. The owner
[selects #298 next on 2026-11-07](docs/session-memory.md#2026-11-07--small-nonrecursive-functions-selected).
Candidate samples need faithful implementations before any coverage gain is
claimed. The expanded opportunity inventory remains outside this commitment.
At that historical checkpoint no language feature after #298 was selected. The sample-only successor begins
with owner-selected #342 on the accepted #298 baseline; all three sample groups
are merged after validation and review. #345 has passed the combined affected
checks and narrow Rosetta assessment/render; independent acceptance passed in PR #354.
Existing source and expression budgets, assurance requirements, broad stages
and deferred capacity work retain their scope.

## Current development sequence

### Small nonrecursive scalar procedures

The owner-selected #370 / #29 package and the November 16 external review's
#391 repair have complete local Linux ARM64 validation and merged through
PR #371 on November 17. Milestone 23 is complete. The delivery includes
#372's catalogue repair, #375's handwritten
source-token correspondence and #390's qualified-validity alias correction.
The [delivery account](docs/scalar-procedures.md#delivery-assurance-and-validation)
connects the complete native/Lean checkpoints, the failed original regression
run and independently reviewed successful repair coverage. Current source,
expression and full formal-domain rules remain unchanged by recovery.

The precise `scalar-procedures` fragment adds one faithful Rosetta mapping,
**Return multiple values**, taking supported mappings from 83 to 84. Broad
[#11](https://github.com/berkeleynerd/silver/issues/11) stays open at Stage 2
for its remaining procedure/ranged-subtype/Image forms. No successor language
feature was selected at that merge checkpoint. Named scalar arguments #392 is
delivered; the reduced milestone-24 package is complete on Linux in
[PR #406](https://github.com/berkeleynerd/silver/pull/406).

### Small nonrecursive scalar functions

**Complete on Linux, independently accepted and merged, 2026-11-08.** The owner's
**“Proceed”** selects existing [#298](https://github.com/berkeleynerd/silver/issues/298)
after the Integer/Boolean scalar recommendation.
[Milestone 20](https://github.com/berkeleynerd/silver/milestone/20), **Small
nonrecursive functions**, contains #298 as its one cohesive package. The
[dated authorization](docs/session-memory.md#2026-11-07--small-nonrecursive-functions-selected)
and [bounded capability plan](docs/scalar-functions.md) retain one cohesive work
package, exact-source/no-authored-contract guarantees, complete-call-chain
assurance, actual native/Lean source correspondence and complete validation.
The owner authorized implementation merge on 2026-11-08 with **“Let's merge it.”**
The [dated decision](docs/session-memory.md#2026-11-08--scalar-function-merge-authorized)
supersedes the earlier merge hold and authorizes ordinary issue/milestone closeout.

The [scalar-functions stage record #341](https://github.com/berkeleynerd/silver/issues/341)
tracks this precise Rosetta fragment within the same package. The
[delivery account](docs/scalar-functions.md#delivery-assurance-and-validation)
records the narrow Rosetta reconciliation. General functions, procedures and
booleans keep their separate scope.

The first driver is a Boolean `Is_Prime` function for Primality by trial division,
whose task explicitly requires that function. The chosen first fragment has
explicit-in scalar formals, closed scalar bodies with one terminal return, and
earlier-only calls as complete scalar assignment RHSs. Each body is checked over
its full formal domain; native probes selected `--no-inlining` to preserve that
coverage even for unused functions. The capability record specifies scope,
hiding, result facts and source-derived capacity accounting. Existing
4,096-byte complete-source, expression/operator and storage budgets remain.
Complete native/Lean/source checkpoints and all formerly pending regression
outcomes passed. The narrow Rosetta render and three tests also passed: only
Primality by trial division moves Stage 8 to 1, taking Stage-1 mappings from
70 to 71. Independent review accepts the complete 645-ID inventory and delivery target
`4d9ce491ee`. PR #339 merged as `05302f760f`; its six issues and
milestone 20 are closed. Planning PR #346 merged as `74ea2edeaa`; the first
milestone 21 implementation group is selected below.
Recursion, `out`/`in out`, array/String signatures, general package admission and
capacity rewrites remain outside this package. No split is selected; if needed,
record increment issues and their order together. This completes the committed
delivery batch; successor planning does not expand its scope or change its
validation inputs.

### Scalar-function Rosetta batch

**All twelve programs in #342/#343/#344 are validated, independently reviewed
and merged through PRs #351/#352/#353. The owner-selected #345 combined
checkpoint and independent acceptance passed on Linux, 2026-11-08; published in
[PR #354](https://github.com/berkeleynerd/silver/pull/354).** The owner initially
instructed **“Proceed with the planning effort we just discussed.”** The
[dated decision](docs/session-memory.md#2026-11-08--coherent-batch-planning-authorized)
authorizes the batching guidance, one successor assessment, milestone/issues
and reviewable planning publication alongside #298, now delivered.
The owner subsequently [authorized merging ready PR #346](docs/session-memory.md#2026-11-08--batch-planning-merge-authorized-report-next-unit-first),
with the next unit reported before implementation starts.
After that report and merge, the owner instructed **“OK, while that trundles
along let's tackle the next unit of work.”** The
[dated selection](docs/session-memory.md#2026-11-08--callable-integer-examples-selected-during-external-review)
authorizes #342's four callable examples through reviewed publication while
the external review proceeds. The later
[“Agreed. proceed.”](docs/session-memory.md#2026-11-08--callable-examples-merge-and-divisor-group-authorized)
authorizes merging ready PR #351 and implementing #343. The subsequent
[owner selection](docs/session-memory.md#2026-11-08--divisor-examples-merge-and-digitprime-group-authorized)
authorizes merging ready PR #352 and implementing #344. The subsequent
[“Proceed.”](docs/session-memory.md#2026-11-08--digitprime-merge-and-combined-rosetta-delivery-authorized)
authorizes merging ready PR #353 and completing #345 through reviewed publication.
The [2026-11-09 owner instruction](docs/session-memory.md#2026-11-09--pr-354-merge-authorized-report-the-next-unit)
authorizes the ready combined delivery merge and ordinary issue/milestone closeout.

[Milestone 21](https://github.com/berkeleynerd/silver/milestone/21) proposes
twelve numeric tasks using the delivered scalar-function fragment. The
[capability plan](docs/scalar-function-rosetta-batch.md) records primary task
requirements, three sample groups and the shared validation/reconciliation work.
The increment order is:

1. [#342 — Callable integer examples](https://github.com/berkeleynerd/silver/issues/342)
   establishes the common sample patterns. Its four programs have passed focused
   application proof/build/execution; the [checkpoint](docs/scalar-function-rosetta-batch.md#callable-integer-examples--2026-11-08)
   records exact inputs, domains and outputs.
2. [#343 — GCD and divisor calculations](https://github.com/berkeleynerd/silver/issues/343)
   and [#344 — Digit and prime algorithms](https://github.com/berkeleynerd/silver/issues/344)
   can then proceed independently with separate sample ownership. #343's four
   programs now have successful focused application validation and independent
   review; its [checkpoint](docs/scalar-function-rosetta-batch.md#gcd-and-divisor-examples--2026-11-08)
   records exact inputs, domains and evidence reuse. #344 now has four validated
   programs; its [checkpoint](docs/scalar-function-rosetta-batch.md#digit-and-prime-examples--2026-11-08)
   records complete task ranges, helper domains and production checks.
3. [#345 — Combined delivery](https://github.com/berkeleynerd/silver/issues/345)
   completes shared validation, review and narrow Rosetta reconciliation.

The intended saving is reuse of unchanged compiler/runtime and Lean/source
evidence, subject to applicability and required audits. Every new program still
needs its own admission, complete application proof/build/execution and task
fidelity review. No compiler change, new language form, larger resource bound or
restart of deferred #119 is proposed. All twelve programs have focused application
validation. #345 reconciles exactly their twelve task mappings: the rendered
Stage-1 total rises from 71 to 83, while broad unsupported constructs and all
tracked stage fields remain unchanged. The [combined checkpoint](docs/scalar-function-rosetta-batch.md#combined-delivery--2026-11-08)
distinguishes 84 programs and 147 executable cases. The
[current-main integration](docs/scalar-function-rosetta-batch.md#current-main-integration--2026-11-09)
uses the complete review-response assurance and accounts for 648 test executions,
including three fresh Rosetta results. PR #354 completes the combined delivery
and milestone 21 under the owner-authorized merge. The next unit is to be reported
before any successor implementation begins.

### Rosetta sample expansion

**Complete on Linux and merged, 2026-11-07, through owner-authorized PR #337.**
The owner instructed **“Let's proceed to tackle 300 after determining if our
tutorial is up-to-date. This may only live in a branch at this time.”** The
[dated authorization](docs/session-memory.md#2026-11-07--tutorial-audit-and-rosetta-sample-expansion-selected)
selects existing [#300](https://github.com/berkeleynerd/silver/issues/300) in
[milestone 15](https://github.com/berkeleynerd/silver/milestone/15), after the
completed String #296 and Boolean-array #297 deliveries. Functions #298 are now
selected above after this delivery. The
[tutorial audit](docs/rosetta-sample-expansion.md#tutorial-audit--2026-11-07)
finds the available README current after correcting its stale #314 status;
its 31 referenced samples pass admission. No separate first-party tutorial was
located in the searched history or branches. Revisit a specific tutorial if the
owner supplies its pointer; no arbitrary replacement tutorial is selected.
Guide/planning PR #336 merged as `fdbd6132ca`. The ten-program implementation
merged in [PR #337](https://github.com/berkeleynerd/silver/pull/337) as `219358339f`;
its [delivery record](docs/rosetta-sample-expansion.md#delivery-and-validation--2026-11-07)
retains the successful complete manifest, fresh native provenance refresh,
applicable complete Lean evidence, focused tests and final render. It adds nine
Stage-1 mappings (61 to 70) without a language change. The independent review
accepts final target `d4aab1db5b` with no unresolved finding. The owner authorized
its ready merge on 2026-11-07; the
[dated decision](docs/session-memory.md#2026-11-07--rosetta-sample-expansion-merge-authorized)
supersedes the earlier merge hold. Issue #300 and milestone 15 are closed.

The [bounded record](docs/rosetta-sample-expansion.md) restores the missing #300
scope link and retains ten programs with eleven mappings: FizzBuzz; Even or odd;
Empty string; Array concatenation; Bubble sort also serving Sort an integer
array; Greatest common divisor; Factors of an integer; Leap year; Multiplication
tables; and the required one-dollar Count the coins problem. The expanded
91-mapping opportunity inventory is retained by link, outside this commitment.

The implemented algorithms retain faithful task behavior and independent expected
outputs; every sample passed admission/proof/build/execution. The independent
review confirms final evidence applicability and the eleven reconciled assessments.
FizzBuzz and Even or odd already qualified for Stage 1. No language, capacity or
broad supported-identifier change is selected.
The completed batch is merged. The subsequent function selection appears above;
the expanded opportunity inventory remains unselected.

### Fixed-size Boolean arrays

**Complete on Linux, 2026-11-07, through PR #335.**
The [delivery account](docs/boolean-arrays.md#delivery-assurance-and-validation--2026-11-07)
records complete assurance, regression applicability and the accepted closing review.

After the ready structural-guard delivery, the owner's instruction to proceed
selects existing [#297](https://github.com/berkeleynerd/silver/issues/297) from
the recorded feature queue. The
[dated authorization](docs/session-memory.md#2026-11-06--structural-guards-merged-boolean-arrays-selected-next)
distinguishes that ordering inference from the owner's exact words.
[Milestone 19](https://github.com/berkeleynerd/silver/milestone/19), **Fixed-size
Boolean arrays**, contains this one cohesive work package; do not create a
duplicate stage issue. Authorization reached main as `430d206684` through
[PR #333](https://github.com/berkeleynerd/silver/pull/333). The owner later
[authorized merging PR #335](docs/session-memory.md#2026-11-07--boolean-array-merge-authorized),
which completes #297 and finding #334; milestone 19 closes with that delivery.

The [delivery record](docs/boolean-arrays.md#delivery-assurance-and-validation--2026-11-07)
tracks initialized static one-dimensional Boolean arrays and indexed reads/writes,
composed with existing Boolean/scalar/index/loop machinery. The implementation
uses explicit positional/singleton aggregates, typed Boolean storage, existing
name resolution and incoming-state snapshots. Complete Linux native Bronze/Silver
and Lean/source/module/axiom checks and the ordinary final build passed; the
delivery account separately identifies final runtime applicability and exact
closing review. Historical failures retain their outcomes.

The bounded drivers are Sieve of Eratosthenes through 100 and wrapping elementary
cellular automata for rules 90, 30 and 122. The integrated, separately tested
Rosetta metadata promotes only `fixed-boolean-arrays`: 61 Stage-1 assessments,
distinct from 61 source samples, 117 manifest execution cases and 38 Rosetta source files. All six
existing stage issue positions remain unchanged. Broad `arrays` stage #12 remains
Open/Backlog; broad `arrays`/`booleans`, Boolean element iteration and `others`
aggregates remain unsupported.

The complete-source 4,096-byte limit and existing expression/storage budgets
remain unchanged. General containers, dynamic/multidimensional arrays, functions
#298, the separate #300 sample batch, capacity rewrites and Oracle amendments
remain outside this unit. The owner-authorized merge retains the complete
validated implementation and its reviewed evidence.

### Source-tree structural guards

**Complete on Linux and merged, 2026-11-06, through
[PR #332](https://github.com/berkeleynerd/silver/pull/332).**

The [delivery record](docs/source-tree-structural-guards.md#merged-delivery--2026-11-06)
retains authorization, exact governed source, independent review, complete
Lean/source/module/axiom audit, focused tests and native evidence applicability.
Merge `7d17ed20f5fe64b4061867587a00ec5f8873b56a` has exactly the reviewed final
`b353f926c4` tree. Issue #314 was automatically closed by `Fixes #314` on merge,
its board status is Done, and milestone 18 is closed. No validation rerun is
claimed by this closeout.

The five named source-tree languages now have fail-closed category, precedence
and association guards with the required source wiring, positive inventories
and negative controls. Existing trees, evaluation, rendered tokens, semantic
endpoints, admitted language and legitimate same-operator Boolean nesting are
preserved. Opaque fixed token leaves and source-interpretation premises retain
their documented limits. The next selected feature is #297 above.

### Lean source parallelism

**Complete on Linux, 2026-11-06, through ordered PR #326 and PR #330 merges.**

[PR #326](https://github.com/berkeleynerd/silver/pull/326) merged as
`508692aa8957c319a6baaffd1d0fb5a17afcc8ea`, delivering the four-module output
certificate #323 and four-leaf predicate split #324.
[PR #330](https://github.com/berkeleynerd/silver/pull/330) followed as
`315906b94fe535eecc4abc3a433b272c3eeacb03`, delivering the matched eight-chunk
comparison #327 and stable-content cache work #328. Parent #8 and
[milestone 17](https://github.com/berkeleynerd/silver/milestone/17) are complete.
The reconciliations preserved validated implementation and evidence inputs.

The [initial delivery record](docs/lean-line-chunks.md#completed-production-validation--2026-11-06)
retains the bounded 512-line experiment and original production history. Its
roughly 65-minute line/reconstruction result versus a historical 184-minute
monolith is descriptive, with differing conditions. The
[throughput delivery record](docs/lean-incremental-throughput.md#merged-delivery--2026-11-06)
retains the matched four/eight comparison, actual-object reuse pilot, complete
Linux native and Lean/source/module/axiom checkpoint, focused tests, critical
review and timing/cache attribution. Eight stable content buckets are retained;
reconstruction remains substantial serial work. These observations do not
establish a whole-project or general edit-speed improvement.

The current language, Oracle, reconstruction representation, source/token
statements, required checks and automatic CPU settings are unchanged. The
completed performance packages do not select a broader proof/cache framework.
The separately selected #314 follow-up appears above.

### Interim external review response for PR #307

**Repairs, complete Linux assurance and closing review passed, 2026-11-05.** The
[interim report](docs/reviews/interim-review-0d30841795-20261105.md) identifies
five blockers across the String delivery and inherited array/scalar behavior.
The [owner authorization](docs/session-memory.md#2026-11-05--interim-external-review-repairs-authorized)
selects a bounded B2 admission design, B1–B5 implementation, focused regressions
and record corrections, then one stable complete native/Lean/source/regression
checkpoint and independent review. Native and cached Lean/source assurance
have passed; reviewed regression coverage accounts for all 595 test IDs. The
[closing delivery review](docs/reviews/review-interim-response-closing-20261105.md)
passed. The owner [authorized merging PR #307 on 2026-11-06](docs/session-memory.md#2026-11-06--repaired-string-merge-authorized).
The external report remains interim and clears no unexamined scope.
Med-1's remaining structural guards were retained as a separate follow-up and
are now selected in the structural-guard milestone above. No new language
feature is selected by this response.

### Bounded String indexing and character operations

**Complete on Linux through [PR #307](https://github.com/berkeleynerd/silver/pull/307).
Assurance and closing review passed 2026-11-05; owner-authorized merge 2026-11-06.**

[Milestone 16](https://github.com/berkeleynerd/silver/milestone/16) contains
[#296](https://github.com/berkeleynerd/silver/issues/296), authorized on 2026-10-31
and resumed on 2026-11-03. The
[historical delivery record](docs/bounded-string-characters.md#delivery-assurance-and-validation)
retains the previous implementation, native/Lean checks, 578-method regression
accounting and reviews. The [interim response](docs/interim-review-response-20261105.md)
supersedes that completion claim and records the repaired native/Lean checkpoint
and reviewed 595-ID regression coverage. The
[repair closing review](docs/reviews/review-interim-response-closing-20261105.md)
passed; the historical [closing review](docs/reviews/string-delivery-closing-20261104.md)
passed at `9111fbf88be337214278f185501d2f9de1761442`.
The original failed and interrupted runs remain recorded.

The fragment admits fixed-bound String indexed reads and element writes,
printable-ASCII Character objects and typed comparisons, and bounded slices.
It preserves actual lower bounds, valid null ranges, assignment sliding,
snapshots and composition with existing guards, loops and Boolean expressions.
The source, operator and operand budgets remain unchanged.

Rosetta promotes only `bounded-string-characters` for reversal, palindrome
detection and selective character replacement. The bounds/sliding sample adds
regression coverage, not another task gain. Broad `characters`, `string-indexing`
and other general String uses remain separate. Stage issues #11/#12 remain
Open/Backlog at rendered stages 2/3; #9/#10 remain Done at stage 1. Issue #296
records the precise feature mapping, so no duplicate stage issue is needed.

Milestone 16 covers this completed delivery and its selected review repairs.
The structural guards in #314 and Boolean arrays #297 are complete as recorded
above. Sample expansion #300 is now selected after the tutorial audit; functions
#298 and deferred capacity/assurance-mode work retain their unselected scope.

### Boolean scalar objects and expressions

**Implemented and validated on Linux, 2026-10-31
([PR #295](https://github.com/berkeleynerd/silver/pull/295)); merged after PR #289 on 2026-10-31.**

[Milestone 14](https://github.com/berkeleynerd/silver/milestone/14) contains one
coherent work package, [#291](https://github.com/berkeleynerd/silver/issues/291),
driven by Sequence of primes by trial division, Square but not cube and Common
list elements. The [delivery record](docs/boolean-objects.md#delivery-assurance-and-validation)
records complete Linux native and Lean/actual-source assurance against the
implementation and review inputs,
with exact native/Lean results, regression applicability and evidence limits.

The fragment adds initialized scalar Boolean constants and variables,
assignment, `True`/`False`, `not`, eager `and`/`or`/`xor`, and Boolean expressions
in existing short-circuit conditions. Ada visibility governs predefined names.
Both eager operands need incoming safety facts; stored flags preserve no scalar
predicate facts. Neither xor operand may contain xor, bounding the pinned
producer's formula expansion. Source/operator/leaf limits and the Oracle remain
unchanged. Boolean arrays, callable routines and enumeration iteration remain
excluded.

The feature was developed on the validated subtype baseline
`fa6b5e982cad5662b18f498e75cafbac9fb07cc9`. The owner
[authorized ordered merge](docs/session-memory.md#2026-10-31--named-subtype-and-boolean-validation-and-merge-authorized)
on 2026-10-31; both PRs merged in that order, and milestones 13/14 are closed.
The [delivery closeout](docs/session-memory.md#2026-10-31--named-subtype-and-boolean-deliveries-complete)
records their merge identities.
Rosetta promotes only `scalar-boolean-objects` for the three selected drivers.
Broad Boolean/logical-operator/Boolean-flag uses remain separate, and stage
issues #11/#12 remain Open/Backlog at rendered stages 2/3. The queue above and
deferred capacity/assurance-mode work retain their existing scope.

### Named Integer subtypes and bounded array components

**Implemented and validated on Linux, 2026-10-30
([PR #289](https://github.com/berkeleynerd/silver/pull/289)); merged 2026-10-31.**

[Milestone 13](https://github.com/berkeleynerd/silver/milestone/13) delivers one
coherent work package, [#286](https://github.com/berkeleynerd/silver/issues/286),
driven by Rosetta Sum of squares. The
[2026-10-29 authorization](docs/session-memory.md#2026-10-29--named-integer-subtypes-and-bounded-array-components-authorized)
covers implementation, complete assurance, regressions, independent review and
feature PR publication. The [delivery record](docs/named-integer-subtypes.md#delivery-assurance-and-validation)
identifies the implementation/review target, complete Linux native and Lean/source
audits, retained regression coverage with the repaired-source refresh, and the
scoped independent reviews. It preserves the earlier failed native and Lean
runs and the interrupted Lean run as historical outcomes.

The increment admits direct named static Integer range subtypes for initialized
scalar objects and components of existing anonymous fixed arrays. Optional
static scalar object constraints may narrow the named range. Stored values
respect their declared bounds; body reads and constant-array foreach elements
use the declared component interval. Existing source/operator/operand budgets
remain unchanged. Subtype aliases, conversions, derived types,
functions/procedures, dynamic bounds and general arrays remain excluded. The
Static-only Body_Tail equality repair is runtime-erased and source/pin/certificate
reviewed; it adds no obligation class or Oracle amendment.

Rosetta promotes only the two authorized Sum of squares and Sum and product
approaches through the narrow `named-integer-subtypes` identifier. The broad
`ranged-subtypes` and `arrays` identifiers remain unsupported; stage issues
[#11](https://github.com/berkeleynerd/silver/issues/11) and
[#12](https://github.com/berkeleynerd/silver/issues/12) remain Open/Backlog at
rendered stages 2 and 3. PR #289 merged on 2026-10-31. Deferred
capacity and assurance-mode work retains
its existing triggers.

### Fixed-array external review response

**Complete on Linux, 2026-10-29 ([PR #283](https://github.com/berkeleynerd/silver/pull/283),
following [PR #266](https://github.com/berkeleynerd/silver/pull/266)).**

[Milestone 12](https://github.com/berkeleynerd/silver/milestone/12) completes the
owner-selected response to the [external review of PR #263](docs/reviews/review-10cdcd274c.md):
precedence/association guards [#268](https://github.com/berkeleynerd/silver/issues/268),
catalogue and managed Rosetta-input capture, required records and the two stack
observations. Findings #269–#282 track the other required corrections; existing
issues retain the bookkeeping and optional follow-ups.

The later scalar-guard frontend blocker
[#284](https://github.com/berkeleynerd/silver/issues/284) predates arrays. Its
[repair](docs/scalar-guard-frontend-repair.md) corrects native compiler
configuration without changing admission and is delivered through #283.
The owner authorized the final combined validation and merge through
[PR #285](https://github.com/berkeleynerd/silver/pull/285).

The [final packet](docs/evidence/array-final-validation-20261029/README.md) records
complete native proof/coverage/provenance, native build, Lean/source/module/axiom
assurance, fresh full regressions and refreshed 8 MiB stack observations on the
combined inputs. The [integration/evidence review](docs/reviews/review-array-final-integration-20261029.md)
confirms the implementation and final evidence. The final external iteration and
combined-tree report was not supplied; no external approval is claimed. Broader
language, capacity and optional refactors remain unselected.

**Sequence since 2026-10-24.** Language development resumes first, following the
[Rosetta progression](rosetta/progression.md) at the current 4,096-byte strict
language: stage [#9](https://github.com/berkeleynerd/silver/issues/9), whose sample delivery
is recorded below, then the next construct stage after its own scope and
authorization. The strict/extended
assurance-modes milestone (#88–#94 in the order below) follows on the owner's
later instruction when the current bounds bind a needed program, and the
deferred #119 strict-mode rule on its recorded trigger. See the
[decision](docs/session-memory.md#2026-10-24--capacity-derivation-119-deferred-language-development-resumes).

### Rosetta samples using the current language

The [#9 delivery record](docs/rosetta-supported-samples.md) maps the issue's
original 31 tasks: fourteen executable regressions (thirteen new programs plus
the existing null sample), fourteen prose/tooling skips and three exclusions
whose assessed substitutes do not implement the requested semantics. The
complete Linux native/Lean and full-suite validation checkpoint passed on
2026-10-25, with independent sample review. No construct or supported identifier
changed, so the generated progression was not re-rendered.

The owner-requested [assessment reconciliation #225](https://github.com/berkeleynerd/silver/issues/225)
is recorded in the [targeted mapping](rosetta/assessment-reconciliation-20261025.md).
The [#226 delivery](docs/rosetta-finite-samples.md) adds five finite regressions
for compile-time calculation, N-plus-one-half loops, immutability, Integer
literals and the NxN minimum-cell grid, all within today's language. Integer
sequence is language-eligible but excluded from that batch because its faithful
full-range execution emits billions of lines. After the planning pass, the owner
instructed merging #221/#227 and proceeding with #226; the
[2026-10-25 authorization](docs/session-memory.md#2026-10-25--merge-deliveries-and-implement-the-five-finite-samples)
covered this five-sample batch through validation, review and delivery. The
implementation and independent review target is `3aae49385f`; complete Linux
validation passed and [PR #228](https://github.com/berkeleynerd/silver/pull/228)
publishes the samples and evidence. [Finite current-language Rosetta samples](https://github.com/berkeleynerd/silver/milestone/6)
is complete and closed after PR #228 merged and #226 closed.

The re-render keeps `supported` unchanged and gives stage 1 38 assessments,
without expanding #9's original scope. The old ten-task #11 group now splits
between six current-language candidates and four narrow future approaches.
Generated stage 2 (#11) now also includes procedures, while arrays (#12) moves
to stage 3; both remain unsupported and Backlog. New unsupported identifiers
describe only the reviewed approaches, so their late generated positions do
not establish implementation priority. The owner has now selected interval-checked division below. The remaining #11
constructs keep their own unselected scope; the bounded array increment selected
below does not select every approach in the broad arrays stage. A generated
stage number does not authorize implementation.

### Constant Integer-array iteration

**Complete on Linux, 2026-10-29 ([PR #266](https://github.com/berkeleynerd/silver/pull/266)).**

The owner [authorized the feature as a stacked PR](docs/session-memory.md#2026-10-28--constant-integer-array-iteration-authorized-as-a-stacked-pr)
while PR #263 was under external review. [Milestone 11](https://github.com/berkeleynerd/silver/milestone/11)
delivers one bounded increment, [#264](https://github.com/berkeleynerd/silver/issues/264):
`for E of [reverse] A loop`, where `A` is an existing constant anonymous
fixed-size Integer array. Brackets denote optional syntax. The faithful driver
is Rosetta Loops/Foreach. The
[delivery record](docs/constant-array-iteration.md#delivery-assurance-and-validation)
identifies complete Linux native and Lean/source assurance, reviewed regression
coverage and independent review. The
[recovery handoff](docs/constant-array-iteration-pause-20261028.md) retains the
historical VM-upgrade pause; interrupted runs remain interrupted.

[PR #283](https://github.com/berkeleynerd/silver/pull/283) follows #266 with the
review response and scalar-guard frontend repair. The
[final combined packet](docs/evidence/array-final-validation-20261029/README.md)
records the completed validation of that configuration. Mutable iteration,
general iterators, broad arrays #12 and the remaining procedures/ranged-subtype
forms in #11, capacity/assurance modes and proof-performance follow-ups remain separate.
Source, expression and operator limits are unchanged.

### Fixed-size Integer arrays

**Complete on Linux, 2026-10-28 ([PR #263](https://github.com/berkeleynerd/silver/pull/263)).**

[Milestone 10](https://github.com/berkeleynerd/silver/milestone/10),
[#260](https://github.com/berkeleynerd/silver/issues/260), delivers the bounded
Integer-array fragment selected by the
[owner](docs/session-memory.md#2026-10-27--fixed-size-integer-arrays-authorized).
The [rotation driver](samples/rosetta_shift_list_left_3.adb) maps
`[1,2,3,4,5,6,7,8,9]` to `[4,5,6,7,8,9,1,2,3]` with two explicit copy loops.
The [capability record](docs/fixed-integer-arrays.md) describes the rules; its
[delivery evidence](docs/fixed-integer-arrays.md#delivery-assurance-and-validation)
records the exact implementation, native and universal/source assurance,
regression results and independent review.

The fragment admits anonymous one-dimensional constant or mutable Integer
arrays, nonempty static bounds, mandatory explicit initialization and scalar-only
checked subscripts for reads and writes. Declaration snapshots retain exact
values; body reads use declared component intervals (full Integer for
`of Integer`). Indexed writes preserve other components, existing String/input
facts and captured loop bounds. The source
and operator budgets are unchanged.

Rosetta support is limited to `fixed-integer-arrays` and the exact rotation
approach. Broad `arrays` and
[stage #12](https://github.com/berkeleynerd/silver/issues/12) remain open for
named array types, dynamic or null arrays, array attributes, whole-array
operations, mutable/general iteration and other unadmitted forms. Other #11 constructs,
capacity/assurance-mode work and further proof-performance packages remain
outside this increment.

### Checked integer division and scalar refinement

[Milestone 7](https://github.com/berkeleynerd/silver/milestone/7), **Checked integer
division and scalar refinement**, is **complete on Linux, 2026-10-26**, with
two ordered deliveries. The
[2026-10-25 owner instruction](docs/session-memory.md#2026-10-25--merge-228-and-implement-interval-checked-integer-division)
authorizes the first through delivery. The subsequent
[roadmap continuation](docs/session-memory.md#2026-10-25--continue-non-deferred-roadmap-delivery)
selects scalar guard refinement next and continued assessment/delivery of
non-deferred successors.
The owner's [2026-10-26 review pause](docs/session-memory.md#2026-10-26--pause-after-scalar-guard-delivery-for-external-review)
ends that continuation at the completed scalar guard delivery. The
[external comprehensive review](docs/reviews/review-22838bc809.md) reports no
blocker or medium finding. Its small record/metadata response in
[milestone 8](https://github.com/berkeleynerd/silver/milestone/8) is complete,
including the owner-selected narrow regression-reuse clarification and all seven
low record corrections. Informational suggestions have explicit dispositions
and bounded follow-up links. The later fixed-size-array authorization above
resumes one capability; optional test/tooling work is not automatically selected.

[Development velocity follow-up #246](https://github.com/berkeleynerd/silver/issues/246)
has a retained [assessment and scheduling checklist](docs/development-velocity.md)
covering source-proof cost, checkpoint scheduling and candidate dependency
changes. After the review response merged, the owner
[selected its first package](docs/session-memory.md#2026-10-26--first-development-velocity-package-authorized)
under [milestone 9, Source-proof iteration cost](https://github.com/berkeleynerd/silver/milestone/9).
This increment is **complete on Linux, 2026-10-27**: concise checkpoint/invalidation
guidance, bounded profiling and the composition-check dependency split, with
complete applicable assurance and independent review. The
[delivery record](docs/development-velocity.md#first-package-implementation-and-validation)
retains the 27.97% build-wall reduction in one matched workload, exact source
statements and reconstruction, memory limits and validation scopes. Certificate chunking,
predicate-proof optimization and persistent runner metrics remain conditional;
new language development is not selected by the #246 authorization.

1. [Interval-checked integer division #229](https://github.com/berkeleynerd/silver/issues/229):
   **delivered** fully grouped `/`, `mod` and `rem` in current scalar-expression positions,
   driven by Josephus. Retain object-local ranges and current source/operator
   budgets. The [capability record](docs/integer-division.md) specifies the
   design obligations, evidence and exclusions. Its work packages are
   [scope/design #230](https://github.com/berkeleynerd/silver/issues/230),
   [native admission #231](https://github.com/berkeleynerd/silver/issues/231),
   [universal/source assurance #232](https://github.com/berkeleynerd/silver/issues/232)
   and [validation/delivery #233](https://github.com/berkeleynerd/silver/issues/233).
   No partial package completes the parent or admits a construct.
2. [Scalar guard refinement #234](https://github.com/berkeleynerd/silver/issues/234):
   **delivered** after division. The
   [selected scope](docs/scalar-guard-refinement.md) refines mutable names and
   loop indexes against static thresholds, separates declared ranges from flow,
   replaces facts on assignment, joins branches and widens mutable facts at loop
   boundaries while preserving captured index bounds. The finite driver is
   100 doors. The [delivery checkpoint](docs/scalar-guard-refinement.md#delivery-assurance-and-validation)
   retains complete native and universal/source assurance, retained regression
   results with focused repair validation, and independent review. Its completed packages are
   [scope/design #237](https://github.com/berkeleynerd/silver/issues/237),
   [native admission #238](https://github.com/berkeleynerd/silver/issues/238),
   [universal/source assurance #239](https://github.com/berkeleynerd/silver/issues/239)
   and [validation/delivery #240](https://github.com/berkeleynerd/silver/issues/240).
   No new syntax does not eliminate the assurance work.
   The [sample](samples/rosetta_100_doors.adb) preserves the discovered
   529-byte driver; the manifest independently derives all 100 lines by pass-major
   toggles. Rosetta metadata adds the narrow `scalar-guard-refinement`
   identifier and maps 100 doors to the exact fragment. Its previous array/Boolean
   approach is replaced by the faithful visit-count model; arrays, Boolean objects,
   named subtypes, expression inversion and variable relations stay unsupported.
   The Unicode-variable assessment uses the same selected guard form but still
   requires unsupported Unicode identifiers. Rendering remains planning metadata;
   the linked delivery evidence establishes this increment's completion.

This deliberately selects division ahead of generated stage order (division
was stage 6 at selection), because the assessed bounded arithmetic drivers offer
more immediate capability than named subtypes. Seven concrete sample approaches
are implemented and independently reviewed
in the native/arithmetic core scope; the capability record retains their successful
manifest checks, complete native/Lean audits and the repaired certificate parity
check. The delivery metadata adds only `interval-integer-division` to supported identifiers and maps
those seven approaches to it. The broad `integer-division` identifier, including
`abs`, remains unsupported; the old ten-task assessment upper bound is not a
delivered-task count. Assessment corrections
may change generated positions, which remain planning metadata.

The later owner instruction selects the bounded array increment above after
the external review. This completed milestone does not resume capacity derivation or the
strict/extended assurance-mode packages. Complete feature-local report accounting
remains part of division's assurance within the existing bounds.

### Unbounded programs

**Capacity derivation deferred 2026-10-24; language development resumes.** The
owner approved deferring the full #119 derivation after an
[independent assessment](docs/evidence/119-sequencing-assessment-20261024/README.md)
put it at about 50% complete (range 40–65%) against its self-reported 85%, with
the remaining half estimated at 200–415M tokens before any production package.
Accepted #119 evidence is frozen at the R92 checkpoint `f1920759b1` in draft
PR #121 (tag `evidence/119-r92-accepted-f1920759b1`); #119, its children and the
open findings are deferred in Backlog, and PR #121 stays unmerged. #88–#94 keep
their conditional authorization but form the later assurance-modes milestone
(extended mode with a crude sound envelope for the silent hard limits; strict mode
stays at 4,096 bytes until #119's rule exists). The paragraphs below record the
2026-10-17 direction and its production order as history; the decision entry
records the re-sequencing, the resume trigger and what is not authorized.

**Retained-tool direction adopted; capacity design resumed.** The owner
[selected](docs/session-memory.md#2026-10-17--retained-tool-capacity-direction-adopted)
keeping the existing GNAT/GNATprove toolchain, accepting explicit tool-imposed
representation boundaries and removing unnecessary Silver limits within a
justified domain. [Decision #117](https://github.com/berkeleynerd/silver/issues/117)
records this disposition. External paired support, compiler forks and replacement
frontends cease to be prerequisites. The [scope](docs/unbounded-programs.md)
and [milestone 5](https://github.com/berkeleynerd/silver/milestone/5) retain the
unchanged Oracle and current supported language.

The reviewed research [#107/#108](docs/research/unbounded-feasibility-result.md)
and [#113](docs/research/frontend-representation-result.md) establishes a
source-derived obstruction to the original full String composition domain.
Two distinct length-2^30 Strings require at least 2^31 shared character entries;
the inspected GNATprove literal producer has a separate finite Why-node space.
These are conditional source facts, not native near-limit failures or safe
admission thresholds. PR #109 and PR #116 preserve the completed research and
reviews. Their external-support recommendation is superseded, not their evidence.

The next technical work is
[#119 Derive capacity rules for unchanged tools](https://github.com/berkeleynerd/silver/issues/119),
a design subpackage of #91 shared with #93. The
[design contract](docs/research/retained-tool-capacity.md) requires a sound,
decidable rule accounting for retained and temporary values, generated data,
dependencies, phase-specific expansion, representation arithmetic and growth.
Prefer program-structure accounting and justify any conservative envelope.
`Integer'Last` is an inherited ceiling; a per-value bound alone does not justify
all compositions. No numerical aggregate cap or larger admission domain is selected.

The selected literal-output native-build increment
[#145](https://github.com/berkeleynerd/silver/issues/145) is technically complete
and In review through [draft PR #121](https://github.com/berkeleynerd/silver/pull/121).
**#119 is In progress** under the [2026-10-20 resumption](docs/session-memory.md#2026-10-20--capacity-goal-119-resumed-after-review-maintenance),
following the completed checkpoint-review maintenance.
The [review disposition](docs/review-a3af180047-disposition.md) enumerates the
remaining #119 obligations, shape-dependent accepted region, configuration
premises and deferred findings. The approximate 80% estimate is a subjective
planning judgment with substantial whole-rule integration uncertainty.

The result covers a selected direct four-job graph with extra compiler options,
direct GNATBIND and a fixed two-unit Silver object/ALI bundle. Production still
runs GPRbuild over a seven-unit project and is outside that researched invocation.
**#89 must adopt the exact researched graph, options, materialization, environment
and fixed-input contracts with Bronze/Silver and Lean source correspondence,
coordinated with #88, or rederive capacity for the alternative graph.** This is
a future production obligation; the checkpoint does not discharge it. Continue
#119's producer/Why3 and fixed-dependency coverage, then current-grammar and
whole-rule composition/comparison, reusing accepted native evidence. Relevant
#150 review follow-ups are reconciled at bounded checkpoints.

Capacity restrictions must be established before admission. An admitted program
hitting a build or proof-essential representation limit remains a defect,
distinct from physical resource exhaustion. Optional confirmation cannot waive
automatic discharge. A reporting-only boundary needs an explicit independence
argument before it may be treated as inconclusive confirmation. These rules
replace the former blanket confirmation-only producer-limit classification.

The milestone's work packages retain their production order, with #119's design
before any expanded membership:

1. **Scope and design [#87](https://github.com/berkeleynerd/silver/issues/87):**
   completed historical proposal and corrections; #117 selects the revised route.
2. **Proof confirmation and resource outcomes [#88](https://github.com/berkeleynerd/silver/issues/88):**
   separate build and confirmation, preserve complete success auditing and input
   identity, and classify resource, representation and other failures accurately.
3. **Compiler storage and complexity [#89](https://github.com/berkeleynerd/silver/issues/89):**
   input-sized storage, growable process/file/path interfaces, explicit stack work
   and producer/consumer representation accounting. Adopt the researched native
   invocation with source correspondence, or rederive capacity for the selected
   alternative, as recorded above. Admission stays unchanged.
4. **Parameterized Lean assurance [#90](https://github.com/berkeleynerd/silver/issues/90):**
   exact length ranges and the selected capacity predicate, native correspondence,
   composition and automatic discharge. Admission stays unchanged.
5. **Pinned-tool capacity rules [#91](https://github.com/berkeleynerd/silver/issues/91):**
   complete #119's justified whole-program design, then implement its native/Lean
   rules after #89/#90. A partial component or researched stop does not satisfy
   the adoption dependency.
6. **Remove unnecessary source, operator and expression caps [#92](https://github.com/berkeleynerd/silver/issues/92):**
   admit larger programs after #88–#91, retaining necessary capacity accounting.
7. **String and argument capacity within pinned-tool limits [#93](https://github.com/berkeleynerd/silver/issues/93):**
   generalize values/runtime contracts within the justified #119/#91 domain;
   re-derive dependency/producer bounds after runtime changes. May overlap #92
   only after their shared capacity and assurance prerequisites hold.
8. **Validation, review and delivery [#94](https://github.com/berkeleynerd/silver/issues/94):**
   complete stable native/Lean assurance, outcome/capacity validation, independent
   review and synchronized capability records before claiming support.

#119 is the current design increment. The owner has also authorized production
#88–#94 once the capacity rule is justified. Those packages remain unstarted,
with their dependencies recorded; no further implementation go-ahead is needed.
No external-tool change, Oracle amendment or arbitrary lower cap is selected.
If complete sound capacity coverage cannot be established, report the exact
missing obligation before removing the existing caps; optional confirmation
cannot fill that gap. #89/#90 coordinate source certificates with one proof
workspace writer. New constructs/Rosetta stages are separate, and native macOS
validation remains independent and nonblocking. The milestone remains open.

### Bounded mutable integers

**Complete after review remediation on Linux x86_64, 2026-10-17.**
[PR #86](https://github.com/berkeleynerd/silver/pull/86) delivers the owner's
[authorized repairs](docs/session-memory.md#2026-10-17--bounded-mutable-integers-review-repairs-authorized)
to [review-b79b986403](docs/reviews/review-b79b986403.md). B1 [#77](https://github.com/berkeleynerd/silver/issues/77)
explicitly rejects empty Integer-assignment RHS intervals; M1 [#78](https://github.com/berkeleynerd/silver/issues/78)
connects independent endpoint readings to declared-range semantics. D1–D6
#79–#84 and minor record corrections are complete. The [repair record](docs/review-b79b986403-repairs.md)
separates source/proof/test input commit `78cf419452`, bidirectional source
reviews and the passing native, full-suite and complete cached Lean/source
checkpoint. The original PR #76 delivery and its retained failures below remain
historical evidence. Optional implementation improvements remain deferred;
no next construct is authorized.

The [capability record](docs/bounded-mutable-integers.md) defines the selected narrow
increment under [stage #11](https://github.com/berkeleynerd/silver/issues/11),
driven by [Find square difference](rosetta/f/find-square-difference/silver.md).
An initialized mutable Integer result can receive a loop index and be printed
with Integer Image. Optional object-local static ranges constrain initialization
and assignments; named subtype/type declarations and conversions remain outside
this increment.

The implementation separates exact declaration snapshots from Ada-staticness. Every
executable-body read of a mutable scalar uses its full declared range; neither
assignments nor guards narrow that range. RHS interval inclusion preserves the
target range, loop bounds are captured at entry, and Image lengths use the
current expression interval. Scalar and String writes persist across iterations
and after a loop; only its scoped index is removed. The universal and source arguments passed the repair checkpoint. Image
applicability retains the source-route, fixed-template and native evidence
classes under the documented producer/consumer assumptions.

[Milestone 4](https://github.com/berkeleynerd/silver/milestone/4) contains all
four work packages, recorded together when scoping began:

1. **Scope and automatic-proof design [#67](https://github.com/berkeleynerd/silver/issues/67):**
   complete through the scope proposal, including the driver, exact rules,
   composition, exclusions, assurance boundaries and future evidence plan.
2. **Native admission and regressions [#68](https://github.com/berkeleynerd/silver/issues/68):**
   Complete: selected SPARK rules, language/catalogue agreement, the driver
   sample and boundary/composition regressions. The complete native audit and
   full-suite execution with the focused snapshot repair are finished.
3. **Universal and actual-source assurance [#69](https://github.com/berkeleynerd/silver/issues/69):**
   Complete: mutable-store semantics, membership, finite execution,
   safety/discharge and source correspondence, including the later M1 repair.
   Image applicability retains the evidence classes and producer premises in
   the capability record. The
   [mutable report envelope](docs/bounded-mutable-report-capacity.md) extends the
   source/producer derivation; the old constant-only bound is retained as history.
   Complete native validation and the complete cached Lean build with fresh
   whole-project auditing passed.
4. **Validation, review and delivery [#70](https://github.com/berkeleynerd/silver/issues/70):**
   Complete: independent source review, both low finding repairs, native and
   Lean validation, and full-suite execution supplemented by the focused snapshot
   repair. The capability record distinguishes actual inputs, source-review
   targets, retained failures, the passing affected recheck and cache/workspace
   provenance. Language, catalogue, samples and support records are synchronized.

The owner's [implementation instruction](docs/session-memory.md#2026-10-17--bounded-mutable-integers-implementation-authorized)
selects packages #68–#70 through complete validation, review and delivery;
completion of #67 alone does not complete this milestone. The board carries live
status and coordinated workspace claims. The
[review](docs/reviews/review-bounded-mutable-integers.md) distinguishes the
implementation target, source review and validation evidence. No new Oracle
policy decision is identified.

The delivered Rosetta mapping uses the narrow identifier
`bounded-mutable-integers`: Find square difference is stage 1, position 15, among
35 baseline tasks. The ten remaining stage-2 tasks retain the broad
`integers`, `ranged-subtypes`, `for-loops` and `scalar-image` identifiers under
#11. General mutable arithmetic/refinement, named types/subtypes, conversions,
other loop forms and other scalar images remain outside this increment. Existing
Rosetta sample work #9 is separate, and procedures and arrays remain future
direction. No new harness goal was requested; the earlier goal remains complete.

### Review of For loops and integers

**Implementation and validation complete on Linux x86_64, 2026-10-17**.
[PR #66](https://github.com/berkeleynerd/silver/pull/66) tracks publication. The owner authorized
the recommended remediation of [review-b8f1d0b9a8](docs/reviews/review-b8f1d0b9a8.md)
on 2026-10-16, after the completed milestone below.
[Milestone 3](https://github.com/berkeleynerd/silver/milestone/3) uses the
finding issues as its increments. The [repair record](docs/review-b8f1d0b9a8-repairs.md)
identifies implementation, exact native/Lean/test inputs, cache reuse and
retained failures separately. The completed increments followed this order:

1. **Recognizer and capacity premise:** L1 [#51](https://github.com/berkeleynerd/silver/issues/51),
   native token-boundary counting with its Lean mirror, source correspondence
   and 63/64-boundary regressions. This is prerequisite to further constructs.
2. **Batched evidence and boundary corrections:** L2–L7 #52–#57, L8 under
   existing #31, L9 #58 and L13 #62. Preserve historical evidence, disclose
   actual input/cache scope, correct handoff status and document producer and
   invocation premises. This documentation stream ran alongside L1.
3. **Adapter operations:** L10 #59 and L12 #61, explicit workspace lifetime
   and retention plus useful fail-closed diagnostics, with affected assurance.
4. **Regression coverage:** L14 #63, selected admission/composition cases and
   two native regressions, integrated with the preceding changes.
5. **Separate proof follow-ups:** L11 #60 (internal template spelling/meaning
   determinism and stronger endpoints) and L15 #64 (representative
   kernel-checked recognizer witnesses), with separate focused proof evidence.
6. **Integration:** independent review, complete cached native and Lean audits,
   and focused regressions for the combined changes. The original failed
   full suite and its focused repair remain separate history; no repeated
   complete suite, clean build or independent kernel replay is claimed.

No owner policy decision remains open for this scope. There is no new language
construct, Oracle amendment, mandatory clean/replay run or generic provenance
framework. The previous milestone and its harness completion are not reversed.
Existing open Rosetta/planning suggestions remain separate; procedures receive
a stage issue when selected as a near-term capability. Future review effort
uses candidate consolidation, extra independent checking for blocker claims
or disagreements, and a whole-team cost checkpoint.

### Proof iteration controls

**Complete on 2026-10-16.** The owner's “Make it so” instruction selected one
cohesive tooling milestone before further feature work. Its
[single work package #39](https://github.com/berkeleynerd/silver/issues/39) in
[milestone 2](https://github.com/berkeleynerd/silver/milestone/2) delivers a durable
run ledger, resolved-workspace locks and worker coordination, cheap provenance
preflight, rationale for identical-success expensive reruns, recurring-obligation
diagnostic checkpoints, and resume/handoff readout. The
[record](docs/proof-iteration.md) defines scope and completion criteria.

The common runner controls, native/Lean integration, focused regressions and
independent review are complete. The record identifies the final Linux evidence
and repaired review findings. These are parts of one work package, with no
remaining owner policy decision. Required assurance stays
unchanged; no language construct or Oracle amendment is included. The owner has
now separately resumed the existing For loops and integers goal below.

### For loops and integers

**Complete on Linux x86_64, 2026-10-16.** The
[capability record](docs/for-loops-integers.md) admits immutable signed-32-bit
Integer constants, fully grouped `+`, `-` and `*`, comparisons, scoped
forward/reverse loops and standard Integer `'Image`, including Ada's leading
space. These compose with the existing String, input, path and output rules.
The [delivery evidence](docs/for-loops-integers.md#stable-delivery-evidence)
records the complete cached native audit and build, the retained full-suite
failure with its focused snapshot repair/recheck, and the complete cached Lean
build with a fresh audit. It distinguishes actual input scopes and independent
review; the regression evidence is not one clean passing full-suite run.

The owner resumed this same unfinished goal on 2026-10-16 after the selected
[review repairs](docs/review-343c2f8-repairs.md) and
[proof-iteration controls](docs/proof-iteration.md). The dated
[session memory](docs/session-memory.md) preserves that authorization and its
historical harness-status distinction. The settled [Image decision #34](https://github.com/berkeleynerd/silver/issues/34)
required exact Image-length composition, including valid fixed-length
assignments; the delivered producer/scanner/consumer refinement supplies that
connection without author annotations or source replacement.

[Milestone 1](https://github.com/berkeleynerd/silver/milestone/1) and
[stage #10](https://github.com/berkeleynerd/silver/issues/10) followed this order:

1. [Report capacity and placement #17](https://github.com/berkeleynerd/silver/issues/17):
   the prerequisite source/producer envelope, streaming projection,
   reader/policy correspondence and library-level storage. The
   [scalar/loop/Image extension](docs/report-capacity.md#for-loops-and-integers-extension)
   derives the new retained-report envelope within the existing allocation.
2. [Scope and automatic-proof boundary #13](https://github.com/berkeleynerd/silver/issues/13):
   exact scalar/loop/Image rules, resource bounds, complete composition and
   discharge schemas, producer assumptions and motivating programs.
3. [Native admission and regressions #14](https://github.com/berkeleynerd/silver/issues/14):
   verified SPARK admission/report changes with boundary, failure-path and
   interaction regressions.
4. [Universal and actual-source assurance #15](https://github.com/berkeleynerd/silver/issues/15):
   decidable membership, finite execution/termination, safety/discharge and
   correspondence to authoritative source. Forward producer acceptance and
   exact native refinement/consumer meaning are separate checked connections.
5. [Validation, review and delivery #16](https://github.com/berkeleynerd/silver/issues/16):
   stable native Linux and whole-project Lean evidence, independent review and
   synchronized language/catalogue/samples/Rosetta/capability records.

The motivating programs are the nested triangle, computed step sequence and
reverse countdown. The step example multiplies the index by a constant; it
adds no stride clause. Colour bars/Display remains future file output, based
on its faithful image-file assessment. At that milestone, mutable integers,
custom subtypes, conversions, division and other scalar images were excluded.
The later increments above cover selected initialized-object, assignment,
division and named Integer-subtype forms; the remaining exclusions keep their
own scope.

The coordinated Rosetta delivery supports only `integer-for-loops`,
`immutable-integers` and `integer-image`. Their three reviewed drivers are
baseline stage 1. Broad `for-loops`, `integers` and `scalar-image` remain
unsupported. Remaining scalar/loop forms and ranged subtypes are stage 2 on
[#11](https://github.com/berkeleynerd/silver/issues/11), procedures stage 3 and
arrays stage 4 on [#12](https://github.com/berkeleynerd/silver/issues/12).
The stage fields and issue bodies follow this mapping. Procedures receive a
stage issue when selected as a near-term target. This delivery and stage
movement authorize no later capability.

### Partial Output

**Complete**, authorized and validated on 2026-10-15. `Silver_IO.Put (Item)` joins
`Put_Line`: the same bounded String expressions, name visibility and named actuals,
exact bytes without LF, and a flush on every call including empty output. Detected
failure returns with sticky status 1; later statements continue. Invalid-input
paths still reject without any output call.

This is one milestone with three ordered work packages:

1. **Complete:** SPARK runtime and admission, including matching parser/name
   cases and unchanged Put_Line behavior.
2. **Complete:** universal Lean semantics, discharge and actual-source
   correspondence, exact native report policy, focused regressions and a
   [greeting sample](samples/partial_output.adb). The dense 571-call specimen
   proved, built and ran within existing report capacity.
3. **Complete:** independent source/semantic review, stable Linux native
   proof/build/full tests and complete cached Lean validation. Specification,
   catalogue and evidence are synchronized for the published delivery.

The [delivery record](docs/partial-output.md) gives exact evidence and limits,
including preparatory versus final Lean timings. Source/value limits and
accepted axioms are unchanged. No next capability or replacement harness goal
is automatically authorized.

### Run Arguments

**Complete**, authorized and validated on 2026-10-15. Existing input-dependent
programs now run with `silver run SOURCE -- [arguments...]`, preserving empty
values, spaces, quotes and exact argument boundaries through GNAT's direct
process interface. The no-argument form remains supported. Ordinary application
statuses propagate unchanged; neutral diagnostics reflect that status 1 can
mean Reject, output failure or failed launch.

All three work packages are complete: the process/resource boundary, verified
SPARK copying/cleanup with focused regressions, and Linux validation, review and
delivery. The [delivery record](docs/run-arguments.md) distinguishes the frozen
full-suite pass from the final equivalent-formatter repair and affected recheck,
and records final native/Lean evidence and real application executions.

Language membership, application APIs, source/value limits, report acceptance
and all seventeen Lean source bindings are unchanged. Existing source/proof/build
publication guards remain. No new capability or harness goal is automatically
authorized; preserve caches and unrelated Rosetta/scratch work.

<a id="larger-expressions--proposed-next-unit"></a>
### Larger Expressions

**Complete**, authorized and validated on 2026-10-15. The bounded String-expression
fragment now supports **64 leaves per expression and 63 concatenations per source**
across initialization, assignment, comparison and output. The source-wide budget
is the smallest that accommodates one maximal expression, with the same total
available across expression positions; it was not scaled mechanically from thirty.

All three work packages are complete: composition/capacity selection, matching
native/Lean implementation and regressions, and a stable Linux checkpoint and
delivery. Nine current-runtime probes cover grouping, repeated static/dynamic
references, path guards and dense sequences. The historical argument-shell
specimen proved and fit the buffer with 1.5% measured headroom. The review's
denser static construction left only 0.28–0.29%; timing-dependent prover credits
can exceed that margin. These measurements do not establish universal capacity;
see the [capacity correction](docs/review-343c2f8-repairs.md#report-capacity-correction).
The
[delivery record](docs/larger-expressions.md) gives the measured costs and limits.

Universal membership/composition/discharge and actual-source proofs passed at the
expanded constants. Native proof/build, complete cached Lean validation, all test
methods through the full run plus one test-only repair/recheck, and full GNAT code
generation for the focused differential corpus are complete. The specification,
catalogue and [release-report sample](samples/release_report.adb) agree. The
4096-byte source/value bounds, assignment/literal repairs, report policies and
external-tool premises remain. No new API, Oracle amendment or proof framework
was introduced; no next capability is automatically authorized.

### Known outstanding work

Reconciled on 2026-10-15 against the completed Partial Output, Run Arguments and
Larger Expressions deliveries, earlier handoffs and review dispositions.
Conditional follow-ups are tracked as
[`type: follow-up` issues](https://github.com/berkeleynerd/silver/issues?q=is%3Aissue+is%3Aopen+label%3A%22type%3A+follow-up%22)
on the Silver board; the seven that this table held were filed on 2026-10-15. The
linked records retain detailed findings, reasons and historical scope. Closed or
rejected review suggestions are not new tasks.

New language/API capabilities and release tooling remain direction rather than
follow-ups. Additional argument APIs, broader API placement and resizable
strings need their own motivating scope and assurance. For loops and integers
and the bounded mutable extension are recorded above; further capabilities
remain unselected.
Distribution/provenance and extra provers remain
[deferred until needed](#deferred-until-needed). Hosted CI stays disabled; its
dormant wording is revisited only if reactivation is authorized. macOS validation
remains independent and nonblocking.

Argument forwarding and neutral application-status diagnostics are complete in
[Run Arguments](#run-arguments). The prior kernel-bypass repair, default-runner drift tests, real axiom-audit
regression and branch correspondence guards are complete. The theorem-name
registry was deliberately rejected, historical-language retention is not required
before 1.0, and the Python provenance check is intentionally retained. These are
dispositions, not unfinished milestones.

## Language surface direction

Decided on 2026-10-15. The [Rosetta progression](rosetta/progression.md) is the
short-term plan for filling out Silver's natural surface under the Oracle. It
orders the Rosetta Code candidates whose proofs are likely or plausible to
discharge automatically into stages, each adding the constructs its samples
need, the most widely needed first. Each stage states the admission question for
every construct it adds; a stage that adds an input construct is driven by a
sample that uses that input and names the failure paths to test. A stage is a
candidate for a milestone, not an authorization: each still needs its own scope,
the owner's authorization and the complete assurance in
[development.md](development.md).

The assessments are model judgments, not proofs, and the corpus underrepresents
input handling, failure outcomes, modularity and library design. Once the natural
surface is filled out, reassess networking, parallelism (whose required profile
pragma the Oracle does not permit in program source) and other demanding samples,
and add real-world target programs where Rosetta is thin. The
[Rosetta README](rosetta/README.md) describes the assessments, the inclusion
policy and the supported-construct list.

## Planning and tracking

From 2026-10-15, work items and their status are tracked as GitHub issues on the
Silver board, as described in [planning](docs/planning.md). This roadmap keeps
direction: the milestone sequence, deferrals and the reasons for them. Owner
decisions and authorizations stay dated in the
[session memory](docs/session-memory.md). The
[board](https://github.com/users/berkeleynerd/projects/6) holds the conditional
follow-ups and the near-term progression stages.

## Completion criteria

For each area, enumerate its admitted forms, legal positions and interactions
with the other existing features. Each remaining exclusion must have a concrete
semantic, assurance or resource reason. An unimplemented interaction stays open;
it must not disappear into an unspecified later increment while the area is
called closed. Resource policies, including the current source and output size
bounds, are explicit project choices, not requirements of SPARK's Silver level.
They remain in force until any change is implemented and justified. A proof or
tool failure for already-admitted source remains a defect, not a new exclusion.

Establish decidable admission and universal composition, automatic-discharge and
actual-source correspondence arguments for the resulting fragment. Keep the
specification, catalogue, SPARK implementation, proofs and samples aligned.
Exercise boundaries and feature interactions, including failure paths, then
complete the existing [validation workflow](development.md#proof-loop-and-validation)
before marking an extension supported. This adds no separate approval or release
gate and does not substitute examples for the universal argument.

When a formerly rejected composition becomes supported, replace its rejection
expectation with admission, exact output/exit-status and genuine-report checks.
Retain negative tests for justified exclusions and incomplete verification.

The shared binding, declaration, copy and common-expression foundations are
complete. The authorized sequencing checkpoint incorporates repeated output and
retains the audit's diagnostic, report-capacity and translation constraints.
Declaration-time expressions cannot rely on facts established only by a later
body guard. The earlier unfinished **Repeated Output** draft remains preserved as
history; its proposed four-call cap was rejected. Ordinary returning calls
continue execution, and a detected output failure leaves exit status failed even
if later output succeeds. Predicate/path facts are complete in item 5. Call
associations and context/name closure are complete in Names and Calls.

Loops, additional library APIs, resizable strings and unrelated language
constructs are outside this consolidation. The existing assurance guarantees
remain in force.

## Status and admission

Milestones move through **proposed → in progress → supported**:

- **Proposed:** scope, dependencies, and open decisions are recorded. Example
  source may be shown here, but it is not a supported sample.
- **In progress:** implementation and assurance work has begun. Its new forms
  remain excluded from the supported language until admission is complete.
- **Supported:** the specification, catalogue, compiler, proofs, and validation
  agree; the example and its expected behavior are recorded. Each supported example must have a manifest entry.
  Regression checks pass, and any intentional changes to earlier rules or
  samples are documented as part of the change.

The admission criteria and review steps are in
[development.md](development.md). Each increment should introduce one small,
coherent capability. Closely coupled syntax may arrive together. The dependency
relationships below matter more than forcing every feature into a rigid linear
sequence.

## Milestones

| Milestone | Status | Capability and dependencies | Sample |
| --- | --- | --- | --- |
| Null baseline | Supported | `main_procedure`, `spark_mode_on`, and `null_statement` in the null composition. | [samples/null.adb](samples/null.adb) |
| Faster proof feedback | Supported | Native GNATprove/Lake reuse, configurable workers and explicit full/cold/clean checks; [native platform evidence and remaining costs](docs/proof-workflow.md), with subsequent [Lean concurrency measurements](docs/lean-concurrency.md). No language change; [host readiness](docs/host-readiness.md) records local validation and the owner's decision to disable hosted CI. | Developer workflow |
| Sample collection | Supported | Original null source moved byte-for-byte, with a small [manifest](samples/manifest.json) driving admission/proof/build/run checks. No language change. | [samples/null.adb](samples/null.adb) |
| Literal output / Hello World | Supported | `runtime_context`, `literal_output`, and `string_literal` together: one qualified call, printable ASCII literal, verified wrapper and complete report handling. Final validation is recorded in the [capability record](docs/hello-world.md). | [samples/hello_world.adb](samples/hello_world.adb) |
| Named string constant | Supported | A literal-initialized `constant String`, name binding and output through its identifier. Completed [validation](docs/named-strings.md). | [samples/string_constant.adb](samples/string_constant.adb) |
| Command-line message | Supported | Initialize the constant through `Silver_Arguments.First_Or_Default`, with a mandatory validity guard and rejection branch. Completed [Linux validation](docs/command-line.md). | [samples/command_line.adb](samples/command_line.adb) |
| Literal-backed greeting | Supported | Literal prefix, one reference to a literal-initialized String constant, and literal suffix joined by Ada `&`; combined bounds and completed [validation](docs/greeting.md). | [samples/greeting.adb](samples/greeting.adb) |
| Source-certificate performance | Completed investigation | Both candidates failed to establish a validated improvement; retain the existing representation. [Negative result and evidence](docs/certificate-performance.md). | Developer workflow; no language change |
| Lean source compartmentalization | Supported | Per-file binary dependencies and a verified lexical-helper boundary; [measured cache reuse and full validation](docs/lean-compartmentalization.md). Certificate representation unchanged. | Developer workflow; no language change |
| Focused Lean checks | Supported | Synchronized module targets and scoped fresh auditing; complete routine checks retain caching and source correspondence, with optional replay/provenance. [Validation and limits](docs/lean-iteration.md). | Developer workflow; no language change |
| Guarded command-line greeting | Supported | Dynamic concatenation behind the fixed validity/capacity guard; verified normalization, complete application reports and independent report-policy refinement. [Completed validation](docs/command-line-greeting.md). | [samples/command_line_greeting.adb](samples/command_line_greeting.adb) |
| Fixed-length string assignment | Supported | One literal-initialized variable, one equal-decoded-length literal assignment, then output by the bound name. Completed [Linux validation](docs/string-assignment.md), including full Lean audit and fresh kernel replay. | [samples/string_assignment.adb](samples/string_assignment.adb) |
| Input-dependent branching | Supported | One equality comparison between validated command-line input and a literal, choosing between two terminal literal outputs. [Completed Linux validation](docs/input-branching.md). | [samples/input_branching.adb](samples/input_branching.adb) |
| Compose String Results | Supported | Shared bounded output expressions, repeated static references, tighter safe capacities and one branch-selected fixed-length result; [completed Linux validation](docs/string-results.md). | [samples/composed_result.adb](samples/composed_result.adb) |
| Copy String Values | Supported | Up to two literal-backed constants in mutable shells, named initialization and equal-length copies, with bounded constant output references; [completed Linux validation](docs/copy-values.md). | [samples/copied_result.adb](samples/copied_result.adb) |
| Shared declarations, names and copies | Supported | Ordered initialized bindings, literal/name snapshots, mutability and fixed static/dynamic bounds across the then-existing bodies; [scope and completed validation](docs/shared-bindings.md). Sequencing and context rules are supported below; broader API placement remains separate. | [Shared-binding sample](samples/shared_bindings.adb), native tests and universal/source proofs passed |
| Common String expressions | Supported | Shared bounded expressions in every expression position; [completed validation](docs/common-expressions.md). | [samples/common_expressions.adb](samples/common_expressions.adb) |
| Statement sequencing and assignment | Supported | Nonempty finite sequences, fixed-bound assignments, one-level choices and returning output effects; [validation record and resource follow-up](docs/statement-sequencing.md). | [samples/statement_sequence.adb](samples/statement_sequence.adb) |
| Equality, guards and branches | Supported | Nested conditionals, `elsif`, optional `else`, bounded predicates/integer literals and path-sensitive assignments, output and rejection; [completed 5a–5c validation](docs/branches.md). | [samples/conditional_statements.adb](samples/conditional_statements.adb), [samples/path_guards.adb](samples/path_guards.adb) |
| Names and Calls | Supported | Reordered/grouped/repeated contexts, use-visible calls with local-name hiding, and named `Item`/`Default` actuals for existing operations; [completed validation](docs/names-and-calls.md). | [samples/names_calls.adb](samples/names_calls.adb) |
| For loops and integers | Supported | Immutable signed-32-bit Integer constants, scoped forward/reverse loops, grouped arithmetic, comparisons and standard Integer Image, composed with existing String/path/output rules; [complete delivery evidence](docs/for-loops-integers.md#stable-delivery-evidence). | [Triangle](samples/for_loop_triangle.adb), [computed step](samples/for_loop_step.adb), [countdown](samples/for_loop_countdown.adb) in the coordinated delivery |
| Bounded mutable integers | Supported | Initialized Integer objects with optional object-local static ranges, range-preserving assignments, exact declaration snapshots and captured loop bounds; [completed Linux validation](docs/bounded-mutable-integers.md). | [Find square difference](samples/find_square_difference.adb) |
| Interval-checked Integer division | Supported | Fully grouped `/`, `mod` and `rem`, nonzero divisor intervals and operator-specific result bounds; [Linux validation and assurance](docs/integer-division.md). | [Josephus](samples/rosetta_josephus_problem.adb) and six further regressions |
| Scalar guard refinement | Supported | Bare mutable/index comparisons against static thresholds, assignment replacement, branch hulls and captured bounds with mutable loop widening; [Linux validation and assurance](docs/scalar-guard-refinement.md#delivery-assurance-and-validation). | [100 doors](samples/rosetta_100_doors.adb) |
| Fixed-size Integer arrays | Supported | Anonymous one-dimensional Integer arrays with nonempty static bounds, explicit initialization, checked scalar-only subscripts, exact declaration snapshots and component-preserving writes; [delivery assurance and validation](docs/fixed-integer-arrays.md#delivery-assurance-and-validation). Broad arrays remain separate. | [Left rotation by three](samples/rosetta_shift_list_left_3.adb) |
| Constant Integer-array iteration | Supported | Forward/reverse element iteration over existing constant anonymous fixed-size Integer arrays, immutable scoped elements and existing body compositions; [delivery assurance and validation](docs/constant-array-iteration.md#delivery-assurance-and-validation). Mutable iteration and general iterators remain separate. | [Loops/Foreach](samples/rosetta_loops_foreach.adb) |
| Named Integer subtypes and bounded components | Supported | Direct static Integer range subtypes for initialized scalar objects and existing fixed-array components, optional narrower scalar object ranges, and declared component bounds in body reads and foreach elements; [complete Linux assurance and validation](docs/named-integer-subtypes.md#delivery-assurance-and-validation). Broad ranged subtypes and arrays remain separate. | [Sum of squares](samples/rosetta_sum_of_squares.adb), [Sum and product](samples/rosetta_sum_and_product.adb) |
| Boolean scalar objects and expressions | Supported | Initialized scalar Boolean objects, assignment and eager/short-circuit expressions; no retained scalar predicate facts through flags, no xor inside xor operands; [delivery assurance and validation](docs/boolean-objects.md#delivery-assurance-and-validation). | [Sequence of primes](samples/rosetta_sequence_of_primes_by_trial_division.adb), [Square but not cube](samples/rosetta_square_but_not_cube.adb), [Common list elements](samples/rosetta_common_list_elements.adb) |
| Bounded String indexing and Character operations | Supported | Printable-ASCII Character values and typed comparisons, fixed-bound String indexed reads/writes and bounded slices, preserving actual/null bounds, sliding and snapshots; [complete Linux assurance and validation](docs/bounded-string-characters.md#repaired-delivery-checkpoint--2026-11-05). | [Reversal](samples/rosetta_reverse_a_string.adb), [palindromes](samples/rosetta_palindrome_detection.adb), [selective replacement](samples/rosetta_selective_character_replacement.adb) |
| Fixed-size Boolean arrays | Supported | Explicitly initialized anonymous one-dimensional predefined Boolean arrays, safe scalar-only indexes and mutable component writes; exact snapshots and typed stored flags without retained predicate facts. [Linux evidence and closing confirmation](docs/boolean-arrays.md#delivery-assurance-and-validation--2026-11-07). Broad arrays/booleans and Boolean iteration/`others` remain separate. | [Sieve through 100](samples/rosetta_sieve_of_eratosthenes.adb), [elementary cellular automata](samples/rosetta_elementary_cellular_automaton.adb) |
| Small nonrecursive scalar procedures | Supported | Explicit scalar parameter modes, source-written output initialization, nonaliasing scalar calls and range-checked copy-back; [original delivery evidence](docs/scalar-procedures.md#delivery-assurance-and-validation). The named/mixed extension is recorded separately below. Broad procedures remain separate. | [Return multiple values](samples/rosetta_return_multiple_values.adb) |
| Named scalar arguments | Supported | Fully positional, reordered fully named and positional-prefix/named-suffix calls of existing Integer/Boolean scalar functions and procedures; case-insensitive callee-formal selectors, every formal exactly once, unchanged full domains, incoming-state checks, aliases, copy-back, source and budgets. [Complete native/Lean/suite evidence and closing review](docs/named-scalar-arguments.md#delivery-assurance-and-validation); precise [stage #393](https://github.com/berkeleynerd/silver/issues/393). Defaults remain excluded; broad functions/procedures and arrays (#11/#12) remain separate. | [Named parameters](samples/rosetta_named_parameters.adb) |

The output target covers admitted literals and bounded command-line
messages; the text `Hello, world!` receives no special treatment. String literals do not imply support for
arbitrary String operations, dynamic-length indexing, general arrays, access types, or file
handles. Each additional form needs explicit admission and composition rules.

## Output design and next increments

Hello World originally admitted its context clause, literal, and call as one
coherent capability, without an artificial `runtime_context.adb` step. Sequencing
now also admits an output-capable context whose body contains only null or
assignment statements. The original API is
`Silver_IO.Put_Line`; [Partial Output](#partial-output) adds `Silver_IO.Put`. Both
are implemented in verified SPARK over the existing libc
`putchar` and `fflush` symbols plus GNAT
`__gnat_set_exit_status`. The [review repairs](docs/hello-review-repairs.md)
replace abrupt exit with ordinary status assignment and return. The focused
[runtime experiment](docs/hello-runtime-experiment.md) established the actual
obligation classes before the report checker was extended.

The [language specification](language.md) defines printable ASCII literals,
quote escaping, empty strings, the source bound, exact LF output, detected
failure, and the current permitted compositions. The
[trusted boundary](docs/trusted-boundary.md#literal-output-boundary) defines
external effects and progress. Repeated calls, initialized variables and bounded
common String expressions are now supported. Broader library admission remains
excluded.

The owner authorized the command-line message task below on 2026-10-09.
The review repairs are complete in `251dd85`; named strings are committed in
`2f76b20`. The command-line scope and assurance are recorded in the
[history](docs/roadmap-history.md#hello-world-with-a-command-line-message). A general proof
engine, catalogue framework, or additional output API is not a prerequisite.

The source bridge checks both recognizers and the selected runtime libraries.
Source-certificate replay remains a development cost to measure as these grow.
Preserve caching and independent module scheduling; improve representation when
measurements justify it without weakening source correspondence or kernel checks.
The [greeting record](docs/greeting.md) retains the enlarged certificate's
resource-limit repair and observed replay cost for that follow-up.
The completed [command-line review follow-up](docs/command-line-review-repairs.md)
strengthens the existing Main composition and expression-precedence checks,
regressions and evidence documentation. It adds no admitted forms and does not
authorize another language increment.

## Deferred until needed

Binary attestations, full per-program dependency provenance, additional defenses
for adversarial build environments, and compatibility machinery are deferred.
Revisit them when distributing independently consumed binaries, working in
untrusted/shared environments, or preparing a stable release makes them useful.
They are not prerequisites for Hello World. Existing validation remains in
place; accurate evidence and current language guarantees are still required.

Additional solver cross-checks, alternative kernels such as lean4lean, duplicate
proof developments in Rocq/Isabelle and solver-certificate infrastructure are
deferred. Revisit additional proof tooling only for a demonstrated coverage or
automatic-discharge gap, or when practical use warrants redundancy. No new
prover dependency or Oracle amendment is indicated by the current assessment.

## Recording progress

Each active milestone has a GitHub milestone whose issues carry its work
packages' scope, completion criteria, status and evidence links, as described in
[planning](docs/planning.md). This roadmap records the milestone's purpose,
dependencies, remaining decisions and status changes. When a language capability
becomes supported, update this file, `language.md`, the catalogue and the sample
manifest together, add any construct it completes to the `supported` list in
[rosetta/coverage.json](rosetta/coverage.json), and close its issues. Completed
validation and remaining tool/platform limits are recorded per capability in the
[README's evidence index](README.md#proofs-and-platform-evidence).
Keep proof claims and assumptions in
[docs/assurance.md](docs/assurance.md) and
[docs/trusted-boundary.md](docs/trusted-boundary.md), linking to them here.

Linux is the primary implementation and validation platform. macOS validation
is independent and secondary under the Oracle. Record actual evidence per host.
The owner has disabled GitHub Actions repository-wide and directed local
validation; the retained workflow is dormant and hosted results are not a
required follow-up. On 2026-10-09 the owner added
the [remote repository](https://github.com/berkeleynerd/silver) and authorized
committing outstanding work and pushing the completed history. This publication
does not authorize another language increment.

## History

Completed milestone narratives moved to [docs/roadmap-history.md](docs/roadmap-history.md)
on 2026-10-15. Earlier links to their sections land here:

- <a id="production-solver-allowance--complete"></a>[Production solver allowance — complete](docs/roadmap-history.md#production-solver-allowance--complete)
- <a id="expression-headroom--solver-budget-experiment-complete"></a>[Expression Headroom — solver-budget experiment complete](docs/roadmap-history.md#expression-headroom--solver-budget-experiment-complete)
- <a id="admission-repairs--complete"></a>[Admission Repairs — complete](docs/roadmap-history.md#admission-repairs--complete)
- <a id="focused-source-checks--complete"></a>[Focused Source Checks — complete](docs/roadmap-history.md#focused-source-checks--complete)
- <a id="names-and-calls--complete"></a>[Names and Calls — complete](docs/roadmap-history.md#names-and-calls--complete)
- <a id="branch-review-repair--complete"></a>[Branch review repair — complete](docs/roadmap-history.md#branch-review-repair--complete)
- <a id="completed-foundation-work"></a>[Completed foundation work](docs/roadmap-history.md#completed-foundation-work)
- <a id="lean-critical-path"></a>[Lean Critical Path](docs/roadmap-history.md#lean-critical-path)
- <a id="existing-feature-consolidation"></a>[Existing-feature consolidation](docs/roadmap-history.md#existing-feature-consolidation)
- <a id="equality-guards-and-branches-increments"></a>[Equality, guards and branches increments](docs/roadmap-history.md#equality-guards-and-branches-increments)
- <a id="audit-follow-ups"></a>[Audit follow-ups](docs/roadmap-history.md#audit-follow-ups)
- <a id="completed-increments-and-validation-cadence"></a>[Completed increments and validation cadence](docs/roadmap-history.md#completed-increments-and-validation-cadence)
- <a id="input-dependent-branching"></a>[Input-dependent branching](docs/roadmap-history.md#input-dependent-branching)
- <a id="generalizing-the-existing-features"></a>[Generalizing the existing features](docs/roadmap-history.md#generalizing-the-existing-features)
- <a id="next-goals-after-the-greeting-review"></a>[Next goals after the greeting review](docs/roadmap-history.md#next-goals-after-the-greeting-review)
- <a id="bounded-source-certificate-performance"></a>[Bounded source-certificate performance](docs/roadmap-history.md#bounded-source-certificate-performance)
- <a id="guarded-command-line-greeting"></a>[Guarded command-line greeting](docs/roadmap-history.md#guarded-command-line-greeting)
- <a id="hello-world-with-a-command-line-message"></a>[Hello World with a command-line message](docs/roadmap-history.md#hello-world-with-a-command-line-message)
- <a id="literal-backed-greeting"></a>[Literal-backed greeting](docs/roadmap-history.md#literal-backed-greeting)
- <a id="completed-report-policy-follow-up"></a>[Completed report-policy follow-up](docs/roadmap-history.md#completed-report-policy-follow-up)
