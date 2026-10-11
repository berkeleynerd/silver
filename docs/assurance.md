# Silver assurance argument

## Scope and current status

The [Oracle](../oracle.md) requires a language-wide guarantee: every source
admitted by explicit, decidable rules must automatically discharge every required
Bronze and Silver obligation. Membership does not depend on prover success.
Failure to admit, prove or compile a valid program is an implementation or
toolchain defect; it cannot silently narrow the language.

The completed [Compose String Results](string-results.md) increment established
one bounded expression grammar inside six output shells plus null, with nine
concrete output forms. Its recorded inputs passed the complete Linux checkpoint;
the capability record gives exact input and cache scope. Independent replay was
not requested.

The [Copy String Values](copy-values.md) extension is complete.
Up to two literal-backed constants in each mutable shell add six finite variants,
for fifteen output forms. The rules and assurance argument below passed the
complete physical Linux checkpoint: native compiler audit/build, full tests,
complete Lean source correspondence and a fresh axiom/coverage audit, with cache
reuse and no optional independent replay. The capability record identifies the
validated inputs and retained evidence. Earlier [branching](input-branching.md),
[source compartmentalization](lean-compartmentalization.md), and
[focused-runner](lean-iteration.md) records remain evidence for their own inputs,
not validation of this changed tree.

The [language specification](../language.md) defines the precise admitted syntax
and behavior; the [catalogue](../catalogue/silver.json) and compiler must agree
with it. This document separates the universal Lean arguments, actual-source
correspondence, verified SPARK implementation, observed native results, and
external tool premises. Examples corroborate those arguments and do not replace
them. Linux is the current validation platform. Hosted GitHub CI is disabled at
the owner's direction, and macOS proofs and records are outside this task.

Inherited meaning is fixed by the checked-in
[Ada 2022 Reference Manual](../references/ada/2022/RM-TOC.html) and
[SPARK 16.1 Reference Manual](../references/spark/16.1/docs/lrm/source/index.rst).
The assurance targets are the User's Guide definitions of
[Bronze](../references/spark/16.1/docs/ug/en/source/bronze_level.rst) and
[Silver](../references/spark/16.1/docs/ug/en/source/silver_level.rst).
The [trusted boundary](trusted-boundary.md) names the frontend, proof tools,
runtime imports, ABI and environmental assumptions used throughout.

## Membership and composition

`Current.Member` is the union of the null grammar and `Compose.Member`.
`Current.accepts_iff_member` proves decidability; `member_has_meaning` and
`meaning_unique` give every admitted source exactly one canonical decoded program.
Admission remains the union of the finite shells; meaning and report routing
select the first accepted shell in the shared enumeration. This uniqueness
result does not require a separate all-forms-disjointness claim.
`ComposeAdmission` connects independent relational operand/expression/shell
parsing to its executable model. `ComposeSemantics` tracks the ordered parsed
payloads and their bounds; `ComposeDecode`'s `decoded_valid` connects every admitted
payload stream to the validity conditions in `ComposeMain`.

Membership covers the entire source, including its 1..4096-byte bound, permitted
ASCII alphabet, comments, trivia, case-insensitive identifiers and whole-word
token boundaries. Doubled quotes decode to one quote, while literal character
case and contents are preserved. The slots distinguish the static-length result,
immutable argument, and up to two literal-backed constants. Declarations are
distinct ignoring ASCII
case; references resolve to the declared slot, and reserved/type/package-name
exclusions preserve the intended bindings. No additional unit, declaration,
operator, statement or effect is admitted through an unmatched suffix.

The catalogue exposes these rules and permitted compositions. The integration
suite compares its parsed JSON with actual compiler output and exercises
admission boundaries. This checks maintained metadata; it is not a proof of a
general JSON serializer or general Ada name resolution.

### Null subgrammar and its proof

The null grammar admits only `procedure Main is pragma SPARK_Mode (On); begin
null; end Main;`, with permitted lexical variations. `Admission`, `Cursor`,
`Uniqueness`, `RecursiveBridge` and `SourceBridge` connect the independent token
grammar, recursive cursor equations, checked source and SPARK recognizer
refinement. `Semantics.admitted_assurance` establishes normal return, unchanged
abstract state and an empty trace for every admitted null source.

There is no application object, value-dependent expression, call, branch or
loop. Consequently its required application obligation list is empty, and the
modeled checker discharges it in one step. Real report acceptance still requires
completed analysis and full Main coverage. Startup, compilation and runtime
implementation retain the external premises below.

