# Silver assurance argument

The [Partial Output milestone](partial-output.md) extends the current statement
model with `Put` alongside `Put_Line`. Both use the same bounded expressions,
path validity and exact source-name rules. `Silver.Output.Runtime.putProgram` renders
the checked native byte loop and flush without LF. Its exact-success and
prefix-failure proofs feed the shared ordered effect semantics, preserving sticky
failure and continued execution; invalid-input executions contain only rejection
effects, so even an empty Put cannot occur there. Whole-body source rendering
includes both runtime operations. The selected IO report must prove both owned
postconditions, regardless of which operation Main uses.

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
assignment, comparison and output. The completed [sequencing increment](statement-sequencing.md)
replaced those fixed bodies with nonempty sequences and one-level equality choices.
The completed [conditional milestone](branches.md) adds recursive choices,
`elsif`, optional `else`, bounded predicates and path-sensitive composition.
The completed [Names and Calls checkpoint](names-and-calls.md) adds context
visibility, resolved call names and named actuals for the existing operations.
The completed [Larger Expressions record](larger-expressions.md) establishes the
subsequent 64-leaf/63-operator fragment's universal/source checkpoint and records
native validation, composition probes and dense report capacity.
The rules and proof interfaces below describe the current inputs. Each delivery
record distinguishes the combined Linux checkpoint's canonical Lean audit,
cache-preserving native proof audit, full-suite results and focused repairs.
Earlier capability and performance records retain their original input scope.

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

`Current.Member` is the union of the null grammar and `Predicate.Member`.
`Current.accepts_iff_member` proves decidability; `member_has_meaning` and
`meaning_unique` give every admitted source exactly one decoded program.
`PredicateAdmission` and `PredicateBodyAdmission` define the two output-shell
scanners, predicates, basic statements, nonempty lists and recursive choices.
The condition/body readings, soundness, meaning and uniqueness modules connect
scanner events to an explicit source AST retaining written `elsif` and omitted
`else`. `PredicateGrammar` connects those readings to faithful lowering and
normalized program validity. The reading relations include scanner equalities
and scanner-computed positions; their theorems do not independently establish
that the scanner accepts every source described by the prose grammar.
The static and argument shells are disjoint. `PredicateSelectors` connects
argument/output/assignment flags to the decoded program, including all nested
arms. Shared `Compose` expression/declaration proofs remain in use; their obsolete
fixed-shell recognition is not the current language.

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
1..64 leaves, counting empty values and each repeated static/dynamic reference.
The program additionally has at most sixty-three syntactic concatenations, including
all predicate operands and conditional arms. A source precheck skips complete literals and trivia/comments;
its verified traversal counts only operator ampersands. This permits one maximal
expression or the same aggregate operator count spread across positions;
equal counts do not imply equal proof costs. The limits are explicit native
proof/translation resource policies.

For static contribution `S`, dynamic occurrence count `K`, and capacity `C`,
membership requires `S + K*C <= 4096`. Declaration initializers precede guards
and use `C = 4096`; body expressions use their current reachable input interval
and the separate invalid-input case. An unreachable evaluation has no dynamic
length obligation, but its static contribution must still fit within 4096 bytes.
For a static assignment target of length `T`, the static RHS contribution `S`
must satisfy `S <= T`, and `S = T` without dynamic occurrences, even there.
Admission therefore does not rely on GNAT's operand order or folding a dead
length mismatch away. Syntax,
names and mutable assignment targets must remain legal on all paths.
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
clauses. The [Names and Calls extension](names-and-calls.md) adds the shared
context visibility and association rules for the existing packages and APIs;
additional declaration regions and general Ada visibility remain excluded.

### Command-line initialization and path validity

The argument shell initializes one immutable String first through
`Silver_Arguments.First_Or_Default`, then elaborates ordinary declarations before
its statement sequence. The initializer and `Input_Is_Valid` observe the same
immutable argument vector. Zero arguments selects the admitted default; one
argument is valid exactly when it contains at most 4096 printable ASCII bytes.
An explicit empty argument remains empty. Extra arguments, unsupported bytes and
oversized arguments are invalid.

