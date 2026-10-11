# Silver assurance argument

## Scope and current status

The [Oracle](../oracle.md) requires a language-wide guarantee: every source
admitted by explicit, decidable rules must automatically discharge every required
Bronze and Silver obligation. Prover success does not define membership. A proof
failure on admitted source is a toolchain or implementation defect.

The current [language specification](../language.md) states the admitted syntax,
restrictions and behavior. This document records its assurance argument and
evidence. Future capabilities remain in the [roadmap](../roadmap.md) until they
complete the [admission workflow](../development.md).

The SPARK implementation recognizes eight productions: null, literal output,
named-constant output, guarded command-line output, literal-backed concatenation,
guarded command-line concatenation, fixed-length literal assignment and
input-dependent branching. The latest completed source-correspondence and
validation checkpoint is recorded in
[source compartmentalization](lean-compartmentalization.md). This maintenance
change preserves the language rules and external assumptions while changing the
compiler's source boundaries and Lean dependencies. Its measurement record
includes complete native validation, source correspondence, the fresh axiom
audit and independent kernel replay. The preceding language increment is
recorded in [input-branching.md](input-branching.md).
The [focused-runner record](lean-iteration.md) describes the subsequent
workflow simplification; it changes validation scope and optional replay,
not the source-correspondence argument.
The preceding assignment increment is recorded in
[string-assignment.md](string-assignment.md).
The preceding report-policy refinement is recorded in
[command-line-greeting.md](command-line-greeting.md).
The preceding [command-line capability](command-line.md) and
[review repairs](command-line-review-repairs.md) retain their completed evidence.
Completed earlier capability evidence remains in [hello-world.md](hello-world.md),
the [repair record](hello-review-repairs.md) and [named-strings.md](named-strings.md);
workflow history is in [proof-workflow.md](proof-workflow.md) and
[review-repairs.md](review-repairs.md). These records retain their actual input
and platform scope; earlier results do not validate later changes.
Pinned Lean 4.34.1 proves membership and behavior of the restricted source
models. The first five, assignment and branching application safety-obligation
lists are empty. Guarded dynamic
concatenation has nonempty, universally valid arithmetic range schemas with a
proved finite decision procedure. The reviewed Ada argument and explicit
GNATprove-generation and bounded-solver-completion premises connect those models
to real programs, whose complete reports are checked. The fixed
runtime library set has its own nonempty, separately audited GNATprove
obligations. The compiler bridge checks authoritative bytes and the complete
reviewed source token shape, then proves membership equivalence for every
interpretation satisfying the checked definition equations. Interpreting those
equations as SPARK uses the approved front end and GNATprove's checked machine
bounds and contracts. A separate conditional theorem composes the external tool
contracts; it does not verify GNAT, the OS, or an arbitrary Ada front end.

Inherited meanings come from the checked-in
[Ada 2022 Reference Manual](../references/ada/2022/RM-TOC.html) and
[SPARK 16.1 Reference Manual](../references/spark/16.1/docs/lrm/source/index.rst).
The pinned frontend must support every source line and lexical element that fits
Silver's 4096-byte source bound. Ada's minimum required capacity alone does not
establish that; the native boundary compilation tests exercise this frontend
premise, as described in the [trusted boundary](trusted-boundary.md).
The assurance targets are the SPARK User's Guide definitions of
[Bronze](../references/spark/16.1/docs/ug/en/source/bronze_level.rst) and
[Silver](../references/spark/16.1/docs/ug/en/source/silver_level.rst).

## Null subgrammar and its proof

The original null recognizer remains a subgrammar of one current language, not
a separately selectable language edition. Let a source be a finite sequence of
bytes. It belongs to this null subgrammar
exactly when all of the following conditions hold:

1. It contains between 1 and 4096 bytes, inclusive.
2. Its non-comment whitespace consists only of space, horizontal tab, carriage
   return, and line feed.
3. Comments have Ada's `--` introducer and continue to carriage return, line
   feed, or end of file. Their contents consist only of printable ASCII bytes
   or horizontal tabs.
4. The explicit trivia/token grammar removes the permitted comments and
   whitespace and matches the entire following sequence with ASCII
   case-insensitive word equality and whole-word boundaries:

   ```text
   procedure Main is pragma SPARK_Mode ( On ) ; begin null ; end Main ;
   ```

All other bytes, tokens, and token combinations are excluded. In particular,
word tokens must retain their Ada lexical boundaries: removing a separator
between two words does not concatenate them into two tokens. Both occurrences
of the procedure name must be `Main`, ignoring ASCII letter case. No additional
compilation unit, context clause, declaration, or statement is admitted.

This rule is a predicate on source bytes, independent of any invocation or
result of GNATprove. A finite scan followed by comparison with the fixed token
sequence decides it. The source-size limit is an explicit language restriction;
it is not a limit inferred from a prover timeout.

The typed SPARK catalogue drives token comparison and JSON export. Character,
case-folding, comment-ending, and word-boundary rules are likewise shared
between recognition and export. The checked-in JSON is compared with the real
compiler output by the integration suite. The SPARK recognizer has a proved
postcondition equating its result with the independent ghost `Is_Member`
specification. The Lean source bridge checks the authoritative specification and
expression bodies, their typed syntax and precedence, and the denotation of
those expressions. `RecursiveBridge` interprets recursive calls parametrically,
applies the three uniqueness lemmas, and composes the resulting equivalences
with cursor/grammar equivalence in the final source theorem. A complete reviewed
token shape fixes surrounding declarations and binding scopes as well as the
selected bodies. The JSON names the admitted constructs, their conditions, the eight token
sequences and permitted compositions. Construct metadata is maintained explicitly;
integration compares parsed JSON values, not whitespace or key order. Output
word-token selection is explicit in the exporter. An integration assertion
compares its word set with the alphabetic tokens of the productions;
source checks separately bind those productions to the recognizers.

### Null structural proof

**Theorem.** Under the inherited Ada/SPARK semantics and the trusted external
toolchain/runtime boundary, every source satisfying the membership rule has the
same user-program behavior as the displayed null procedure and satisfies the
required Bronze and Silver safety properties.

**Lexical step (reviewed Ada correspondence).** Lean proves the custom grammar
and scanner equivalent. Agreement of that restricted grammar with Ada's lexical
rules is the following reviewed argument, not a theorem about a complete Ada
lexer. By membership condition 4, every admitted source has exactly
the displayed token sequence. The other conditions permit only Ada whitespace,
comments, and ASCII case variations, which do not change the meaning of those
tokens. Therefore each admitted source parses as the same single library
procedure body, named `Main`, with no parameters, one `SPARK_Mode (On)` pragma,
one null statement, and a matching named end. There is no second source unit or
additional executable construct hidden in an admitted layout or comment.

**Declaration step.** The procedure declares no objects, types, nested
subprograms, or other runtime entities. `SPARK_Mode (On)` selects SPARK analysis;
it introduces no executable computation. Thus the admitted declarative part
requires no user-code initialization or elaboration operation that could fail.

**Execution step.** Ada's null statement performs no action. Executing the
procedure body reaches that statement once and then returns. There are no
expressions, assignments, parameters, user-code calls, branches, loops, or
recursive edges. Consequently the user program has one execution path and no
value-dependent input domain. Its only argument tuple is the empty tuple.