### Bounded String output expressions

Every output position admits a flat left-associated chain of 1..16 literal or
bound-name operands. Empty operands count. A static-length name may occur more
than once; the dynamic argument name occurs at most once per expression, in any
position. An assignment-bearing shell must use its mutable result in its final
expression. Membership counts each static reference at the initialized object's
fixed length, rather than counting only its distinct source span.

For static contribution `W`, dynamic occurrence count `D` (zero or one), and
selected capacity `C`, membership requires `W + D*C <= 4096`. An absent capacity
clause uses 4096. `ComposeExpression` proves exact evaluated length, printable
bytes, and equality between the operand-list meaning and left-associated
concatenation. Its prefix bound covers every intermediate concatenation,
including empty operands and repeated static references. Branch alternatives
are checked independently; their output lengths are not added together.

The reviewed Ada interpretation uses predefined `String` concatenation and
ordinary fixed-length initialization. Operand order fixes output byte order;
no particular Ada operand evaluation order is assumed, since these operands
have no effects. Literal/constant expressions can be folded statically. Mutable
and argument expressions may call GNAT's runtime concatenation implementation.
The bound applies in both cases. Storage availability and faithful predefined
operator implementation remain external premises.

### Named constants and their composition

A literal-initialized `constant String` has its bounds and bytes from that
literal. Output may use the name repeatedly or omit it. Every reference is
case-insensitively bound to its own declaration, and the weighted expression
bound counts all occurrences at that object's length. The static-output shell
still has exactly one constant. Mutable shells permit zero through two constants
before the result and after argv when present. Each has a literal initializer;
constant-to-constant and argv copies are excluded. Constants may be unused or
used only by result initialization or assignment. This generalizes the earlier
[named-string](named-strings.md) and [literal-backed greeting](greeting.md)
forms without assuming arbitrary declaration sequences or unrestricted names.

### Guarded command-line initialization

The argument shells initialize one immutable String through
`Silver_Arguments.First_Or_Default` and execute the mandatory
`Input_Is_Valid` guard before their output or inner choice. Both queries observe
the same immutable argument vector. Zero arguments selects the admitted default;
one argument is valid exactly when it contains at most 4096 printable ASCII
bytes. An explicit empty argument remains empty. Extra arguments, unsupported
bytes and oversized arguments are invalid.

`Arguments.Runtime` models the whole owned wrapper. Its checked rendering and
SPARK contracts establish bounded printable results with lower bound one.
The extended-return copy preserves bytes while normalizing imported String
bounds. Invalid input produces an internal empty value, but the guard executes
`Reject` rather than printing it. `Reject` sets status 1 and returns, producing
no application output. Admitted defaults always satisfy the library's domain;
the wrapper also safely handles arbitrary defaults outside the application
grammar.

An optional canonical capacity in 0..4096 strengthens the executable guard on
the selected String. A value exceeding it is rejected even when it came from
the default. This is observable source behavior, not truncation or a hidden
change to the argument domain. Without an explicit clause, the library's
4096-byte bound suffices. `ComposeMain`'s `guarded_length` connects successful guard
evaluation to the capacity used in each expression's bound.

Retrieving an oversized process argument can allocate storage before Silver
checks its length. The language bound is therefore not an allocation guarantee.
GNAT startup, the unconstrained-String ABI, immutable argv, sufficient resources
and returning external calls retain their documented assumptions.

### Guarded command-line concatenation

The earlier fixed prefix/name/suffix greeting is now a specialization of the
same expression and guard rules. The dynamic occurrence may be first, last or
between operands. The wrapper's proved lower-bound normalization and the
weighted output bound cover all such placements. The earlier
[guarded-greeting record](command-line-greeting.md) retains historical evidence;
its fixed two-concatenation grammar is no longer the current composition rule.

### Fixed-length string assignment

A mutable String acquires its fixed bounds from a literal or preceding
literal-backed constant initializer. Each replacement is also a literal or
preceding constant and must have exactly the same decoded length.
The simple assignment shell initializes, assigns once and then evaluates the
common expression. The selected-result shell first initializes immutable input
then zero through two literal-backed constants and a distinct mutable result;
after the validity/capacity guard, equality
selects one of two equal-length assignments, followed by one common output.