`Arguments.Runtime` models the whole owned wrapper. Its checked rendering and
SPARK contracts establish bounded printable results with lower bound one and an
empty result for invalid input. The extended-return copy preserves bytes while
normalizing imported String bounds. The predicate context tracks that invalid
case separately from the interval of valid selected lengths. Every admitted
invalid-input path must execute Reject and cannot output. A validity query may
establish a safe path; a positive selected-input length also excludes invalid
input. `Predicate.Program.invalid_trace` and `invalid_run` cover these outcomes.
Reject sets status 1 and returns, so it does not erase a reachable path or supply
new length/validity facts. Admitted defaults satisfy the library's domain; the
wrapper also handles arbitrary defaults outside the application grammar safely.

Length predicates refine the path's selected-input interval. Bounded decimal or
based integer literals denote values in 0..4096; the source may express a smaller
capacity or an exact length using the admitted comparisons and short-circuit
operators. A source may reject valid input by its own logic. This is observable
source behavior, without truncation or a hidden change to the argument domain.
Each body expression is bounded under the facts established before its evaluation.

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
can replace it only when its exact affine length agrees with that shape on every
reachable input. This admits constant/mutable copies, self-copy and a
static/dynamic assignment justified by an exact-length predicate or true String
equality. `PathBounds` and `PredicateExecution` extend the shared fixed-bound
argument to those facts. Declaration initializers execute before body facts are
available and must remain safe across the full input domain.

`Bindings.assignment_length`, `assignment_preserves` and
`assignment_preserves_other` establish exact length compatibility, preserved
initialization/bounds and unchanged other objects. Output reads the resulting
store. Assignments may occur throughout sequences and conditional arms.
Each conditional arm starts from the pre-choice store; only the chosen one executes. Later
statements observe its updates. Output may omit every assignment target.

The source interpretation connects declaration elaboration and each parsed
read/write to these generic store operations; the [current delivery record](branches.md)
tracks its integrated validation. No path may read an uninitialized binding.
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

### Statement sequences, predicates and path facts

`PredicateStatements` executes ordered statements over the current initialized
store. `PredicateExecution` proves that the checked interpreter succeeds for
valid programs, preserves initialized bounds and carries the path context through
assignments, branches and joins. Repeated `elsif` selects the first true arm;
an omitted `else` leaves the false-path store and effects unchanged. Each written
arm is nonempty and may contain nested conditionals.

Conditions include String equality/inequality, fixed-bound length comparisons,
validity queries, grouping, `not`, `and then` and `or else`. Short-circuiting passes
only the applicable path facts to its right operand. True String equality (or
false inequality) can establish equal lengths; unequal bytes do not establish
unequal lengths. Operands must already be safe when evaluated. At least one
String comparison operand contains a declared name for Ada array-type resolution.
`IntegerLiteral` connects bounded Ada decimal/based spelling to exact values.

The context conservatively joins valid-length intervals and separately records
invalid-input reachability and rejection. Fixed bounds survive byte updates;
mutable byte equality and arbitrary disjoint sets of lengths are not retained.
Those explicit analysis limits affect membership, not inherited Ada meaning.
`PredicateConditionMeaning`, `PredicateBodyMeaning` and `PredicateGrammar`
connect the parsed source AST and faithful lowering to that same program's
execution and effects. `PredicateSourceBridge` and `PredicateCorrespondence`
combine those arguments with checked native equations and refinements. The
[delivery record](branches.md) records the completed 5a–5c milestone and keeps
focused evidence distinct from the final combined Linux checkpoint.

## Output effects and failure outcomes

`Predicate.Program.execution_sound` and `Current.effects_domain` prove that every
executed output value is printable and at most 4096 bytes. `OutputRuntime`
interprets the whole `Silver_IO` body: length guard, byte writes, LF write, flush,
checked statuses, failure-status assignment and early return. Its renderer matches
the actual body, with only checked Static ghost actions erased. GNATprove verifies
the wrapper for every String, including arbitrary lower bounds and oversize values.

