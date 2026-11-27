module

public import Silver.ApplicationPackageBodiesControl
public import Silver.ApplicationPackageBodiesStatementModel

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages

inductive Fn : Ty → Type
  | takeToken : Fn (.arrow .source (.arrow .number (.arrow .token .number)))
  | skipAt : Fn (.arrow .source (.arrow .number .number))
  | nameAfter : Fn (.arrow .source (.arrow .number .number))
  | forbidden : Fn (.arrow .source (.arrow .number (.arrow .number .truth)))
  | nameIs : Fn (.arrow .source (.arrow .number (.arrow .number (.arrow .spelling .truth))))
  | equalName : Fn (.arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth)))))
  | sameName : Fn (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | reads : Fn (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number (.arrow .number .stateSet)))))
  | union : Fn (.arrow .stateSet (.arrow .stateSet .stateSet))
  | tail : Fn (.arrow .source (.arrow .parseContext (.arrow .appScan (.arrow .metadata (.arrow .bodyStop (.arrow .truth (.arrow .functions (.arrow .procedures .appScan))))))))
  | target : Fn (.arrow .source (.arrow .parseContext (.arrow .number .number)))
  | attribute : Fn (.arrow .source (.arrow .number (.arrow .scalars (.arrow .arrayTable (.arrow .number (.arrow .number (.arrow .truth .scalarResult)))))))
  | bound : Fn (.arrow .source (.arrow .parseContext (.arrow .number (.arrow .activeFlow (.arrow .number (.arrow .number .scalarResult))))))
  | included : Fn (.arrow .interval (.arrow .interval .truth))
  | isEmpty : Fn (.arrow .interval .truth)
  | normalize : Fn (.arrow .interval .interval)
  | maxBindings : Fn .number
  | emptyPath : Fn .path
  | pathJoin : Fn (.arrow .path (.arrow .path .path))
  | bodyToken : Fn (.arrow .source (.arrow .parseContext (.arrow .bodyScan (.arrow .token .bodyScan))))
  | validBody : Fn (.arrow .source (.arrow .parseContext (.arrow .bodyScan .truth)))
  | validFlow : Fn (.arrow .parseContext (.arrow .activeFlow .truth))
  | basic : Fn (.arrow .source (.arrow .parseContext (.arrow .appScan (.arrow .metadata (.arrow .functions (.arrow .procedures .appScan))))))
  | invalid : Fn (.arrow .appScan .appScan)

def names : FunctionNames Fn
  | _, .takeToken => ["take_token"]
  | _, .skipAt => ["skip_at"]
  | _, .nameAfter => ["name_after"]
  | _, .forbidden => ["forbidden_name"]
  | _, .nameIs => ["name_is"]
  | _, .equalName => ["equal_name"]
  | _, .sameName => ["packages", ".", "same_name"]
  | _, .reads => ["state_reads"]
  | _, .union => ["packages", ".", "union"]
  | _, .tail => ["application_tail"]
  | _, .target => ["array_target"]
  | _, .attribute => ["scalar_expressions", ".", "read_array_attribute"]
  | _, .bound => ["read_counted_bound"]
  | _, .included => ["included"]
  | _, .isEmpty => ["scalars", ".", "is_empty"]
  | _, .normalize => ["scalars", ".", "normalize"]
  | _, .maxBindings => ["scalar_expressions", ".", "max_bindings"]
  | _, .emptyPath => ["paths", ".", "empty_context"]
  | _, .pathJoin => ["paths", ".", "join"]
  | _, .bodyToken => ["body_token"]
  | _, .validBody => ["valid_body"]
  | _, .validFlow => ["valid_flow"]
  | _, .basic => ["application_basic"]
  | _, .invalid => ["invalid_application"]

abbrev ValidFlow := Predicate.ParseContext → Predicate.ActiveFlow → Bool