`ComposeDecode` proves these length equalities for every admitted payload.
`Compose.Main` interprets declarations in order and assignments as updates to
the initialized fixed-length cell. Its statement interpreter rejects a
length-mismatched assignment, and `execution_refines` proves that no admitted
program takes that failure case. Both selected branches establish the same
length invariant before output; the evaluated bytes are the chosen replacement.
`ComposeSemantics.constant_read_is_bound` identifies each normalized named
operand with the bytes in its immutable declaration slot. Independent
`SourceOperandValue` and `SourceExpressionValue` relations read those slots
directly. `meaning_constant_elaboration` carries this read correspondence at
every parsed initializer, assignment and output step; the public
`authoritative_main_correct` theorem retains that derivation alongside the
statement execution result. The copy variants passed complete source-correspondence
validation in the Linux checkpoint.
No path may read an uninitialized binding. The initial bytes may be overwritten,
but initialization still determines the object's bounds.

Under Ada RM 3.3.1 and 5.2, those equal lengths satisfy the assignment constraint.
The pinned frontend's static elimination of satisfied literal and constant-copy
assignment checks
is an explicit tool premise, exercised by native positive and unequal-length
negative controls. The isolated copy experiment found only existing proved
range checks and at most the existing initializer advisory across the positive
controls; all passed the unchanged report audit. Unused constants added
no warning class. These observations corroborate the external-tool premises;
they do not establish the universal theorem. Mutable concatenation can still
produce range checks.
The precisely classified ineffective-initialization advisory is discussed below;
it does not waive a safety obligation.

### Input-dependent branching

The inner condition compares the validated String with a literal using
predefined array equality. Equality compares length and element bytes without
requiring equal array bounds; it preserves case. The terminal-branch shell
chooses one of two output expressions. The selected-result shell chooses the
literal or literal-backed constant assigned before common output. A failed outer
guard performs
neither the equality-selected output nor an assignment branch.

`Compose.Main.composition` uses the same typed templates for rendered source
tokens and interpreted declaration/statement sequencing. `rendered_tokens`
checks every shell, and `execution_refines` connects ordered parser events to
`Compose.Program.action`. `Compose.SourceBridge.authoritative_main_correct`
retains the actual-source checks while composing parsing, decoding and that
execution result. The earlier [branching record](input-branching.md) describes
the narrower terminal-literal capability and its historical evidence.

## Output effects and failure outcomes

`ComposeMain`'s `action_domain` and `Current.action_domain` prove that every selected
output value is printable and at most 4096 bytes. `OutputRuntime` interprets the
whole `Silver_IO` body: length guard, byte writes, LF write, flush, checked
statuses, failure-status assignment and early return. Its renderer matches the
actual body; only fixed Static ghost actions and annotations are erased, with
their declarations checked separately. GNATprove verifies the wrapper for every
String, including arbitrary lower bounds and oversized values.

Success requires acceptance of the selected bytes followed by exactly one LF,
and a successful flush. A detected write or flush failure returns status 1 and
records an accepted prefix of that requested output; it cannot count as successful
completion. A prefix may be the entire byte sequence when flush fails. Guard
rejection returns status 1 with no output. Null returns status 0 with no output.
Every output is terminal along its executed path, so no later application action
can overwrite a detected failure.

`Current.execution_specified` proves these outcomes for every modeled completed
execution. `healthy_execution` gives exact bytes and the expected status under
`Output.Runtime.Healthy`; invalid or over-capacity input remains a rejection
even in that environment. `every_meaning_assured` quantifies over every admitted
meaning and environment, not just the samples.

The observation is acceptance by the host C output stream, not consumption by a
reader or durable storage. Blocking calls, signals, abnormal process termination
and arbitrary external exceptions are outside the completed-reply model.
Effectful operations have explicit nontermination allowances; there is no
claimed progress theorem for an unresponsive output environment. libc, GNAT's
returning status setter and normal startup remain trusted dependencies.

## Mechanical proofs and their correspondence

A correct separate model or a matching source pin alone does not establish the
required correspondence. The checked chain has these distinct parts:

1. Twelve handwritten source-binding modules fix `include_str` paths for both
   recognizers, both lexical-helper units and the six selected runtime files.
   Generated candidates reconstruct their exact included bytes and checked
   tokens. The generator cannot select replacement source bindings. Source
   alphabet checks include comments and literals.
