module

public import Silver.ApplicationPackageCallsModel
public import Silver.ApplicationNativeDeclarationLaws

@[expose] public section

/-! Complete typed Package_Call_At source tree, including native declaration
order, fixed actual/seen storage, early returns, explicit alias checks and
implicit state updates. The raw interpreter accepts arbitrary imported calls;
its specialization below still requires each imported helper's source meaning. -/
namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

inductive Function : Ty → Type
  | callee : Function (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number (.arrow .routineKind .number)))))
  | invalidApplication : Function (.arrow .appScan .appScan)
  | reference : Function (.arrow .source (.arrow .number .reference))
  | take : Function (.arrow .source (.arrow .number (.arrow .token .number)))
  | skip : Function (.arrow .source (.arrow .number .number))
  | nameAfter : Function (.arrow .source (.arrow .number .number))
  | sameName : Function (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | actualAfter : Function (.arrow .source (.arrow .parseContext (.arrow .number (.arrow .activeFlow (.arrow .functionFormal .number)))))
  | targetActual : Function (.arrow .source (.arrow .parseContext (.arrow .number (.arrow .activeFlow (.arrow .procedureFormal .procedureActual)))))
  | stateTarget : Function (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number .number))))
  | stateReads : Function (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number (.arrow .number .stateSet)))))
  | union : Function (.arrow .stateSet (.arrow .stateSet .stateSet))
  | actualNameFree : Function (.arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth)))))
  | visibleState : Function (.arrow .source (.arrow .parseContext (.arrow .metadata (.arrow .number .truth))))
  | scalarLookup : Function (.arrow .source (.arrow .scalars (.arrow .number (.arrow .number .number))))
  | validBody : Function (.arrow .source (.arrow .parseContext (.arrow .bodyScan .truth)))

def functionNames : FunctionNames Function
  | _, .callee => ["package_callee"]
  | _, .invalidApplication => ["invalid_application"]
  | _, .reference => ["scalar_expressions", ".", "read_reference"]
  | _, .take => ["take_token"]
  | _, .skip => ["skip_at"]
  | _, .nameAfter => ["name_after"]
  | _, .sameName => ["packages", ".", "same_name"]
  | _, .actualAfter => ["actual_after"]
  | _, .targetActual => ["procedure_target_actual"]
  | _, .stateTarget => ["state_target"]
  | _, .stateReads => ["state_reads"]
  | _, .union => ["packages", ".", "union"]
  | _, .actualNameFree => ["actual_name_free"]
  | _, .visibleState => ["visible_state"]
  | _, .scalarLookup => ["scalar_expressions", ".", "lookup"]
  | _, .validBody => ["valid_body"]

def imported (calls : ApplicationPackageCalls.Calls) : ApplicationNative.Calls Function
  | _, .callee => packageCallee calls
  | _, .invalidApplication => ApplicationPackages.invalidApplication
  | _, .reference => calls.reference
  | _, .take => calls.take
  | _, .skip => calls.skip
  | _, .nameAfter => calls.nameAfter
  | _, .sameName => calls.sameName
  | _, .actualAfter => calls.actualAfter
  | _, .targetActual => calls.targetActual
  | _, .stateTarget => calls.stateTarget
  | _, .stateReads => calls.stateReads
  | _, .union => PackageBindings.stateUnion
  | _, .actualNameFree => calls.actualNameFree
  | _, .visibleState => calls.visibleState
  | _, .scalarLookup => calls.scalarLookup
  | _, .validBody => calls.validBody

abbrev E := Expr Function
abbrev P := Place Function
abbrev C := Command Function .appCall

def call1 (fn : Function (.arrow a b)) (x : E a) : E b := .app (.function fn) x
def call2 (fn : Function (.arrow a (.arrow b c))) (x : E a) (y : E b) : E c := .app (call1 fn x) y
def call3 (fn : Function (.arrow a (.arrow b (.arrow c d)))) (x : E a) (y : E b) (z : E c) : E d :=
  .app (call2 fn x y) z