Each call succeeds only if its requested bytes and LF are accepted and its flush
succeeds. A detected write/flush failure returns and records an accepted prefix
of that call's requested output. Later statements and calls still execute; a
later success does not clear the failure status. `SequenceEffects` combines
per-call traces in execution order with sticky failure. Under failure, the
combined bytes need not be a prefix of the entire intended output. Its cumulative
bound is the actual number of output effects times 4097; there is no separate
call-count cap. Reject records status 1 and returns without output of its own. Null returns
status 0 without output.

`Current.execution_specified` proves the per-call trace relation for every
modeled completed execution. `healthy_execution` gives the concatenation of all
requested outputs and expected status under healthy per-call environments;
invalid input remains a rejection, and valid input follows the program’s written rejection logic. `every_meaning_assured`
quantifies over every admitted meaning and environment, not just samples.

The observation is host C stream acceptance, not reader consumption or durable
storage. Blocking, signals, abnormal termination and arbitrary external exceptions
are outside the completed-reply model. No progress theorem is claimed for an
unresponsive output environment. libc, GNAT's returning status setter and normal
startup remain trusted dependencies.

## Mechanical proofs and their correspondence

A correct separate model or a matching source pin alone does not establish the
required correspondence. The checked chain has these distinct parts:

1. Seventeen handwritten source-binding modules fix `include_str` paths for the
   specifications and bodies of both recognizers, both lexical-helper units,
   the context/name and integer-literal helpers, the path-fact specification,
   and the six selected runtime files.
   Generated candidates reconstruct their exact included bytes and checked
   tokens. The generator cannot select replacement source bindings. Source
   alphabet checks include comments and literals.
2. `SourceBridge` and the retained `OutputSourceBridge`, `NamedSourceBridge`,
   `ArgumentsSourceBridge` and `LexicalSourceBridge` check complete reviewed
   token shapes, declarations, imports, contracts and the relevant typed
   lexical/runtime bodies. Surrounding scopes and helper declarations cannot
   disappear behind a selected-body comparison. The runtime bridges render the
   entire owned IO/Arguments bodies and conjoin checked source with refinement.
3. `ComposeExpressions`, `ComposeEvaluation`, `ComposeEquations` and
   `ComposeSourceChecks` retain shared typed binding, declaration, operand,
   expression and state-step interpretations. Their helper-only interface is
   separate from obsolete fixed-shell recognizer equations. Legal caller domains
   and recursive uniqueness establish those helpers' meanings for arbitrary
   callees satisfying their actual definition equations and verified contracts.
4. `Compose.Lexical.InterpretedSource` supplies only retained lexical equations.
   `interpreted_primitives` proves trivia, literals, identifiers, exclusions,
   name equality, capacities, tokens, normalization and allowed bytes on their
   legal machine domains. No whole-recognizer-equality premise is introduced.
5. `NamesSourceBridge` interprets context visibility, operation spelling and
   named/positional association through the checked source trees and recursive
   equations. Its concrete model inhabits all equations. Local binding lookup
   establishes hiding before use-visible operations are selected; the
   argument initializer also accounts for its own declaration name.
   `IntegerLiteralSourceBridge` and `PathFactsSourceBridge` interpret the checked
   integer parser and path algebra. Predicate native/basic/body/outer equation
   modules connect actual recursive scanners, tables and selectors to the
   mathematical parser. `PredicateSourceChecks` checks their source definitions;
   `PredicateSourceBridge` combines those checks and executable refinements;
   `PredicateCorrespondence` supplies arbitrary-callee recognition and selector
   conclusions. Concrete models independently inhabit the equation and native
   range/progress interfaces. `Form_Result` uses identity normalization and the
   specified source-length/allowed-character checks at that call site; their
   denotations remain part of the Ada/frontend interpretation premise.
6. The predicate grammar connects recognition to initialized, path-valid programs.
   `PredicateExecution`, `PredicateComposition`, `PredicateObligations`,
   `PredicateChecks`, `SequenceEffects` and `Current` connect source-order
   execution, every assignment/output/rejection, specified failure outcomes and
   modeled automatic discharge.