def functions (calls : Statement.Calls) (validFlow : ValidFlow) : ApplicationNative.Calls Fn
  | _, .takeToken => calls.takeToken
  | _, .skipAt => calls.skipAt
  | _, .nameAfter => calls.nameAfter
  | _, .forbidden => calls.forbiddenName
  | _, .nameIs => calls.nameIs
  | _, .equalName => calls.equalName
  | _, .sameName => calls.sameName
  | _, .reads => calls.stateReads
  | _, .union => PackageBindings.stateUnion
  | _, .tail => calls.applicationTail
  | _, .target => calls.arrayTarget
  | _, .attribute => calls.readArrayAttribute
  | _, .bound => calls.readCountedBound
  | _, .included => Integer.Interval.included
  | _, .isEmpty => Integer.Interval.isEmpty
  | _, .normalize => Integer.Interval.normalize
  | _, .maxBindings => ScalarExpression.maxBindings
  | _, .emptyPath => PathFacts.Context.empty
  | _, .pathJoin => calls.pathJoin
  | _, .bodyToken => calls.bodyToken
  | _, .validBody => calls.validBody
  | _, .validFlow => validFlow
  | _, .basic => calls.applicationBasic
  | _, .invalid => ApplicationPackages.invalidApplication

def procedures (calls : Statement.Calls) : Statements.Procedures :=
  ⟨calls.readCondition, calls.joinInto, calls.widenInto⟩

def parameters : FunctionParameters Fn
  | _, .attribute => ["text", "position", "names", "arrays", "mask_first", "mask_after", "range_query"]
  | _, _ => []

abbrev E := Expr Fn
abbrev P := Place Fn
abbrev C := Statements.Command Fn
abbrev text : E .source := .variable "text"
abbrev context : E .parseContext := .variable "context"
abbrev info : E .metadata := .variable "info"
abbrev input : E .appScan := .variable "input"
abbrev result : P .appScan := .variable "result"
abbrev scan : P .bodyScan := .field .applicationScan result
abbrev position : P .number := .field .scanPosition scan
abbrev facts : P .activeFlow := .field .scanFacts scan
abbrev reads : P .stateSet := .field .applicationReads result
abbrev inputScan : E .bodyScan := .field .applicationScan input
abbrev inputPos : E .number := .field .scanPosition inputScan
abbrev inputFacts : E .activeFlow := .field .scanFacts inputScan
abbrev condition : E .conditionResult := .variable "condition"
abbrev yes : P .activeFlow := .variable "yes"
abbrev first : E .number := .variable "first"
abbrev last : E .number := .variable "last"
abbrev start : E .number := .variable "start"
abbrev bounds : E .interval := .variable "bounds"
abbrev inner : P .parseContext := .variable "inner"
abbrev inside : P .appScan := .variable "inside"
abbrev insideScan : P .bodyScan := .field .applicationScan inside
abbrev insideFacts : P .activeFlow := .field .scanFacts insideScan
abbrev invalid : C := .returned (.app (.function .invalid) input)
abbrev token (pos : E .number) (symbol : Compose.ShellToken) : E .number :=
  .app (.app (.app (.function .takeToken) text) pos) (.token symbol)
abbrev keyword (pos : E .number) (word : String) : E .number := token pos (.word word)
abbrev skip (pos : E .number) : E .number := .app (.app (.function .skipAt) text) pos
abbrev after (pos : E .number) : E .number := .app (.app (.function .nameAfter) text) pos
abbrev isEmpty (value : E .interval) : E .truth := .app (.function .isEmpty) value
abbrev nonzero (value : E .number) : E .truth := .ne value (.number 0)
abbrev zero (value : E .number) : E .truth := .eq value (.number 0)
abbrev nameIs (word : String) : E .truth := .app (.app (.app (.app (.function .nameIs) text) first) last) (.word word)
abbrev readEffects (ctx : E .parseContext) (low high : E .number) : E .stateSet :=
  .app (.app (.app (.app (.app (.function .reads) text) ctx) info) low) high
abbrev addReads (value : E .stateSet) : C :=
  .assign reads (.app (.app (.function .union) reads.expression) value)
abbrev callTail (ctx : E .parseContext) (value : E .appScan) (stop : Predicate.BodyStop) : E .appScan :=
  .app (.app (.app (.app (.app (.app (.app (.app (.function .tail) text) ctx) value)
    info) (.bodyStop stop)) (.truth true)) (.variable "catalog")) (.variable "procedure_catalog")
abbrev closeToken (symbol : Compose.ShellToken) : C :=
  .assign scan (.app (.app (.app (.app (.function .bodyToken) text) context) scan.expression) (.token symbol))
abbrev close (word : String) : C := .list [closeToken (.word "end"), closeToken (.word word), closeToken (.symbol ";")]
abbrev validScan : E .truth := .app (.app (.app (.function .validBody) text) context) scan.expression