2. `SourceBridge` and the retained `OutputSourceBridge`, `NamedSourceBridge`,
   `ArgumentsSourceBridge` and `LexicalSourceBridge` check complete reviewed
   token shapes, declarations, imports, contracts and the relevant typed
   lexical/runtime bodies. Surrounding scopes and helper declarations cannot
   disappear behind a selected-body comparison. The runtime bridges render the
   entire owned IO/Arguments bodies and conjoin checked source with refinement.
3. `ComposeExpressions` renders typed operand, expression-tail, expression,
   state-step, shell-suffix and public-selector bodies. `ComposeSourceBridge`
   checks them against authoritative Ada, including precedence, record/subtype
   declarations, finite token/form mappings, source constants and executable
   refinement contracts. The typed Main templates render those same shell
   tables and interpret their ordered parsed payloads.
4. `Compose.Lexical.InterpretedSource` contains only retained lexical-body
   equations. For arbitrary helper calls, `interpreted_primitives` proves the
   meanings of trivia, literals and decoded lengths, identifiers, exclusions,
   name equality, decimal capacities, fixed tokens, normalization and allowed
   bytes on their legal machine domains. No deleted suffix/member body or
   parser-equals-model assertion is an interpretation premise.
5. `ComposeEvaluation` records legal executed helper calls, respecting
   short-circuit branches, and proves typed-evaluation congruence. The source
   bridge starts with raw body equations using the actual arbitrary callees;
   `normalized_definitions` derives equations using the proved lexical meanings
   from those raw equations and the verified caller-domain facts. Recursive
   uniqueness in `ComposeEquations` then closes operand/expression/shell behavior.
   `interpreted_member`, `interpreted_arguments` and `interpreted_assignment`
   establish admission and the report selectors. The source bridge retains
   checked source, helper interpretation and SPARK executable-refinement facts
   in its membership/selector theorems. The verified Step postcondition carries
   legal state bounds through recursive shell calls.
6. `ComposeAdmission`, `ComposeSemantics` and `ComposeDecode` connect that grammar
   to canonical decoded programs satisfying all expression, initialization,
   assignment and guard bounds. `ComposeExecution`, `ComposeObligations` and
   `Current` then establish behavior and the modeled automatic discharge result.

The interpretation of the checked restricted Ada fragment as these equations
uses the approved frontend's predefined operators, indexing, short-circuit
evaluation, scope and machine arithmetic. GNATprove proves actual caller
preconditions, numeric bounds, normalization and executable refinement;
these facts justify using lexical meanings only on legal call domains.
Interpreting rendered statements additionally uses ordinary Ada initialization,
assignment, branches, sequence, return and verified Static ghost erasure.
This is a constrained semantic interface with explicit premises, not a verified
general Ada parser, arbitrary overload resolution or a theorem about GNAT's
implementation. The source-equation conclusions quantify over interpretations
satisfying their checked equations; they do not assume recognition correctness.

The current proof facade uses the shared composed recognizer. Historical model
modules can remain as reusable mathematical developments, but obsolete
fixed-production source bridges do not establish correspondence for replaced
Ada functions. Source-pin changes must be reviewed together with these semantic
changes. The preceding Compose String Results checkpoint rebuilt its changed
output specification/body certificates and checked the whole project; ten
unrelated certificates retained identical bytes and modification times. The
completed Copy String Values checkpoint validates the subsequent source/proof
changes and full project; its exact certificate and cache scope is recorded in
[the capability record](copy-values.md).

## Automatic completion and the external boundary

`ComposeObligations` associates each output expression with a conservative range
schema: its counted static length plus its zero-or-one dynamic contribution.
`prefix_schema` proves that each left-associated concatenation prefix refines
the complete expression's schema. `program_schemas` covers both alternative
output sites where present, including repeated static references and selected
result assignment. The stronger effect-domain bound remains 4096 per output.

For arithmetic safety, all current schemas refine a uniform bound with fixed
part at most 4096 and variable bound at most 4096. Their sum fits the Ada-required
minimum `Integer'Last` of 32767. `Guarded.RangeObligation.discharge_iff` proves
that checking the maximal variable length decides universal validity, and its
bounds theorem covers both empty and nonempty String ranges. Literal/object
bounds and the verified normalized argument result supply lower bound one.
The current proof reuses this range theory; it does not retain the old fixed
prefix/suffix grammar as an admission condition.

