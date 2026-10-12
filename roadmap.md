# Silver roadmap

## First priority: audit and complete the existing language

On 2026-10-11 the owner directed that the existing constructs be audited against
the revised [Oracle](oracle.md) before any new work resumes. This queue takes
priority over all later roadmap sections. Finish its audits and necessary
repairs before starting unrelated feature, performance or infrastructure work.
Completing combinations of already implemented constructs belongs to this queue;
it must not be deferred as unrelated language expansion.

All items below are **queued**. Work in the listed order, implementing tightly
coupled items together where needed and recording each item's outcome. In
particular, call admission and library failure semantics must be settled
together; later construct work must keep the shared frontend and report policy
complete. An unchecked item is not complete merely because its motivating
sample works. This entry records the work queue; it does not claim that any
audit or implementation repair has already been performed.

For each item, identify all applicable semantic cases and combinations with
other admitted constructs. Implement them or record an explicit restriction
with a semantic, safety or verification justification. Remove restrictions
based only on templates or implementation convenience. Complete the relevant
GNATprove checks and composition/boundary/failure regressions, and reconcile the
specification, catalogue, implementation and samples under the
[development workflow](development.md). A documented, justified no-change
finding can close an audit; an unresolved case or unproved required obligation
cannot. Record evidence and any remaining limitations beside the completed item.

Migrate tests alongside each audit: replace template-only rejection expectations
when the corresponding cases become supported, and retain negative tests for
justified exclusions and incomplete verification. Keep independent expected
output/exit-status checks and checks of genuine GNATprove reports; catalogue
parity alone does not establish correctness. Extract shared test helpers as
needed while touching those tests. Preserve the relevant SPARK contracts and
source/library identity checks throughout the refactoring.

- [ ] **A01 — Compositional admission and catalogue.** Replace the six
  whole-program template alternatives with rules for declarations, expressions,
  statements and their combinations. Make catalogue entries describe those
  rules rather than fixed sample layouts, occurrence counts and operand lists.
  Use shared declaration, expression and statement parsing, with a structured
  admission result describing the program's constructs and required library
  interfaces. Replace the driver's `Output_Mode`/`Dynamic_Mode` template switches
  with that information, carried consistently through library snapshots,
  project construction and expected proof coverage. Share applicable construct
  metadata with catalogue export. Begin with this frontend-to-driver interface,
  coordinating A03 so broader admission receives the correct verification.

- [ ] **A02 — Lexical rules and implementation resource limits.** Audit source
  encoding, comments, whitespace, case folding and token boundaries. Separate
  semantic restrictions from source/report buffer capacities and parser nesting
  or recursion limits; justify and clearly diagnose each retained bound.
  Preserve scanner safety and termination without treating the 4096-byte source
  capacity as a general requirement of SPARK Silver.

- [ ] **A03 — General application proof-report acceptance.** Remove the
  empty-obligation, range-check-only and fixed Main/entity-set assumptions.
  Consolidate the legacy empty-report recognizer and the structured report
  reader into one structured parser, separating report decoding from application
  and library acceptance policies.
  Determine relevant units, entities and required coverage from the actual
  program and selected libraries; do not infer expected coverage solely from
  whichever records happen to appear in a report. Accept all applicable
  discharged obligation classes while rejecting missing, skipped, suppressed,
  assumed or unproved required checks. Update report-shape assertions in tests
  alongside these policies, retaining independent coverage and failure checks.
  Keep this policy current throughout A04–A20.

- [ ] **A04 — Main procedure body.** Audit entry-point naming, matching end
  names, the parameterless interface, declarative-part placement and executable
  body composition. Distinguish entry-point requirements from parser shortcuts.
  State the boundary with additional units, nested subprograms and exception
  handlers without implying that those future constructs are implemented.

- [ ] **A05 — SPARK mode pragma.** Audit the placement and scope of
  `pragma SPARK_Mode (On);` across the admitted program structure. Preserve the
  Oracle's explicit pragma policy and ensure that no admitted application body
  escapes the required SPARK analysis.

- [ ] **A06 — Context clauses and qualified names.** Audit `with Silver_IO;`
  and `with Silver_Arguments;`, their order, grouping and relationship to actual
  uses. Settle qualification, visibility and name resolution; justify any
  retained exclusions rather than requiring one context layout per sample.

- [ ] **A07 — Null statements.** Support `null;` in each applicable admitted
  statement context, including sequences and conditional branches. Remove the
  sole-statement and no-output-combination restrictions; verify unchanged Ada
  no-op behavior and complete report handling.

- [ ] **A08 — String literals and String values.** Audit empty values, doubled
  quotes, character-domain restrictions, literal case and every applicable
  admitted expression context. Settle String bounds and initialization while
  keeping source capacity, value bounds and library output limits distinct.

- [ ] **A09 — Named constants and identifier binding.** Audit multiple
  declarations, initializer expressions, declaration/reference ordering,
  repeated references and reuse across statements and expressions. Settle
  identifier legality, case-insensitive binding, visibility and reserved or
  runtime-name exclusions. Remove the one-constant and one-use shortcuts.