def declarations : List (Declaration Fn) := [
  {type := .appScan, name := "result", typeName := ["application_scan"], constraint := some (.property .appScanCount input), initial := some input},
  {type := .conditionResult, name := "condition", typeName := ["condition_result"], constraint := some (.property .appScanCount input), initial := none},
  {type := .activeFlow, name := "yes", typeName := ["scalar_flow"], constraint := some (.property .appScanCount input), initial := some inputFacts},
  {type := .truth, name := "have_yes", typeName := ["boolean"], initial := some (.truth false)},
  {type := .number, name := "first", additionalNames := ["last", "start"], typeName := ["literal_position"], initial := none},
  {type := .scalarResult, name := "low", additionalNames := ["high"], typeName := ["scalar_expressions", ".", "expression_result"], initial := none},
  {type := .interval, name := "bounds", typeName := ["scalars", ".", "interval"], initial := none},
  {type := .truth, name := "definite", typeName := ["boolean"], initial := none}]

def armRead : C := .list [
  .invariant validScan,
  .invariant (.app (.app (.function .validFlow) context) yes.expression),
  .invariant (.truthEq (.field .applicationAllowProcedureCalls result.expression) (.field .applicationAllowProcedureCalls input)),
  .invariant (.gt position.expression inputPos), .increases position.expression,
  .assign (.variable "start") position.expression,
  .procedure (.readCondition text context start facts.expression (.variable "condition")),
  .choose (zero (.property .conditionAfter condition)) invalid .nothing,
  addReads (readEffects context start (.property .conditionAfter condition)),
  .assign position (keyword (.property .conditionAfter condition) "then"),
  .assign facts (.property .conditionTrue condition),
  .choose (.le position.expression start) invalid .nothing,
  .assign result (callTail context result.expression .arm), .choose (zero position.expression) invalid .nothing]

def armExit : C := .list [
  .choose (.variable "have_yes")
    (.list [.procedure (.joinedLemma context yes.expression facts.expression), .procedure (.joinInto yes facts.expression)])
    (.list [.assign yes facts.expression, .assign (.variable "have_yes") (.truth true)]),
  .assign facts (.property .conditionFalse condition),
  .exitWhen (zero (keyword position.expression "elsif")),
  .assign position (keyword position.expression "elsif"), .choose (.le position.expression start) invalid .nothing]

def armCommands : C := .sequence armRead armExit

def ifEnding : C := .list [
  .choose (nonzero (keyword position.expression "else"))
    (.list [.assign position (keyword position.expression "else"), .assign result (callTail context result.expression .endOnly)]) .nothing,
  .choose (zero position.expression) invalid .nothing,
  .procedure (.joinedLemma context facts.expression yes.expression), .procedure (.joinInto facts yes.expression), close "if"]

def ifCommands : C := .list [.assign position (keyword position.expression "if"), .loopBody armCommands, ifEnding]

def binderRejected : E .truth :=
  .orElse (.orElse (.orElse (.orElse (.orElse (zero first) (.le last first))
    (.group (.andThen (.app (.app (.app (.function .forbidden) text) first) last) (.not (nameIs "string")))))
    (.group (.andThen (.contextHasDynamic context) (nameIs "silver_arguments"))))
    (.app (.app (.app (.function .sameName) text) (.nameSpan first last)) (.nameSpan (.field .infoNameFirst info) (.field .infoNameAfter info))))
    (.eq (.field .scalarCount (.field .contextScalarNames context)) (.function .maxBindings))

abbrev row : E .arrayBinding := .index .arrayItem (.property .contextArrays context) (.variable "target")
abbrev arrayFirst : E .number := .variable "array_first"
abbrev arrayLast : E .number := .variable "array_last"
def arrayDeclarations : List (Declaration Fn) := [
  {type := .number, name := "array_first", typeName := ["literal_position"], constant := true, initial := some (skip position.expression)},
  {type := .number, name := "array_last", typeName := ["literal_position"], constant := true, initial := some (after arrayFirst)},
  {type := .number, name := "target", typeName := ["array_bindings", ".", "binding_count"], constant := true,
   initial := some (.app (.app (.app (.function .target) text) context) position.expression)}]

def arrayRejected : E .truth :=
  .orElse (.orElse (.orElse (.orElse (.orElse (zero arrayFirst) (.le arrayLast arrayFirst))
    (.app (.app (.app (.app (.app (.function .equalName) text) first) last) arrayFirst) arrayLast))
    (zero (.variable "target"))) (.property .arrayMutable row)) (.property .arrayBoolean row)

