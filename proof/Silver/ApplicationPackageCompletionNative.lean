module

public import Silver.ApplicationPackageProcedureControl

@[expose] public section

/-! Exact typed native routine-completion tree. Every output prefix is evaluated
before any output formal is appended. Partial signature writes and all original
failure returns remain in their source order. -/
namespace Silver.ApplicationPackageCompletion.Native
open ApplicationNative ApplicationPackageProcedure

inductive Fn : Ty → Type
  | takeToken : Fn (.arrow .source (.arrow .number (.arrow .token .number)))
  | skipAt : Fn (.arrow .source (.arrow .number .number))
  | nameAfter : Fn (.arrow .source (.arrow .number .number))
  | validName : Fn (.arrow .source (.arrow .nameSpan .truth))
  | sameName : Fn (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | routineFrame : Fn (.arrow .source (.arrow .state (.arrow .metadata (.arrow .number (.arrow .number .state)))))
  | objectAt : Fn (.arrow .source (.arrow .state (.arrow .metadata (.arrow .truth .objectResult))))
  | contextOf : Fn (.arrow .scanResult .parseContext)
  | bodyOf : Fn (.arrow .scanResult .bodyScan)
  | applicationOf : Fn (.arrow .bodyScan .appScan)
  | initialFlow : Fn (.arrow .parseContext .activeFlow)
  | stateReads : Fn (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number (.arrow .number .stateSet)))))
  | actualAfter : Fn (.arrow .source (.arrow .parseContext (.arrow .number (.arrow .activeFlow (.arrow .functionFormal .number)))))
  | applicationTail : Fn (.arrow .source (.arrow .parseContext (.arrow .appScan (.arrow .metadata
      (.arrow .bodyStop (.arrow .truth (.arrow .functions (.arrow .procedures .appScan))))))))
  | functionReturnAfter : Fn (.arrow .source (.arrow .parseContext (.arrow .bodyScan (.arrow .functionType .number))))
  | union : Fn (.arrow .stateSet (.arrow .stateSet .stateSet))
  | emptyFunctions : Fn .functions
  | emptyProcedures : Fn .procedures

def functionNames : FunctionNames Fn
  | _, .takeToken => ["take_token"]
  | _, .skipAt => ["skip_at"]
  | _, .nameAfter => ["name_after"]
  | _, .validName => ["packages", ".", "valid_name"]
  | _, .sameName => ["packages", ".", "same_name"]
  | _, .routineFrame => ["routine_frame"]
  | _, .objectAt => ["package_object_at"]
  | _, .contextOf => ["context_of"]
  | _, .bodyOf => ["body_of"]
  | _, .applicationOf => ["application_of"]
  | _, .initialFlow => ["initial_flow"]
  | _, .stateReads => ["state_reads"]
  | _, .actualAfter => ["actual_after"]
  | _, .applicationTail => ["application_tail"]
  | _, .functionReturnAfter => ["function_return_after"]
  | _, .union => ["packages", ".", "union"]
  | _, .emptyFunctions => ["functions", ".", "empty_metadata"]
  | _, .emptyProcedures => ["procedures", ".", "empty_metadata"]

/-- Only this symbol permits named association here. The final source binding
checks its fourth formal against the original Package_Object_At header. -/
def functionParameters : FunctionParameters Fn
  | _, .objectAt => ["text", "frame", "info", "local"]
  | _, _ => []

def modelFunctions (calls : ApplicationPackageBodies.CompletionCalls) : Calls Fn
  | _, .takeToken => calls.takeToken
  | _, .skipAt => calls.skipAt
  | _, .nameAfter => calls.nameAfter
  | _, .validName => calls.validName
  | _, .sameName => calls.sameName
  | _, .routineFrame => calls.routineFrame
  | _, .objectAt => calls.objectAt
  | _, .contextOf => calls.contextOf
  | _, .bodyOf => calls.bodyOf
  | _, .applicationOf => ApplicationPackages.applicationOf
  | _, .initialFlow => calls.initialFlow
  | _, .stateReads => calls.stateReads
  | _, .actualAfter => calls.actualAfter
  | _, .applicationTail => calls.applicationTail
  | _, .functionReturnAfter => calls.functionReturnAfter
  | _, .union => PackageBindings.stateUnion
  | _, .emptyFunctions => {}
  | _, .emptyProcedures => {}