`Current.all_obligations_discharge` proves validity and terminating mathematical
discharge for every admitted meaning. `automatic_discharge_complete` returns a
uniform successful certificate for every member. Its step bound concerns this
Lean-defined checker, **not** the runtime or step count of CVC5, Z3 or Alt-Ergo.
A schema is not a prediction of the number of emitted GNATprove records:
static folding may eliminate checks, and translation may split or repeat them.

`Current.Tools` and `Current.ToolContract` state external operations and their
contracts as theorem parameters, without project-specific axioms. They require
faithful completed parsing, obligation generation, completion of proof on the
concrete bounded range fragment, fixed-library proof completion, same-source
build completion, and preservation and realization of modeled execution.
`generationFaithful` relates each emitted range check to a source schema; it
does not itself establish that the producer omitted no required obligation.
Faithful and complete GNATprove generation, static elimination of satisfied
assignment checks, accurate diagnostics and the accepted report shapes remain
explicit producer premises.

`automatic_pipeline` derives a completed modeled pipeline for every member
under those contracts. `pipeline_checks_valid`, `pipeline_preserves` and
`pipeline_realizes` establish generated-check validity and specified/healthy
execution outcomes. The library-proof marker is separate from semantic
preservation; neither follows from an empty Main report. `model_tool_contract`
shows that the interface is jointly inhabited, not that physical tools have
been verified. The null specialization retains its empty-obligation argument.

In particular, completion of the pinned external solvers within the application
configuration's 10,000-step limit remains an explicit premise. Lean proves
neither those solvers nor a universal bound on their work. Native experiments
exercise maximal source/operand lengths, capacity boundaries and report shapes;
their measured margins belong in [the capability record](string-results.md).
Solver effort can vary with source size and translation. These measurements do
not prove completion for arbitrary SPARK, or a host-independent wall-clock bound.

Physical instantiation also requires genuine matching tools, stable source and
project files, sufficient resources, successful infrastructure I/O and completed
external processes. GNAT startup/code generation, binder, linker, libc and OS
implementations remain trusted. The conditional pipeline theorem and proved
SPARK driver guards are distinct; there is no single theorem for the entire CLI,
shell, filesystem and toolchain. Detected infrastructure or verification failure
prevents publication and is reported as a defect, never as nonmembership or
successful proof.

## Selected library sources and evidence

Every output project selects the unchanged application `main.adb` and exactly
six library files: IO and Arguments specifications/bodies, plus Output_Libc and
Runtime interface specifications. Null projects select only Main. Bootstrap
embeds exact library bytes in `Silver_Library_Sources`; the compiler compares
installation files with them before capture. The compiler audit checks that
generated binding, and Lean reads the authoritative library files directly.
Runtime changes therefore require regenerated bindings and affected native and
Lean validation. This binds source selection, not compiler-binary identity.

`Silver_Libraries` verifies capture/reread equality. The driver checks the same
captured source set before proof, build and publication, and rereads application
and library snapshots after proof/build. All four runtime reports are required.
`Complete_Runtime_Proof` checks full selected entity coverage, completed analysis,
every flow/proof record, approved dependency assumptions, and absence of skipped,
assumed, justified or unexpected warning records. IO/Arguments require nonempty
checks and their respective Put_Line/First_Or_Default postconditions; the two
interfaces require full package coverage and specification coverage for exactly
the approved imports. No historical check total substitutes for coverage.

### Source-selected application policies

`Uses_Arguments` and `Uses_Assignment` have SPARK-proved refinement contracts to
the same grammar's selectors. The driver computes one `Application_Kind` and
uses it consistently in report acceptance and build/publication prerequisites.
All output shells use `Complete_Application_Proof`; only null retains
`Complete_Null_Proof`.

| Policy | Source composition | Expected call-report entities | Advisory allowance |
| --- | --- | --- | --- |
| Static | Direct or constant-backed expression | Main and Put_Line | None |
| Argument | Immutable input, with direct or branch-selected output | Main, First_Or_Default, Input_Is_Valid, Reject and Put_Line | None |
| Assigned | Literal/constant-initialized result, one compatible assignment, output | Main and Put_Line | At most one exact ineffective-initialization advisory |
| Selected | Immutable input and branch-assigned result, common output | Main and the four argument/output callees | The same narrow allowance |