def arrayCommands : C := .list [
  .choose (.field .contextPure context) invalid .nothing,
  .assign position (keyword last "of"),
  .choose (nonzero (keyword position.expression "reverse")) (.assign position (keyword position.expression "reverse")) .nothing,
  .block arrayDeclarations (.list [
    .choose arrayRejected invalid .nothing,
    .assign position (keyword arrayLast "loop"), .assign (.variable "bounds") (.property .arrayComponentBounds row),
    .assign (.variable "definite") (.truth true)])]

abbrev readBound (whereAt : E .number) : E .scalarResult :=
  .app (.app (.app (.app (.app (.app (.function .bound) text) context) whereAt) inputFacts) first) last
abbrev low : E .scalarResult := .variable "low"
abbrev high : E .scalarResult := .variable "high"
abbrev shape : E .scalarResult := .variable "shape"
abbrev lowBounds : E .interval := .field .scalarValueBounds low
abbrev highBounds : E .interval := .field .scalarValueBounds high

def shapeDeclaration : Declaration Fn := {
  type := .scalarResult, name := "shape", typeName := ["scalar_expressions", ".", "expression_result"], constant := true,
  initial := some (.namedApp "range_query"
    (.app (.app (.app (.app (.app (.app (.function .attribute) text) start) (.field .contextScalarNames context))
       (.property .contextArrays context)) first) last) (.truth true))}

def countedCommands : C := .list [
  .assign (.variable "start") (keyword last "in"),
  .choose (nonzero (keyword start "reverse")) (.assign (.variable "start") (keyword start "reverse")) .nothing,
  .block [shapeDeclaration] (.choose (nonzero (.field .scalarValueAfter shape))
    (.list [.assign position (keyword (.field .scalarValueAfter shape) "loop"),
      .assign (.variable "bounds") (.field .scalarValueBounds shape), .assign (.variable "definite") (.truth true)])
    (.list [
      .assign (.variable "low") (readBound start),
      .assign (.variable "high") (readBound (token (.field .scalarValueAfter low) (.symbol ".."))),
      .assign position (keyword (.field .scalarValueAfter high) "loop"),
      .assign (.variable "bounds") (.group (.ite (.orElse (isEmpty lowBounds) (isEmpty highBounds)) .empty
        (.app (.function .normalize) (.intervalValue (.field .lower lowBounds) (.field .upper highBounds))))),
      .assign (.variable "definite") (.andThen (.andThen (.not (isEmpty lowBounds)) (.not (isEmpty highBounds)))
        (.intLe (.field .upper lowBounds) (.field .lower highBounds)))])),
  addReads (readEffects (.update context (.more .contextMaskFirst first (.one .contextMaskAfter last))) start position.expression)]

def innerDeclarations : List (Declaration Fn) := [
  {type := .parseContext, name := "inner", typeName := ["body_context"], initial := some context},
  {type := .appScan, name := "inside", typeName := ["application_scan"],
   constraint := some (.add (.property .appScanCount input) (.number 1)), initial := none}]

def copyValues : C := .forFlowValues "i" facts.expression (.list [
  .invariant (.forAll "done" (.flowValuesFirst facts.expression) (.sub (.variable "i") (.number 1))
    (.intervalEq (.index .flowValue insideFacts.expression (.variable "done"))
      (.index .flowValue facts.expression (.variable "done")))),
  .assign (.index .flowValue insideFacts (.variable "i")) (.index .flowValue facts.expression (.variable "i"))])

def prepareInner : C := .list [
  .procedure (.appendScalar (.field .contextScalarNames inner)
    (.scalarBindingValue first last bounds (.truth false) bounds (.truth false) (.number 0) (.number 0))),
  .assign (.field .scanPosition insideScan) position.expression,
  .assign (.field .scanTarget insideScan) (.field .scanTarget scan.expression),
  .assign (.field .scanCapacity insideScan) (.field .scanCapacity scan.expression),
  .assign (.field .scanAssigned insideScan) (.field .scanAssigned scan.expression),
  .assign (.field .scanOutput insideScan) (.field .scanOutput scan.expression),
  .assign (.field .applicationAllowProcedureCalls inside) (.field .applicationAllowProcedureCalls result.expression),
  .assign (.field .applicationReads inside) reads.expression,
  .assign (.field .applicationWrites inside) (.field .applicationWrites result.expression),
  .assign (.field .activeFlowPath insideFacts) (.group (.ite (isEmpty bounds) (.function .emptyPath) (.field .activeFlowPath facts.expression))),
  .procedure (.clearValues insideFacts)]