def modelProcedures (calls : ApplicationPackageBodies.CompletionCalls) : ProcedureCalls where
  signature := calls.signatureAt
  appendFormal := calls.appendFormal
  completion := fun _ _ info => ApplicationPackageBodies.completionFailed info

abbrev text : Expr Fn .source := .variable "text"
abbrev globals : Expr Fn .state := .variable "globals"
abbrev info : Expr Fn .metadata := .variable "info"
abbrev frame : Expr Fn .state := .variable "frame"
abbrev item : Expr Fn .routine := .variable "item"
abbrev object : Expr Fn .objectResult := .variable "object"
abbrev formal : Expr Fn .formal := .variable "formal"
abbrev result : Expr Fn .appScan := .variable "result"
abbrev input : Expr Fn .appScan := .variable "input"
abbrev context : Expr Fn .parseContext := .variable "context"
abbrev position : Expr Fn .number := .field .statePosition frame
abbrev formalFirst : Expr Fn .number := .field .routineFormalFirst item
abbrev formalCount : Expr Fn .number := .field .routineFormalCount item
abbrev formalLast : Expr Fn .number := .sub (.add formalFirst formalCount) (.number 1)
abbrev token (first : Expr Fn .number) (kind : Compose.ShellToken) : Expr Fn .number :=
  .app (.app (.app (.function .takeToken) text) first) (.token kind)
abbrev skip (first : Expr Fn .number) : Expr Fn .number := .app (.app (.function .skipAt) text) first
abbrev after (first : Expr Fn .number) : Expr Fn .number := .app (.app (.function .nameAfter) text) first
abbrev same (first last : Expr Fn .number) (name : Expr Fn .nameSpan) : Expr Fn .truth :=
  .app (.app (.app (.function .sameName) text) (.nameSpan first last)) name
abbrev contextOf (frame : Expr Fn .state) (assigned : Expr Fn .truth) : Expr Fn .parseContext :=
  .app (.function .contextOf) (.scanResult frame assigned (.truth false))
abbrev union (first second : Expr Fn .stateSet) : Expr Fn .stateSet :=
  .app (.app (.function .union) first) second
abbrev reads (context : Expr Fn .parseContext) (first last : Expr Fn .number) : Expr Fn .stateSet :=
  .app (.app (.app (.app (.app (.function .stateReads) text) context) info) first) last
abbrev output : Expr Fn .truth := .modeEq (.field .formalMode formal) (.mode .output)
abbrev functionRoutine : Expr Fn .truth := .routineEq (.field .routineKind item) (.routineKind .function)
abbrev procedureRoutine : Expr Fn .truth := .routineEq (.field .routineKind item) (.routineKind .procedure)
abbrev validFormal : Expr Fn .truth := .app (.app (.function .validName) text) (.field .formalBodyName formal)

abbrev fail : ApplicationPackageProcedure.Command Fn := .list [
  .assign (.variable "globals") .invalidState, .returned]

def declarations : List (Declaration Fn) := [
  {
    type := .number
    name := "original"
    typeName := ["literal_position"]
    constant := true
    initial := some (.field .statePosition globals)},
  {type := .state, name := "header", additionalNames := ["frame"], typeName := ["parser_state"], initial := none},
  {type := .routine, name := "item", typeName := ["packages", ".", "routine"], initial := none},
  {type := .objectResult, name := "object", typeName := ["package_object_result"], initial := none},
  {type := .stateSet, name := "reads", typeName := ["packages", ".", "state_set"], initial := some .emptyStateSet},
  {type := .formal, name := "formal", typeName := ["packages", ".", "formal"], initial := none},
  {type := .packageType, name := "mark", typeName := ["package_type_result"], initial := none},
  {type := .number, name := "index", typeName := ["packages", ".", "routine_count_type"], initial := none},
  {
    type := .number
    name := "first"
    additionalNames := ["last", "value_first", "value_after", "following", "before"]
    typeName := ["literal_position"]
    initial := none},
  {type := .truth, name := "initialized", typeName := ["boolean"], initial := some (.truth false)}]

