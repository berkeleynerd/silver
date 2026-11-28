module

public import Silver.ApplicationNativeCommands
public import Silver.ApplicationPackageBodiesModel

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic
open ApplicationNative

inductive Fn : Ty → Type
  | skipAt : Fn (.arrow .source (.arrow .number .number))
  | nameAfter : Fn (.arrow .source (.arrow .number .number))
  | takeToken : Fn (.arrow .source (.arrow .number (.arrow .token .number)))
  | scalarTarget : Fn (.arrow .source (.arrow .parseContext (.arrow .number .number)))
  | booleanTarget : Fn (.arrow .source (.arrow .parseContext (.arrow .number .number)))
  | stateTarget : Fn (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number .number))))
  | packageCallAt : Fn (.arrow .source (.arrow .parseContext (.arrow .appScan (.arrow .metadata (.arrow .number (.arrow .routineKind .appCall))))))
  | callAssignmentResult : Fn (.arrow .parseContext (.arrow .bodyScan (.arrow .number (.arrow .number (.arrow .callResult .bodyScan)))))
  | bodyToken : Fn (.arrow .source (.arrow .parseContext (.arrow .bodyScan (.arrow .token .bodyScan))))
  | basicBody : Fn (.arrow .source (.arrow .parseContext (.arrow .bodyScan (.arrow .functions (.arrow .procedures .bodyScan)))))
  | stateReads : Fn (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number (.arrow .number .stateSet)))))
  | packageCallee : Fn (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number (.arrow .routineKind .number)))))
  | stateUnion : Fn (.arrow .stateSet (.arrow .stateSet .stateSet))
  | invalidApplication : Fn (.arrow .appScan .appScan)

def names : FunctionNames Fn
  | _, .skipAt => ["skip_at"]
  | _, .nameAfter => ["name_after"]
  | _, .takeToken => ["take_token"]
  | _, .scalarTarget => ["scalar_target"]
  | _, .booleanTarget => ["boolean_target"]
  | _, .stateTarget => ["state_target"]
  | _, .packageCallAt => ["package_call_at"]
  | _, .callAssignmentResult => ["call_assignment_result"]
  | _, .bodyToken => ["body_token"]
  | _, .basicBody => ["basic_body"]
  | _, .stateReads => ["state_reads"]
  | _, .packageCallee => ["package_callee"]
  | _, .stateUnion => ["packages", ".", "union"]
  | _, .invalidApplication => ["invalid_application"]

def functions (calls : BasicCalls) : Calls Fn
  | _, .skipAt => calls.skipAt
  | _, .nameAfter => calls.nameAfter
  | _, .takeToken => calls.takeToken
  | _, .scalarTarget => calls.scalarTarget
  | _, .booleanTarget => calls.booleanTarget
  | _, .stateTarget => calls.stateTarget
  | _, .packageCallAt => calls.packageCallAt
  | _, .callAssignmentResult => calls.callAssignmentResult
  | _, .bodyToken => calls.bodyToken
  | _, .basicBody => calls.basicBody
  | _, .stateReads => calls.stateReads
  | _, .packageCallee => calls.packageCallee
  | _, .stateUnion => PackageBindings.stateUnion
  | _, .invalidApplication => ApplicationPackages.invalidApplication

abbrev E := Expr Fn
abbrev P := Place Fn
abbrev C := Command Fn .appScan

abbrev text : E .source := .variable "text"
abbrev context : E .parseContext := .variable "context"
abbrev input : E .appScan := .variable "input"
abbrev info : E .metadata := .variable "info"
abbrev result : P .appScan := .variable "result"
abbrev called : P .appCall := .variable "called"
abbrev scan : P .bodyScan := .field .applicationScan result
abbrev inputScan : E .bodyScan := .field .applicationScan input
abbrev position : E .number := .field .scanPosition inputScan
abbrev valueFirst : E .number := .variable "value_first"
abbrev invalid : C := .returned (.app (.function .invalidApplication) input)

abbrev target (fn : Fn (.arrow .source (.arrow .parseContext (.arrow .number .number)))) : E .number :=
  .app (.app (.app (.function fn) text) context) position