- [ ] **A10 — Procedure-call syntax and statement sequencing.** Audit repeated
  calls, mixed statement sequences, argument expressions, parameter association
  forms, evaluation and every applicable admitted statement context. Cover
  both `Put_Line` and `Reject`; complete their effect and failure semantics with
  A11–A12 before declaring the generalized call feature supported.

- [ ] **A11 — Put_Line behavior under composition.** Settle repeated output,
  ordering, LF/flush behavior, empty and oversized values, partial output and
  detected write/flush failure. Specify what subsequent statements do after a
  failure and ensure that later successful calls cannot falsely report overall
  success. Audit per-call contracts and any program-wide status requirements.

- [ ] **A12 — Reject behavior under composition.** Audit the returning
  `Silver_Arguments.Reject` procedure outside the fixed terminal else branch.
  Specify repeated rejection, execution before or after output, process status
  and subsequent execution. Distinguish the procedure's own lack of output
  from claims about all output produced by the program.

- [ ] **A13 — First_Or_Default function calls.** Audit repeated calls, argument
  expressions and every applicable admitted expression/initializer context.
  Cover missing, empty, valid, extra, oversized and unsupported-byte arguments,
  default handling and returned String bounds. Separate this operation's API
  contract from the current single-initializer template.

- [ ] **A14 — Input_Is_Valid function calls.** Audit repeated evaluation and
  use throughout admitted Boolean expression and control-flow contexts. Verify
  consistency with `First_Or_Default`, including the immutable argument-vector
  assumption and all argument outcomes. Remove dependence on one prescribed
  guard spelling or call position.

- [ ] **A15 — String concatenation.** Audit operand counts and ordering,
  repeated constant references, literal-only expressions, nested expressions
  and parentheses using admitted operand forms. Establish intermediate/final
  bounds from the actual expression and GNATprove checks rather than the
  literal/name/literal template or one-use source-consumption argument.

- [ ] **A16 — Conditional statements.** Audit conditions built from admitted
  expressions, branch sequences, nesting and applicable Ada conditional forms.
  Settle initialization, effects and safety facts on every path, including
  paths that make no output call. Replace the fixed output/rejection branches
  with justified composition rules shared with A17–A20.

- [ ] **A17 — Short-circuit and then.** Audit combinations and nesting of
  admitted Boolean operands, parentheses and interaction with conditionals.
  Preserve Ada evaluation order and establish which safety facts are available
  only after the left operand succeeds; remove the prescribed two-operand
  validity/capacity layout.

- [ ] **A18 — String Length attribute.** Audit `'Length` on applicable admitted
  String names/expressions and in applicable admitted expression contexts.
  Cover empty and nonempty bounds, repeated use and interaction with function
  results, comparisons and concatenation; remove confinement to one guard.

- [ ] **A19 — Less-than-or-equal comparison.** Audit `<=` across applicable
  admitted operands, typing and numeric bounds. Accept sufficient safety
  conditions without requiring the capacity literal to equal the maximum value
  encoded by today's template; settle stricter bounds and combinations with other admitted
  Boolean expressions.

- [ ] **A20 — Integer literals.** Audit applicable Ada integer-literal spellings,
  resolution, representable bounds and overflow-safe parsing. Justify any
  restrictions on separators or based notation; remove the canonical-decimal
  shortcut unless supported by a real language-policy reason. Distinguish
  literal syntax from separately unimplemented arithmetic operators.

- [ ] **A21 — Combined composition audit and completion review.** Recheck the
  full interaction matrix after A01–A20, including repetitions, nesting,
  boundary values and failure paths. Confirm catalogue/specification parity,
  source admitted/verified/compiled identity, selected-library coverage and
  actual native behavior. Update support claims to match the completed audits.
  Only then resume unrelated new work.

Loops, general user-defined subprograms and recursion, mutable variables and
assignment, general arithmetic, indexing and additional compilation units remain
future admissions. Do not start those features while this queue is outstanding.

## Existing implementation and earlier milestones

Silver grows through useful capabilities motivated by runnable examples. The
[Oracle](oracle.md) governs the guarantees; [language.md](language.md) and the
[catalogue](catalogue/silver.json) specify what is supported today. This roadmap
records proposals, not implicit authorization or admission of new syntax.

Before 1.0 there is one evolving language. Intentional changes must keep the
specification, catalogue, compiler and examples consistent. GNATprove verifies
actual applications and owned SPARK implementations; reviewed Ada/SPARK
restrictions guide language growth. See [development.md](development.md).

## Status and admission

New capability milestones move from proposed to in progress to supported. A supported capability
has explicit source and composition rules, matching implementation/catalogue,
complete GNATprove evidence, native boundary validation and a manifest sample.
A sample exercises the rules; it does not define them or prove a universal
language theorem. An additional proof assistant is not an admission gate.

## Baseline milestones

The language entries below describe the implemented fixed-form baseline. Their
new-Oracle audits remain pending in the priority queue above; past validation
does not establish complete compositional support.

