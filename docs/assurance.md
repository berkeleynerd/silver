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

The earlier [Copy String Values](copy-values.md) extension completed its
physical Linux checkpoint for fifteen output forms, including two constant
slots in mutable shells. Its native/Lean evidence retains that recorded input
scope; the generalized source has its own checkpoint below.

The completed [shared-bindings increment](shared-bindings.md) replaced fixed
slots with ordered initialized declarations and eight concrete body/capacity
forms. The [common-expression increment](common-expressions.md) extends those
same arrangements with parentheses and shared expressions in initialization,
assignment, comparison and output. Its capability record gives the current
checkpoint status and exact evidence. The rules and proof interfaces below
reflect this implementation. Earlier capability and performance records retain
their original input scope.

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
`ComposeAdmission` defines executable recognition. `ComposeSemantics` connects
operand/expression parsing to that model; `ComposeDeclarations` and
`ComposeGrammar` derive ordered declarations, named references and shell events.
`ComposeDecode`'s `decoded_valid` connects every admitted
payload stream to the validity conditions in `ComposeMain`.

Membership covers the entire source, including its 1..4096-byte bound, permitted
ASCII alphabet, comments, trivia, case-insensitive identifiers and whole-word
token boundaries. Doubled quotes decode to one quote, while literal character
case and contents are preserved. A finite ordered environment gives each
initialized declaration its own binding, mutability and fixed length shape.
Declarations are distinct ignoring ASCII case; reads resolve to earlier
initialized names during declaration and to the current store during execution.
Reserved/type/package-name exclusions preserve the intended bindings. The native
341-entry array follows from `4096 / 12`, since every declaration consumes at
least twelve source bytes; it is not an independent count restriction. No
additional unit, declaration region, operator, statement or effect is admitted
through an unmatched suffix.

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

### Common bounded String expressions

Every initializer, assignment RHS, equality operand and output uses one grammar
of literals, initialized names, concatenation and parentheses. Expressions have
1..16 leaves, counting empty values and each repeated static/dynamic reference.
The program additionally has at most thirty syntactic concatenations, including
both branches. A source precheck skips complete literals and trivia/comments;
its verified traversal counts only operator ampersands. This retains the previous
two-output form's maximum concatenation count while allowing it in new positions;
equal counts do not imply equal proof costs. The limits are explicit native
proof/translation resource policies.

For static contribution `S`, dynamic occurrence count `K`, and capacity `C`,
membership requires `S + K*C <= 4096`. Declaration initializers precede guards
and use `C = 4096`; guarded body expressions use the established capacity.
`Bindings` and `ComposeExpression` prove exact evaluated length, printable bytes,
and equality between flattened operand evaluation and grouped concatenation.
Nonnegative operand lengths bound every prefix and subtree by the complete
expression. `ComposeSemantics` connects the source scanner's operand order,
parenthesis/operand state and successful terminal state to that interpretation.
Alternative branches meet their own value bounds; both contribute source work.

The reviewed Ada interpretation uses predefined `String` concatenation and
ordinary fixed-length initialization. Operand order fixes output byte order;
no particular Ada operand evaluation order is assumed, since these operands
have no effects. Literal/constant expressions can be folded statically. Mutable
and argument expressions may call GNAT's runtime concatenation implementation.
The bound applies in both cases. Storage availability and faithful predefined
operator implementation remain external premises.

### Named constants and their composition

A declaration initializes a constant or mutable String from a common expression.
Literal decoding fixes bytes; each earlier-name occurrence reads its current value.
The resulting bytes become the new object's snapshot. Declarations are folded in source order, with
no forward, cyclic or uninitialized reads. Subsequent assignment changes the
target's bytes without updating earlier copies. The original immutable argument
binding remains first and unique in argument-bearing shapes; its aliases share
one symbolic input length, without introducing another input or library call.

`Bindings.declaration_snapshots`, `snapshot_survives_source_write`,
`declaration_preserves` and `declarations_preserve` provide the reusable value,
snapshot and initialized-store argument. The parser records literal decoding
or a resolved earlier binding index; source semantics reads that binding rather
than trusting a cached origin as its meaning. `Bindings.DeclarationsValid`
relates the declaration sequence to its fixed binding shapes and initialized
values. Constants and mutable objects may remain unused.