The interpretation of the checked restricted Ada fragment as these equations
uses the approved frontend's predefined operators, indexing, short-circuit
evaluation, scope and machine arithmetic. GNATprove proves actual caller
preconditions, numeric bounds, normalization and executable refinement;
these facts justify using helper meanings only on legal call domains.
Lean totalizations outside native checked domains are modeling artifacts, not
claims of equality with arbitrary Ada executions. Actual values are preserved
inside those domains; source contracts, machine types and GNATprove establish
that executed calls stay inside them. The concrete interpretation witnesses do
not remove the frontend premise.
Interpreting rendered statements additionally uses ordinary Ada initialization,
assignment, branches, sequence, return and verified Static ghost erasure.
This is a constrained semantic interface with explicit premises, not a verified
general Ada parser, arbitrary overload resolution or a theorem about GNAT's
implementation. The source-equation conclusions quantify over interpretations
satisfying their checked equations; they do not assume recognition correctness.

The current proof facade uses the predicate scanner and shared expression rules. Historical model
modules can remain as reusable mathematical developments, but obsolete
fixed-production source bridges do not establish correspondence for replaced
Ada functions. Source-pin changes must be reviewed together with these semantic
changes. The preceding Compose String Results checkpoint rebuilt its changed
output specification/body certificates and checked the whole project; ten
unrelated certificates retained identical bytes and modification times. The
completed Copy String Values checkpoint validates that earlier source/proof
revision; its exact certificate and cache scope is recorded in
[the capability record](copy-values.md). The [shared-bindings checkpoint](shared-bindings.md)
and [common-expression checkpoint](common-expressions.md) validate their earlier
revisions. The [sequencing checkpoint](statement-sequencing.md) validates its
recorded inputs; [branches.md](branches.md) records the completed 5a–5c
integration and the exact scope of its combined Linux validation.
The [Names and Calls checkpoint](names-and-calls.md) records its source
revision, its seventeen bindings/certificates, test repairs and complete cached
Lean build with a fresh axiom audit.
The later [Focused Source Checks checkpoint](focused-source-checks.md) narrowed
imports while retaining the complete module set. [Admission Repairs](admission-repairs.md)
records the complete Linux validation of the strengthened assignment and literal
rules, their source correspondence, checked Names helper identities and fresh
whole-project axiom audit.
The later [solver-allowance adoption](expression-headroom.md#production-adoption)
refreshes native and complete Lean evidence for the current 100,000-step driver,
with focused driver/runtime validation and unchanged admission rules.
The [Larger Expressions checkpoint](larger-expressions.md) extends admission to
64 leaves per expression and 63 operators per source, with complete native and
Lean validation, differential code generation, and the full suite followed by a
test-only fixture correction and focused recheck. Its specimen measurements
retain the external-tool premises below.

## Automatic completion and the external boundary

`PredicateObligations` associates each body expression and assignment with its
path's range or exact-length schema. `PredicateChecks` combines those with the
shared declaration schemas. Initializers use the full 4096-byte input domain;
body sites use the valid-length interval and separate invalid-input case that
reach them, including the right operands of short-circuit predicates. Prefix
and grouping results cover intermediate concatenations. The recursive statement
fold covers every assignment, condition, nested arm and subsequent join.
Assignment schemas require compatibility with the target's fixed bounds across
the entire reachable path. The model also generates a validity schema at each
output site, ruling out invalid-input output; this semantic schema does not add
another accepted native safety-record class. Path-check refinement preserves the
exact normalized schema and context; declaration checks retain their shared
refinement rules.
Every emitted safety obligation must correspond to the appropriate range or
length channel; report acceptance is not that correspondence proof.

The arithmetic argument bounds each admitted String value by 4096 bytes and
accounts for predefined concatenation's range arithmetic. Its conservative
range bound fits Ada's required minimum `Integer'Last` of 32767. The existing
`Guarded.RangeObligation` theory decides the uniform bound and covers empty and
nonempty ranges. Literal/object bounds and the normalized argument result supply
the inherited lower-bound behavior. No fixed prefix/suffix grammar is required.

`Current.all_obligations_discharge` proves terminating mathematical discharge
for every admitted meaning; `fragment_checks_valid` supplies schema validity.
`automatic_discharge_complete` returns the small uniform declaration-fragment
certificate after admission. Source-specific path schemas are discharged by the
separate universal theorem, not by that uniform calculation. The step bound in
`all_obligations_discharge` concerns the Lean-defined checker, **not** the runtime
or step count of CVC5, Z3 or Alt-Ergo.
A schema is not a prediction of the number of emitted GNATprove records:
static folding may eliminate checks, and translation may split or repeat them.

`Current.Tools` and `Current.ToolContract` state external operations and their
contracts as theorem parameters, without project-specific axioms. They require
faithful completed parsing, obligation generation, completion of proof for every
source schema accepted by the Lean endpoint-discharge checker, fixed-library
proof completion, same-source build completion, and preservation and realization
of modeled execution.
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

In particular, automatic discharge by the pinned proof portfolio within the application
configuration's 100,000 normalized steps and 1,000 MiB per-prover-process memory
limit, with sufficient environmental resources, remains an explicit premise.
Lean proves neither those solvers nor a universal bound on their work. Native
experiments
exercise maximal source/operand lengths, capacity boundaries and report shapes;
the earlier measured margins belong in [the historical record](string-results.md).
Expression evidence is in [common-expressions.md](common-expressions.md);
the [sequencing record](statement-sequencing.md) contains its application
report-capacity and dense-assignment measurements. The later
[branch record](branches.md#bounded-5bc-capacity-assessment--2026-10-14) records
the completed 782-assignment specimen and its narrower report margin.
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

Integer Image adds a proved semantic refinement of the selected producer model.
Its theory constant, model recognizer and exact byte-splice are tied to their
authoritative SPARK sources. The production driver connects them through native
SPARK contracts and reviewed call ordering: successful snapshot/model selection,
exact theorem installation, successful refinement, then original-vendor spawning.
The installer's successful postcondition establishes complete theorem-byte
readback; the driver's Static argument equality establishes the exact original
options with only the selected model replacement and optional proof-directory
pair. Native source review checks the selected file paths and error branches.
The [Image adapter boundary](trusted-boundary.md#image-proof-adapter-boundary)
states the remaining executable-selection, filesystem and process assumptions.
These distinct arguments do not add an unproved model axiom or a whole-CLI
correspondence claim.

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
assumed, justified or unexpected warning records. Both owned-body reports require nonempty
checks. IO requires proved Put and Put_Line postconditions, and Arguments requires
a proved First_Or_Default postcondition. The two interfaces require full package
coverage and specification coverage for exactly
the approved imports. No historical check total substitutes for coverage.

### Source-selected application policies

`Uses_Arguments`, `Uses_Assignment` and `Uses_Output` have SPARK-proved refinements to
the same grammar's selectors. The driver uses only the argument and assignment
selectors to compute `Application_Kind`, then uses that kind consistently in
report acceptance and build/publication prerequisites. `Uses_Output` currently
has no driver consumer; each policy permits its recorded entity-set alternatives
with neither, either or both `Put` and `Put_Line` entities. A genuine producer may omit a callee even
when the source calls output.
All output shells use `Complete_Application_Proof`; only null retains
`Complete_Null_Proof`.

| Policy | Source composition | Expected call-report entities | Advisory allowance |
| --- | --- | --- | --- |
| Static | Static sequence without assignment | Main, optionally Put and/or Put_Line | Initializer, statically known predicate and exact ghost-output advisories |
| Argument | Argument-input sequence without assignment | Main and argument callees, optionally Put and/or Put_Line; producer may eliminate calls | Same exact messages |
| Assigned | Static sequence containing assignment | Main, optionally Put and/or Put_Line | Above plus exact unused-assignment advisory |
| Selected | Argument-input sequence containing assignment | Main and argument callees, optionally Put and/or Put_Line; producer may eliminate calls | Above plus exact unused-assignment advisory |

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
message `unused assignment`. All four policies additionally permit
`INEFFECTIVE` / `statement has no effect` and `DEAD_CODE` /
`this statement is never reached`, observed for statically known predicates.
Every allowed advisory must have warning severity,
flow provenance, Main filename/entity, a positive location and no suppression
or justification. There is no independent advisory-count cap; the source grammar
and complete report domain still constrain production. These diagnostics do not
waive safety checks. Repeated output permits exactly `"NAME" is set by
"OPERATION" but not used after the call`, with OPERATION either `Put` or
`Put_Line` and NAME one of `Written_Count`,
`Flushed`, `Succeeded` or `Written_Bytes`. Other messages remain rejected. Some legal names make GNATprove omit an advisory.

The application warning list also permits the pinned `imprecise-image` advisory
described in the [Image producer record](for-loops-integers-image.md). Its full
message, warning severity, trivial provenance, Main filename, positive location,
unknown status, absent entity and justification fields, empty suppression string
and structurally empty proof tree are checked. In SARIF, the matching advisory
must retain the producer's open/warning classification and exact external
suppression marker. These fields classify a disabled-by-default advisory; they
do not suppress a required safety check. Runtime warning policies stay unchanged.
The raw-byte policy and its correspondence with the projected report include
these warning records, whose complete bytes are preserved by projection.

A bare-Main report may have an empty flow list and may contain proved safety
checks and approved dependencies. Sequencing removed the earlier nonempty-flow
and empty-proof/dependency conditions for that entity shape, while retaining
complete Main coverage and validation of every emitted record. Argument policies
additionally permit exactly Main with First_Or_Default and Reject, with either,
any combination of Input_Is_Valid, Put and Put_Line. Positive-length predicates can
establish validity without a query, and a shell need not output. Main alone
remains the producer-elimination alternative. Each permitted set is exact;
unknown, missing-within-a-set or duplicate entities remain rejected. Native tests
use genuine reports and mutations; the Python evidence helper applies the same
policies and additionally checks SARIF consistency and totals. The finite sets
and permitted producer elimination remain an explicit tool-format premise.

The bounded, nonrecursive executable scanners have SPARK-proved equality to
independent Static ghost `Runtime_Report_Policy` and `Application_Report_Policy`.
These specifications describe byte traversal, quoted strings, nesting, audited
fields, entities, dependencies and every emitted record, without calling the
executable acceptance traversal. Shared elementary predicates and immutable
tables do not replace that refinement. Retained application audit data has a
16,777,216-byte domain; runtime data retains 262,144 bytes. These are storage
bounds after the streaming projection of unaudited `check_tree` values, not
limits on original evidence-file length. The original reports remain unchanged,
and every record and policy-relevant field remains in the audited input.
The [capacity repair](report-capacity.md) records the current source/producer
envelope and the projection's SPARK argument. It is not a Lean-derived JSON-size
bound. The earlier [capacity evidence](statement-sequencing.md) keeps its
historical input and buffer scope.

The stream-to-policy argument starts with the actual reader's uncapped raw-byte
sequence. `Complete`, `Model.Refines` and `Model.Matches` connect that sequence
to the streaming state, emitted bytes and returned buffer prefix.
`Actual_Projection` derives independent, ordered
`Audit_Projection_Observations` from the complete raw input, including projected
scanner endpoints, exact retained content and selected `{}` replacements.
`From_Buffer` identifies the emitted sequence with `From_String` of the actual
prefix. The application/runtime correspondence theorems then equate
`Unbounded_Application_Report_Policy` or `Unbounded_Runtime_Report_Policy` on
the raw sequence with the corresponding bounded policy on that prefix.

The driver saves Main's raw sequence and successful EOF/close observation before
runtime reads reuse the reader's ghost state. The runtime audit saves each
selected report in its own snapshot. Build and publication require the saved
raw-policy facts together with the executable audit results and completed reads.
The separate null recognizer retains its raw reader and 262,144-byte policy
domain; it is outside this structural correspondence theorem. The
[repair checkpoint](review-343c2f8-repairs.md#integrated-checkpoint) records the
validation status of the complete argument.

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
--prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000 -j0`.
Null uses `--warnings=error`; all output routes use `--warnings=continue` so
their precisely permitted advisories can be classified from the complete report. Every selected library report remains strict. Successful process exit
and accepted report content are separate requirements. `warn_error` is not a
catch-all list of frontend compiler warnings, and this policy does not claim
that GNAT emits no such warnings.

The explicit memory allowance preserves GNATprove 16.1's previous effective
level-2 policy: `--memlimit=0` was treated as unset and still selected 1,000 MiB.
This caps each external prover process, not aggregate compilation memory;
frontend/flow work and concurrent prover processes require additional host
resources. On Linux the pinned Why3 runner applies an address-space limit of
1,048,576,000 bytes. The 100,000-step setting is normalized by GNATprove: the
effective Why3 step limits are 100,000 for Alt-Ergo, 3,515,000 for CVC5, and
80,450,000 for Z3. The [proof-policy repair record](proof-policy-repairs.md)
records the regression and measured limits. This policy does not assert that
each solver succeeds within its allowance: the review observed Alt-Ergo running
out of memory on an admitted goal, while Z3 proved every measured hard goal.

Every fresh output compilation proves its selected libraries as well as Main.
Zero wall-clock timeout does not prevent crashes or resource failure, and the
step bound excludes frontend/flow work, OS delays and total elapsed time.
Failure prevents publication; no warning suppression or obligation waiver is
introduced to make an admitted source pass.

### Running a verified application

`silver run SOURCE -- [arguments...]` uses the same proof, report and publication
guards before invoking the application. `Silver_Platform.Run_Application` copies
the selected suffix of the immutable compiler argument vector into an owning
argument list. Its SPARK loop invariants and Static assertion establish that
every supplied string equals the corresponding original argument, in order,
before the external spawn call. This equality is proved in Silver-owned code,
not assumed as a postcondition of an imported function. Empty strings and argument
boundaries are retained; a NUL guard prevents passing a truncated C argument.

The existing GNAT runtime spawns the executable without a shell and frees the
allocated strings and list afterward through its existing cleanup entry point.
SPARK checks ownership and the cleanup contract's use. Physical spawning, exact
Unix argument delivery and deallocation retain the pinned-runtime ABI and
resource premises in the [trusted boundary](trusted-boundary.md#application-process-boundary).
The driver propagates runtime results in `0 .. 255` unchanged and maps other
returned results to status 3. Its nonzero diagnostic does not infer a failure
cause: status 1 can mean specified rejection, detected output failure or an
indistinguishable launch failure.

The configured proof/build tools still use the existing shell command path.
This CLI change adds native SPARK obligations, not a new Lean CLI correspondence
theorem; the seventeen embedded source bindings and application semantics are
unchanged. The [Run Arguments record](run-arguments.md) tracks the current
checkpoint and its actual validation status.

## Compiler verification evidence

Both recognizers have proved executable/ghost membership refinement.
The output selectors refine the same source grammar; `Step` preserves valid
parser state. Lexical contracts, normalization, exact decimal rendering, source
capture, observed I/O, report-policy refinement and driver ordering are verified
alongside bounds, overflow, initialization, invariants and termination where
applicable. Every Silver-owned compiler/runtime body and the generated
`Silver_Build`/`Silver_Library_Sources` units require full SPARK coverage.
Specification-only coverage is restricted to the approved external import
declarations and the exact Static ghost Character-sequence vendor instance
described in [the boundary audit](trusted-boundary.md#audit-of-the-boundary).
Every Silver-owned implementation and proof helper still requires full coverage.

`Complete_Null_Proof` retains equality with its independent bounded report-pattern
policy and requires the genuine null report's completed single-entity analysis
and empty checks. Its narrower format guarantees are distinct from the output
report traversal. The driver preserves the raw-file reader on this route;
projection correspondence applies to the application and runtime traversal
policies. Both depend on faithful producer reports.

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