def call4 (fn : Function (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (w : E a) (x : E b) (y : E c) (z : E d) : E e := .app (call3 fn w x y) z
def call5 (fn : Function (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f))))))
    (v : E a) (w : E b) (x : E c) (y : E d) (z : E e) : E f := .app (call4 fn v w x y) z

def text : E .source := .variable "text"
def context : E .parseContext := .variable "context"
def input : E .appScan := .variable "input"
def info : E .metadata := .variable "info"
def position : E .number := .variable "position"
def kind : E .routineKind := .variable "kind"
def callee : E .number := .variable "callee"
def reference : E .reference := .variable "reference"
def failure : E .appCall := .variable "failure"
def result : P .appCall := .variable "result"
def actuals : P .packageActuals := .variable "actuals"
def seen : P .packageSeen := .variable "seen"
def callWrites : P .stateSet := .variable "call_writes"
def item : E .routine := .variable "item"
def cursor : E .number := .variable "cursor_at"
def first : E .number := .variable "first"
def last : E .number := .variable "last"
def arrow : E .number := .variable "arrow_end"
def following : E .number := .variable "following"
def named : E .truth := .variable "named"
def slot : E .number := .variable "slot"
def parameter : E .formal := .variable "parameter"
def legacy : E .procedureFormal := .variable "legacy_parameter"
def scalar : E .number := .variable "scalar"
def ordinal : E .number := .variable "ordinal"
def i : E .number := .variable "i"
def j : E .number := .variable "j"
def s : E .number := .variable "s"

def count : E .number := .field .routineFormalCount item
def formalFirst : E .number := .field .routineFormalFirst item
def formalLast : E .number := .sub (.add formalFirst count) (.number 1)
def actual (index : E .number) : P .packageActual := .index .actual actuals index
def output : P .appScan := .field .callResult result
def scan : P .bodyScan := .field .applicationScan output
def facts : P .activeFlow := .field .scanFacts scan

def returnFailure : C := .returned failure

def formalInput : E .functionFormal := .functionFormal
  (.field .nameFirst (.field .formalSpecName parameter))
  (.field .nameAfter (.field .formalSpecName parameter))
  (.field .formalKind parameter) (.field .formalBounds parameter) (.number 0)

def formalOutput : E .procedureFormal := .procedureFormal
  (.field .nameFirst (.field .formalSpecName parameter))
  (.field .nameAfter (.field .formalSpecName parameter))
  (.field .formalKind parameter) (.field .formalBounds parameter) (.number 0)
  (.field .formalMode parameter)

def namedScan : C := .forRange "i" formalFirst formalLast
  (.choose (call3 .sameName text (.nameSpan first last) (.field .formalSpecName (.index .formal info i)))
    (.assign (.variable "slot") i) .nothing)