abbrev insideCount : E .number := .property .appScanCount inside.expression
abbrev outerNames : E .scalars := .field .contextScalarNames context
abbrev innerNames : E .scalars := .field .contextScalarNames inner.expression
abbrev iteratorBinding : E .scalarBinding := .index .scalar innerNames insideCount
abbrev validFacts (ctx : E .parseContext) (flow : E .activeFlow) : E .truth :=
  .app (.app (.function .validFlow) ctx) flow

def setIterator : C := .list [
  .staticAssert (.group (.forAllFlowValues "i" facts.expression
    (.intervalEq (.index .flowValue insideFacts.expression (.variable "i"))
      (.index .flowValue facts.expression (.variable "i"))))),
  .staticAssert (.group (.forAll "i" (.number 1) (.field .scalarCount outerNames)
    (.scalarBindingEq (.index .scalar innerNames (.variable "i")) (.index .scalar outerNames (.variable "i"))))),
  .staticAssert (.eq (.field .contextDeclarationCount inner.expression) (.field .contextDeclarationCount context)),
  .assign (.index .flowValue insideFacts insideCount) bounds,
  .staticAssert (.not (.field .scalarMutable iteratorBinding)),
  .staticAssert (.gt insideCount (.field .contextDeclarationCount inner.expression)),
  .staticAssert (.app (.app (.function .included) (.index .flowValue insideFacts.expression insideCount))
    (.field .scalarBounds iteratorBinding)),
  .staticAssert (validFacts inner.expression insideFacts.expression)]

def innerEntry : C := .list [prepareInner, copyValues, setIterator]

def innerReturn : C := .list [
  .assign inside (callTail inner.expression inside.expression .endOnly),
  .choose (zero (.field .scanPosition insideScan.expression)) invalid .nothing,
  .assign position (.field .scanPosition insideScan.expression),
  .assign (.field .scanTarget scan) (.field .scanTarget insideScan.expression),
  .assign (.field .scanCapacity scan) (.field .scanCapacity insideScan.expression),
  .assign (.field .scanAssigned scan) (.field .scanAssigned insideScan.expression),
  .assign (.field .scanOutput scan) (.field .scanOutput insideScan.expression),
  .assign reads (.field .applicationReads inside.expression),
  .assign (.field .applicationWrites result) (.field .applicationWrites inside.expression),
  .choose (isEmpty bounds) (.assign facts inputFacts)
    (.choose (.variable "definite") (.assign (.field .activeFlowPath facts) (.field .activeFlowPath insideFacts.expression))
      (.assign (.field .activeFlowPath facts) (.app (.app (.function .pathJoin)
        (.field .activeFlowPath inputFacts)) (.field .activeFlowPath insideFacts.expression))))]

def forBinder : C := .list [
  .assign position (keyword inputPos "for"),
  .assign (.variable "first") (skip position.expression), .assign (.variable "last") (after first)]

def forSelect : C := .list [
  .choose binderRejected invalid .nothing,
  .choose (nonzero (keyword last "of")) arrayCommands countedCommands]

def forBounds : C := .list [
  .choose (.le position.expression inputPos) invalid .nothing,
  .procedure (.widenInto context facts), .staticAssert (validFacts context facts.expression),
  .block innerDeclarations (.sequence innerEntry innerReturn), close "loop"]

def forCommands : C := .list [forBinder, forSelect, forBounds]

def commands : C := .list [
  .choose (zero inputPos) invalid .nothing,
  .choose (nonzero (keyword inputPos "if")) ifCommands
    (.choose (nonzero (keyword inputPos "for")) forCommands
      (.returned (.app (.app (.app (.app (.app (.app (.function .basic) text) context) input) info) (.variable "catalog"))
        (.variable "procedure_catalog")))),
  .choose (.orElse (.le position.expression inputPos) (.not validScan)) invalid .nothing, .returned result.expression]

def body : Statements.Body Fn := ⟨"application_statement", declarations, commands⟩

abbrev scope : Scope := [(.source, "text"), (.parseContext, "context"), (.appScan, "input"), (.metadata, "info"),
  (.functions, "catalog"), (.procedures, "procedure_catalog")]

theorem checked_tree : body.checked names parameters scope = true := by decide +kernel

end Silver.ApplicationPackageBodies.Statement.Native