def localLoop : ApplicationPackageProcedure.Command Fn := .list [
  .increases position,
  .assign (.variable "before") position,
  .assign (.variable "first") (skip position),
  .assign (.variable "last") (after (.variable "first")),
  .choose (.andThen (.gt formalCount (.number 0))
    (.group (.forSome "i" formalFirst formalLast
      (same (.variable "first") (.variable "last") (.field .formalBodyName (.index .formal info (.variable "i")))))))
    fail .nothing,
  .assign (.variable "object") (.namedApp "local" (.app (.app (.app (.function .objectAt) text) frame) info) (.truth true)),
  .choose (.le (.field .statePosition (.field .objectFrame object)) (.variable "before")) fail .nothing,
  .assign (.variable "reads") (union (.variable "reads")
    (reads (contextOf (.field .objectFrame object) (.truth false)) (.field .objectInitFirst object) (.field .objectInitAfter object))),
  .assign (.variable "frame") (.field .objectFrame object)]

def outputReadContext : Declaration Fn := {
  type := .parseContext
  name := "context"
  typeName := ["body_context"]
  constant := true
  initial := some (.update (contextOf frame (.truth false)) (.one .contextDeclarationCount (.number 0)))}

def outputReadBody : ApplicationPackageProcedure.Command Fn := .list [
  .assign (.variable "value_after") (.app (.app (.app (.app (.app (.function .actualAfter) text) context)
    (.variable "value_first")) (.app (.function .initialFlow) context))
    (.functionFormal (.field .nameFirst (.field .formalBodyName formal)) (.field .nameAfter (.field .formalBodyName formal))
      (.field .formalKind formal) (.field .formalBounds formal) (.number 0))),
  .assign (.variable "reads") (union (.variable "reads") (reads context (.variable "value_first") (.variable "value_after")))]

def outputReadBlock : ApplicationPackageProcedure.Command Fn := .block [outputReadContext] outputReadBody

def outputRead : ApplicationPackageProcedure.Command Fn := .list [
  .assign (.variable "formal") (.index .formal info (.variable "i")),
  .choose output (.list [
    .choose (.not validFormal) fail .nothing,
    .assign (.variable "first") (skip position),
    .assign (.variable "last") (after (.variable "first")),
    .choose (.not (same (.variable "first") (.variable "last") (.field .formalBodyName formal))) fail .nothing,
    .assign (.variable "value_first") (token (.variable "last") (.symbol ":=")),
    outputReadBlock,
    .assign (.variable "following") (token (.variable "value_after") (.symbol ";")),
    .choose (.le (.variable "following") position) fail .nothing,
    .assign (.field .statePosition (.variable "frame")) (.variable "following"),
    .assign (.variable "initialized") (.truth true)]) .nothing]

def outputAppend : ApplicationPackageProcedure.Command Fn := .list [
  .assign (.variable "formal") (.index .formal info (.variable "i")),
  .choose output (.list [
    .choose (.not validFormal) fail .nothing,
    .assign (.variable "mark") (.packageType (.field .formalBodyTypeName formal)
      (.field .nameAfter (.field .formalBodyTypeName formal)) (.field .formalKind formal)
      (.field .formalBounds formal) (.field .formalTypeIdentity formal)),
    .primitive (.appendFormal (.variable "frame") (.field .formalBodyName formal) (.variable "mark") (.field .formalMode formal)),
    .choose (.eq position (.number 0)) fail .nothing]) .nothing]

def bodyDeclarations : List (Declaration Fn) := [
  {
    type := .parseContext
    name := "context"
    typeName := ["body_context"]
    constant := true
    initial := some (.update (contextOf frame (.variable "initialized")) (.one .contextDeclarationCount (.number 0)))},
  {
    type := .appScan
    name := "input"
    typeName := ["application_scan"]
    initial := some (.app (.function .applicationOf) (.app (.function .bodyOf)
      (.scanResult frame (.variable "initialized") (.truth false))))},
  {
    type := .appScan
    name := "result"
    typeName := ["application_scan"]
    constraint := some (.property .appScanCount input)
    initial := none}]