def actualCommands : C := .list [
  .assign (.variable "first") (call2 .skip text cursor),
  .assign (.variable "last") (call2 .nameAfter text first),
  .assign (.variable "arrow_end") (call3 .take text last (.token (.symbol "=>"))),
  .assign (.variable "slot") (.number 0),
  .choose (.ne arrow (.number 0))
    (.list [.assign (.variable "named") (.truth true), namedScan,
      .assign (.variable "cursor_at") arrow])
    (.choose named returnFailure
      (.assign (.variable "slot") (.sub (.add formalFirst ordinal) (.number 1)))),
  .choose (.orElse (.eq slot (.number 0)) (.index .seen seen.expression slot)) returnFailure .nothing,
  .assign (.index .seen seen slot) (.truth true),
  .assign (.variable "parameter") (.index .formal info slot),
  .assign (.field .actualFirst (actual slot)) cursor,
  .choose (.modeEq (.field .formalMode parameter) (.mode .input))
    (.assign (.variable "following") (call5 .actualAfter text context cursor
      (.field .scanFacts (.field .applicationScan input)) formalInput))
    (.list [
      .assign (.variable "legacy_parameter") formalOutput,
      .assign (.field .actualTarget (actual slot)) (call5 .targetActual text context cursor
        (.field .scanFacts (.field .applicationScan input)) legacy),
      .assign (.variable "following") (.field .targetAfter (.field .actualTarget (actual slot).expression)),
      .assign (.field .actualWrittenState (actual slot)) (call4 .stateTarget text context info cursor)]),
  .choose (.le following cursor) returnFailure .nothing,
  .assign (.field .actualAfter (actual slot)) following,
  .choose (.modeNe (.field .formalMode parameter) (.mode .output))
    (.assign (.field .actualReads (actual slot)) (call5 .stateReads text context info cursor following)) .nothing,
  .assign (.field .applicationReads output) (call2 .union
    (.field .applicationReads output.expression) (.field .actualReads (actual slot).expression)),
  .choose (.ne (.field .actualWrittenState (actual slot).expression) (.number 0))
    (.assign (.index .stateBit callWrites (.field .actualWrittenState (actual slot).expression)) (.truth true)) .nothing,
  .assign (.variable "cursor_at") (call3 .take text following
    (.group (.ite (.eq ordinal count) (.token (.symbol ")")) (.token (.symbol ","))))),
  .choose (.eq cursor (.number 0)) returnFailure .nothing]

def stateAliasScan : C :=
  .forRange "s" (.number 1) (.field .stateCount info)
    (.choose (.andThen (.index .stateBit (.field .routineMayWrite item) s)
      (.index .stateBit (.field .actualReads (actual i).expression) s)) returnFailure .nothing)

def payloadAliasScan : C :=
  .forRange "j" formalFirst formalLast
        (.choose (.andThen (.ne i j) (.not (call5 .actualNameFree text
          (.field .actualFirst (actual j).expression) (.field .actualAfter (actual j).expression)
          (.field .targetFirst (.field .actualTarget (actual i).expression))
          (.field .targetAfter (.field .actualTarget (actual i).expression))))) returnFailure .nothing)

def aliasCommands : C := .list [
  stateAliasScan,
  .choose (.modeNe (.field .formalMode (.index .formal info i)) (.mode .input))
    (.list [
      .choose (.andThen (.ne (.field .actualWrittenState (actual i).expression) (.number 0))
        (.group (.orElse
          (.index .stateBit (.field .routineMayRead item) (.field .actualWrittenState (actual i).expression))
          (.index .stateBit (.field .routineMayWrite item) (.field .actualWrittenState (actual i).expression)))))
        returnFailure .nothing,
      payloadAliasScan,
      .assign (.variable "scalar") (.field .targetScalar (.field .actualTarget (actual i).expression)),
      .choose (.ne scalar (.number 0))
        (.assign (.index .flowValue facts scalar) (.field .formalBounds (.index .formal info i))) .nothing,
      .assign (.field .scanAssigned scan) (.truth true)]) .nothing]

def resetCommands : C := .choose
  (.andThen (.andThen (.index .stateBit callWrites.expression s) (call4 .visibleState text context info s))
    (.kindEq (.field .declarationKind (.index .state info s)) (.scalarKind .integer)))
  (.list [
    .assign (.variable "scalar") (call4 .scalarLookup text (.field .contextScalarNames context)
      (.field .nameFirst (.field .declarationName (.index .state info s)))
      (.field .nameAfter (.field .declarationName (.index .state info s)))),
    .choose (.ne scalar (.number 0))
      (.assign (.index .flowValue facts scalar)
        (.field .scalarDeclaredBounds (.index .scalar (.field .contextScalarNames context) scalar))) .nothing]) .nothing