This generalizes the earlier [named-string](named-strings.md),
[literal-backed greeting](greeting.md) and [copy](copy-values.md) cases. It does
not generalize declaration placement or admit arbitrary Ada names/context
clauses. Those remaining closures stay in
the [roadmap](../roadmap.md#existing-feature-consolidation).

### Guarded command-line initialization

The argument shapes initialize one immutable String first through
`Silver_Arguments.First_Or_Default`, then elaborate their ordinary declaration
list, and execute the mandatory
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
same expression and guard rules. Dynamic occurrences may appear in any position,
including repeated references and grouped subexpressions. The wrapper's proved lower-bound normalization and the
weighted output bound cover all such placements. The earlier
[guarded-greeting record](command-line-greeting.md) retains historical evidence;
its fixed two-concatenation grammar is no longer the current composition rule.

### Fixed-length string assignment

Every initialized mutable String has a fixed length shape: a known static
length, or the symbolic length of the sole selected argument/default. An expression
can replace it only when its exact affine length agrees with that shape. This admits
constant/mutable copies and self-copy, including dynamic-to-dynamic copies. It
does not infer a new static/dynamic equality from a branch condition or capacity.
Declaration initializers execute before those body facts are available.

`Bindings.assignment_length`, `assignment_preserves` and
`assignment_preserves_other` establish exact length compatibility, preserved
initialization/bounds and unchanged other objects. Output reads the resulting
store. The plain assignment shape performs one assignment; the selected-result
shape performs one assignment to the same target on either equality branch,
then common output. Both branch executions start from the pre-choice store, so
one branch cannot affect the other's RHS meaning. Output may omit the target.

The source interpretation connects declaration elaboration and each parsed
read/write to these generic store operations; the [capability checkpoint](common-expressions.md)
includes that correspondence. No path may read an uninitialized binding.
Ada RM 3.3.1 and 5.2 supply the inherited object/assignment constraint semantics.
The assigned bytes can change, but the target's bounds cannot.

Broader copies expose real `VC_LENGTH_CHECK` obligations, especially for dynamic
self/copy assignment. The obligation argument and Main policy therefore include
an exact-length channel as well as concatenation range schemas. Faithful static
elimination is permitted when applicable, but successful elimination of every
assignment length check is no longer a required producer shape. Native discovery
corroborates these check and diagnostic classes; it does not prove a universal
solver bound. Precisely classified unused-initializer/assignment advisories do
not waive either safety class.

### Input-dependent branching

The inner condition compares two bounded expressions using predefined String
equality. At least one contains a declared String name, providing Ada's required
array-type resolution; two literal-only operands are excluded. Equality compares length and element bytes without
requiring equal array bounds; it preserves case. The terminal-branch shell
chooses one of two output expressions. The selected-result shell chooses the
expression value assigned before common output. A failed outer
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
3. `ComposeExpressions` interprets the typed binding lookup, literal/name value,
   declaration, operand, expression-tail, state-step, shell-suffix and selector
   bodies, together with their checked lexical/executable refinements. `ComposeSourceChecks`
   checks them against authoritative Ada; `ComposeSourceBridge` assembles those
   facts, including precedence, scope, record/subtype
   declarations, active binding-array representation, finite token/form mappings,
   source constants and executable refinement contracts. The typed Main shapes
   render those same shell tables and interpret declaration lists and ordered
   parsed payloads. Capacity for every active binding follows from source size;
   loops refine the terminating mathematical traversals without native recursive
   array-state copying.
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
   uniqueness in `ComposeEquations` then closes binding/declaration and
   operand/expression behavior. `ComposeRecognitionEquations` assembles shell
   traversal and routing.
   `interpreted_member`, `interpreted_arguments` and `interpreted_assignment`
   establish admission and the report selectors. The source bridge retains
   checked source, helper interpretation and SPARK executable-refinement facts
   in its membership/selector theorems. The verified Step postcondition carries
   legal state bounds through recursive shell calls.
6. `ComposeSemantics`, `ComposeDeclarations`, `ComposeGrammar` and `ComposeDecode` connect that grammar
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
completed Copy String Values checkpoint validates that earlier source/proof
revision; its exact certificate and cache scope is recorded in
[the capability record](copy-values.md). The [shared-bindings checkpoint](shared-bindings.md)
validates its earlier generalized binding source; this revision requires the
[common-expression checkpoint](common-expressions.md).

## Automatic completion and the external boundary

`ComposeObligations` associates declaration initializers and every body expression
with conservative range schemas. They count the static contribution plus every
dynamic occurrence times the selected input length. Initializers use the full
4096-byte domain; later body sites use the executable guard's capacity.
Prefix/grouping results cover intermediate concatenations, and `program_schemas`
covers comparison operands, assignment RHS values and both alternative branches.
A separate exact-length schema covers assignment compatibility with the target's
fixed bounds. Every emitted safety obligation must correspond to the appropriate
range or length channel; accepting its report is not that correspondence proof.

The arithmetic argument bounds each admitted String value by 4096 bytes and
accounts for predefined concatenation's range arithmetic. Its conservative
range bound fits Ada's required minimum `Integer'Last` of 32767. The existing
`Guarded.RangeObligation` theory decides the uniform bound and covers empty and
nonempty ranges. Literal/object bounds and the normalized argument result supply
the inherited lower-bound behavior. No fixed prefix/suffix grammar is required.

`Current.all_obligations_discharge` proves validity and terminating mathematical
discharge for every admitted meaning. `automatic_discharge_complete` returns a
uniform successful certificate for every member. Its step bound concerns this
Lean-defined checker, **not** the runtime or step count of CVC5, Z3 or Alt-Ergo.
A schema is not a prediction of the number of emitted GNATprove records:
static folding may eliminate checks, and translation may split or repeat them.

`Current.Tools` and `Current.ToolContract` state external operations and their
contracts as theorem parameters, without project-specific axioms. They require
faithful completed parsing, obligation generation, completion of proof on the
concrete bounded range/length fragment, fixed-library proof completion, same-source
build completion, and preservation and realization of modeled execution.
The generation relation must associate every emitted range/length check with
its source schema; that association alone does not establish that the producer
omitted no required obligation. Faithful and complete GNATprove generation,
applicable static elimination, accurate diagnostics and the accepted report
shapes remain explicit producer premises. In particular, accepting length
records in the report checker does not replace their semantic obligation proof.

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
the earlier measured margins belong in [the historical record](string-results.md).
The current expression and resource-policy evidence is in
[common-expressions.md](common-expressions.md).
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
| Static | Ordinary declarations followed by direct output | Main and Put_Line | Exact initializer advisories |
| Argument | Immutable input, ordinary declarations, direct or branch-selected output | Main, First_Or_Default, Input_Is_Valid, Reject and Put_Line | Exact initializer and constant-equality advisories |
| Assigned | Ordinary declarations, one compatible assignment, output | Main and Put_Line | Exact initializer and unused-assignment advisories |
| Selected | Immutable input, ordinary declarations and branch-assigned target, common output | Main and the four argument/output callees | Exact initializer, unused-assignment and constant-equality advisories |

Every emitted Main safety record must be a proved/info `VC_RANGE_CHECK` or
`VC_LENGTH_CHECK`, with the expected Main filename/entity, valid positive
location, prover completion and no suppression or justification. Empty safety
lists are permitted when checks were eliminated. Required coverage, progress
and dependency fields remain checked; dependencies must identify approved
entities and effect, postcondition or absence-of-runtime-error claims. No other
safety class is accepted.

All four policies permit finite lists of the exact `INEFFECTIVE` message
`initialization of "NAME" has no effect`. The name must have the checked Ada
identifier shape. Only Assigned/Selected policies additionally permit the exact
message `unused assignment`. Argument/Selected policies additionally permit
`INEFFECTIVE` / `statement has no effect` and `DEAD_CODE` /
`this statement is never reached`, observed for constant String equality.
Every allowed advisory must have warning severity,
flow provenance, Main filename/entity, a positive location and no suppression
or justification. There is no independent advisory-count cap; the source grammar
and complete report domain still constrain production. These diagnostics do not
waive safety checks. Other messages, including repeated-output ghost-output
advisories, remain rejected. Some legal names make GNATprove omit an advisory.

A bare-Main report requires empty safety/dependency lists. Static/Argument
policies additionally require a nonempty route-permitted advisory list;
Assigned/Selected retain their earlier zero-advisory allowance as well. Outside
this precise fallback, the full source-selected callee set is required. Native
tests use genuine reports and mutations; the Python evidence helper applies the
same four policies and additionally checks SARIF consistency and totals.

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
Null uses `--warnings=error`; all output routes use `--warnings=continue` so
their precisely permitted advisories can be classified from the complete report. Every selected library report remains strict. Successful process exit
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

The [ordinary-module migration](lean-modules.md) permits theorem proof-body edits
to retain consumer artifacts while preserving public statements and exposed
computational definitions. The complete and focused audits remain legacy entry
points so private and transitive declarations stay visible to the fresh audit.
This changes build dependencies, not the required source correspondence or
approved assumptions.

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

Generated reconstruction joins use `kernel_exact` to elaborate their explicit
equality witness independently, then check it at the exact goal type through
Lean's synchronous checked auxiliary-lemma mechanism. A cached auxiliary proof
is reusable only for that same type. This avoids repeated elaborator conversion
without changing source data, final correspondence statements or allowed axioms;
the [reconstruction record](lean-join-optimization.md) gives the implementation,
negative controls and measurement scope.

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