**Bronze consequences.** No user variable is read, so uninitialized data cannot
be read. No parameters or globals are accessed, so parameter/global interference
and unintended global accesses cannot occur. There are no functions requiring
a function-termination argument; the sole procedure itself also terminates by
the execution step. No relaxed-initialization or exceptional-control-flow
construct can undermine these conclusions because none is admitted.

**Silver consequences.** There is no operation that can raise an unexpected
exception in the user program: no arithmetic, range conversion, indexing,
dereference, assertion, explicit raise, or subprogram call. Hence no source-level
runtime-check obligation can fail. Together with the Bronze consequences, this
establishes the required source-level safety properties.

**Composition step.** The null subgrammar permits precisely one composition of semantic
constructs: the library procedure wrapper, its permitted pragma, and its single
null statement. Its declaration and execution steps have already been covered.
Every remaining permitted variation is lexical and preserves this composition
by the lexical step. Thus the proof quantifies over all admitted sources and
all permitted compositions, not merely the checked-in `samples/null.adb` example.

This argument concerns the Silver source program. The GNAT-generated startup,
binder, linker, operating-system interaction, and runtime behavior rely on the
explicit external trust boundary; this document does not prove their
implementations.

## Literal-output membership and semantics

`OutputAdmission.LiteralAt` is the relational quoted-literal grammar used by
`Parsed` and the membership proof. It handles empty values and doubled quotes,
preserves case, and proves that decoded bytes are printable ASCII and bounded
by consumed source. `OutputLiteral` supplies the printable-byte predicate.
`OutputAdmission` defines the 23-token output production and proves scanner
soundness/completeness. Existing trivia and whole-word rules apply outside the
literal. `Current.Member` is the union of the null, literal, named, guarded
argument, concatenation, guarded concatenation, assignment and branching grammars; `Current.accepts_iff_member` connects
decidable membership to that union.
Only these eight compositions are included in the current model; their constructs are not freely
repeatable.

`OutputRuntime` models the actual wrapper's length guard, checked writes,
checked LF, checked flush, failure-status assignment and early return. Its
renderer matches the complete body tokens. Erased operations use a finite set
of fixed ghost actions and fixed loop annotations; checked declarations bind
those actions to Static ghost state. The bound is checked against the actual
`Max_Length` declaration. There is no arbitrary token-list erasure slot.
Interpreting the rendered statements as Ada still uses the restricted frontend
and erasure premises documented in the trusted boundary.

The success theorem requires acceptance of exactly the literal plus LF and a
zero flush status. A failed return records status 1 and an accepted prefix;
returning from the wrapper alone is no longer a claim of successful output.
The admitted `Main` has no following statement and returns with the stored
status. `healthy_output` proves success for every bounded literal when the
external calls return healthy statuses. These theorems model completed replies,
not physical delivery, signals or guaranteed external progress.

`Current.every_meaning_assured` covers every admitted source meaning.
`literal_domain` supplies the output bound from membership, including the
combined concatenation value. `action_domain` also covers initialized argument
values. `healthy_execution` gives exact output
and successful status for valid input under its output-environment premise;
invalid arguments still produce empty output and status 1. The null branch
retains empty output and successful status; the separate null semantics theorem
also proves unchanged abstract state.

### Output structural proof and obligation correspondence

**Lexical and declaration steps (reviewed Ada correspondence).** Membership
fixes one `with Silver_IO;`, the `Main` body, its SPARK pragma and one qualified
call with a string literal. Allowed trivia and case changes preserve those
Ada tokens. Doubled quotes decode to one quote; no expression, declaration,
second call or hidden unit can occur. The selected package declares the sole
called operation with an unconstrained `String` parameter and no precondition.
The literal's decoded length fits the checked wrapper bound. The context clause
elaborates the selected library; its initialization obligations belong to that
library's separately checked report.

**Bronze and Silver steps.** `Main` reads no uninitialized application data,
declares no variables or functions, and contains no arithmetic, indexing,
conversion or dynamic argument expression. Literal evaluation and parameter
passing require no run-time bound check for the unconstrained formal. The
callee has no caller precondition and neither it nor its imports can abruptly
exit the program under their SPARK contracts. Output failure uses the ordinary
returning GNAT status setter, then returns through the wrapper and `Main`.
Possible I/O blocking is explicit in `Always_Terminates => False` on procedures
and effectful imports; it is not a disguised program exit. Thus there is no
application-unit flow, run-time-error or program-exit obligation for this
production. Library checks remain required and nonempty.

**Composition and tool steps.** These steps cover every admitted literal and
layout, and exactly the one permitted call composition. GNATprove verifies the
wrapper for every `String`, including oversized and non-1-based strings.
For this literal-output form, Lean's `Current.obligations` is empty;
its discharge theorem follows from that definition. It does not independently
extract GNATprove obligations from Ada. Correspondence uses the reviewed
structural argument, the explicit faithful-generation tool premise and complete
real reports. The library-proof premise additionally assumes identical selected
sources, logical tool configuration and caller-independent verification; one
successful run alone is not a universal prover-completeness theorem.

### Named constants and their composition

`NamedIdentifier` defines maximal ASCII identifiers, the Ada reserved-word and
visible-name exclusions, and case-insensitive equality of bounded source spans.
`NamedAdmission` defines the separate 30-token production and its declaration,
literal and reference events. Scanner equivalence covers all admitted names,
trivia and literals; it does not merely recognize the motivating example.
`NamedSemantics` proves that the sole declaration initializes one binding with
the literal value, the sole reference resolves to that binding, and evaluating
it yields exactly the original value. The source meaning is unique, and the
literal retains the same printable-byte and length domain as direct output.
`NamedDisjoint` distinguishes this production from the earlier ones.

**Reviewed Ada correspondence and obligations.** The predefined unconstrained
`String` constant acquires its bounds from the initializer. No explicit subtype
constraint, conversion or assignment introduces a length check. All bytes are
initialized before the name is read, and there is no mutation, indexing or other
expression. Excluding reserved words and `String`/`Silver_IO` keeps the type and
package names bound to the intended declarations. The reference is the same
Ada identifier ignoring case. The output operation has no caller precondition
and accepts an unconstrained String. This adds no application-unit obligation;
selected library reports remain nonempty and required. These claims concern
this fixed composition, not arbitrary declarations or name resolution.

The named source semantics reduces to the same output value and verified
wrapper execution as the direct-literal form. Its success, partial-output and
status-1 failure outcomes therefore inherit the runtime theorem and premises
above. The `Current` pipeline also covers the concatenation and guarded argument
compositions below. This named-literal form has empty modeled obligations; the reviewed Ada argument,
faithful tool-generation premise and complete actual reports remain distinct
parts of the assurance.

### Literal-backed concatenation

The new production adds exactly `prefix_literal & Name & suffix_literal` to the
single output call of a literal-initialized constant. The initializer, prefix
and suffix obey the existing literal rules. The declaration and sole reference
obey the named-output rules; no additional shadowing exclusion is needed.
The name is read exactly once, and Ada's predefined String concatenations
associate to the left. Extra operands, repeated references, subexpression
parentheses and command-line initializers remain excluded.