abbrev packageCall (start : E .number) (kind : PackageBindings.RoutineKind) : E .appCall :=
  .app (.app (.app (.app (.app (.app (.function .packageCallAt) text) context) input) info) start) (.routineKind kind)

abbrev nativeBasic : E .bodyScan :=
  .app (.app (.app (.app (.app (.function .basicBody) text) context) inputScan) (.variable "catalog")) (.variable "procedure_catalog")

abbrev semicolon : C := .assign scan
  (.app (.app (.app (.app (.function .bodyToken) text) context) scan.expression) (.token (.symbol ";")))

def positionalConstant (name : String) (spelling : List String) (initial : E .number) : Declaration Fn :=
  {type := .number, name, typeName := spelling, constant := true, initial := some initial}

def declarations : List (Declaration Fn) := [
  {type := .appScan, name := "result", typeName := ["application_scan"],
   constraint := some (.property .appScanCount input), initial := some input},
  positionalConstant "first" ["literal_position"] (.app (.app (.function .skipAt) text) position),
  positionalConstant "last" ["literal_position"] (.app (.app (.function .nameAfter) text) (.variable "first")),
  positionalConstant "value_first" ["literal_position"]
    (.app (.app (.app (.function .takeToken) text) (.variable "last")) (.token (.symbol ":="))),
  positionalConstant "scalar" ["scalar_expressions", ".", "binding_count"] (target .scalarTarget),
  positionalConstant "flag" ["boolean_count"] (target .booleanTarget),
  positionalConstant "state" ["packages", ".", "state_id"]
    (.app (.app (.app (.app (.function .stateTarget) text) context) info) position),
  {type := .appCall, name := "called", typeName := ["application_call"],
   constraint := some (.property .appScanCount input), initial := none}]

def assignmentCommands : C := .list [
  .assign called (packageCall valueFirst .function),
  .choose (.ne (.field .valueAfter (.field .callValue called.expression)) (.number 0))
    (.list [
      .assign result (.field .callResult called.expression),
      .assign scan (.app (.app (.app (.app (.app (.function .callAssignmentResult) context)
        (.update scan.expression (.one .scanPosition position))) (.variable "scalar")) (.variable "flag"))
        (.field .callValue called.expression)),
      semicolon])
    (.list [
      .assign scan nativeBasic,
      .assign (.field .applicationReads result)
        (.app (.app (.function .stateUnion) (.field .applicationReads result.expression))
          (.app (.app (.app (.app (.app (.function .stateReads) text) context) info) valueFirst)
            (.field .scanPosition scan.expression)))]),
  .choose (.ne (.variable "state") (.number 0))
    (.assign (.index .stateBit (.field .applicationWrites result) (.variable "state")) (.truth true)) .nothing]

def dispatch : C := .choose
  (.andThen (.ne valueFirst (.number 0)) (.group (.orElse (.ne (.variable "scalar") (.number 0))
    (.ne (.variable "flag") (.number 0)))))
  assignmentCommands
  (.choose (.andThen (.field .applicationAllowProcedureCalls input) (.ne
    (.app (.app (.app (.app (.app (.function .packageCallee) text) context) info) position) (.routineKind .procedure))
    (.number 0)))
    (.list [.assign called (packageCall position .procedure), .assign result (.field .callResult called.expression), semicolon])
    (.assign scan nativeBasic))

def commands : C := .list [
  .choose (.eq position (.number 0)) invalid .nothing, dispatch,
  .choose (.le (.field .scanPosition scan.expression) position) invalid .nothing, .returned result.expression]

def body : Body Fn .appScan := ⟨"application_basic", declarations, commands⟩

abbrev CheckedTree : Prop := body.wellFormed names = true ∧
  body.scoped [(.source, "text"), (.parseContext, "context"), (.appScan, "input"), (.metadata, "info"),
    (.functions, "catalog"), (.procedures, "procedure_catalog")] = true

theorem checked_tree : CheckedTree := by decide +kernel

end Silver.ApplicationPackageBodies.Basic
