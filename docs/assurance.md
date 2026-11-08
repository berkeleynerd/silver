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

## Small nonrecursive scalar functions

The [function increment](scalar-functions.md) extends ordered Main declarations
with closed Integer/Boolean functions and whole-assignment calls. Its
[delivery record](scalar-functions.md#delivery-assurance-and-validation) retains
complete native and Lean/source assurance, applicable regression results and
final review status on the exact implementation inputs.

`ScalarFunctions.DefinitionsChecked` checks each definition against exactly the
earlier signatures. `compileDefinitions` constructs the executable environment
in the same order. `compileDefinitions_valid` and `checked_definitions_safe`
establish that every definition, including an unused one, returns within its
declared result type for every fitting tuple of formal arguments. The body
executes in its own initialized local/formal frame and has no effects. Calls
resolve only to earlier definitions; their argument expressions use the same
incoming caller state. Integer calls expose their declared result interval,
while Boolean calls export no predicate facts. Finite counted loops and the
ordered definition construction retain termination without recursion.

`Definition.obligations` includes local initializer, body and terminal-return
checks. `definitions_obligations_discharge` covers the complete declaration
list. These obligations and the constructed environment are consumed by the
existing program execution and obligation endpoints, rather than considering
only functions reached by the sample or Main's execution.

The source path retains all declarations through `FunctionDeclarationsAt` and
`Sequence.FunctionTokensAt`. Their checkedness and uniqueness results feed
`Predicate.form_reading_valid` and `SourceMeaning`, tying the ordered
typed definitions to the admitted author source. The metadata, visibility,
formal/local declaration, body and return readers have corresponding source
trees, native domains and equations. Their authoritative token checks remain
part of the required complete source checkpoint.

`FunctionDeclarationNative.InterpretedSource` takes raw definition equations,
native contracts and direct callee links. Its lower `Predicate.BodyLibraries`
derivation uses `RawHelperEquations`; it does not require the completed function
declaration law as a premise. Body-reader equations, normalized wrapper models
and actual/return-import meanings are derived internally. The
[independent repair review](reviews/review-scalar-functions-raw-source-r1-e76a3f9420.md)
records the #340 correction and its exact scope. The model inhabitant exercises
this construction, while the integrated source bridge retains the complete
native domains and identities of the actual callees.

The unchanged-source native recipe adds `--no-inlining` for function-bearing
programs so every function is analyzed over its formal domain. The
[source-selected policy](#source-selected-application-policies) requires exact
Main/local-function coverage and successful termination witnesses, retaining
all safety checks and the permitted local Effects/AoRTE dependencies. The
[producer account](scalar-functions-report-capacity.md) extends the retained
report envelope within the existing allocation. Its
[bounded review](reviews/review-scalar-function-capacity-20261107.md) does not
replace complete compiler proof or the final Lean/source audit.

## Boolean scalar objects and expressions

The [Boolean delivery checkpoint](boolean-objects.md#delivery-assurance-and-validation)
records complete Linux native and Lean/actual-source assurance on
`8f676fc40975781cdcaa50772d4d95f7e40054a1`, with exact
native, actual-source/module/axiom and regression evidence in the linked packet. The arguments
below cover the resulting language and its permitted compositions. Focused checks
and samples remain corroborating evidence.

`BooleanBindings` separates initialized Boolean storage and visibility from
Integer and String bindings. The ordered declaration semantics preserve the
initializer's value, including immutable snapshots. `ComposeBooleanDeclarations`
and the predicate model use earlier declarations' exact elaboration values;
body reads and writes retain the declared scalar and array domains. A stored
Boolean value carries no relation to the Integer, String or argument-validity
facts from which it was computed. Boolean assignment therefore cannot recover
an earlier guard or justify a later unsafe operation.

The predicate semantics distinguish eager `and`, `or` and `xor` from
`and then` and `or else`. Eager operands must both be safe under the incoming
facts, and their result contributes no operand-derived refinement. Short-circuit
forms pass the appropriate outcome facts to their right operand. Boolean
negation swaps outcomes; Boolean equality compares values without retaining
relations to the expressions that produced them. Existing scalar, String,
argument-validity and loop-composition arguments apply through the extended
condition and body models.

Actual-source interpretation uses typed Boolean declaration and assignment
bodies, checked precedence and scope, and authoritative token equality.
`ComposeBooleanDeclarationLibraries` connects each raw declaration callee to its
checked lexical, binding, initial-flow or condition-reader interpretation on the
native ready domain. The declaration equation follows from those meanings; it
is not an assumed equality between the compiler scanner and the admission model.
`PredicateFlowBounds` permits mutable flow facts within their declared bounds,
including during elaboration, matching the native precondition. The Boolean
binding and xor lexical-scanner checks join the complete source requirements.

The [producer account](evidence/boolean-objects-20261030/producer-review.md)
uses the existing safety classes and report envelope. Nested xor is excluded
because the pinned producer duplicates its operand formulas; each xor operand
must contain no xor. The source restriction is checked lexically, ignoring
strings, comments and identifier substrings, and is reflected in admission and
source correspondence. Independent xor expressions remain available. No report
policy, source budget or required obligation is relaxed.

## Fixed-size Boolean arrays

The [Boolean-array delivery record](boolean-arrays.md#delivery-assurance-and-validation--2026-11-07)
records the exact implementation, scoped reviews, successful Linux native
Bronze/Silver and complete Lean/source checkpoints, and ordinary final build.
It separately tracks final runtime applicability and the exact closing review
target and disposition. The proof structure below retains the existing explicit
source/native-refinement and automatic-pipeline premises.

Integer and Boolean arrays share descriptor bounds and source-derived allocation
budgets, with a component-kind tag distinguishing their typed projections.
`ScalarExpression` excludes Boolean cells from Integer expressions;
`BooleanArrays` reuses the checked index layout with a Boolean store and proves
initialization, selected-cell updates and preservation of other cells and
scalar Boolean bindings. Native Integer placeholder values reserve storage;
they do not encode Boolean execution values.

`ComposeBooleanArrayTrace` retains every raw initializer condition and reads
all aggregate elements in the same incoming declaration environment.
The declaration semantics evaluate those conditions to exact stored Boolean
values, so later writes do not alter snapshots. `ComposeBooleanArrayElaboration`
separately accounts for the native allocation placeholders. `PredicateBooleanArrayBodySource` connects
checked indexed reads and writes to their native helpers; target index and RHS
use the incoming state, with updates carried through the existing finite loops.
Stored Boolean reads return the incoming facts for both outcomes and cannot
recover scalar, String or input-validity relations from an earlier condition.
Eager and short-circuit operands retain their ordinary safety rules.

The source chain includes component-mark resolution, Boolean-array header and
initializer helpers, typed indexed conditions and assignments, and the actual
String/Character initializer and write traces affected by the shared store.
`Compose.SourceBridge.actual_boolean_array_helpers` transports the checked
helper shapes to the authoritative implementation tokens. These checks must
compose with the complete source/endpoint, module and axiom audit and native
Bronze/Silver obligation coverage. Focused builds, matching pins and sample
outputs do not individually establish the resulting-language guarantee.

## Named Integer subtypes and bounded components

The [delivery record](named-integer-subtypes.md#delivery-assurance-and-validation)
identifies this extension's implementation/review target, complete Linux native
and Lean/source audits, retained regressions with the repaired-source refresh,
and scoped independent reviews. The feature is implemented and validated in
[PR #289](https://github.com/berkeleynerd/silver/pull/289), merged on 2026-10-31. Named subtypes carry nonempty static Integer bounds in a separate
metadata environment. They allocate no runtime value cells and preserve Integer's
operations and meaning. `IntegerSubtypeBindings` models ordered lookup and the
operation-hiding flags; `ComposeSubtypeDeclarations` connects subtype and type-mark
readings to the parsed bounds, including optional narrower object constraints.
`ComposeSubtypeChecks` retains and discharges both endpoint expressions' raw
arithmetic obligations. `ComposeInitializerTrace` and `SequenceSubtypeReady`
carry validity and hiding facts through the complete ordered declaration trace.

Each array descriptor now carries its component interval. `IntegerArrays`
checks every initializer and indexed write against that interval and proves
preservation through the actual component update. `ArrayBindingsOrdered` and
`ArrayBindingsRead` connect disjoint storage segments, initialized-value
containment and subsequent body ranges. Constant-array iteration uses the same
component interval for its immutable nonstatic element. Scalar guard refinement,
mutable widening and scoped identity restoration retain their existing rules.
The endpoint statement gains no owner-supplied assumption or annotation.

Typed subtype lookup/type-mark/declaration trees and the array helper trees
pass source-token, explicit precedence/scope inventory and interpreted-equation
checks. The structural inventories apply to the named tree languages; they do
not establish a uniform guard for every source-tree representation. The array metadata and environment predicates now
have rendered trees and domain-implies-precondition theorems in
`ArrayBindingsNativeEquations` and `ArrayBindingsSourceChecks`, tying the
strengthened mathematical allocation domain to the checked native predicate.
These helper results retain the integration scope described below; they do not
replace the complete authoritative-source checkpoint.

The [producer and report account](named-integer-subtypes-report-capacity.md)
retains the existing accepted check classes. Static subtype declarations add no
new runtime proof entity; bounded components use the existing range-check route.
Shorter scalar declarations raise the conservative Main envelope to
31,822,336 bytes, within the existing 32 MiB allocation. The source, operator and
operand budgets and the frontend/tool premises remain unchanged.

## Fixed-size Integer arrays

The [delivery assurance and validation record](fixed-integer-arrays.md#delivery-assurance-and-validation)
identifies the exact native, Lean/source, regression and independent-review
evidence for this bounded fragment. `ArrayLayout.lean` gives each descriptor a
finite segment in the existing Integer store and proves indexed projection,
initialization, component update and disjoint-cell preservation. Indexed
`Integer.Expr` checks a nonempty subscript interval contained in the descriptor
bounds and joins the addressed cell ranges. `IntegerChecks.lean` retains index
and aggregate-length obligations. `IntegerArrays.lean` requires mutability and
the declared component range for every target cell and RHS containment before indexed assignment, deriving
store-fit preservation while leaving other cells unchanged.

Declaration elaboration uses exact initialized components; indexed snapshots
remain nonstatic. Body reads use declared component ranges, with no element-wise flow
refinement. The parsed header supplies the array environment, initial store and
source-derived scalar/index bounds used to separate array, scalar and loop
identities. Loop execution captures its bounds before iteration and threads
component writes through the store, preserving earlier snapshots and existing
String/input facts. `ComposeInitializerTrace` and `ComposeArrayChecks` retain
the original initializer, index and arithmetic obligations before snapshot
folding; `PredicateChecks` carries them into current-language discharge.

The source chain derives declaration behavior from typed native bodies and raw
helper equations in `ComposeArrayEquations`, with each helper's actual caller
domain and capacity/cursor premises. `ComposeSourceChecks` transports reviewed
complete-shape checks to authoritative output tokens through
`Output.SourceBridge.actual_complete_shape`. `PredicateArrayBodySource` connects
the scalar-only subscript reader, array-aware RHS reader, flow overlay and
indexed-assignment helpers; `ScalarExpressionSourceBridge` includes the indexed
read helper bridge. `PredicateSourceChecks` requires authoritative complete
source shapes, and `PredicateSourceBridge` combines those checks with executable
refinements. The parsed meaning and retained obligations feed `Current` through
the existing correspondence chain. A matching source pin or focused model proof
alone does not establish these actual-source conclusions; the frontend and
interpretation premises described below still apply.

The array helper claims have distinct integration levels.
`ArrayBindings.SourceChecks.CheckedSource` checks complete helper source shapes
and feeds the helper correspondence side theorems; it is not a field of
`Predicate.SourceBridge.CheckedSource`. The `maxBindings` and `maxElements`
constants are connected by the complete specification token pin rather than
separate constant-extraction equations. Mutable-cell write-frame and raw header
elaboration lemmas remain independently checked supporting results; the
current public endpoint does not consume every such lemma. The read-only
array-frame theorem applies to all programs satisfying its validity hypotheses,
not only programs with no mutable arrays. These distinctions describe the
existing proof structure and do not weaken any theorem or change the endpoint.

The [producer/capacity record](fixed-integer-arrays-report-capacity.md) connects
index and aggregate conversion routes to the pinned producer. Its exact
array-loop advisory withholds information and never excuses a failed check.
The retained Main envelope is 25,084,928 bytes, covered by a 32 MiB allocation;
the runtime/null limits and language source/operator budgets are unchanged.
Broader array forms remain outside the admitted fragment.

## Constant Integer-array iteration

The [#264 delivery record](constant-array-iteration.md#delivery-assurance-and-validation)
identifies the complete Linux native and Lean/source checkpoint, reviewed
regression coverage and independent review. Its retained caches and incremental
builds are distinguished from clean rebuilds and independent kernel replay.
The predicate core's
`arrayLoop` retains the resolved array descriptor, direction and fresh element
identity. Execution captures the finite index sequence once and reads the actual
component at each step. It restores the scoped binder while retaining writes to
other objects. The core requires valid nonempty bounds, declared component ranges,
readonly component cells and separation from both the element binder and every
nested loop binder.

`PredicateExecution.statements_constant_components` reuses immutable-store
preservation. `arrayLoop_components_stable` strengthens it through nested bodies,
and `arrayLoop_body_actual_component` relates the element value to the actual
component. Thus temporary lexical bindings cannot silently overwrite array
storage in the mathematical store. The source chain derives binder separation
from the existing scalar/array allocation rules; it is not an assumed bound on
arbitrary mathematical identities. Ordered finite enumeration covers both
directions, and the nonempty array transfers the definitely-executed body's
String/input facts. Mutable scalar widening and outer immutable facts follow the
existing loop rules.

`PredicateObligations` includes the implicit cursor's array-index schema and
the body's ordinary obligations. The same descriptor bounds establish every
implicit component access. `PredicateLoopNative` connects the native `of` branch
to source readings and the dedicated semantic constructor. The complete
checkpoint includes the authoritative source chain, full source-shape checks
and byte-exact certificate; focused proofs and matching pins alone do not
establish that correspondence. All admitted body compositions retain their
required obligations under the existing frontend and tool premises.

The [producer/capacity account](constant-array-iteration-report-capacity.md)
inspects GNAT's indexed-loop/component-renaming expansion and charges its
implicit check sites and shorter syntax. The revised 31,269,376-byte envelope
fits the existing 32 MiB allocation. No new diagnostic class, runtime library,
tool or source/operator limit is introduced. Mutable iterables remain excluded.

## For loops and standard Integer Image

The [completed Linux capability checkpoint](for-loops-integers.md#stable-delivery-evidence)
records the coordinated scanner/schema, consumer and whole-document endpoint
audits, complete native validation and independent review for the delivered
fragment. The external premises below remain part of the assurance claim.

The scalar grammar combines signed-32-bit Integer objects and scoped indexes
with grouped arithmetic, comparisons and standard Integer Image. The
[bounded mutable extension](bounded-mutable-integers.md#integrated-validation-and-review)
includes the [completed review repairs](review-b79b986403-repairs.md) for
B1's frontend acceptance failure and M1's declared-range source-reading gap.
The original checkpoint remains historical evidence. The selected model
retains exact ordered initializer values separately from Ada-staticness,
mutability and declared ranges. Its complete native and Lean validation,
regressions and independent source review are recorded at the linked checkpoint.
Interval proofs cover every intermediate operation, including minimum-value
negation. That earlier checkpoint used declared mutable read ranges; the
[guard increment](#scalar-guard-refinement) below
adds explicit flow refinement. Bounds are read once at loop entry. The semantic
loop argument is induction over the finite Ada range, independent of runtime iteration counts and solver unrolling. Existing
String snapshots, path facts, returning output/rejection effects and fixed-bound
assignments compose through empty, definitely nonempty and uncertain loops.
Image contributes its derived length interval to every String expression
position, including concatenation and assignment.

At that earlier checkpoint, mutable body reads used the whole declared range.
`Integer.Assignment.check_sound`
derives safe RHS evaluation, target-range inclusion and preservation of the
scalar range invariant. `Integer.Assignment.execute` changes exactly its target;
`Integer.Assignment.unchanged` proves preservation of every other scalar value.
Declaration snapshots retain exact values, including
constants copied from mutable objects; these snapshots do not acquire
Ada-staticness. The guard increment replaces the earlier nonrefining assignment
and comparison analysis with separate current flow and declared ranges.
`Predicate.Execution` threads Integer and String stores through branches,
sequences and each finite iteration. Loop bounds use the entry store, and
`restoreIndex` restores only the scoped index. `Program.scalar_execution_invariant`
preserves declared ranges, while `Program.all_obligations_discharge` covers
initializers, assignment range checks and every body obligation. Image lengths
use exact values during declaration elaboration and the current scalar read
interval in the guard body analysis. Input-length facts survive scalar
writes; live mutable Image equalities are not retained.

`ScalarConstraintAt` independently reads optional declared constraints: absent
`range` denotes the selected type mark's bounds (full Integer for `Integer`); a present range has source readings of
both static endpoint expressions, exact delimiter/cursor positions and bounds
equal to their evaluations in the elaboration store. This relation is required
by `ScalarDeclarationAt`; `scalar_declaration_checked` consumes its endpoint
meaning. `Sequence.scalar_tokens_source_bounds` carries the property through
the parsed trace, and `Predicate.meaning_scalar_source_bounds` gives it for
every decoded declaration at the program endpoint. These M1 repair proofs passed
focused validation and the [complete repair checkpoint](review-b79b986403-repairs.md).

`Sequence.scalar_tokens_objects` connects the parsed declaration trace to
ordered object elaboration, and `Predicate.form_reading_valid` connects that
trace to the body checker. The actual-source connection additionally checks
the typed constraint/declaration and scalar-assignment bodies, their imported
callees, the six-field native binding record, and the widened body environment.
The environment's verified full-array mapping contract yields the active-prefix
map consumed by the adapter; mere agreement of a source pin is insufficient.

The source argument must use the checked scalar-literal/expression, interval,
Predicate and Compose equations together, retaining their executable refinements.
It must then join the actual Image scanner's initialized execution to complete
normalized template matching and original insertion offsets. The full typed
Integer, String and Image schemas are checked against the native template bytes;
partial name or tag observations do not establish their meaning. Broad producer
string spelling is handled before accepted-match liveness establishes ASCII.
Equal valid normalized bytes determine equal values through the internal
`JSON.Valid.encode_injective` theorem in
[ImageModelCanonicalRead.lean](../proof/Silver/ImageModelCanonicalRead.lean),
and `Valid.canonical_meaning_eq` supplies equal semantic projections. A
terminating mathematical decoder proves the canonical round trip for
independently valid ASCII integral JSON, including arrays, objects and valid
signed integer tokens. It retains numeric token spelling, including negative
zero. This is not unrestricted injectivity of arbitrary `Value.encode`, a
runtime parser, or a proof that the external parser succeeds or is correct.
The selected-schema and refinement endpoints no longer take external parser
soundness or finite-template parsing-success hypotheses. The
[consumer interpretation and original typed-context premises](trusted-boundary.md#image-proof-adapter-boundary)
remain required. The [remediation record](review-b8f1d0b9a8-repairs.md#focused-proof-evidence)
separately identifies the focused checks for this strengthening.

The reverse connection covers every admitted program's generated model:
unchanged or refinement, as appropriate. The
[complete producer review](for-loops-image-producer-review.md) establishes the
pinned source routes for exact selected templates whenever emitted, unique
selected names, Image's Integer/String dependencies and broad document syntax.
Complete automatic discharge also requires every admitted Main Integer Image
occurrence to use the pinned size-12 `Standard_String__Img.to_string`
translation. The scanner checks templates, not Main occurrences; this
[producer applicability premise](trusted-boundary.md#image-proof-adapter-boundary)
is rechecked when the producer pin or admitted Image form changes.
`ProducerSchemas.envelope` derives scanner requirements using finite template
validity and source-interpreted table bytes. `producer_finishes` and
`FilesSource.native_producer_finishes` derive successful initialized scanning
and `Finish`, including models without Image, without assuming acceptance.
`JSON.DocumentSpan.field_room` derives per-theory room from the physical
whole-file bound. Faithful external serialization in the intended Natural
counter domain remains an explicit premise; the compiled counter increment
is unchecked. Generic well-typed JSON or parser faithfulness alone does not
supply these precise producer-format properties.

The exact clone fixes all five substitutions, qualified primitive identities,
type roles, import and alias scope. Its signature instantiates
`IntegerImageTheory.assertion_valid` at size 12. The asserted decimal length is
therefore derived from predefined Image semantics and the proved theory, not
assumed from scanner acceptance or supplied as an unproved model axiom.
`ImageModelConsumerBoundary` connects the actual consumer's returned signature
through the reviewed finite constructor, namespace and primitive-meaning
contract. That contract concerns the actual checked `Clone.substitutions`,
not arbitrary trees with equivalent decoded role rows. The fixed mathematical
role decoder alone does not establish the consumer connection.
Scanner-derived offsets, the native Files contract and syntax-preserving
insertion must establish the complete transformed document. Removing precisely
the two added spans recovers the original bytes in order. The corrected 23-ID
band is fresh above every admitted producer counter and within the consumer's
integer range; see the [producer review](for-loops-image-schema.md).

`FilesSource.native_refined_document` in `ImageRefinementEndpoint` connects
those facts to the actual template selectors, initialized scanner, native file
execution and refined output. `producer_refined_document` in
`ImageProducerEndpoint` derives refinement from the producer contract;
`RefinedDocument.consumer_instance` in `ImageConsumerEndpoint` identifies the
actual inserted clone and its scope and derives the interpreted Image assertion.
The final audit recorded in the capability checkpoint covers this combined chain. Source certificates, separate
model theorems, matching hashes or successful examples do not individually
establish the composition. Physical filesystem, parser, qualified-name
resolution and tool execution remain explicit external premises; Silver-owned
matching, exact payload selection, source correspondence and obligation
discharge remain required proofs.

## Interval-checked Integer division

The [division capability record](integer-division.md) tracks the current
implementation and its completed Linux validation checkpoint. Fully grouped `/`,
`mod` and `rem` compose through every scalar-expression position, including
initializers, static constraint endpoints, bounds, comparisons, assignments and
Image. Exact declaration snapshots and immutable declared assignment bounds
remain distinct from the current scalar read intervals introduced by the
[guard increment](#scalar-guard-refinement). Guards
and assignments update current intervals under its selected rules; division
retains the same interval safety checks.

[IntegerDivision.lean](../proof/Silver/IntegerDivision.lean) uses `Int.tdiv`,
`Int.fmod` and `Int.tmod` for Ada quotient, modulus and remainder. Its
`checkedDivide_sound`, `checkedModulo_sound` and `checkedRemainder_sound` derive
interval inclusion, definedness and Integer-range safety for every represented
operand pair. Quotient uses the four endpoint quotients; the remainder operators
use exact singleton evaluation or proved sign/magnitude bounds. Each nonempty
divisor interval excludes zero before empty propagation. This last ordering is
a conservative Silver restriction. Minimum/-1 is excluded for quotient overflow;
`mod` and `rem` retain their defined zero result.

[IntegerChecks.lean](../proof/Silver/IntegerChecks.lean) adds separate `divide`,
`modulo` and `remainder` obligations. Their `Valid` interpretations require
nonzero divisors and in-range results, with the quotient's minimum/-1 exclusion.
`Obligation.discharge_sound`, `Expr.obligations_discharge` and
`Expr.automatic_discharge_complete` connect endpoint checks to every expression
node and safe checked evaluation. `PredicateObligations` and `PredicateChecks`
carry those scalar schemas through declarations, assignments, loop bounds,
predicates and Image into `Program.all_obligations_discharge` and the current
language endpoint. These are mathematical discharge claims under the stated
external-tool premises, not measured solver completion bounds.

The checked native helper interpretation in
[ScalarsNativeSourceBridge.lean](../proof/Silver/ScalarsNativeSourceBridge.lean)
provides `divide_sound`, `modulo_sound` and `remainder_sound`;
[ScalarExpressionSourceBridge.lean](../proof/Silver/ScalarExpressionSourceBridge.lean)
and the Compose work-counter equations connect actual recognition, case-insensitive
whole-keyword matching and shared operator accounting. Source-shape comparisons
must be reviewed with these semantic extensions. The independent
[source-bridge integration review](reviews/review-integer-division-integration-14b9302a97.md)
reports no findings at `14b9302a97`. The complete source/module/axiom audit passed
on the final implementation inputs, as recorded in the capability record;
static review and executed validation remain separate claims.

`VC_DIVISION_CHECK` / `division check proved` is the additional accepted Main
safety-record class. Its semantic obligation is the nonzero second operand above;
complete proved status, provenance and coverage are still required. The
[feature-local producer/report calculation](integer-division-report-capacity.md)
adds at most one 2,048-byte retained record per new operator occurrence, within
the unchanged aggregate 63-operator budget. It extends the previous Main envelope
from 15,292,416 to **15,421,440 bytes**, below the unchanged 16,777,216-byte domain.
The calculation relies on the reviewed pinned producer routes and inherited
counting premises; neither report acceptance nor sample success proves discharge.

## Scalar guard refinement

The [guard delivery record](scalar-guard-refinement.md#delivery-assurance-and-validation)
records #234/#239/#240's completed native Bronze/Silver verification,
authoritative-source Lean checks, whole-project module/axiom audit and delivery
validation on the final guard inputs. Its linked evidence distinguishes final
checks from historical focused runs on earlier source bindings. The
[final integration review](reviews/review-scalar-guard-final-integration-20261026.md)
at `bc9b0815eb` reuses the earlier scoped semantic and source reviews; the later
[proof-only candidate repair](reviews/review-scalar-guard-candidate-integration-repair-20261026.md)
records renderer normalization and the exact required header lexer spellings.
The later [compiler advisory assessment](reviews/review-scalar-guard-array-initialization-advisory-20261026.md)
reviews exact diagnostic classification and the malformed-message guard, with
all safety checks, source coverage and provenance still required. The proof chain below retains the Oracle's guarantee and existing external
premises; proof success remains separate from source membership.

[ScalarFlow.lean](../proof/Silver/ScalarFlow.lean) separates current read intervals
from `Integer.Analysis.declared`, mutability and Ada-staticness. Its
`refineComparison_sound` derives concrete-store containment for either comparison
outcome. Refinement selects a bare resolved mutable/index identity against an
Ada-static singleton threshold, in either operand order, after both operands
have checked in incoming flow. `refineOrKeep` retains the incoming interval when
the selected intersection is empty; it does not prune the independent
input/String context or excuse static illegality. A single interval retains the
hull of a hole. Immutable declaration snapshots remain exact and retain their
original staticness; a singleton mutable read or nonstatic snapshot does not
become a static threshold.

[IntegerMutable.lean](../proof/Silver/IntegerMutable.lean)'s
`Assignment.check_flow_sound` proves safe RHS evaluation in incoming current
flow, containment in the target's immutable declared bounds, concrete-store
containment in both resulting flow and declared ranges, and agreement with
checked execution. `Assignment.after` replaces only the target's current interval
with the inferred RHS. The nonempty-RHS requirement remains, including in empty
loops and unreachable arms. `statement_ranges_invariant` and
`statements_ranges_invariant` in
[PredicateStatements.lean](../proof/Silver/PredicateStatements.lean) preserve
abstract containment in declared bounds. `statement_preserves_fixed` and
`statements_preserves_fixed` preserve immutable cells.

[PredicateChecking.lean](../proof/Silver/PredicateChecking.lean)'s
`Condition.refine_sound` covers true/false transfer, negation and short-circuit
reached flow. Branches join scalar intervals componentwise using `Ranges.join`;
`Ranges.join_left` and `Ranges.join_right` retain either concrete outcome.
Scalar reads and Image inside String expressions use that same reached flow.
`loopEntry` and `loopExit` in `PredicateStatements` capture bounds in entry flow,
then widen every mutable cell to its declared range before analyzing the body.
Outer-index facts survive entry; the fresh immutable index uses its captured
interval. `Analysis.widen_closed` in `ScalarFlow` supplies repeated-iteration
closure when readonly values are preserved. An abstractly empty loop returns
entry scalar flow; a possibly executing loop widens mutable exit intervals and
restores entry immutable/outer-index facts, dropping its own index. No
loop-carried scalar invariant is inferred. More precise bounds can expose an
empty index-dependent assignment RHS, so no blanket admission-monotonicity
claim is made.

`statements_execution_sound` in
[PredicateExecution.lean](../proof/Silver/PredicateExecution.lean) composes
concrete current-flow and declared-range containment with checked execution,
String bounds and effects across every branch and finite iteration.
[PredicateComposition.lean](../proof/Silver/PredicateComposition.lean)'s
`Program.current_scalar_execution_invariant`, `Program.scalar_execution_invariant`
and `Program.immutable_snapshot_preserved` expose the corresponding program
claims. Input-length facts survive scalar writes; no relationship to a later
live mutable Image is retained.

The source correspondence has additional exact domain obligations.
[PredicateNativeState.lean](../proof/Silver/PredicateNativeState.lean)'s
`Native.ValidContext` includes `ScalarMetadata.BaseReady`, separately from
`Native.ValidFlow`. The [#244 repair](reviews/review-scalar-guard-context-domain-repair.md)
adds nonempty bounds for every active mutable binding, including hypothetical
bindings beyond the declaration prefix. `BaseReady.mutable_bounds` and
`baseReady_iff_native` in
[PredicateFlowInvariant.lean](../proof/Silver/PredicateFlowInvariant.lean) match
all scalar native context clauses, including declared-bound containment.
`prefix_baseReady` in [PredicateHeaderFlow.lean](../proof/Silver/PredicateHeaderFlow.lean)
derives readiness from actual parsed declarations; immutable loop-index append
preserves it without forbidding empty indexes. This repairs a formal contract
domain, with no new language restriction or external premise. The final
source checkpoint includes the integrated #244 repair.

The [#243 repair](reviews/review-scalar-guard-token-wrapper-repair.md) preserves
the full raw token domain. `Adapter.takeTokenModel` in
[PredicateAdapter.lean](../proof/Silver/PredicateAdapter.lean) uses inherited
spelling/word-token semantics, including nonfixed token kinds.
`Wrappers.token_expression_projection`, `normalize_tokens` and
`token_interpreted` in
[PredicateAdapterEnvironment.lean](../proof/Silver/PredicateAdapterEnvironment.lean)
derive raw callee meaning before semantic fixed-token projection. The last
projection requires `Adapter.FixedToken`; `basic_token_calls_fixed`,
`loop_token_calls_fixed` and `body_token_calls_fixed` in `PredicateBasicLibraries`,
`PredicateLoopHelpers` and `PredicateEquations` establish the actual caller
inventories. `model_raw_equations` supplies a concrete full-domain witness.
Normalization is therefore conditional on the inherited lexical equations,
never an assumed replacement of raw `Take_Token` behavior.

The endpoint chain uses typed source trees, arbitrary-callee equations,
checked contracts and concrete model witnesses. `syntax_bareTarget`,
`scalarAt_staticness`, `scalarCondition_whenTrue_model` and
`scalarCondition_whenFalse_model` in
[PredicateScalarGuardMeaning.lean](../proof/Silver/PredicateScalarGuardMeaning.lean)
connect parsed identities/staticness to semantic refinement.
`PredicateConditionMeaning` and `PredicateBodyMeaning` carry complete flow into
[PredicateGrammar.lean](../proof/Silver/PredicateGrammar.lean)'s `meaning_valid`
and `source_execution_sound`. Flow storage and read overlays are interpreted in
`PredicateFlowSourceBridge`; scalar helpers,
conditions, assignments and loops retain their respective native equations and
source checks. `Implementation.Definitions` and `Implementation.correspondence`
in [PredicateEquations.lean](../proof/Silver/PredicateEquations.lean) compose
those domain-bounded calls; `Implementation.model_definitions` witnesses that
interface. `SourceChecks.actualSource` in `PredicateSourceChecks` checks the
authoritative spec/body tokens and the precedence/scope inventories explicitly
represented in its checked-source record. Its scalar-body, scalar-helper and
adapter fields additionally carry the constructor-level precedence and
association checks in `PredicateStructuralGuards`. They check nested operands
and accept same-operator Boolean nesting on either side. The Image scanner has
standalone structural/consume guard theorems beside its source-token checks;
`FilesSource.ActualSource` carries the `FilesSplice` expression guard, including
its numeric and byte-index children. The
[structural-guard record](source-tree-structural-guards.md) documents their
inventories, negative controls, review and validation.

These guards cover operators represented by the named tree constructors. They
do not parse opaque token leaves, including the fixed Boolean tests in
`PredicateLoopNative` and `ImageModelFinishNative`. They strengthen evidence
behind the interpreted-source premises without removing those premises or
changing the endpoint statements. Exact token/source checks, applicable semantic
equations and ordinary correspondence review remain required.
[PredicateSourceBridge.lean](../proof/Silver/PredicateSourceBridge.lean)'s
`checked_source` and `actual_source_correspondence` retain explicit
`InterpretedSource` dependencies. `executable_correspondence` additionally
requires `ExecutableRefinement`, whose public wrapper equalities require native
verification. Neither matching pins nor inhabited model equations establish
those executable facts.

Obligation generation follows admission's exact intermediate flow:
`Condition.obligations_exact`, `simple_obligations_exact` and
`all_modeled_obligations_discharge` in
[PredicateObligations.lean](../proof/Silver/PredicateObligations.lean) feed
`Program.all_obligations_discharge`, `Program.checks_fragment` and
[Current.lean](../proof/Silver/Current.lean)'s `all_obligations_discharge` and
`automatic_discharge_complete`. The latter is the modeled automatic checker;
actual generation coverage and pinned-solver completion retain the existing
`Current.ToolContract` premises. Under that contract and the interpreted/native
wrapper dependencies,
[PredicateCorrespondence.lean](../proof/Silver/PredicateCorrespondence.lean)'s
`executable_main_correct`, `current_executable_membership` and
`executable_pipeline` connect admitted authoritative source, unique meaning,
execution, every modeled obligation and the same-source tool pipeline. These
are conditional claims under those explicit dependencies, checked at the final
guard checkpoint, with no new trusted premise or obligation suppression.

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
The program additionally shares a sixty-three-operator budget across String
concatenations and scalar arithmetic, including all predicate operands and
conditional arms. A source precheck skips complete literals and trivia/comments;
its verified traversal counts operator ampersands and the admitted scalar
operators, including whole case-insensitive `mod` and `rem` keywords. `/=` remains
a comparison and contributes no division occurrence. This permits one maximal
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

1. Handwritten source-binding modules fix `include_str` paths for the
   authoritative recognizer, lexical/name/path, scalar/interval/Image, adapter
   and runtime units. [AuthoritativeSource.lean](../proof/Silver/AuthoritativeSource.lean)
   is the normative import list (32 bindings at the For loops and integers
   delivery), paired with the lakefile's binary source dependencies.
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
   `ComposeSourceCandidate` performs the helper source decisions over the complete
   reviewed output shape without importing source bindings or certificates.
   `ComposeSourceChecks` retains the authoritative proposition names and theorem
   statements, transporting the reviewed checks through
   `Output.SourceBridge.actual_complete_shape` to certified actual output tokens.
   Reviewed-shape checks alone establish no actual-source claim; the final
   `ComposeSourceBridge.CheckedSource` interface remains authoritative and unchanged.
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
shared declaration schemas. Scalar interval proofs additionally establish each
intermediate signed-32-bit arithmetic result and its overflow obligation;
Integer Image contributes its exact possible length interval. Loop schemas
cover once-evaluated bounds, scoped indexes, finite iteration and the composed
String/path facts for empty, nonempty and uncertain ranges.
Initializers use the full 4096-byte input domain;
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
Every emitted safety obligation must correspond to the appropriate range,
length, index, overflow or nonzero-divisor channel and its scalar, Image, loop or
String/path schema;
report acceptance is not that correspondence proof.

The length argument bounds each admitted String value by 4096 bytes.
`Guarded.RangeObligation` decides its conservative uniform length bound using
Ada's required minimum `Integer'Last` of 32767. Actual endpoints of fixed-bound
slices, copies and concatenations require an additional argument: source-derived
metadata bounds each nonnull first index by a declaration-count-scaled ceiling,
and the covered expression length bounds every grouped intermediate. The
resulting endpoint bound uses the pinned signed-32-bit `Integer'Last` of
2147483647, rather than 32767. The actual execution store retains null
endpoints; dynamic metadata may use a different valid null interval. The checked
repair relates these intervals by null equivalence, without assuming equal
endpoints for every empty String.
`Predicate.source_actual_string_bounds_assured` now derives the initialized
bounds store from the source and connects these facts to the exact source-schema
inventory, raw initializers, reached body expressions and every loop iteration.
Both `Current.admitted_assurance` and `Current.every_meaning_assured` expose
this guarantee. The [#304 semantic review](reviews/string-character-core-20261031.md)
accepted that connection. The [delivery evidence](bounded-string-characters.md#delivery-assurance-and-validation)
records the successful complete native and actual-source checkpoints, final
regression coverage and independent source review.

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
The generation relation must associate every emitted range, length, index, overflow or
nonzero-divisor check with its source schema; that association alone does not establish that the producer
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

The physical `buildCompletes` premise includes the application build's
reviewed frontend options. [Blocker #284](scalar-guard-frontend-repair.md) exposed
an admitted contradictory-guard assignment whose runtime interval theorem is
valid but which GNAT's current-value replacement rejected. The repair selects
the pinned frontend's `-gnatdM` option to disable that optimization, retaining
the same author source, admission rules, runtime checks and obligation policy.
This is a correction to the external-tool configuration; it neither strengthens
the Lean theorem into a verified GNAT result nor weakens its completion premise.

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

Integer Image's completed delivery requires the full semantic/source refinement
above, in addition to the arithmetic theory and byte-splice properties. The
[capability checkpoint](for-loops-integers.md#stable-delivery-evidence) names
`ImageProducerEndpoint`, `ImageRefinementEndpoint` and `ImageConsumerEndpoint`
and records the final combined audit/review evidence. The production
driver connects them through native
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

The [indexed Main repair](indexed-main-discovery.md) uses admission's existing
one-unit property to select Main explicitly in the generated project. The
driver reads `main~1.spark`; its report policies continue to require the entity
and source identities `Main` and `main.adb`. This project configuration and
artifact selection belong to the native driver guards and reviewed tool
ordering, not an embedded Lean source certificate for the complete CLI.

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

For the [scalar-function increment](scalar-functions.md), these runtime
entity alternatives additionally require every source-declared local function.
Admission supplies its exact source name; coverage does not accept arbitrary
`Main.` prefixes or omit unused functions. Function-bearing proof runs use
`--no-inlining` to analyze each body over its full formal domain. The exact local
entities may carry successful `SUBPROGRAM_TERMINATION` flow records and
`CLAIM_EFFECTS`/`CLAIM_AORTE` dependencies, with the same complete safety-check
discharge requirements as Main. No function postcondition is assumed. Complete
delivery validation remains pending as recorded in the capability record.

Every emitted application safety record must be a proved/info `VC_RANGE_CHECK`,
`VC_LENGTH_CHECK`, `VC_OVERFLOW_CHECK`, `VC_DIVISION_CHECK` or `VC_INDEX_CHECK`,
with filename `main.adb`, the exact Main or declared local-function entity,
valid positive location, prover completion and no suppression or justification. Empty safety
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
flow provenance, filename `main.adb`, the exact Main or declared local-function
entity, a positive location and no suppression
or justification. There is no independent advisory-count cap; the source grammar
and complete report domain still constrain production. These diagnostics do not
waive safety checks. Repeated output permits exactly `"NAME" is set by
"OPERATION" but not used after the call`, with OPERATION either `Put` or
`Put_Line` and NAME one of `Written_Count`,
`Flushed`, `Succeeded` or `Written_Bytes`. Other messages remain rejected. Some legal names make GNATprove omit an advisory.

Identified local functions additionally permit `UNUSED_VARIABLE` with exactly
`unused variable "NAME"`, warning severity and flow provenance. The name obeys
the checked Ada identifier grammar and 4,096-byte source bound. The source file,
positive location and exact local entity remain required, and suppression or
justification is rejected. This unused-formal advisory is excluded from Main's
entity. Its producer route and storage accounting are retained in the
[function report-capacity record](scalar-functions-report-capacity.md).

The application warning list also permits the pinned `imprecise-image` advisory
described in the [Image producer record](for-loops-integers-image.md). Its full
message is accepted only with the producer's exact `Image`, `image` or `IMAGE`
attribute spelling; all remaining bytes must match. The warning severity,
trivial provenance, Main filename, positive location,
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
33,554,432-byte domain; runtime data retains 262,144 bytes. These are storage
bounds after the streaming projection of unaudited `check_tree` values, not
limits on original evidence-file length. The original reports remain unchanged,
and every record and policy-relevant field remains in the audited input.
The [capacity repair](report-capacity.md) records the source/producer envelope
and the projection's SPARK argument. The
[bounded mutable extension](bounded-mutable-report-capacity.md) bounds retained
Main reports by 15,292,416 bytes within the unchanged 16,777,216-byte domain,
including constrained declarations, scalar assignments and non-deduplicated
Image advisories. The [division extension](integer-division-report-capacity.md)
adds at most 63 nonzero-divisor records, yielding 15,421,440 bytes within the same
domain. These are source-reviewed producer bounds, not Lean-derived JSON-size
bounds. The earlier
[capacity evidence](statement-sequencing.md) keeps its
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
--prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000 -j0
--no-loop-unrolling`. Loop expansion is not an admission or automatic-discharge
argument.
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
theorem; the embedded source bindings and application semantics are
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
obligations. The exact compiler-only `array-initialization` information note in
`silver_output_profile` likewise withholds a flow fact and is counted separately
from required checks. The fixed-array extension separately classifies the
same exact information note in Main; all required flow/proof checks remain.
Exact rules and the pinned producer assessment are in [the trusted boundary](trusted-boundary.md).

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