**Reviewed Ada correspondence and obligations.** Under
[Ada RM 4.9](../references/ada/2022/RM-4-9.html), the literal initializer makes
the constant static, and its name and the prefix/suffix literals are static
string expressions. Predefined String concatenation is a static function, so
both concatenations are static expressions too. Their bytes are, in order,
prefix, initialized value and suffix. Left association fixes expression grouping;
the result does not depend on operand evaluation order because all operands are
pure. The existing name exclusions preserve the
predefined type and library binding, and no admitted declaration can replace
the predefined operator. String literals and their initialized constant have
the usual lower bound 1, including null strings; both concatenation results
fit the supported GNAT String index range.

The length argument uses the three distinct literal spans in one complete
parse. Their combined decoded length is at most the source length, not three
times that length. Quotes, escaping, syntax and trivia consume additional
source bytes without adding result bytes. The sole name reference inserts its
initializer value once. Consequently both the intermediate prefix/value result
and the final result are at most 4096 bytes and contain only printable ASCII.
This bound covers empty operands and doubled quotes. Each result fits the
existing output wrapper's domain without a new application guard or contract.

There is no constrained assignment, dynamic operand, index, conversion or
caller precondition. The source is passed unchanged to GNATprove and GNAT;
Silver neither computes a replacement literal nor emits replacement Ada.
The structural argument and genuine application reports support the existing
empty-application-report policy for this composition. The complete fixed
library reports remain required. Lean's modeled empty obligations, the reviewed
Ada static-expression argument, and faithful tool generation remain distinct
parts of the assurance. The [capability record](greeting.md) records the proof
integration and validation status.

The proof extension uses `ConcatAdmission` for the 34-token production and
`ConcatDisjoint` to distinguish it from the four earlier forms.
`Concat.parsed_literal_consumption` accumulates decoded bytes over the
whole parse using monotone cursor advancement. `concatenation_bounds` applies
that sum to both intermediate and final lengths; `output_domain` establishes
the printable-byte and maximum-length output domain.

The typed `Concat.Main.composition` shares its syntax between token rendering
and interpretation. Literal and reference nodes consume the parser's ordered
events, with actual binding lookup for the sole reference. This ties initializer,
prefix and suffix values to their source positions. The expression's checked
grouping enforces left association, while the decoder's event order makes no
claim about Ada operand evaluation order. `evaluation_refines` and
`execution_refines` connect the initialized binding, concatenated value and
existing IO wrapper. `Current.concat_execution_refines` embeds this result in
the current language through its existing output action.
`Concat.SourceBridge.authoritative_main_correct` retains the checked source,
parsing against the typed renderer, event evaluation and equality to
`Current.execute`. Reading the fixed syntax as Ada retains the frontend premise
above.

### Guarded command-line initialization

`ArgumentsAdmission` reuses the named identifier grammar and defines one closed
51-token production: the two ordered context clauses, one named constant
initialized by `Silver_Arguments.First_Or_Default`, and one mandatory validity
guard. Its event trace still has exactly one declaration, default literal and
matching reference. The name excludes `Silver_Arguments` in addition to the
named grammar's exclusions, so the initializer and guard retain their package
binding. The extra exclusion applies to both command-line productions.
`ArgumentsSemantics` proves unique source meaning, reference resolution and the
printable, bounded default domain; `ArgumentsDisjoint` separates it from all
three earlier forms.

`ArgumentsRuntime` renders the entire owned wrapper body from typed expressions
and statements. Its interpreter distinguishes normal return, fallthrough and
invalid argument/local reads. `initializer_refines` and `validity_refines`
prove that all inputs return normally in this model without invalid reads and
agree with independent argument-selection cases. Both queries use the same
immutable argument vector. Missing input selects the admitted default; one
printable ASCII argument of at most 4096 bytes selects its exact value,
including the explicitly empty String. Extra arguments, unsupported bytes and
oversized input select an internal empty initializer result and a false guard.
The mandatory false branch sets status 1 and returns without an output call.
The source composition cannot mistake that internal value for a successful
empty argument. An invalid default is guarded safely by the wrapper but cannot
occur in admitted source.

`ArgumentsSemantics` also defines a small typed `Main` composition. The same
initializer, reference and conditional nodes drive its token renderer and
execution interpreter. `Main.rendered_tokens` proves that this composition
renders to `Arguments.requiredTokens`; changing the branch order changes that
rendering. The interpreter evaluates the initializer before creating the
binding and executing the guard, and reports an uninitialized reference as a
failed evaluation. `Arguments.execution_refines` connects that execution to
`Arguments.Runtime.executeMain` for every admitted source meaning;
`Current.argument_execution_refines` connects the result to the current model.
`Arguments.SourceBridge.authoritative_main_correct` retains the checked source,
parsing against that rendering, and equality of the interpreted result with
`Current.execute` in one theorem.
These are model refinement theorems. Reading the fixed typed syntax as Ada uses
the reviewed frontend interpretation below. Output success, partial-output
failure and detected status 1 follow from the existing IO theorem. Input
rejection has no output even in an otherwise healthy output environment.
The interpreter handles completed imported calls, not storage exhaustion,
external mutation of argv, signals or unbounded external blocking.