def bodyCommands : ApplicationPackageProcedure.Command Fn := .list [
  .assign (.field .applicationAllowProcedureCalls (.variable "input")) procedureRoutine,
  .assign (.field .applicationReads (.variable "input")) (.variable "reads"),
  .assign (.variable "result") (.app (.app (.app (.app (.app (.app (.app (.app (.function .applicationTail)
    text) context) input) info) (.group (.ite functionRoutine (.bodyStop .returnOnly) (.bodyStop .endOnly))))
    (.andThen procedureRoutine (.not (.variable "initialized")))) (.function .emptyFunctions)) (.function .emptyProcedures)),
  .choose (.eq (.field .scanPosition (.field .applicationScan result)) (.number 0)) fail .nothing,
  .choose functionRoutine (.list [
    .assign (.variable "value_first") (token (.field .scanPosition (.field .applicationScan result)) (.word "return")),
    .assign (.variable "value_after") (.app (.app (.app (.app (.function .functionReturnAfter) text) context)
      (.field .applicationScan result)) (.functionType (.number 0) (.field .routineResultKind item) (.field .routineResultBounds item) (.number 0))),
    .assign (.field .applicationReads (.variable "result")) (union (.field .applicationReads result)
      (reads context (.variable "value_first") (.variable "value_after"))),
    .assign (.field .scanPosition (.field .applicationScan (.variable "result"))) (token (.variable "value_after") (.symbol ";")),
    .choose (.orElse (.eq (.field .scanPosition (.field .applicationScan result)) (.number 0))
      (.stateSetNe (.field .applicationWrites result) .emptyStateSet)) fail .nothing]) .nothing,
  .assign (.variable "first") (skip (token (.field .scanPosition (.field .applicationScan result)) (.word "end"))),
  .assign (.variable "last") (after (.variable "first")),
  .assign (.variable "following") (token (.variable "last") (.symbol ";")),
  .choose (.orElse (.le (.variable "following") (.variable "original"))
    (.not (same (.variable "first") (.variable "last") (.field .routineBodyName item)))) fail .nothing,
  .assign (.field .routineBodyAfter (.variable "item")) (.variable "following"),
  .assign (.field .routineMayRead (.variable "item")) (.field .applicationReads result),
  .assign (.field .routineMayWrite (.variable "item")) (.field .applicationWrites result),
  .assign (.field .routineAssigned (.variable "item")) (.field .scanAssigned (.field .applicationScan result)),
  .assign (.index .routine (.variable "info") (.variable "index")) item,
  .assign (.field .infoCompleted (.variable "info")) (.variable "index"),
  .assign (.field .infoAssigned (.variable "info")) (.eagerOr (.field .infoAssigned info) (.field .routineAssigned item)),
  .assign (.field .statePosition (.variable "globals")) (.variable "following")]

def commands : ApplicationPackageProcedure.Command Fn := .list [
  .choose (.ge (.field .infoCompleted info) (.field .routineCount info)) fail .nothing,
  .assign (.variable "index") (.add (.field .infoCompleted info) (.number 1)),
  .primitive (.signature text globals (.variable "info") (.truth true) (.variable "header")),
  .choose (.eq (.field .statePosition (.variable "header")) (.number 0)) fail .nothing,
  .assign (.variable "item") (.index .routine info (.variable "index")),
  .choose (.andThen (.gt formalCount (.number 0)) (.group (.orElse
    (.orElse (.eq formalFirst (.number 0)) (.gt formalFirst (.field .parameterCount info)))
    (.gt formalCount (.add (.sub (.field .parameterCount info) formalFirst) (.number 1)))))) fail .nothing,
  .assign (.variable "frame") (.app (.app (.app (.app (.app (.function .routineFrame) text) globals) info)
    (.variable "index")) (.field .statePosition (.variable "header"))),
  .choose (.eq position (.number 0)) fail .nothing,
  .whileLoop (.eq (token position (.word "begin")) (.number 0)) localLoop,
  .assign (.field .statePosition (.variable "frame")) (token position (.word "begin")),
  .choose (.gt formalCount (.number 0)) (.list [
    .forRange "i" formalFirst formalLast outputRead,
    .forRange "i" formalFirst formalLast outputAppend]) .nothing,
  .block bodyDeclarations bodyCommands]

def body : ApplicationPackageProcedure.Body Fn :=
  {name := "package_completion_at", declarations, commands}

abbrev CheckedTree : Prop := body.wellFormed functionNames = true ∧
  body.scoped [(.source, "text"), (.state, "globals"), (.metadata, "info")] ["globals", "info"] = true ∧
  body.namedCorrect functionParameters = true

theorem checked_tree : CheckedTree := by decide +kernel

end Silver.ApplicationPackageCompletion.Native
