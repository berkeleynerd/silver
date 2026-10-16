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

## Current development sequence

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

**Resumed on 2026-10-16; integration and scope reconciliation first.** The owner
explicitly resumed the same unfinished goal, retaining the settled standard
Integer `'Image` scope. The eleven selected
[review repairs](docs/review-343c2f8-repairs.md) and the
[proof-iteration controls](docs/proof-iteration.md) are complete prerequisites.
Reconcile the preserved feature work with current `main`, then finish the
scope/automatic-proof boundary and continue implementation and assurance in the
order below. Apply the managed proof workflow throughout.
[Session memory](docs/session-memory.md) records this instruction and distinguishes
it from the harness record, which still reports paused because the available
tool has no resume operation. No replacement goal or scope expansion is needed.
[Milestone 1](https://github.com/berkeleynerd/silver/milestone/1) and
[stage #10](https://github.com/berkeleynerd/silver/issues/10) track delivery;
unfinished implementation and proof work remain preserved, not supported.

Ordered work packages:

1. [Report capacity and placement #17](https://github.com/berkeleynerd/silver/issues/17):
   **complete for the currently admitted language**. The
   [capacity repair](docs/report-capacity.md) delivers the source/producer
   envelope, streaming projection, reader/policy correspondence, library-level
   storage and regressions. Re-derive the envelope for scalar, loop and Image
   checks under #13–#16 before their admission.
2. [Scope and automatic-proof boundary #13](https://github.com/berkeleynerd/silver/issues/13):
   apply the settled Integer `'Image` decision to the existing immutable scalar
   and loop fragment, its resource rules, composition/discharge plan and samples.
   This scope work may inform #17; it does not admit the new constructs.
3. [Native admission and regression programs #14](https://github.com/berkeleynerd/silver/issues/14):
   verified SPARK admission/report changes and executable boundary, failure-path
   and interaction regressions.
4. [Universal and actual-source assurance #15](https://github.com/berkeleynerd/silver/issues/15):
   decidable membership, execution/termination, universal safety/discharge and
   correspondence to the actual authoritative source, alongside native work.
5. [Stable validation, review and delivery #16](https://github.com/berkeleynerd/silver/issues/16):
   stable native Linux proof/build/full tests, complete cached Lean checks with
   fresh audit, independent review and synchronized specifications/catalogue/
   Rosetta/evidence before completion and publication.

The [capability record](docs/for-loops-integers.md) specifies immutable signed
32-bit Integer constants, fully grouped `+`, `-` and `*`, comparisons, scoped
forward/reverse loops, and standard Integer `'Image` with its leading space.
The motivating programs are nested Loops/For, Loops/For with a specified step
(constant step times loop index), and Loops/Downward for. Colour bars/Display
now has a faithful image-file assessment requiring future file output.
[Decision #34](https://github.com/berkeleynerd/silver/issues/34) is settled;
its Image length/composition and proof/report consequences remain work under
#13–#16. Mutable integers, custom subtypes, conversions and division remain
excluded from this milestone.

The corrected generated progression has for loops in stage 2, integers/ranged
subtypes/scalar images in stage 3, procedures in stage 4, and arrays in stage 5.
This milestone spans stage 2 and an immutable Integer/Image subset of stage 3;
it does not deliver every integer form or every stage-3 sample. Remaining scalar
forms and ranged subtypes stay on [#11](https://github.com/berkeleynerd/silver/issues/11),
and arrays on [#12](https://github.com/berkeleynerd/silver/issues/12). Procedures
remain the following generated candidate, to receive a stage issue when selected
as a near-term target. The independent Stage 1 sample collection is not a
dependency. A partial work package does not complete this milestone.

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
are selected above; other new capabilities remain unselected.
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

The output target covers admitted literals and bounded command-line
messages; the text `Hello, world!` receives no special treatment. String literals do not imply support for
additional string-variable forms, arbitrary concatenation, indexing, general arrays, access types, or file
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