| Milestone | Status | Scope and evidence | Sample |
| --- | --- | --- | --- |
| Null baseline | Implemented; audit pending | One parameterless Main, SPARK mode and null statement. | [null](samples/null.adb) |
| Faster proof feedback | Supported | Incremental GNATprove, native solver caches and explicit full/cold audits; [workflow](docs/proof-workflow.md). | Developer workflow |
| Sample collection | Supported | [Manifest](samples/manifest.json) drives admission, proof, build and execution checks. | All supported samples |
| Literal output | Implemented; audit pending | One qualified call and printable ASCII literal; [evidence](docs/hello-world.md). | [hello_world](samples/hello_world.adb) |
| Named string | Implemented; audit pending | One literal-initialized immutable String and matching output reference; [evidence](docs/named-strings.md). | [string_constant](samples/string_constant.adb) |
| Command-line message | Implemented; audit pending | Pure initializer, mandatory validity guard and rejection branch; [evidence](docs/command-line.md). | [command_line](samples/command_line.adb) |
| Literal-backed greeting | Implemented; audit pending | Prefix, one constant reference and suffix joined by predefined String concatenation; [evidence](docs/greeting.md). | [greeting](samples/greeting.adb) |
| Guarded command-line greeting | Implemented; audit pending | Capacity guard, one-based runtime result and complete application reports; [evidence](docs/command-line-greeting.md). | [command_line_greeting](samples/command_line_greeting.adb) |

The assurance-method cleanup does not change these six complete source forms.
Repeated statements and broader uses of the existing operations are now part of
the priority audit/repair queue. User-defined subprograms and other unimplemented
construct families remain future language work. No fixed universal call-count or
recursion-depth limit is proposed here.

## Guarded command-line greeting

The sixth form combines `First_Or_Default` with the fixed short-circuit condition
`Input_Is_Valid and then Name'Length <= capacity`, followed by one
prefix/name/suffix output or `Reject`. Capacity equals 4096 minus the decoded
prefix and suffix lengths. Only the specified attribute/comparison/conditional
composition is admitted.

The obligation experiment exposed a String lower-bound requirement for empty
prefixes. The owned initializer now returns a one-based String and proves that
postcondition while preserving its bytes. Every emitted Main range check and
selected-library obligation must discharge. Complete report handling permits
frontend optimization to vary the actual count without suppressing obligations.

The [capability record](docs/command-line-greeting.md) records native Linux ARM64
validation; [host readiness](docs/host-readiness.md) records later Linux x86-64
validation. Native macOS validation of this form remains independently pending.

## Output design and next increments

`Silver_IO.Put_Line` is verified SPARK over existing libc `putchar` and `fflush`
and GNAT's returning status setter. A detected failure sets status 1 and returns;
partial output is possible. Current application branches are terminal.
Repeated calls require a deliberate failure-propagation design as well as
expanded source and composition rules. See the
[output boundary](docs/trusted-boundary.md#literal-output-boundary).

The current source bound is 4096 bytes. Strings do not imply arbitrary arrays,
indexing, access types, variables or file handles. Broader statements, callable
subprograms, mutable values and APIs need explicit scope and GNATprove-supported
implementation. Forwarding application arguments through `silver run` is a
separate convenience; compiled applications currently accept them directly.

## Hello World with a command-line message

Completed following authorization on 2026-10-09: named literal constants and
then guarded command-line initialization. Missing input selects the default;
one printable ASCII argument of at most 4096 bytes is preserved, including
empty input. Invalid, oversized or extra input returns status 1 without output.
The immutable argument-vector and runtime ABI premises are documented in the
[trusted boundary](docs/trusted-boundary.md#command-line-boundary).

## Literal-backed greeting

Completed in `a73f85e`. Exactly three source literals contribute once each to
the result: prefix, constant initializer and suffix. Their distinct source spans
bound the intermediate and final concatenations. General expressions and
repeated references remain excluded. The [record](docs/greeting.md) retains the
native obligation experiment and independent macOS ARM64 review.

## Completed report-policy follow-up

The guarded greeting also adds independent Static ghost report policies.
GNATprove establishes equality between executable acceptance and the bounded
runtime/application policies. This verifies owned report interpretation while
retaining the genuine-producer and faithful-obligation-generation premises.
See [assurance](docs/assurance.md#selected-library-sources-and-evidence).

## Deferred until needed

Binary attestations, full deployment provenance, additional defenses for
adversarial build environments and compatibility machinery remain deferred
until practical use requires them. Existing source identity and complete actual
obligation checks remain in place. New proof tools need a demonstrated practical
need; separate metatheory development is not a prerequisite for language growth.

## Recording progress

Update language rules, catalogue, implementation and sample manifest together
for each admitted change. Record evidence by actual inputs, native platform and
cache mode, with links from the [README](README.md#proofs-and-platform-evidence).
Keep exact claims in [assurance](docs/assurance.md) and external assumptions in
[trusted-boundary](docs/trusted-boundary.md).

Linux is primary; macOS validation is independent and nonblocking. The owner
has directed local validation and disabled GitHub Actions repository-wide.
The retained workflow is dormant. Publication authority and current handoff
state belong in [session memory](docs/session-memory.md).
