# Roadmap history

Completed milestone narratives and finished planning sections, moved verbatim from
[roadmap.md](../roadmap.md) on 2026-10-15 with only their link paths adjusted. Current
direction is in the roadmap; work status is on the Silver board, as described in
[planning](planning.md).

### Production solver allowance — complete

On 2026-10-15 the owner authorized raising application GNATprove's step allowance
from 10,000 to 100,000. The driver and current assurance documentation now agree.
Both retained 64-leaf failures proved with today's runtime and passed their
build/execution probes. The complete native audit, complete cached Lean check,
18 focused driver/report-integrity tests, and real static/dynamic sample command
and execution checks passed on stable inputs. Caches and historical measurements
are preserved. That checkpoint left the 16-leaf/30-concatenation language limits
and compiler-development proof settings unchanged. The
[delivery record](expression-headroom.md#production-adoption) gives exact
validation scope; the subsequent admission expansion is tracked in
[Larger Expressions](../roadmap.md#larger-expressions).

### Expression Headroom — solver-budget experiment complete

On 2026-10-15 the owner authorized retrying the two retained 64-leaf failures
with a larger solver-step allowance before considering language changes or proof
refactoring. The bounded investigation is complete; it does not expand admission.

Fresh sequential 10,000-step controls reproduced both failures. At 100,000 steps,
both exact retained programs proved all 63 Main checks: dynamic in 55.857 seconds,
static in 46.187 seconds. Sampled total process RSS peaked at 1.22 GiB or less.
The previously failing checks used 10,738 and 11,609 normalized Z3 steps. These
were search-budget failures, not demonstrated memory exhaustion. No run reached
its external ten-minute experiment budget.

The result favors a modest solver-budget adjustment as the first candidate for
larger-expression work; these failures do not justify a broad proof refactor or
more RAM. That experiment left the 16-leaf/30-concatenation admission limits and
production solver options unchanged; the later production change is tracked above.
The original retained runtime is historical; production adoption subsequently
completed current-runtime confirmation. Larger-fragment assurance remains required
before any admission expansion.
See the [experiment record](expression-headroom.md) for exact scope and memory
accounting. The broader expression-capacity work is tracked in
[Larger Expressions](../roadmap.md#larger-expressions).

### Admission Repairs — complete

The owner authorized one bounded repair milestone on 2026-10-14 following the
independent assessment of review `e2c4fc2`. It completed on Linux on 2026-10-15,
before further language features. The [delivery record](admission-repairs.md)
tracks the findings, changes and validation. All four parts are complete:

1. Repair assignment compatibility: for a static target of length `T`, require
   the RHS static contribution `S <= T`, with equality when there are no dynamic
   occurrences, even on unreachable paths. Retain reachable-path equality.
2. Repair literal recognition: a final decoded `[` cannot have a closing quote
   immediately followed by an ASCII letter, digit or underscore. Align native
   admission, Lean semantics/source correspondence, specification and catalogue.
3. Close the bounded documentation/test findings, add the checked Names/Compose
   lexical equality guard, and record the existing dense-capacity measurement.
4. Run compact regressions and one full GNAT object-code-generation pass over
   available admitted differential corpora, then one stable Linux native
   proof/build/full-test and complete cached Lean checkpoint. Independently review,
   record exact scope, commit and publish. Preserve caches and review evidence.

Native rule changes, specification/catalogue and bounded regressions are implemented.
The full native audit, all 307 tests, complete 252-module Lean source/model check
and code generation for all 93,007 admitted corpus programs passed. The complete
suite retained identical inputs throughout; the record distinguishes cache reuse,
source rebuilding and the fresh axiom audit. No broader name
resolution refactor, new API, Oracle amendment, corpus-wide GNATprove or per-edit
full-corpus gate is included. macOS, hosted CI and independent replay remain out
of scope.
The larger Names lexical-call adapter remains deferred under the documented
interpretation premise; this milestone's checked helper identities address
the observed duplication without claiming to remove that premise.

### Focused Source Checks — complete

The owner authorized this single bounded performance milestone on 2026-10-14.
Six import-only edits remove accidental source-certificate dependencies while
preserving theorem statements, accepted axioms, exact source correspondence,
complete audit coverage and normal Lake invalidation. No language or Oracle
change is included.

The baseline unrelated-source edit made the composed target stale; the narrowed
target remains cached. Relevant source edits still invalidate their certificates
and checks. All 62 focused tests and the complete 252-module Lean check passed.
The [delivery record](focused-source-checks.md) distinguishes the one-time
904-second composed rebuild, the 7.326-second focused check after an unrelated
edit, and the 129.990-second combined check that rebuilds the changed path proofs.
These are scoped measurements, not a matched whole-build speedup ratio. Existing
caches and still-current native proof evidence are preserved. This milestone
adds no new cache mechanism and does not authorize another language capability.

### Names and Calls — complete

The owner authorized this single bounded delivery on 2026-10-14, completing the
remaining context/name and existing-call association work in items 2, 6 and 7.
The completed language supports reordered/grouped/repeated `with` clauses and
context `use` clauses for the existing shells' packages, resolves qualified and
use-visible calls with Ada's local-name hiding rules, and admits positional and
named `Item`/`Default` associations for the
existing single-parameter operations. Parameterless operations and the sole,
first immutable argument initializer retain their existing meaning and placement.

Matching native admission, inhabited Lean source correspondence and semantic/
discharge proofs, specification/catalogue/sample updates, and admitted/rejected
sibling and compile/run regressions are complete. The Linux checkpoint passed
native proof/build/catalogue checks and complete Lean validation; the
[delivery record](names-and-calls.md) distinguishes the full test run,
certificate-copy repairs, focused final rechecks and cache reuse. New APIs, package renaming,
additional declaration regions and general Ada overload resolution remain separate.
Items 2, 6 and 7 are now closed within their specified fragment. Existing
resource/capacity follow-ups remain explicit below; the source-import performance
follow-up is completed above;
this completion does not authorize a new capability.

### Branch review repair — complete

The owner authorized the bounded response to
[review `4503d17`](reviews/review-4503d17.md) on 2026-10-14, with the
regression scope narrowed to three cases using the existing harness. This
corrective unit preceded the later context/name and call-association delivery.
B1 independently reproduced an admitted, proved static-length mismatch in
an unreachable arm that GNAT could not build; the completed repair restores static
compatibility before further feature work.

| Order | Scope | Completion criterion and status |
| --- | --- | --- |
| 1 | Static assignment compatibility | **Complete:** require equal lengths when both sides have statically known lengths regardless of reachability; retain dynamic path refinement. Align native admission, Lean semantics/source correspondence, specification and catalogue as an explicit pre-1.0 change. |
| 2 | Bounded review follow-up | **Complete:** reject the reported mismatch, compile/run its equal-length sibling and retain a dynamic path-refined assignment compile. Reuse existing tests; no blanket differential-corpus compilation or new framework. Add the identified local token, literal-byte and precedence links; correct restriction purposes, stack/evidence disclosures and stale counts; record the completed dense specimen without rerunning it. |
| 3 | Stable Linux checkpoint and handoff | **Complete:** one stable-input native proof/build/full-test and complete cached Lean/source-correspondence checkpoint, independent diff review, documented dispositions and authorized publication. Preserve caches, scratch and review evidence; independent replay, macOS and hosted CI remain out of scope. |

The [completed checkpoint](branches.md#completed-repair-checkpoint) records
3,049 native checks, 294 tests and complete Lean/source correspondence with a
fresh axiom audit. Historical
language-retention proofs, broad test matrices, informative catalogue-template
declarations and manifest-tag cleanup, stack redesign and unrelated cleanup
remain deferred until the affected area is next touched. This repair changes no Oracle
guarantee and adds no language feature.

### Completed foundation work

**Shared bindings, String expressions, statement sequencing, predicates, path-sensitive branches, and existing context/call rules are complete.**
On 2026-10-12 the owner requested placing all recommended
performance work at the beginning of the roadmap, then authorized the baseline
and declaration-level profiling item. That [measurement](lean-baseline.md)
is complete. Item 2's authorized bounded reconstruction/equality experiment is
also [complete and adopted](lean-join-optimization.md). The authorized
[module/dependency pilot](lean-module-pilot.md) is complete. After reassessing
its scope, the owner authorized a coherent [module migration](lean-modules.md),
which is adopted: the complete proof-edit check fell from 213.6 to 9.6 seconds
while preserving source correspondence and private/transitive audit coverage.
The authorized [selective proof tuning and final integration](lean-proof-authoring.md)
are also complete: one declaration-proof split reduces peak memory, while a
marginal reuse trial is rejected. The bounded performance investigation is closed.
The first consolidation item, the
[restrictions and capacity audit](restrictions-capacity.md), is also
complete. The authorized shared declaration, name and copy foundations have
also passed their [complete checkpoint](shared-bindings.md). Common String
expressions have passed their [complete checkpoint](common-expressions.md).
The owner authorized [statement sequencing and assignment](statement-sequencing.md)
on 2026-10-13. Its complete native/Lean checkpoint passed, including repeated-output
effect composition. The authorized bounded follow-up to
[review `9b99d52`](reviews/review-9b99d52.md) is also complete: current
documentation and focused regressions are repaired, and both selected dense
assignment measurements passed. Their [capacity record](statement-sequencing.md#external-review-and-capacity-follow-up)
discloses costs, report headroom and the then-uncompiled 771-assignment variant.
The [current bounded assessment](branches.md#bounded-5bc-capacity-assessment--2026-10-14)
retains the larger 782-assignment specimen admitted by relaxed guard placement;
the later review completed it with a 2,013,253-byte report (96.0% of the buffer).
The reported 33.6 minutes and 6.1 GiB are specimen measurements, not worst-case bounds.
The owner has authorized delivery of all
[Equality, guards and branches increments](#equality-guards-and-branches-increments).
**All 5a–5c milestones are complete.** Conditional statements (5a) was published
in `dc5295eabe`; predicates and path-sensitive composition (5b/c) passed their
shared complete Linux checkpoint. The [delivery record](branches.md)
distinguishes native proofs, the full-suite run and focused repairs, complete
Lean validation and reused caches. The subsequent
[Names and Calls checkpoint](names-and-calls.md) completes context/name rules
and existing-call associations; new APIs remain separate.

The authorized narrow
[interpretation-witness repair](common-expressions.md#external-review-of-9b72d36)
for review M1 is complete, including the combined concrete model witness and
accurate assurance wording. Existing source-correspondence checks remain intact
and their caches were reused. For M2, add an admitted sibling when a negative
admission rule is next touched, rather than converting the full suite now. Additional source pins,
broader bridge/boundary witnesses, a diagnostic CLI and catalogue/history cleanup
from the review remain deferred until the affected work needs them.

### Lean Critical Path

The [latest completed desktop checkpoint](copy-values.md#physical-linux-checkpoint)
spent 6,010 of 6,234 seconds in `OutputBodyCertificate`; ten unrelated
certificates stayed cached and the fresh axiom audit took 1.36 seconds. These
are retained physical-host measurements, not timings for the current sandbox
or its unfinished proof edit. The generated reconstruction is the first target;
module visibility can separately reduce unnecessary rebuilds after proof edits.

| Order | Work item | Bounded result |
| --- | --- | --- |
| 1 | Baseline and declaration-level profiling — complete | Isolated no-change, proof-only and reconstructed feature-workload checks passed. The profile locates the dominant cost in large reconstruction-join elaboration; the proof-only edit separately exposes unnecessary downstream rebuilding. Host, cache state, timing/memory attribution and limits are in the [measurement record](lean-baseline.md). |
| 2 | Source reconstruction and equality proofs — complete | Adopt checked explicit join witnesses, preserving exact source bytes, final statements and accepted axioms. Complete integration and reconstructed feature-workload checks passed; runner time fell from 130.5 to 14.9 minutes (observed 8.75×, with baseline concurrency caveat). Structural alternatives timed out and remain rejected. The [record](lean-join-optimization.md) covers tests, audits, memory and retained optimized caches. |
| 3 | Module-system pilot and coherent migration — complete | Adopt module boundaries across all 107 ordinary proof files, retaining both legacy audit roots. The same complete proof-only check falls from 213.563 to 9.573 seconds; nineteen ordinary consumers retain their artifacts. Complete source correspondence, fresh audits and public/source-byte invalidation controls pass. The [migration record](lean-modules.md) explains compatibility repairs, scope and retained caches; the [pilot](lean-module-pilot.md) remains historical evidence. |
| 4 | Selective proof-authoring improvements — complete | Adopt twelve separately checked declaration facts in the existing composed-source proof. The matched two-file rebuild falls from 171.569 to 158.564 seconds and peak child RSS from 11.466 to 4.323 GiB. Reject marginal lexical-proof reuse; defer example/tactic rewrites and persistent proof-state infrastructure without a measured need. Statements, source correspondence and axioms are unchanged. See the [proof-tuning record](lean-proof-authoring.md). |
| 5 | Integration and measurement — complete | The final complete cached source-correspondence check and fresh axiom/module audit pass. Independent reviews confirm the measured scope and unchanged dependency artifacts; source-invalidation machinery is unchanged. Preserve all caches and the retained language draft. The [record](lean-proof-authoring.md) distinguishes focused timings, the final checkpoint, rejected work and limits. The bounded performance investigation is closed; the subsequent consolidation is complete within the fragment below. |

The [earlier reconstruction trials](certificate-performance.md) remain
failed/interrupted experiments, not speedup evidence. Their memory constraints
justify a measured retry, not automatic adoption. The 2026-10-12 isolated module
probe on pinned Lean 4.34.1 confirmed proof-only invalidation savings, but also
showed that ordinary module imports can hide unused private declarations from
the audit; a direct `import all` restored detection in that tiny graph. The
subsequent bounded pilot confirms that top-facade `import all` is insufficient
for deeper ordinary imports. Existing legacy roots retain the required coverage.
The later authorized migration retains those legacy roots and demonstrates the
complete-workload benefit. Computational interfaces remain exposed; further
opacity or API redesign is not part of this change.

**10× faster feature feedback is a stretch target.** It is not a promised gain
or a requirement to reject smaller useful improvements. With other costs held
fixed, the retained timings imply roughly 15× faster certificate checking for
10× faster Lean checkpoints; whole-development turnaround needs its own
measurement. Keep theorem statements, accepted axioms, source correspondence
and complete obligation discharge unchanged during performance comparisons.

Lean 4.34.1, cached project artifacts, per-source dependencies, focused checks,
parallel workers and optional separate replay are already in use; preserve them.
Broad `SymM`/`vcgen` migration is deferred until a measured symbolic-execution
hotspot warrants it. `native_decide` and ordinary `bv_decide` do not preserve the
current axiom boundary. Blanket opacity or lower heartbeat limits are not
general speedups. Keep GitHub Actions disabled and validation local; macOS
proof work remains outside this sequence.

A recorded iteration-cost observation from the branch repair was the public
`SourceCertificates` import chain: a path-source byte change also invalidates
`ComposeSourceChecks`, whose own assertions concern other source files. The
[Focused Source Checks milestone](focused-source-checks.md) removes this
accidental dependency, preserving correspondence and normal Lake invalidation.
No import restructuring was part of the earlier repair. Freeze coupled native/proof edits before expensive
source-check builds so isolated lanes do not repeat those checks at integration.

### Existing-feature consolidation

**Shared declarations, expressions and statement sequences are supported.** On 2026-10-12
the owner asked to revisit the implemented capabilities, maximize their useful
scope within the Oracle's automatic Bronze/Silver guarantee, and put this work
ahead of further isolated feature increments. The
[historical assessment](language-generalization.md) records the closure
targets at the Copy String Values baseline. The completed
[restriction audit](restrictions-capacity.md) classifies that baseline's
constructs, records native capacity experiments, repairs the catalogue discrepancy,
and proposes the binding/expression foundation since implemented below.
Those records retain their original scope; current rules are in
[language.md](../language.md).

Here, **closed** means that a feature works throughout an explicitly specified
fragment of the existing constructs, wherever the shared binding, initialization,
length, control-flow and effect rules permit it. It does not mean support for all
Ada/SPARK or a claim to recognize every program that an external prover might
prove. A completed narrow milestone is not evidence of that broader closure.
The bounded consolidation entries below have completed their stated scopes.
Remaining resource extensions and additional APIs are proposals, not admitted syntax.

| Order | Work item | Required result before calling the area closed |
| --- | --- | --- |
| 1 | Restrictions and capacity audit — complete | The [audit record](restrictions-capacity.md) inventories all constructs and restrictions by origin, records dense native source/translation/report experiments and their limits, and verifies the catalogue consistency repair. Capacity observations do not establish a universal bound or admit the proposed fragment. |
| 2 | Declarations, names and copies — complete | Shared binding rules for finite declaration lists, initialized constants and mutable objects, and copies from earlier initialized values. Track case-insensitive uniqueness, mutability, value snapshots and fixed bounds; remove the incidental one-variable/two-constant slot restrictions. The [Names and Calls checkpoint](names-and-calls.md) completes context-clause order/grouping/repetition, qualification and visibility for the existing packages together with item 7. |
| 3 | String expressions — bounded fragment complete | Shared literals, names, concatenation and parentheses in initialization, assignment, comparison and output, with repeated dynamic occurrences and every intermediate bound. The [original checkpoint](common-expressions.md) established the sixteen-leaf/thirty-operator fragment. [Larger Expressions](larger-expressions.md) completes universal/source proofs, native validation and composition/capacity measurements for the current sixty-four-leaf/sixty-three-operator limits. |
| 4 | Statement sequencing and assignment — complete | Finite sequences of the admitted null, assignment, output and conditional statements. Compatible expression assignments, multiple initialized objects and self-copy work wherever state rules permit; preserve initialized reads and each target's fixed bounds. Classify harmless diagnostics precisely without suppressing safety obligations. |
| 5 | Equality, guards and branches — complete | Specify the supported String-equality and validity/length predicate grammar and its Boolean compositions. Admit finite nested conditionals under shared rules; propagate path facts and establish initialization and bounds at joins instead of enumerating whole-program arrangements. Preserve `and then` evaluation order and make only established path facts available to each operand. Resolve integer-literal spellings, including separators and based notation, representable bounds and overflow-safe parsing. All three [increments](#equality-guards-and-branches-increments) passed their checkpoints; the [delivery record](branches.md) retains exact evidence and scope. |
| 6 | Output effects — complete | Compose output in those sequences and branches, including repeated calls and output interleaved with assignments. Prove the cumulative trace and continued attempts after returning failures, with sticky failure status. Derive size bounds from the actual sequence and per-call contract; no separate four-call limit. Positional and named `Item` associations for `Put_Line` passed the [Names and Calls checkpoint](names-and-calls.md). [Partial Output](partial-output.md) extends those rules and effects to `Put`, with no appended LF and a flush on every call. |
| 7 | Existing argument operations — complete | Compose the existing initialization, validity and rejection operations with those declarations, expressions and statements. Make required validity facts and rejection effects explicit; preserve actual returning-call semantics and the specified argument domain. The [Names and Calls checkpoint](names-and-calls.md) completes positional/named `Default` associations and context/name rules with item 2. The immutable argument initializer remains first and unique; new positional-argument APIs are a separate capability. |

The authorized [shared-binding milestone](shared-bindings.md) implements
ordered literal/name declarations, snapshots, mutability, compatible static or
dynamic-length copies and self-copy within the existing body shapes. It removes
the fixed declaration slots and mandatory assignment-target output use. Its
complete native/Lean checkpoint and independent review passed.
The native 341-slot capacity derives from the 4096-byte source limit and the
minimum twelve-byte declaration; it is not another arbitrary count restriction.

Items 2 and 7's context-clause order/grouping and visibility closure is complete
in Names and Calls. The sole immutable argument initializer stays first and unique;
additional API placements are not implied by supported statement sequencing.
Expression initializers and parentheses are now supported by the completed
[common-expression checkpoint](common-expressions.md), including expression
equality and fixed-length expression assignment. The completed item 5 adds
path-refined assignments, nested predicates and generalized validity/Reject
placement. The completed **statement sequencing and assignment** work includes
repeated-output effect composition from item 6; its [record](statement-sequencing.md)
retains the original fixed-guard checkpoint. Names and Calls completes context/name
closure and call associations for the existing operations. The retained operator budget counts
concatenations; it does not bound total translation time, memory or report size.
The recognizer's source comment now describes only that lexical budget, so the
older wording follow-up is closed.

These are dependency priorities, not seven isolated implementations. Shared
declaration, expression and statement rules should replace the need to enumerate
another complete-program template for every combination. Develop coupled rows
together where their interactions require it. Build reusable binding,
expression, statement and effect theorem interfaces as these foundations are
implemented; measure their reduction in proof duplication and feature-edit work.
This carries the shared-rule performance recommendation into the language work
without a separate core-language or proof-framework redesign. Literals,
escaping, comments, whitespace and case-insensitive names already vary throughout their declared
lexical domain; preserve that coverage in the generalized grammar.

As admission is generalized, carry source-derived library requirements and
verification policies consistently into library snapshots, project construction
and expected entity, dependency and proof coverage. Required coverage must remain
independent of whichever records happen to appear in a report. Extend policies
for obligation classes generated by the supported fragment, retaining rejection
of missing, skipped, suppressed or unproved required checks and the documented
external-tool premises. This does not prescribe a new parser or driver architecture.

For the syntax decisions above, record supported alternatives or justified
exclusions within the existing fragment. They do not imply additional library
operations or general arithmetic. These clarifications incorporate the useful
findings from the [remote-plan review](remote-plan-review.md) into the
existing sequence.

#### Equality, guards and branches increments

On 2026-10-13 the owner authorized all three increments through delivery, pausing
only for a genuine stop condition requiring the operator. Implement conditional
structure first, followed by predicates and path facts; the latter may share one
checkpoint. Routine implementation/proof failures require continued work, not
another approval. Escalate a needed Oracle amendment, conflicting requirements,
or unavailable external resources with no sound authorized workaround. The
[delivery record](branches.md) tracks decisions, evidence and the completed
checkpoints. All three increments below are now supported.

| Order | Increment/status | Scope and completion criteria |
| --- | --- | --- |
| 5a | Conditional statements — complete | Nested String-equality conditionals, `elsif`, optional `else` and nonempty written arms, preserving the outer input guard and source/expression budgets. Recursive native semantics, inhabited source correspondence, selectors and the complete Linux checkpoint passed; [evidence](branches.md#completed-5a-checkpoint--2026-10-14) records native audit, test repair, warm Lean check and retained failures. |
| 5b | Predicate and literal grammar — complete | String equality/inequality, validity and Length comparisons compose with grouped short-circuit logic and `not` primaries. Decimal/based integer literals, separators, matching delimiters and bounded exponents preserve Ada meaning with overflow-safe parsing. Predicate meaning, safe evaluation, actual source correspondence, literal/operand boundaries, catalogue and samples passed the [combined checkpoint](branches.md#completed-5bc-checkpoint--2026-10-14). Supported alternatives and exclusions are explicit in the language specification. |
| 5c | Path-sensitive composition — complete | Branch facts justify bounded expressions and fixed-bound assignments; static/static assignment lengths must also agree on unreachable paths after the review repair; joins preserve only justified interval/validity/rejection facts. Invalid inputs reject without output, and Reject/output failures return with sticky failure status. The simultaneous concrete source-model witness, native selector refinements, universal discharge and source correspondence passed the [combined checkpoint](branches.md#completed-5bc-checkpoint--2026-10-14), with interaction and rejection tests. |

Items 5b and 5c shared one complete checkpoint, preserving both scopes. Together
with the published 5a checkpoint, they close item 5. The later Names and Calls
checkpoint completes context/name closure and positional/named call associations
in items 2, 6 and 7. New argument APIs
retain their separate roadmap placement; this completion does not authorize them.

#### Audit follow-ups

The restriction audit is complete. These findings retain the following
completed scope and remaining follow-ups within the existing items. The [native findings](restrictions-capacity.md#native-measurements-and-integration)
retain the sources, results and limitations. All extensions still require the
complete assurance and validation described below.

| Finding | Work items | Required follow-up |
| --- | --- | --- |
| New length-check obligations | 2: bindings/copies; 4: assignment | Shared bindings completed the range/length policy, fixed-bound copy argument and actual-source/native/Lean checkpoint. Item 5 completed path-refined assignments and their source/native/Lean integration. Preserve complete coverage, approved dependencies and rejection of unproved or suppressed checks. |
| Repeated-output ghost advisories | 4: sequencing; 6: output effects | Sequencing implements precise classification of the observed `INEFFECTIVE` advisories for `Written_Count`, `Flushed`, `Succeeded` and `Written_Bytes`. These concern overwritten/unused ghost outputs and differ from the precisely classified initializer/unused-assignment messages in the shared-binding policy. Retain all safety obligations and cumulative effect semantics; do not accept warnings indiscriminately. |
| Dynamic-expression solver limit | 3: expressions | The [step-budget experiment and adoption](expression-headroom.md) resolved both retained failures; production uses 100,000 steps. [Larger Expressions](larger-expressions.md) completed universal/source and native assurance, composition probes and dense report-capacity validation for the current 64-leaf/63-operator fragment. External solver completion remains a documented premise; successful specimens are not universal solver-time bounds. |
| Dense proof cost and report capacity — bounded follow-up complete | 3: expressions; 4: sequencing; 6: output effects | Sequencing probes justified a separate 2 MiB application buffer. Both the static 800-assignment and alternating argument-input 769-assignment cases completed within it; the latter leaves 5.4% headroom. The [sequencing record](statement-sequencing.md) discloses measured costs. The [bounded 5b/c reassessment](branches.md#bounded-5bc-capacity-assessment--2026-10-14) records the completed 782-assignment specimen. The later [785-assignment specimen](names-and-calls.md#dense-assignment-review-evidence) proved all 829 checks, with a 2,020,723-byte report (96.36%), 76,429 bytes remaining and reviewer-measured 32-minute compilation. The [Larger Expressions dense case](larger-expressions.md#dense-composition-and-report-capacity) then combined 758 assignments with 63 concatenations and passed with 1.5% report headroom. Reconsider the envelope before changing the producer, report format or admitted fragment. These observations are not universal bounds; complete producer/report capacity and solver completion remain explicit tool premises. No arbitrary call cap or report truncation is introduced. |

### Completed increments and validation cadence

[Input-dependent branching](input-branching.md),
[Compose String Results](string-results.md) and
[Copy String Values](copy-values.md) passed their complete Linux checkpoints.
Their supported scopes remain those in [language.md](../language.md); the historical
milestones below do not imply full closure of their underlying features.

The [source compartmentalization](lean-compartmentalization.md) and
[focused Lean runner](lean-iteration.md) are complete. Use focused checks
during development and batch complete source-correspondence checks at stable
checkpoints, preserving caches and running inputs. Optional independent replay
and further certificate infrastructure are not prerequisites for this work.

## Input-dependent branching

**Supported**, following owner authorization on 2026-10-10.
The [capability record](input-branching.md) records the obligation experiment,
implementation, source correspondence and completed full Linux validation:

```ada
with Silver_IO;
with Silver_Arguments;

procedure Main is
   pragma SPARK_Mode (On);

   Mode : constant String :=
     Silver_Arguments.First_Or_Default ("brief");
begin
   if Silver_Arguments.Input_Is_Valid then
      if Mode = "verbose" then
         Silver_IO.Put_Line ("Silver is ready. Input validation succeeded.");
      else
         Silver_IO.Put_Line ("Ready.");
      end if;
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

Admit one immutable command-line String using the existing missing/default,
empty-input, printable-byte and size rules. Inside the mandatory validity
guard, compare the bound name to an admitted literal with predefined String
`=` and select exactly one of two literal-output branches. Comparison is
case-sensitive byte equality; identifier binding remains case-insensitive.
The default, comparison literal and output literals vary over the existing
domain, rather than assigning special meaning to `brief` or `verbose`.
Unequal-length operands simply compare false. Invalid input still reaches the
terminal rejection branch, and each successful path makes one terminal output
call with the existing failure semantics.

This added runtime choice without a new library API. The subsequent sequencing
increment supports branch assignments, multiple outputs and finite sequences
under shared rules. The later predicates and path-sensitive milestone also
supports bounded Boolean compositions and nested decisions. The original milestone's focused native obligation
experiment covered empty strings, unequal lengths, case differences and
maximum-size sources and confirmed the strict empty-Main report policy. Exact
membership, branch meaning, binding, complete obligation handling and actual
source correspondence passed the full Linux checkpoint. Existing caches and
evidence were preserved; hosted CI remains disabled and macOS proofs are a
non-goal for this work.

## Generalizing the existing features

The original 2026-10-10 assessment led to bounded output expressions, tighter
capacity guards, branch-selected results and compatible constant copies. Those
increments are supported within their documented scopes. The
[assessment record](language-generalization.md) preserves that history,
including the 2026-10-12 review of the composition gaps at its recorded baseline.
The current consolidation status is above.

The [consolidation priority](#existing-feature-consolidation) supersedes the earlier
recommendation to keep repeated assignments, more bindings and repeated dynamic
references as separate later candidates. Consolidate them through shared rules
for the existing fragment. The older staging choices are not evidence that
their restrictions are required by the assurance target.

## Next goals after the greeting review

Originally recorded on 2026-10-09 while external review of `a73f85e` was pending.
That review is now assessed in the
[greeting record](greeting.md#external-review-and-native-macos-validation),
with no blocking finding. The owner authorized the combined remit on 2026-10-09,
and both implementation units are complete. Address independently confirmed
correctness or assurance defects before further language expansion. Review
suggestions do not automatically require new infrastructure or approval gates.

The completed order was a bounded source-certificate performance pass, then
the guarded command-line greeting with report-policy functional refinement.
Neither performance candidate established an improvement; the original
representation remains. The feature passed complete native validation and
independent review without an Oracle amendment. Further work needs its own
owner-authorized scope. The fifth-form implementation baseline is `a73f85e`; the reviewed
documentation handoff is `fee3afe`.

### Bounded source-certificate performance

**Completed investigation:** neither of the two candidates established a
validated improvement. Retain the existing representation; no third approach is
authorized. The [performance record](certificate-performance.md) distinguishes
failed and interrupted trials from successful validation. The investigation
raised the CI Lean allowance to 120 minutes without measuring hosted capacity.
The retained workflow is now dormant at the owner's direction; validation runs
locally.

The owner separately authorized [Lean scheduling and concurrency tuning](lean-concurrency.md)
on 2026-10-10. That work uses the existing proofs and certificate representation;
it does not reopen the two-candidate representation investigation or authorize
another language capability.

The following records the bounded investigation scope.

The [greeting evidence](greeting.md) identifies a substantial cost in the
enlarged recognizer certificate. Its timings overlapped other probes, so they
motivate investigation without constituting a controlled benchmark. Caching
already works; this task concerns rebuilding changed source certificates.
The external review also identifies a capacity risk in the configured CI Lean
job's former 60-minute timeout. Hosted CI had not run at that planning checkpoint,
so a timeout was not established.
That assessment included job-budget headroom before the first hosted run;
a larger timeout alone would not improve proof feedback.

- Establish a comparable baseline on fixed current source bytes and pinned
  tools on Linux ARM64. Record certificate and full-replay phase times, peak
  memory, artifact size and warm-cache behavior. Keep measurements in the
  evidence record, not as machine-dependent language acceptance thresholds.
- Limit implementation candidates to reconstruction lemmas, proof terms and
  their generator. The current reconstruction tree is already balanced. Large
  character-list conversions are a candidate bottleneck; the earlier raw-byte
  experiment was unsuccessful and is not a ready solution.
- Run heavy experiments separately in native-host workspaces with explicit
  time and memory budgets based on the baseline and available resources.
  Preserve normal caches and other hosts' state; use parallel work where the
  memory budget permits it. Trial budgets do not change proof acceptance policy.
- Preserve exact authoritative bytes, checked lexing and source correspondence,
  source-change cache invalidation, the fresh axiom audit and independent kernel
  recheck. Adopt only a successfully checked improvement that exceeds ordinary
  measurement variation without a material memory regression. No new trusted
  shortcut, source/runtime/language change or general certificate framework.

Completion means a measured decision after at most two candidate approaches.
A successful candidate must pass focused generation, mutation and cache tests,
full Lean validation and ordinary semantic review before a local commit. If
neither improves matters, retain the implementation and record the findings;
stop that investigation rather than extending it into an open-ended redesign.
The authorized language implementation follows that bounded decision.

### Guarded command-line greeting

**Supported**, after authorization on 2026-10-09 and the bounded performance
decision. The sixth complete production combines command-line initialization
with an explicit capacity guard and one prefix/name/suffix concatenation:

```ada
with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Name : constant String := Silver_Arguments.First_Or_Default ("world");
begin
   if Silver_Arguments.Input_Is_Valid
     and then Name'Length <= 4088
   then
      Silver_IO.Put_Line ("Hello, " & Name & "!");
   else
      Silver_Arguments.Reject;
   end if;
end Main;
```

The capacity must equal 4096 minus the decoded prefix and suffix lengths; the
example therefore reserves 4088 bytes for `Name`. Only this use of `'Length`,
`<=`, canonical decimal and `and then` is admitted. Both references bind to the
same constant. Missing input selects the default; empty input prints the
decorations; invalid, extra, oversized or over-capacity input returns status 1
without output. The [language specification](../language.md#command-line-initialization-and-path-requirements)
contains the exact rules.

The obligation experiment exposed a String lower-bound requirement for empty
prefixes. The owned SPARK initializer now constructs one-based results and
proves that bound while preserving bytes. Lean checks admission, typed Main
meaning, source correspondence, output bounds and a finite range-obligation
decision procedure. Concrete GNAT obligation generation and pinned prover
completion remain explicit external-tool premises. Every emitted application
and selected-library check is audited. SPARK proves executable report acceptance
equivalent to independent ghost policies.

The [capability record](command-line-greeting.md) records complete Linux
validation, review, resource-option repair and preserved tool failures. The
[external review disposition](command-line-greeting.md#external-review-disposition)
assesses the feature review with no surviving blocking, high- or medium-severity
finding and records five documentation clarifications. Its reported native macOS
results remain optional external evidence; obtaining or corroborating their raw
logs is not a pending requirement. Additional routing assertions, layout tests
and an exact-sample theorem are deferred without a demonstrated correctness gap.
Subsequent host validation, evidence recovery and the owner's decision to
validate locally with hosted CI disabled are recorded in
[host readiness](host-readiness.md).
Reassignment, mutable strings, repeated references, general expressions/conditionals
and a new output API remain outside that completed increment. The owner
subsequently authorized the fixed-length assignment increment recorded above.

## Hello World with a command-line message

Recorded on 2026-10-08 and **authorized for implementation on 2026-10-09**.
The preceding review repairs are complete in `251dd85`. Named strings are
supported in `2f76b20` with [complete Linux evidence](named-strings.md).
Guarded command-line input is also supported; its
[capability record](command-line.md) records the completed compiler audit,
tests, Lean replay and independent kernel recheck, with actual platform scope.

The two increments are:

1. A named `constant String` initialized from a string literal, then passed
   to `Silver_IO.Put_Line`, with case-insensitive whole-name binding.
2. Initialization by `Silver_Arguments.First_Or_Default`, followed by the fixed
   `Input_Is_Valid` guard. The true branch prints the constant; the false branch
   calls `Reject` and returns with status 1 and no application output.

The command-line sample contains:

```ada
Message : constant String :=
  Silver_Arguments.First_Or_Default ("Hello, world!");
```

and the complete body:

```ada
if Silver_Arguments.Input_Is_Valid then
   Silver_IO.Put_Line (Message);
else
   Silver_Arguments.Reject;
end if;
```

A missing argument uses the default. One printable ASCII argument of at most
4096 bytes is preserved, including an explicitly empty argument. Extra arguments,
unsupported bytes and oversized input are unsuccessful without truncation.
The pure initializer returns an internal empty value for invalid input; the
required false branch never prints it. Both queries observe the same immutable
argument vector. The focused experiment selected this design because SPARK
rejects a side-effecting function in a constant initializer. Only this complete
guard composition is admitted.

Runtime initialization fixes the object's length from its initial value.
Reassignment, concatenation, mutable strings, general arrays, access types,
arbitrary conditionals and general command-line package access remain outside
that completed task. Literal-backed greeting is now supported below;
guarded command-line concatenation is now supported above.
The owner authorized the first statically compatible assignment composition on
2026-10-10: exactly one literal-initialized variable, one literal assignment of
equal decoded length, then output by the same name. The
[capability record](string-assignment.md) tracks its implementation and
assurance. Further assignment forms remain later work.

The implementation reuses the approved GNAT argument imports beneath a verified
SPARK wrapper. Application reports remain empty; selected owned libraries have
complete nonempty reports. The source bridge covers the recognizer and argument
wrapper, with immutable argv and runtime ABI semantics documented as trusted
premises. The sample manifest records default, empty, valid and rejected input
cases. At that checkpoint, passing arguments required invoking the compiled
application directly; [Run Arguments](../roadmap.md#run-arguments) supplies the later CLI
convenience. No Oracle amendment.

## Literal-backed greeting

Completed in `a73f85e`, following authorization on 2026-10-09 and repair commit
`54844c5`. The motivating application declares a literal-backed `Name` constant
and calls `Silver_IO.Put_Line ("Hello, " & Name & "!")`.

The capability admits arbitrary existing-domain literals for the initializer,
prefix and suffix, with exactly one reference to the constant. The sum of their
decoded lengths is bounded by their consumption of the complete source. The
completed work includes a genuine GNATprove obligation experiment, SPARK
recognition, Lean admission/composition/source correspondence, catalogue/specification
and sample updates, boundary and rejection tests, and full native validation.
The [capability record](greeting.md) retains the evidence and replay costs.
Literal contents receive no special treatment.

Repeated references, literal-only or arbitrary concatenation expressions,
additional declarations and assignment remain excluded. The completed
[command-line greeting](#guarded-command-line-greeting) adds an explicit capacity
guard before constructing its output; the earlier argument-validity guard alone
does not reserve space for a prefix and suffix.

## Completed report-policy follow-up

The guarded-greeting increment closes the identified functional-refinement gap
in `Silver_Library_Reports`. Independent Static ghost byte traversal and complete
report policies specify coverage, dependencies and discharge; SPARK proves exact
acceptance equivalence for selected runtime and dynamic Main reports. Shared
elementary predicates do not replace the independent traversal and policy.
See [the assurance scope](assurance.md#selected-library-sources-and-evidence)
and [completed evidence](command-line-greeting.md).

Faithful complete GNAT obligation generation and pinned prover completion on the
concrete arithmetic fragment remain explicit external-tool premises. The new
Lean decision procedure proves universal validity of the admitted range schemas;
it does not verify the bundled solver implementations or their configured step allowance.
No additional solver, certificate framework or adversarial report authentication
was introduced. Additional tools still need an identified coverage gap.