**Reviewed Ada correspondence and obligations.** The `String` constant obtains
its bounds from a pure, unconstrained String-returning function with no caller
precondition. Its default is an admitted literal. The complete initializer
executes before the body, and the only reference reads the initialized constant.
The pure Boolean validity query has no caller precondition; the fixed `if`
selects either the unconstrained output call or the returning rejection
procedure. There are no source-level indexes, conversions, explicit String
constraints, arithmetic, assertions or proof annotations. No operation introduces
an application-author obligation. Runtime argument access is guarded inside the
verified library by its count checks. GNATprove analyzes library initialization,
function termination, argument-access preconditions and the bounded-printable
return postcondition. The report checker requires every emitted flow/proof
record to be proved and requires the `First_Or_Default` postcondition explicitly;
it does not require a record for every named obligation class. Completeness of
obligation generation remains a trusted GNATprove premise. GNAT may allocate the returned
String before Silver checks its length; that resource premise is explicit in
the [trusted boundary](trusted-boundary.md#command-line-boundary).

These structural steps cover every admitted default, identifier, lexical
variant and permitted argv outcome. They do not admit arbitrary conditions,
reassignment or general command-line access. The empty modeled Main obligation
list is connected to actual GNATprove generation by the same explicit tool
premise and complete report checks as the earlier forms.

### Guarded command-line concatenation

The sixth production combines the argument initializer with a fixed short-circuit
condition: `Input_Is_Valid and then Name'Length <= capacity`. Its output is
`prefix_literal & Name & suffix_literal`, and its false branch calls `Reject`.
Both references bind to the sole declaration. The canonical decimal capacity
must equal 4096 minus the decoded prefix and suffix lengths. Membership checks
this arithmetic independently of a prover result.

`GuardedDecimal` proves the bounded decimal scanner against a separate digit
relation and relates literal length to decoded bytes. `GuardedAdmission` defines
the 62-token grammar and ordered declaration/literal/reference/capacity events.
`GuardedSemantics` proves unique meaning, binding, source-consumption bounds and
the output domain for every argument vector. The typed `Guarded.Main.composition`
renders exactly to the admitted tokens and consumes those events in source
order. Its interpreter initializes the constant, short-circuits the guard and
selects output or rejection. `Current.guarded_execution_refines` connects it to
the current execution model; general conditionals are not admitted.

**Reviewed Ada correspondence.** The owned initializer's verified postcondition
now fixes the result's lower bound at 1. Extended returns construct
`String (1 .. Item'Length)` and copy the original value, including null and
non-1-based defaults. The original bytes and invalid-input behavior are preserved.
This is an owned-SPARK proof, not a new assumption about GNAT's returned bounds.
The Lean body renderer checks the extended-return statements; its byte-value
interpreter abstracts array bounds, whose numeric correctness is proved in SPARK.
This form concatenates the runtime result of the argument initializer.
Predefined Ada String concatenation and its runtime index semantics remain
frontend premises. The static-expression argument in the literal-backed section
applies to that separate form.

The pure initialized value is bounded by 4096. Each literal is bounded by its
consumption of source bytes. Both concatenations therefore fit the conservative
Integer range bounds 8192 and 12288, below Ada's guaranteed positive minimum
32767. Empty operands still require the owned lower-bound fact. The tighter
capacity guard independently ensures that the final printable result fits the
4096-byte output domain. A missing argument uses the default, a valid empty
argument prints just the decorations, and invalid or over-capacity input returns
status 1 without application output. Every branch reads initialized data.

`Guarded.RangeObligation` quantifies over every selected-value length
up to its bound. Its finite checker is proved equivalent to validity by checking
the maximum. Two source-operation schemas describe the left-associated sums;
`obligations_refine_uniform` bounds every admitted program by the two fixed
maximal schemas, and `all_obligations_discharge` proves their discharge.
`Current` composes these theorems with membership and execution. Its mathematical
step bound counts checker transitions, not external solver instructions.

Real GNATprove reports contain range checks, with optimization-dependent counts.
`Complete_Application_Proof` audits Main body coverage, the four exact called
library entities, every flow/proof record, approved dependencies and completed
analysis. It admits only proved Main `VC_RANGE_CHECK` proof records. It does not
pin a check total or infer that omitted checks were unnecessary: faithful and
complete GNATprove generation remains an explicit external premise. The previous
five forms retain their strict empty-report route. All selected library reports
remain required before build and publication.

### Fixed-length string assignment

The seventh production adds a literal-initialized `String` variable, one
assignment of an equal-decoded-length literal, and one final output call through
the same name. `AssignmentAdmission` defines the 33-token production, an
independent event grammar and a decidable scanner. The initializer length is
recorded before the assignment; both references obey the existing case-insensitive
identifier binding rules. `AssignmentEquations` proves uniqueness of the new
recursive suffix equation on its verified domains. `AssignmentExpressions`
checks the typed expression's grouping and closes its arbitrary helper calls
through the existing identifier/literal/trivia proofs.

`AssignmentSemantics` proves unique meaning, binding of both references and
`assignment_length` for every admitted source. Its variable model stores the
name, fixed length and current bytes. Assignment updates only the bytes after
checking target identity and length. The typed `Main.composition` uses the same
nodes for rendering and interpretation: it consumes declaration, initializer,
assignment target, replacement and output-reference events in order.
`assignment_preserves_constraint` and `evaluation_refines` establish that it
preserves the fixed length and output reads exactly the replacement value.
`AssignmentDisjoint` distinguishes the production from each earlier form.
`Current.assignment_execution_refines` integrates the result with the existing
output and failure semantics. The assignment source bridge retains checked
recognizer expressions, contracts and typed Main rendering; the current facade
also checks the new report selector's source-refinement contract.

**Reviewed Ada correspondence and obligations.** Under Ada RM 3.3.1 and 5.2,
the unconstrained `String` variable acquires its constraint from initialization;
assignment must preserve its length. Both values are fully initialized static
literals, including null strings and doubled quotes. Source membership establishes
equality of their decoded lengths, so the assignment's length check is statically
satisfied. No index, conversion, arbitrary expression or additional output
operation is admitted. The output reference resolves to the same variable and
observes the new bytes. Literal bounds put both values within the wrapper's
domain. The pinned frontend's faithful interpretation and static elimination
of that satisfied check remain external premises; the native experiment
corroborates them, including a deliberately failing unequal-length control.

The safety-obligation model is empty for this composition. GNATprove nevertheless
may report `INEFFECTIVE` for the initializer's overwritten value, whose length
still establishes the variable constraint. This is a dead-value advisory, not
an unproved safety obligation. `Complete_Assignment_Proof` retains and narrowly
classifies it, checks complete Main coverage and allowed dependency records,
and requires an empty proof list and no other warning records or skipped, assumed
or suppressed checks in the audited report. Successful tool termination is
checked separately; `warn_error` is not a catch-all list of compiler warnings.
The permitted library-effect dependency remains explicit. GNATprove omits the advisory for some legal identifiers, so its
presence is not an acceptance requirement. The assignment route uses
`--warnings=continue` to collect the full report; every other route keeps
`--warnings=error`, and every selected library report retains its strict policy.
No diagnostic is suppressed in source or erased from evidence. The independent
ghost `Assignment_Report_Policy` specifies this route and SPARK proves acceptance
equivalent to it. The [capability record](string-assignment.md) records genuine
report variants, mutation tests and validation.

### Input-dependent branching

The eighth production has one argv-initialized constant, the existing
validity/rejection guard and one inner String equality choosing between terminal
literal outputs. Its completed full assurance checkpoint is recorded in the
[capability record](input-branching.md).

`BranchingAdmission` defines the 67-token production, an independent event grammar
and scanner soundness/completeness. The existing literal grammar preserves all
four decoded payloads in order: default, comparison, matching output and other
output. In `BranchingSemantics`, `member_has_meaning`, `meaning_unique` and
`meaning_binds` establish the program payload and case-insensitive reference
binding. `choose` compares byte lists exactly; `unequal_lengths_choose_no` records
the differing-length case. `output_domain` bounds whichever output is selected
without summing unexecuted branches.

The typed `Branching.Main.composition` uses shared rendering and interpretation
nodes for initialization, reference lookup, predefined equality and the nested
conditional. `rendered_tokens`, `checked_precedence` and `instantiation` connect
the token production to its ordered parser events. `execution_refines` selects
the corresponding literal only after the validity guard; `missing_execution`,
`single_execution`, `empty_execution` and `extra_arguments_rejected` cover the
argument cases. `valid_output_success` retains complete bytes and successful
flush; `valid_output_failure` retains status 1 and an accepted prefix. There is
no statement after either output call.

`BranchingDisjoint` distinguishes the new form from all seven earlier grammars.
`Current.branching_execution_refines` integrates a distinct `branchingMain`
meaning, preserving input-dependent behavior in the union. Its range-obligation
list is empty, and it still requires fixed-library evidence.
`BranchingEquations` and `BranchingExpressions` supply the recursive recognizer
equation, uniqueness argument and typed expression interpretation.
`BranchingSourceBridge` checks the authoritative suffix body, numeric domain,
recursive contract and executable recognizer postcondition against the typed
expression, and connects the typed Main to `Current.execute`. The public union
is closed by `GuardedSourceBridge`.

**Reviewed Ada correspondence and obligations.** Both equality operands are
fully initialized Strings. Ada's predefined array equality compares element
values and length; it does not require equal operand lengths or equal bounds.
It preserves character case and does not concatenate, index or mutate the
application values. The selected output argument is one literal bounded by the
complete source. Default selection and the validity query retain the same
immutable-argv premise as the existing command-line forms.

The native experiment found empty Main flow/proof lists, including empty and
escaped literals, differing lengths and an exact 4096-byte source. The unchanged
driver routes this form through `Complete_Null_Proof` with `--warnings=error`;
it satisfies neither the dynamic-concatenation nor assignment selector.
No report policy, proof option, runtime source or library obligation is relaxed.
Faithful complete GNATprove generation and frontend equality meaning remain
external premises. Focused examples corroborate the route; they do not establish
universal assurance or substitute for the complete capability checkpoint.

### Selected library sources and evidence

Every output application project selects unchanged `main.adb` and exactly six
runtime files: the IO and Arguments specifications/bodies plus the Output_Libc
and Runtime interface specifications. Null applications select only `main.adb`.
Bootstrap embeds their exact bytes in `Silver_Library_Sources`; the
compiler rejects installation files that differ before snapshotting them.
The compiler audit checks this generated binding against the current source,
and Lean checks those source files directly. After editing a runtime file,
bootstrap, rebuild, compiler audit and complete Lean validation must be
refreshed together.
This binds source selection; it is not a compiler-binary attestation.

`Silver_Libraries` has proved contracts connecting captured expected bytes and
runtime rereads to byte identity. The driver records equality with the specific
captured source set before proof, build and publication. Library and application
snapshots are rechecked after proof and build. Stable workspace/project files
and genuine tools remain environmental premises.

`Silver_Library_Reports` checks complete selected entity coverage, completed
analysis, every flow/proof record, approved dependency assumptions, and no
skipped checks or `pragma Assume`. All four selected library reports are
required. The IO and Arguments bodies require nonempty checks and proved
`Put_Line` and `First_Or_Default` postconditions respectively. The Output_Libc
and Runtime reports require full package coverage and specification coverage
for their exact approved imports. No arbitrary historical check total is pinned.
The executable scan is bounded and nonrecursive. Its result is proved equal to
independent ghost policies, `Runtime_Report_Policy` and
`Application_Report_Policy`, and `Assignment_Report_Policy`. The ghost definitions specify byte traversal,
quoted/escaped strings, nesting, required immediate fields, entity coverage,
dependencies and every emitted result; they do not call executable traversals or record/coverage acceptance functions.
Elementary byte predicates and immutable policy tables are shared; data
constructors have exact component contracts. Refinement is equality, covering both
acceptance and rejection in the supported bounded format. These definitions
and lemmas use Static ghost erasure. The format still belongs to the genuine
pinned producer; this is not a general JSON or provenance theorem. Faithful,
complete obligation generation remains trusted.

## Compiler verification evidence

`Silver_Profile.Accepts` is the null source recognizer;
`Silver_Output_Profile.Accepts` recognizes the seven output productions. Both have an
independent ghost membership specification and proved executable refinement.
For the null recognizer, its postcondition is
`Accepts'Result = Is_Member (Source)`. The independent ghost specification uses
recursive comment/trivia boundaries, token spans, lexical boundaries, and the
fixed token sequence; it does not call the imperative recognizer. Loop invariants
and contracts establish the connection inside SPARK. The functions specifying
whitespace, allowed bytes, identifier characters, comment endings, case folding,
and word-token classification also have proved numeric postconditions.

`Silver_Numbers.Decimal` now also has a proved exact-value contract. Its ghost
`Represents` relation requires the last digit to equal the value's remainder
modulo ten, the preceding text to represent the quotient, and the empty prefix
to represent zero. This is positional decimal identity, without a saturating or
overflowing parser. The postcondition additionally forbids leading zeroes except
for a one-character result and retains the original length/digit bounds. The
full `Natural` input domain and the fixed-width reverse algorithm are preserved;
GNATprove unrolls its bounded loop and proves all unit checks.

`Silver_Reports.Complete_Null_Proof` has an exact functional postcondition:
its result equals the independent ghost predicate `Recognizes_Null_Report`.
The proofs cover removal of space/HT/LF/CR, quantified occurrence of the eight
required field patterns, and the first SPARK-entity prefix's single-entity shape.
Recursive congruence and helper refinements connect that predicate to the actual
bounded scanner. This is exact report-pattern recognition; the genuine pinned
GNATprove producer and its report schema remain trusted. It does not authenticate
arbitrary JSON or establish report provenance by text matching.

The compiler proof covers bounds, overflow, initialization, preconditions,
postconditions, invariants, and applicable termination checks. All owned entities
must have full SPARK coverage. The audit enumerates every current unit, including
IO and Arguments even though the compiler does not itself call their public
operations. The imported subprograms in three reviewed interface packages have
specification-only coverage; the packages themselves require full coverage.
Their existing implementation bodies are external. Generated `Silver_Build`
and `Silver_Library_Sources` are covered too. See the
[compartmentalization record](lean-compartmentalization.md) for current
maintenance validation and the [branching record](input-branching.md) for the
preceding language checkpoint. The
[command-line repair record](command-line-review-repairs.md),
[command-line capability](command-line.md) and
[Hello World repair evidence](hello-review-repairs.md) retain earlier baselines.

The report model and its refinement assertions use SPARK's predefined `Static`
level. GNATprove still verifies their bodies, recursive termination, contracts,
and loop invariants; GNAT omits those mathematical computations from the
executable. The actual bounded report scan and `-gnata`/`-gnato` remain enabled.
The driver checks the report once, retains its Boolean result as a runtime
guard, and has a separate static precondition requiring the semantic report
predicate before build/publication. The report domain remains 262,144 bytes.
The regression suite passes maximum-sized positive/negative reports through the
real CLI and verifies that GNATprove rejects a deliberately false static
postcondition. This is ghost erasure, not removal of proof obligations.

Optional diagnostics describe limitations on using recursive contracts and
numeric-variant expression bodies inside proofs. They withhold information; no
obligation is waived. The evidence auditor counts exactly those documented
limitation codes and rejects failed checks, incomplete coverage, source
suppressions, `pragma Assume`, unapproved external assumption dependencies,
justified obligations, and other warnings. The
[trusted-boundary document](trusted-boundary.md) specifies the exact imports,
contracts, report assumptions, and diagnostic classification.

Reproduce the compiler evidence from the repository root:

```sh
python3 scripts/dev.py prove --full
```

The full validation command supplies the required `SILVER_HOST`, forces unit
analysis, fixes semantic proof options, records parallelism, and audits the result.
A manifest binds all compiler/project/generated inputs, driver scripts, Alire
resolution/configuration, tool identities, and final reports by content hashes.
Before/after fingerprints must agree. SARIF and `.spark` diagnostics must agree
by rule, location and message; the summary must agree with check/entity counts.
No fixed historical check count is used as an acceptance criterion. The project has no
fallback output directory when that host setting is omitted.
The selected host's generated `Silver_Build` specification is included in the
same source-policy and proof-coverage audits as the shared compiler units. Its
constants select native tool/settings/context and output paths. Generated
configuration, Alire state, and compiler outputs belong to that host alone.

The audited regime explicitly selects `-U --mode=all --report=all
--warnings=error --checks-as-errors=on --level=2 --prover=cvc5,z3,altergo
--timeout=30`, a selected worker count (`-j 0` by default), a native filesystem
solver cache and `-f`. The cache is scoped by host and Alire lock identity;
GNATprove determines reuse for its proof tasks. Existing sessions are also
retained. A full audit therefore does not establish an uncached runtime bound.
Optional `dev.py prove --cold` implies the same full audit with fresh native
output, sessions and solver cache in a unique host-local workspace, preserving
ordinary warm state. It rejects custom `--subdirs` and prints its evidence path.
`--jobs N` controls resource usage. Other exploratory flags belong to
`dev.py tool`; direct exploratory GNATprove calls require an `explore` output
subdirectory and cannot select an audit-managed cache. This catches routine
command mistakes, not arbitrary wrapper behavior. Such runs do not create
audited success evidence. The wall-clock timeout remains machine-dependent;
passing evidence is not a performance guarantee on every host. Application
proof uses the separate deterministic step-limited configuration documented
below and in the trusted boundary. Its dynamic-range argument is distinct from
this compiler-development audit. The normal report
directory is `.silver/<host>/compiler/obj/gnatprove/`; cold runs use the printed
path under `.silver/<host>/compiler/obj/cold-<random>/gnatprove/`.
`gnatprove.out` provides the readable summary; `.spark` and SARIF supply the
machine-audited coverage and individual results. A process exit status alone is
not sufficient evidence.

Without `--full`, `dev.py prove` preserves sessions/reports and allows GNATprove
to skip unchanged units. The same logical options apply, but this incremental
feedback does not establish a newly audited complete report set. Before that
invocation, the selected directory's previous completed proof manifest is
invalidated. Development builds remain independent of proof state; compiler
binary attestation is deferred under the [pre-1.0 policy](../development.md).

## Source identity and automatic program verification

Membership is evaluated on bytes read from the author's actual Ada/SPARK source.
After admission, the compiler allocates a fresh private workspace and writes the
same bytes to `main.adb`. It rereads and compares that snapshot after writing,
after proof, and after compilation. GNATprove and GPRbuild use the same generated
project and the same explicitly named snapshot. The generated project selects
Ada 2022 and enables assertion/overflow checking; it adds no source contracts,
pragmas, or declarations.

These checks have proved contracts. Static ghost transcripts record bytes observed by
the actual read/write calls, closure/EOF observations, exact command text, and
returned process status. `Same_Source` establishes equality with the admitted
source from those observations. The driver's ordered proof/build/publication
guards require successful source and project writes, matching snapshots,
successful named tool invocations, and accepted proof evidence before publishing
an executable. These are connected contracts for the real SPARK procedures.
The transcripts and historical driver flags are erased from executable code;
their contracts remain GNATprove obligations. Mixed contracts retain Runtime
checks on actual bounds, commands, reports and source equality. See the
[native I/O record](native-io-performance.md) for the bounded erasure change.
The external filesystem, libc calls, and tool behavior retain their documented
trusted meanings; their implementations are not verified here.

The null program's real GNATprove report confirms one analyzed entity, full
SPARK coverage, completed flow/proof analysis, zero checks, and no skipped or
assumed obligations. These zero counts follow from the admitted semantics.
They are checked alongside coverage so an empty or incomplete run cannot count
as success. Verification failures return an error for an admitted program; they
do not turn the prover into the membership rule.

The regression suite exercises the actual SPARK CLI with case changes, comments,
CR/LF/tab layouts, maximum-length sources, extra constructs, identifier-boundary
errors, forbidden bytes, inaccessible files, and oversized sources. Native
proof/build/run cases verify snapshot identity, including 4096-byte variants.
Additional cases simulate external tool failure, incomplete proof reports,
skipped/assumed obligations, and source changes during proof or compilation.
These tests are implementation evidence, not a universal language theorem.

Completed assignment validation belongs in [string-assignment.md](string-assignment.md);
the completed eighth-form checkpoint belongs in [input-branching.md](input-branching.md).
Guarded-concatenation results remain in [command-line-greeting.md](command-line-greeting.md);
literal-backed concatenation validation remains in [greeting.md](greeting.md);
the preceding repair and capability results are in
[command-line-review-repairs.md](command-line-review-repairs.md) and
[command-line.md](command-line.md). Earlier
sample and regression results retain their scope in [hello-world.md](hello-world.md)
and [named-strings.md](named-strings.md).
Platform workers exercise hostile inherited tool settings, symlinked temporary
paths, and preservation of other-host artifacts. Those workers simulate foreign
hosts; only native execution establishes a platform's ABI compatibility. Actual
CLI tests also exercise installation paths containing spaces, quotes, shell
punctuation and Unicode, and invocation from another working directory.

## Mechanical proofs and their correspondence

Lean 4.34.1 is installed by `scripts/bootstrap_lean.py` from a release archive
whose upstream SHA256 is pinned for each supported platform. The version is also
recorded in `proof/lean-toolchain`. The Lake project treats warnings as errors
and has no Mathlib dependency. The runner defaults both Lake workers and threads
per Lean build/audit process to available CPUs; `--workers N` and `--threads N`
adjust these independently. The [concurrency record](lean-concurrency.md)
documents the measurements and remaining serial work. The build re-elaborates
Lake configuration on every invocation, because the pinned Lake
caches `get_config?` values without comparing new command-line options. This
preserves accepted module objects while making resource settings effective; a
real Lake regression checks both changed child arguments and cache reuse. The
optional `--memory-mb` setting is an internal per-process resident-memory
threshold in MiB, checked periodically. It is neither a hard OS-enforced cap nor
an aggregate budget for concurrent processes. The pinned standalone
`leanchecker` accepts no memory-limit CLI option.

Each native host uses its own `.tools/<host>/lean` installation and
`.silver/<host>/proof` workspace. The checker copies shared proof inputs
without modifying them and writes generated candidate certificates only in
that host's workspace. Lake's manifest and objects are isolated there too.
The workspace's sibling `src` link resolves directly to the authoritative
repository `src`, so `include_str` continues to bind the actual SPARK files.
A non-link source directory is rejected; the runner repairs its own outdated
source symlink and verifies that it resolves to the authoritative directory. No global mutable
host selector is used, and other-host or legacy flat artifacts are preserved.
Lean subprocesses discard inherited Lean/Lake/Elan overrides, bind the pinned
native installation explicitly, and use host-local system-config/cache paths.
External artifact restoration is disabled. Local Lake artifacts are preserved
unless `--clean` is requested. A real Lake probe with
poisoned inherited settings selected the same native tools and search paths as
the clean environment and left the foreign-host sentinel unchanged.

`scripts/check_lean.py` checks the pinned version, synchronizes proof inputs,
regenerates twelve candidate source-certificate modules and builds incrementally.
The handwritten `SourceCertificates` facade imports them; Lake can check their
independent declarations in parallel. The facade and source bindings remain
protected inputs, not candidate output. With no target, the runner builds the
whole project, executes `Silver.Audit` afresh even on a cache hit, and requires
every project module in that audit's actual import closure. Repeatable
`--target MODULE` options instead build selected modules and their dependencies,
then freshly audit their actual import closure. Focused results are separate
from complete results and do not establish complete source correspondence.
Both modes synchronize authoritative proof inputs before building.

The imported-module inventory comes from Lean's actual environment rather than
source-text regexes. The audit inspects the transitive
axioms of every declaration originating in a Silver proof module, including
private and generated declarations. It permits only Lean's standard `propext`,
`Quot.sound`, and `Classical.choice` foundations. Unfinished proofs,
project-specific axioms, and native-evaluation trust axioms fail the audit.
Routine validation uses the pinned local toolchain and Lake's imported object
cache. Optional `--replay` (with `--full` retained as an alias) independently
rechecks the whole environment with `leanchecker --fresh Silver.Audit` and is
incompatible with `--target`. This additional replay is useful for toolchain or
cache investigations and explicit audits; it is not an Oracle requirement.
`--clean` discards the host workspace without implying replay.

A successful complete check writes `.silver/<host>/lean-proof.log` and
`.silver/<host>/lean-evidence.json`. The concise result records scope, modules,
tool version and identities, phase timings, an aggregate input fingerprint and replay status.
Focused checks write `lean-focused.log` and `lean-focused-evidence.json` in
that host's directory. `--provenance` adds detailed
input, workspace and artifact inventories. Input and tool changes during
a run are rejected, and protected workspace copies must match shared inputs.
The current scope's stale success evidence is removed before setup or generation
begins; other hosts' evidence is untouched.

The earlier clean replay is recorded in [review-repairs.md](review-repairs.md);
incremental/full workflow validation is in [proof-workflow.md](proof-workflow.md).
Input fingerprints include orchestration scripts and proof/source inputs;
tool stability is checked independently. Detailed provenance is optional.

```sh
python3 scripts/bootstrap_lean.py
python3 scripts/check_lean.py
```

The proof chain has distinct checked components:

1. `Lexical` and `Admission` define an independent grammar for comments, trivia,
   token spelling and boundaries, and the null token production. They
   prove scanner soundness/completeness and `accepts_iff_member`.
2. `Cursor` proves that the 1-based cursor specification denotes exactly that
   grammar (`Cursor.isMember_iff`). `Uniqueness` proves that the recursive
   comment/trivia/suffix equations uniquely determine their meanings on the
   verified domains.
3. Twelve handwritten binding modules fix the `include_str` paths: both
   recognizer specifications/bodies, the `Silver_Output_Lexical` specification
   and body, and the six selected library files. `AuthoritativeSource` imports
   all bindings; each certificate imports only its own binding.
   `SourceLexer` rejects bytes outside HT/LF/CR
   and printable ASCII, including inside comments, and rejects unsupported
   lexical syntax. Generated certificates check each line and reconstruct the
   exact included source. The generator supplies candidates; it cannot choose
   the authoritative binding. Python and Lean enforce the source alphabet.
4. `SourceBridge.CheckedSource` combines lexical certificates, all body/header
   checks, catalogue constants and refinement contracts, and equality with the
   complete checked-in `ReviewedSourceShape`. An added operator, helper,
   context clause, or changed scope cannot hide behind unchanged selected
   bodies. `Precedence` checks grouping; the typed expression model records the
   predefined operator interpretation for the reviewed fragment.
5. `RecursiveBridge` defines `Expressions.DefinitionEquations`, describing the
   checked expressions with
   arbitrary recursive callees. All three uniqueness lemmas are applied to
   derive their cursor meanings and membership equivalence. The final theorem
   quantifies over every interpretation satisfying these equations and retains
   every `CheckedSource` fact. An explicit model witness establishes consistency
   of the equation interface. GNATprove separately proves actual `Accepts =
   Is_Member`, normalization, primitive predicates and machine-bound safety.
   Reading the fixed fragment as these equations uses the trusted Ada/SPARK
   front end and inherited predefined semantics; Lean does not verify GNAT's
   implementation or perform general Ada overload resolution.

6. `Semantics.admitted_assurance` covers every null-subgrammar source, every initial
   state, and every execution of its permitted composition. All runs return
   normally with unchanged state and an empty trace. Syntax-directed generation
   yields zero obligations, and a total checker has an explicit one-step
   discharge certificate for them.

7. `OutputExpressions` renders and interprets typed literal/suffix expressions;
   its primitive interpretation also reuses checked lexical expression trees.
   The output, named, argument and concatenation expression trees each have a checked
   `WellFormedTrees` predicate for Ada precedence and explicit grouping,
   included in their source-translation checks.
   `OutputEquations` proves uniqueness of literal/suffix cursor equations.
   `OutputSourceBridge.CheckedSource` checks the output recognizer, lexical
   helper specification/body, IO sources and Output_Libc interface, complete
   `ReviewedOutputShape`, catalogue and
   refinement contracts, runtime statement rendering, Static ghost declarations,
   numeric bound and returning status-setter signature. Its literal-membership
   callback denotes the actual `Is_Literal_Member` helper, not the expanded public
   union. The lexical helper imports the existing `Silver_Profile` primitives;
   `LexicalConstants` checks that its source bound and comment introducer agree
   with the output profile. Expression/header checks name the helper
   specification for moved ghost equations and the helper body for ordinary
   implementations. Production-specific suffix checks still name the output
   recognizer. `NamedSourceBridge` retains checked identifier/span/forbidden-name
   and named-suffix templates, including the complete forbidden-name enum and
   its ordinary case/return spelling body in their respective helper units.
8. `ArgumentsExpressions` interprets the package-name exclusion and argument
   suffix. It closes shared and new callees on their verified domains and
   applies identifier/suffix uniqueness. `ArgumentsSourceBridge` checks exact
   Arguments spec/body and Runtime spec bytes, contracts, the whole typed
   argument-body rendering and the typed argument Main composition. Runtime
   normalization uses checked extended-return nodes; SPARK verifies their
   machine bounds while the Lean interpreter preserves the returned byte value.
9. `ConcatExpressions` and `ConcatEquations` interpret the literal-backed
   concatenation suffix and prove its recursive uniqueness. `ConcatSourceBridge`
   checks the source expression, refinement header, typed Main rendering and
   precedence. `GuardedEquations` and `GuardedExpressions` add the bounded decimal
   and literal-length calculations, capacity/name conditions and guarded suffix.
   `GuardedSourceBridge` checks these actual-source expressions and the typed
   guarded Main renderer. Its current-language facade includes all eight forms;
   the guarded- and assignment-selector theorems connect the driver classifiers
   to their exact productions. `AssignmentSourceBridge` adds the assignment
   expression, fixed-length mutation and ordered Main rendering checks.
   `BranchingSourceBridge` adds the equality/terminal-branch Main composition and
   actual suffix and executable refinement checks. `authoritative_current_member_iff` and
   `checked_current_pipeline` retain the checked source facts when composing
   membership and the conditional external-tool result. Each checked recursive
   interpretation is closed by the corresponding uniqueness argument. The
   source reading still uses the approved Ada frontend and SPARK's numeric facts.
10. `Current` composes runtime and source-meaning model lemmas for the eight
   productions, including `Arguments.execution_refines` and
   `Arguments.Runtime.main_refines`. It does not import the source bridges.
   `Output.SourceBridge.authoritative_runtime_correct` separately conjoins the
   checked IO source with its runtime refinement. The argument bridge's
   `authoritative_argument_runtime_correct` similarly retains `CheckedSource`
   alongside the pure-query and Main runtime refinements.
   `authoritative_main_correct` combines `CheckedSource`, parsing of the typed
   Main rendering, and its interpreted result's equality with `Current.execute`.
   This ties the initializer, guard polarity and branch order to the admitted
   token production. The combined pipeline theorem retains the checked source
   facts when applying `Current`'s conditional pipeline result; changing source
   invalidates that source check. Its model tool-contract witness is not
   verification of the physical toolchain.
   Reading checked Ada tokens as these typed expressions/statements still uses
   the approved frontend, SPARK's proved bounds, and the documented GNAT/libc
   meanings; this is not a verified general Ada parser or whole-toolchain theorem.

The twelve embedded Ada files are declared as binary Lake input dependencies,
each attached to the exact library owning its handwritten binding module.
Editing one file invalidates that binding, its certificate and their transitive
importers; it does not by itself invalidate unrelated certificates or
source-independent models. Changes to shared Lean dependencies can rebuild more
modules. The default fresh axiom audit and optional kernel replay retain
their whole-project scope; focused checks audit only their selected import
closure. Content rehashing detects changed source even if
timestamps are restored; line-ending differences remain significant. A cached
Lean object for different Ada source is not accepted as current evidence. Kernel
regression theorems reject unsupported comment/literal forms and prove
that inserted declarations or a changed size constant alter the complete
reviewed token shape. Python tests reject unsupported bytes before generation
and check that the generator cannot supply authoritative bindings. Candidate
parity is checked separately. These are kernel/source-policy checks, not a
claim that every mutation has been replayed through a full altered-source build.
The shared authoritative files remain untouched by these tests. Fingerprints
record provenance; source equality is established
by the checked certificates themselves.

## Automatic completion and the external boundary

`SupportedTools` states its dependencies as explicit theorem parameters, without
adding axioms. Its operations describe parsing, obligation generation, proving,
building, and executing. Its contract requires faithful parsing of the modeled
Ada production, faithful generation of its obligations, terminating acceptance
of an empty obligation set, terminating compilation, and forward/backward
preservation of the source semantics. The parse-completion premise includes
allowed ASCII bytes. Parsing and compilation use the same source parameter.

`admitted_pipeline_completes` derives completion for every member from these
contracts for this restricted null-program pipeline and the proved
empty-obligation result. It does not assume
that Silver membership directly implies tool success or require a solver
complete for arbitrary SPARK. `supported_pipeline_preserves` and
`supported_pipeline_executes` establish safety and realization of the permitted
execution through that pipeline. `checked_membership_supported_pipeline`
connects source-checked membership to this conditional completion result.

For the current union, `Current.Tools` and `Current.ToolContract` extend this
structure with the fixed six-file library set's separately audited proof and
execution over an immutable argument vector and output environment. `automatic_pipeline` composes faithful parsing, obligation generation,
bounded-range discharge, fixed-library proof and same-source compilation.
`generationFaithful` relates each generated check to a concatenation schema;
`generated_range_fragment` proves it lies within the checked uniform bounds.
`boundedRangeProofCompletes` explicitly assumes completion of the pinned external
provers on that concrete arithmetic fragment. The Lean decision procedure proves
validity and termination for its mathematical schemas; it is not a proof of
CVC5/Z3/Alt-Ergo or of their 10,000-step bound. The native obligation experiments
and boundary cases exercise this premise; they do not prove it universally.
`pipeline_preserves` and `pipeline_realizes` establish specified outcomes and,
in a healthy output environment, exact bytes and the expected status. Invalid
arguments retain rejection status 1 under that premise. The fixed-library proof premise is
an explicit pipeline requirement; behavior preservation is a separate external
tool-contract premise, not a consequence derived from that proof marker.
Neither premise is inferred from an empty application report or from membership.
The source correspondence theorem connects checked recognition to this union.

Instantiation for physical GNAT/GNATprove invocations uses the approved external
toolchain and a supported operational environment: matching installed tools,
accessible immutable source/project files, sufficient resources, successful I/O,
and completion of the invoked processes. Runtime startup, linking, libc, and
the OS remain within the explicit trust boundary. The theorem does not establish
those implementations or assert infallibility under tool crashes or resource
exhaustion. Real GNATprove evidence checks positive coverage, the appropriate
empty, range-check or assignment-advisory application policy, and discharge of every selected library check;
identifying those records with semantic obligations uses the external tool contract; the driver's proved guards connect observed success to artifact
publication. There is no separate single theorem modeling the entire CLI and OS.

| Claim | How established | Scope and premises |
| --- | --- | --- |
| Decidable membership | Lean grammar/cursor equivalence; checked source shape; applied recursive uniqueness; GNATprove refinement | Fixed compiler-source fragment, interpreted with the approved frontend and checked numeric/normalization contracts. |
| Construct/composition safety | Lean universal execution theorems; reviewed Ada lexical/semantic argument; verified wrappers | All eight compositions; admitted concatenations, equality, defaults and argument outcomes use the documented argv, GNAT ABI and output premises. |
| Catalogue correspondence | Shared SPARK rules, Lean source checks, parsed JSON integration comparison | Explicit construct metadata and token/byte tables for the eight productions. No general serializer theorem. |
| Compiler Bronze/Silver | GNATprove and content-bound coverage/result audit | All owned units; pinned external imports and the documented runtime assumptions. |
| Component functional correctness | GNATprove contracts; Lean recognition bridge | Membership, normalization, decimal rendering, null/runtime/application report-policy refinement, I/O observations and ordered driver guards. |
| Source preservation | GNATprove snapshot/transcript contracts; integration tests | Same snapshot around proof/build; immutable project/filesystem and faithful external tools remain premises. |
| Automatic discharge | Lean bounded-range decision and refinement theorems; conditional external-tool theorem; real report checks | Empty checks for the first five forms and branching, valid bounded-range schemas for the sixth, statically compatible assignment in the seventh, and separately audited fixed libraries. External generation and pinned-fragment prover completion remain explicit premises. |
| Native support | Native build/proof/tests plus simulated routing tests | Capability and repair records identify actual inputs, modes and hosts. Historical macOS baseline evidence retains its original scope. The later [external review](command-line-greeting.md#external-review-disposition) reports native macOS validation of the sixth form; corroborating records are entirely optional. Validation runs locally with hosted CI disabled at the owner's direction; [host readiness](host-readiness.md) records replacement-host evidence and recovery. |

These boundaries do not change membership or waive any obligation. Admission,
verification or compilation failure on admitted source remains an implementation
or toolchain defect. Specified external output failure is an execution outcome. Any extension of
the current language must extend the catalogue, source correspondence, and
universal composition/discharge arguments before it is admitted.

For a language extension, first specify its constructs, decidable admission and
composition rules, inherited semantics, and generated obligation classes. Prove
generation soundness and complete automatic discharge over the entire admitted
fragment using the smallest argument justified by those obligations. A general
decision procedure or certificate framework is not a prerequisite. Update the source bridge and report checker before admitting the new
syntax. Empty-obligation arguments remain valid for the null specialization;
they do not establish anything about future checks. Solver steps/parallelism,
warning policy, supported report schemas and capacity tests belong to that
extension's validation. See [the development workflow](../development.md).