Every emitted Main safety record must be a proved/info `VC_RANGE_CHECK` with the
expected Main filename/entity, valid positive location and no suppression or
justification. Empty safety lists are permitted when checks were eliminated.
Required coverage, progress and dependency fields are still checked; dependencies
must identify approved entities and effect, postcondition or absence-of-runtime-
error claims. No other safety class or warning is accepted.

The initializer advisory concerns overwritten bytes, not their constraint-setting
role. Its exact severity, identifier, name shape, location and message are checked.
Some legal identifiers cause GNATprove to omit it. Assignment-bearing policies
also retain the genuine bare-Main report shape with empty safety/dependency
lists and zero or one permitted advisory. That allowance does not apply to
static/argument policies. Native tests include actual reports and mutations;
the Python evidence helper selects the same four kinds and additionally checks
SARIF consistency and totals.

The bounded, nonrecursive executable scanners have SPARK-proved equality to
independent Static ghost `Runtime_Report_Policy` and `Application_Report_Policy`.
These specifications describe byte traversal, quoted strings, nesting, audited
fields, entities, dependencies and every emitted record, without calling the
executable acceptance traversal. Shared elementary predicates and immutable
tables do not replace that refinement. The report domain remains 262,144 bytes.
Static erasure removes proof computations from the executable while all their
GNATprove obligations remain; real report guards and assertion/overflow checks
remain enabled.

These are policies for genuine pinned GNATprove reports, not authenticators for
arbitrary JSON or hostile filesystem contents. Complete report acceptance does
not prove that GNATprove generated every required obligation. The external
producer, provenance and immutable-workspace premises remain essential.

## Source identity and automatic program verification

Admission reads the author's actual Ada/SPARK bytes. The compiler writes those
same bytes into a fresh private workspace as `main.adb`, rereads them after
writing, proof and compilation, and uses one generated project for both tools.
The project selects Ada 2022 and assertion/overflow checking without adding
application contracts, declarations or pragmas.

SPARK Static ghost transcripts record actual read/write byte observations,
EOF/closure, exact command text and returned status. `Same_Source` and the
ordered driver contracts connect those observations to source identity and
require successful writes, matching snapshots, the named successful proof/build
commands and accepted report policies before publication. Their erasure leaves
the real I/O, error handling and guards executable. Reading libc observations as
stable file contents still requires the documented external semantics and absence
of concurrent replacement. Comprehensive per-program attestations remain deferred.

Application proof uses `-U --mode=all --report=all --checks-as-errors=on --level=2
--prover=cvc5,z3,altergo --steps=10000 --timeout=0 --memlimit=0 -j0`.
Static/argument/null routes use `--warnings=error`; assigned/selected routes use
`--warnings=continue` so their exact advisory can be classified from the full
report. Every selected library report remains strict. Successful process exit
and accepted report content are separate requirements. `warn_error` is not a
catch-all list of frontend compiler warnings, and this policy does not claim
that GNAT emits no such warnings.

Every fresh output compilation proves its selected libraries as well as Main.
Zero wall-clock timeout does not prevent crashes or resource failure, and the
step bound excludes frontend/flow work, OS delays and total elapsed time.
Failure prevents publication; no warning suppression or obligation waiver is
introduced to make an admitted source pass.

## Compiler verification evidence

Both recognizers have proved executable/ghost membership refinement.
The output selectors refine the same source grammar; `Step` preserves valid
parser state. Lexical contracts, normalization, exact decimal rendering, source
capture, observed I/O, report-policy refinement and driver ordering are verified
alongside bounds, overflow, initialization, invariants and termination where
applicable. Every Silver-owned compiler/runtime body and the generated
`Silver_Build`/`Silver_Library_Sources` units require full SPARK coverage.
Only the exact reviewed external imports receive specification-only coverage.

`Complete_Null_Proof` retains equality with its independent bounded report-pattern
policy and requires the genuine null report's completed single-entity analysis
and empty checks. Its narrower format guarantees are distinct from the output
report traversal. Both depend on faithful producer reports.

Run the complete compiler audit with `python3 scripts/dev.py prove --full`.
It forces analysis and refreshes reports, with explicit logical options:
`--mode=all --report=all --warnings=error --checks-as-errors=on --level=2
--prover=cvc5,z3,altergo --timeout=30`, all selected units, configurable workers
(default all available cores), and the host-local native solver cache.
Full analysis may reuse native proof results and is not a cold-performance claim.
Optional `--cold` allocates separate fresh output/session/cache directories while
preserving the normal warm state and other hosts' evidence.