def callCommands : C := .list [
  .choose (.eq callee (.number 0)) returnFailure .nothing,
  .assign (.variable "item") (.index .routine info callee),
  .assign callWrites (.field .routineMayWrite item),
  .choose (.andThen (.gt count (.number 0)) (.group (.orElse
    (.orElse (.eq formalFirst (.number 0)) (.gt formalFirst (.field .parameterCount info)))
    (.gt count (.add (.sub (.field .parameterCount info) formalFirst) (.number 1)))))) returnFailure .nothing,
  .assign (.variable "cursor_at") (.field .referenceAfter reference),
  .choose (.gt count (.number 0))
    (.list [
      .assign (.variable "cursor_at") (call3 .take text cursor (.token (.symbol "("))),
      .choose (.eq cursor (.number 0)) returnFailure .nothing,
      .forRange "ordinal" (.number 1) count actualCommands]) .nothing,
  .choose (.gt count (.number 0)) (.forRange "i" formalFirst formalLast aliasCommands) .nothing,
  .assign (.field .applicationReads output) (call2 .union
    (.field .applicationReads output.expression) (.field .routineMayRead item)),
  .assign (.field .applicationWrites output) (call2 .union
    (.field .applicationWrites output.expression) callWrites.expression),
  .forRange "s" (.number 1) (.field .stateCount info) resetCommands,
  .assign (.field .scanPosition scan) cursor,
  .choose (.routineEq kind (.routineKind .procedure)) (.assign (.field .scanAssigned scan) (.truth true)) .nothing,
  .assign (.field .callValue result) (.callValueAggregate cursor
    (.field .routineResultKind item) (.field .routineResultBounds item)),
  .choose (.orElse (.le cursor position) (.not (call3 .validBody text context scan.expression))) returnFailure .nothing,
  .returned result.expression]

def callBody : Body Function .appCall where
  name := "package_call_at"
  declarations := [
    {type := .number, name := "callee", typeName := ["packages", ".", "routine_count_type"], constant := true,
      initial := some (call5 .callee text context info position kind)},
    {type := .appCall, name := "failure", typeName := ["application_call"], constant := true,
      constraint := some (.property .appScanCount input),
      initial := some (.applicationCall (.property .appScanCount input) .invalidCall (call1 .invalidApplication input))},
    {type := .reference, name := "reference", typeName := ["scalar_expressions", ".", "name_reference"], constant := true,
      initial := some (call2 .reference text position)},
    {type := .appCall, name := "result", typeName := ["application_call"],
      constraint := some (.property .appScanCount input),
      initial := some (.applicationCall (.property .appScanCount input) .invalidCall input)},
    {type := .packageActuals, name := "actuals", typeName := ["package_actual_array"], initial := some .emptyActuals},
    {type := .stateSet, name := "call_writes", typeName := ["packages", ".", "state_set"], initial := some .emptyStateSet},
    {type := .packageSeen, name := "seen", typeName := ["package_seen_array"], initial := some .emptySeen},
    {type := .routine, name := "item", typeName := ["packages", ".", "routine"], initial := none},
    {type := .number, name := "cursor_at", typeName := ["literal_position"],
      additionalNames := ["first", "last", "arrow_end", "following"], initial := none},
    {type := .truth, name := "named", typeName := ["boolean"], initial := some (.truth false)},
    {type := .number, name := "slot", typeName := ["packages", ".", "formal_count_type"], initial := none},
    {type := .formal, name := "parameter", typeName := ["packages", ".", "formal"], initial := none},
    {type := .procedureFormal, name := "legacy_parameter", typeName := ["procedures", ".", "formal"], initial := none},
    {type := .number, name := "scalar", typeName := ["scalar_expressions", ".", "binding_count"], initial := none}]
  commands := callCommands

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem call_wellFormed : callBody.wellFormed functionNames = true := by decide +kernel

theorem call_scoped : callBody.scoped
    [(.source,"text"), (.parseContext,"context"), (.appScan,"input"), (.metadata,"info"),
     (.number,"position"), (.routineKind,"kind")] = true := by decide +kernel

end Silver.ApplicationPackageCalls.Native.Call