The auditor requires every owned unit/entity, discharged checks and approved
external assumptions. It cross-checks `.spark`, SARIF and text summary and binds
sources, generated configuration, projects, scripts, Alire state, tools and final
reports by content. Inputs and tools must remain stable. Failed checks, missing
coverage, suppressed/justified obligations, `pragma Assume` and unclassified
warnings fail the audit. The documented `contracts-recursive` and
`numeric-variant` limitation notes withhold prover information; they do not waive
obligations. Exact rules are in [the trusted boundary](trusted-boundary.md).

Incremental `dev.py prove` preserves sessions and gives development feedback,
while invalidating the previous completed full-audit manifest. Ordinary builds
do not require such a manifest. Exploratory GNATprove commands use separate
`explore` outputs/caches. Native tests exercise source/report mutation, tool
failure, maximum bounds and exact runtime bytes; their results and platform
scope belong in the capability record rather than a permanent historical-count
gate. A zero process exit status alone is insufficient verification evidence.

## Lean checking and iteration

Lean 4.34.1 is pinned in `proof/lean-toolchain` and installed from pinned upstream
archive hashes. The project treats warnings as errors and has no Mathlib
dependency. Use `scripts/check_lean.py` to synchronize authoritative proof inputs
into `.silver/<host>/proof`; its checked sibling source link retains direct
access to the actual repository source. Tools, workspace objects, candidates
and evidence are isolated by native host. Inherited tool/search-path overrides
and external artifact restoration are disabled; local caches are preserved.

The runner's default builds the whole project incrementally and executes the
actual-import/module-coverage and transitive axiom audit afresh, including on
cache hits. Every project module must be in the complete audit closure. Only
`propext`, `Quot.sound` and `Classical.choice` are permitted; unfinished proofs,
project-specific axioms and native-evaluation trust axioms fail. Source/config
and retained build-trace checks reject direct kernel-checking bypasses, including
unsafe weak arguments that survive a configuration reversion. Honest local
objects/traces and the pinned toolchain remain trust assumptions; these checks
are not a sandbox against arbitrary hostile metaprograms.

Repeatable `--target MODULE` options build and freshly audit only the selected
actual import closure, recording separate focused evidence. They support fast
model iteration and do not establish whole-project correspondence. Optional
`--replay` (`--full` is an alias) adds `leanchecker --fresh` over the complete
environment and cannot be combined with `--target`. `--clean` discards the host
workspace without implying replay. Complete proofs and source correspondence
are required; independent replay is an optional investigation/audit step.

Each embedded Ada file is a binary dependency of its handwritten binding and
its own generated source certificate. Content rehashing detects edits even with
restored timestamps; line endings matter. A change rebuilds that binding,
certificate and transitive importers. Unrelated certificates/models may remain
cached, while shared Lean changes can invalidate more. Candidates cannot replace
protected proof modules, bindings or configuration. Exact source correspondence
comes from the kernel-checked reconstruction and semantic proofs, not hashes
alone. The [partition record](lean-compartmentalization.md) documents this reuse.

Both Lake workers and threads per Lean build/audit process default to available
CPUs; `--workers` and `--threads` control them separately. Configuration is
re-elaborated to apply changed settings without throwing away accepted objects.
Worker pools can multiply, and serial proof steps remain.
`--memory-mb` is Lean's periodically checked per-process resident-memory threshold,
not a hard OS cap or an aggregate concurrent-memory budget. The separate pinned
`leanchecker` has no memory-limit option. Measurements and limits are in the
[concurrency record](lean-concurrency.md).

Inputs, tools and protected workspace copies are rechecked between phases.
Complete and focused evidence record their actual scope, aggregate input digest,
tools, timings and replay status; `--provenance` adds detailed inventories.
Replay/provenance also compare compiled-object hashes between phases. Routine
runs rely on the pinned local toolchain and Lake cache. Each run invalidates its
own stale success record before setup, leaving other hosts' evidence untouched.

Use focused checks during implementation, then one stable complete Linux
checkpoint after the related source/proof edits are ready. Preserve ongoing
checks and caches; repeat only validation invalidated by changes, failures or a
concrete unresolved concern. The [development workflow](../development.md)
requires full native and Lean assurance before marking the capability supported.
Historical results retain their actual input/host scope, and configured dormant
CI is not evidence of a hosted run.
