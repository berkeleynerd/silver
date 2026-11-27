module

public import Silver.ApplicationPackageDeclarationsControl
public import Silver.ApplicationPackageDeclarationsSignatureModel

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose ApplicationNative Control

inductive Function : Ty → Type
  | skip : Function (.arrow .source (.arrow .number .number))
  | nameAfter : Function (.arrow .source (.arrow .number .number))
  | take : Function (.arrow .source (.arrow .number (.arrow .token .number)))
  | validName : Function (.arrow .source (.arrow .nameSpan .truth))
  | sameName : Function (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | fresh : Function (.arrow .source (.arrow .metadata (.arrow .nameSpan .truth)))
  | hide : Function (.arrow .source (.arrow .hiding (.arrow .number (.arrow .number .hiding))))
  | hideOuter : Function (.arrow .source (.arrow .state (.arrow .metadata (.arrow .nameSpan .state))))
  | typeAt : Function (.arrow .source (.arrow .state (.arrow .metadata (.arrow .number .packageType))))
  | validState : Function (.arrow .source (.arrow .state .truth))
  | arrayEnvironment : Function (.arrow .source (.arrow .arrays .truth))
  | functionMetadata : Function (.arrow .source (.arrow .functions .truth))
  | maxRoutines : Function .number
  | maxFormals : Function .number

def functionNames : FunctionNames Function
  | _, .skip => ["skip_at"] | _, .nameAfter => ["silver_output_profile",".","name_after"]
  | _, .take => ["take_token"] | _, .validName => ["packages",".","valid_name"]
  | _, .sameName => ["packages",".","same_name"] | _, .fresh => ["package_name_fresh"]
  | _, .hide => ["hide_name"] | _, .hideOuter => ["hide_outer"] | _, .typeAt => ["package_type_at"]
  | _, .validState => ["valid_state"] | _, .arrayEnvironment => ["array_bindings",".","valid_environment"]
  | _, .functionMetadata => ["functions",".","valid_metadata"] | _, .maxRoutines => ["packages",".","max_routines"]
  | _, .maxFormals => ["packages",".","max_formals"]

structure Calls where
  base : SignatureCalls
  arrayEnvironment : Source → ArrayBindings.Env → Bool
  functionMetadata : Source → FunctionBindings.Metadata → Bool

def Calls.get (calls : Calls) : ApplicationNative.Calls Function
  | _, .skip => calls.base.skip | _, .nameAfter => calls.base.nameAfter | _, .take => calls.base.take
  | _, .validName => calls.base.validName | _, .sameName => calls.base.sameName | _, .fresh => calls.base.fresh
  | _, .hide => calls.base.hide | _, .hideOuter => calls.base.hideOuter | _, .typeAt => calls.base.typeAt
  | _, .validState => calls.base.stateValid | _, .arrayEnvironment => calls.arrayEnvironment
  | _, .functionMetadata => calls.functionMetadata | _, .maxRoutines => PackageBindings.maxRoutines
  | _, .maxFormals => PackageBindings.maxFormals

abbrev E := Expr Function
abbrev P := Place Function
abbrev S := Statement Function

def text : E .source := .variable "text"
def outer : E .state := .variable "outer"
def info : P .metadata := .variable "info"
def header : P .state := .variable "header"
def completing : E .truth := .variable "completing"
def original : E .number := .variable "original"
def functionEnd : E .number := .variable "function_end"
def procedureEnd : E .number := .variable "procedure_end"
def nameFirst : E .number := .variable "name_first"
def nameAfter : E .number := .variable "name_after"
def name : E .nameSpan := .nameSpan nameFirst nameAfter
def item : P .routine := .variable "item"
def routineId : P .number := .variable "routine_id"
def formalCount : P .number := .variable "formal_count"
def formalStart : P .number := .variable "formal_start"
def opened : P .number := .variable "open"
def first : P .number := .variable "first"
def last : P .number := .variable "last"
def nextPos : P .number := .variable "next"
def modeEnd : P .number := .variable "mode_end"
def mode : P .mode := .variable "mode"
def mark : P .packageType := .variable "mark"
def parameter : P .formal := .variable "parameter"
def slot : P .number := .variable "slot"
def before : P .number := .variable "before"
def position : P .number := .field .statePosition header
def outerPosition : E .number := .field .statePosition outer
def completed : E .number := .field .infoCompleted info.expression
def routineCount : E .number := .field .routineCount info.expression
def parameterCount : E .number := .field .parameterCount info.expression
def itemCount : E .number := .field .routineFormalCount item.expression
def itemStart : E .number := .field .routineFormalFirst item.expression
def itemFunction : E .truth := .routineEq (.field .routineKind item.expression) (.routineKind .function)
def marked : E .number := .field .markAfter mark.expression
def markedKind : E .scalarKind := .field .markKind mark.expression
def markedIdentity : E .number := .field .markIdentity mark.expression
def markedBounds : E .interval := .field .markBounds mark.expression
def markedName : E .nameSpan := .field .markName mark.expression
def formalName : E .nameSpan := .nameSpan first.expression last.expression
def take (pos : E .number) (token : ShellToken) : E .number := call3 .take text pos (.token token)
def empty (value : E .number) : E .truth := .eq value (.number 0)
def present (value : E .number) : E .truth := .ne value (.number 0)
def inc (value : E .number) : E .number := .add value (.number 1)
def validState : E .truth := call2 .validState text header.expression
def rejected : S := .sequence (.assign header .invalidState) .returned
def rejectIf (test : E .truth) : S := .choose test rejected .nothing
def returnIf (test : E .truth) : S := .choose test .returned .nothing

def completeItem : S := .list [
  returnIf (.ge completed routineCount),
  .assign routineId (inc completed),
  .assign item (.index .routine info.expression routineId.expression),
  returnIf (.andThen (.gt itemCount (.number 0)) (.group (.orElse
    (.orElse (empty itemStart) (.gt itemStart parameterCount))
    (.gt itemCount (inc (.sub parameterCount itemStart)))))),
  returnIf (.orElse (.not (call3 .sameName text (.field .routineSpecName item.expression) name))
    (.truthNe (.group itemFunction) (.group (present functionEnd)))),
  .assign formalStart itemStart,
  .assign (.field .routineBodyName item) name,
  .assign (.field .routineBodyFirst item) original ]

def newItem : S := .list [
  returnIf (.orElse (.eq routineCount (.function .maxRoutines)) (.not (call3 .fresh text info.expression name))),
  .assign routineId (inc routineCount),
  .assign item (.recordDefault .routine),
  .assign (.field .routineKind item) (.group (.ite (present functionEnd) (.routineKind .function) (.routineKind .procedure))),
  .assign (.field .routineSpecName item) name,
  .assign (.field .routineSpecFirst item) original ]

def entry : S := .list [
  .assign header .invalidState,
  returnIf (.orElse (.orElse (.orElse (empty original)
    (.group (.andThen (empty functionEnd) (empty procedureEnd)))) (empty nameFirst)) (.le nameAfter nameFirst)),
  .choose completing completeItem newItem,
  .assign header (.update outer (.more .statePosition nameAfter (.more .statePure (.truth true)
    (.one .stateHiding (call4 .hide text (.field .stateHiding outer) nameFirst nameAfter))))),
  .assign opened (take position.expression (.symbol "(")) ]

def invariants : S := .list [
  .annotate (.invariant validState),
  .annotate (.invariant (.gt position.expression (.number 0))),
  .annotate (.invariant (.le formalCount.expression parameterCount)),
  .annotate (.invariant (.conditionalTrue (.gt formalCount.expression (.number 0))
    (.andThen (.andThen (.gt formalStart.expression (.number 0)) (.le formalStart.expression parameterCount))
      (.le formalCount.expression (inc (.sub parameterCount formalStart.expression)))))),
  .annotate (.completingFormals completing formalStart.expression item.expression formalCount.expression info.expression),
  .annotate (.increases position.expression) ]

def environmentAssertions : S := .list [
  .annotate (.assertion (call2 .arrayEnvironment text (.field .stateArrayNames header.expression))),
  .annotate (.assertion (call2 .functionMetadata text (.field .stateFunctions header.expression))) ]

def selectSlot : S := .choose completing (.list [
    rejectIf (.ge formalCount.expression itemCount),
    .assign slot (.add formalStart.expression formalCount.expression)])
  (.list [
    rejectIf (.eq parameterCount (.function .maxFormals)),
    .assign slot (inc parameterCount),
    .choose (empty formalCount.expression) (.assign formalStart slot.expression) .nothing ])

def duplicate : E .truth :=
  let prior : E .formal := .index .formal info.expression (.variable "i")
  .andThen (.gt formalCount.expression (.number 0))
    (.group (.forSome "i" formalStart.expression (.sub (.add formalStart.expression formalCount.expression) (.number 1))
      (call3 .sameName text formalName (.group (.ite completing
        (.field .formalBodyName prior) (.field .formalSpecName prior))))))

def readMode : S := .list [
  .assign nextPos (take last.expression (.symbol ":")),
  .assign modeEnd (take nextPos.expression (.word "in")),
  .choose (present modeEnd.expression)
    (.list [
      .assign nextPos (take modeEnd.expression (.word "out")),
      .assign mode (.group (.ite (present nextPos.expression) (.mode .inputOutput) (.mode .input))),
      .choose (empty nextPos.expression) (.assign nextPos modeEnd.expression) .nothing ])
    (.list [.assign nextPos (take nextPos.expression (.word "out")), .assign mode (.mode .output)]),
  rejectIf (.orElse (empty nextPos.expression) (.group (.andThen itemFunction (.modeNe mode.expression (.mode .input))))),
  .assign mark (call4 .typeAt text header.expression info.expression nextPos.expression),
  rejectIf (empty marked) ]

def completeParameter : S := .list [
  .assign parameter (.index .formal info.expression slot.expression),
  rejectIf (.orElse (.orElse (.orElse (.orElse
    (.not (call3 .sameName text (.field .formalSpecName parameter.expression) formalName))
    (.modeNe (.field .formalMode parameter.expression) mode.expression))
    (.kindNe (.field .formalKind parameter.expression) markedKind))
    (.ne (.field .formalTypeIdentity parameter.expression) markedIdentity))
    (.intervalNe (.field .formalBounds parameter.expression) markedBounds)),
  .assign (.field .formalBodyName parameter) formalName,
  .assign (.field .formalBodyTypeName parameter) markedName ]

def newParameter : S := .list [
  .assign parameter (.recordValue .formal true
    (.more .formalSpecName formalName (.more .formalSpecTypeName markedName (.more .formalKind markedKind
    (.more .formalBounds markedBounds (.more .formalTypeIdentity markedIdentity (.one .formalMode mode.expression))))))),
  .resize .parameters info slot.expression ]

def storeParameter : S := .list [
  .choose completing completeParameter newParameter,
  .assign (.index .formal info slot.expression) parameter.expression,
  .assign formalCount (inc formalCount.expression),
  .assign position marked,
  .call (.appendFormal header formalName mark.expression mode.expression),
  environmentAssertions,
  returnIf (empty position.expression) ]

def endParameter : S := .list [
  .assign nextPos (take position.expression (.symbol ")")),
  .choose (present nextPos.expression) (.list [
    .assign position nextPos.expression,
    .annotate (.assertion (.gt position.expression (.number 0))),
    .annotate (.assertion validState),
    .exited ]) .nothing,
  .assign position (take position.expression (.symbol ";")),
  rejectIf (.le position.expression before.expression) ]

def selectFormalCommands : List S := [
  invariants,
  .assign before position.expression,
  .assign first (call2 .skip text position.expression),
  .assign last (call2 .nameAfter text first.expression),
  rejectIf (.not (call2 .validName text formalName)),
  selectSlot ]

def hideFormalCommands : List S := [
  rejectIf duplicate,
  .assign header (call4 .hideOuter text header.expression info.expression formalName),
  environmentAssertions,
  returnIf (empty position.expression) ]

def iteration : S := .list (selectFormalCommands ++ hideFormalCommands ++ [readMode, storeParameter, endParameter])

def resultType : S := .list [
  .assign mark (call4 .typeAt text header.expression info.expression (take position.expression (.word "return"))),
  rejectIf (empty marked),
  .choose completing (.list [
    rejectIf (.orElse (.orElse (.kindNe (.field .routineResultKind item.expression) markedKind)
      (.ne (.field .routineResultTypeIdentity item.expression) markedIdentity))
      (.intervalNe (.field .routineResultBounds item.expression) markedBounds)),
    .assign (.field .routineBodyResultName item) markedName ])
    (.list [
      .assign (.field .routineResultKind item) markedKind,
      .assign (.field .routineResultBounds item) markedBounds,
      .assign (.field .routineResultTypeIdentity item) markedIdentity,
      .assign (.field .routineSpecResultName item) markedName ]),
  .assign position marked ]

def finish : S := .list [
  rejectIf (.andThen completing (.ne formalCount.expression itemCount)),
  .choose (.not completing) (.list [
    .assign (.field .routineFormalCount item) formalCount.expression,
    .assign (.field .routineFormalFirst item) formalStart.expression ]) .nothing,
  .choose itemFunction resultType .nothing,
  .assign position (call3 .take text position.expression (.group (.ite completing (.token (.word "is")) (.token (.symbol ";"))))),
  rejectIf (.orElse (.le position.expression outerPosition) (.not validState)),
  .choose (.not completing) (.list [
    .assign (.field .routineSpecAfter item) position.expression,
    .resize .routines info routineId.expression ]) .nothing,
  .assign (.index .routine info routineId.expression) item.expression ]

def body : Control.Body Function where
  name := "package_signature_at"
  declarations := [
    constant .number "original" ["literal_position"] (call2 .skip text outerPosition),
    constant .number "function_end" ["literal_position"] (take outerPosition (.word "function")),
    constant .number "procedure_end" ["literal_position"] (take outerPosition (.word "procedure")),
    constant .number "name_first" ["literal_position"] (call2 .skip text (.group (.ite (present functionEnd) functionEnd procedureEnd))),
    constant .number "name_after" ["literal_position"] (call2 .nameAfter text nameFirst),
    localDeclaration .routine "item" ["packages",".","routine"],
    localDeclaration .number "routine_id" ["packages",".","routine_count_type"],
    localDeclaration .number "formal_count" ["packages",".","formal_count_type"] [] (some (.number 0)),
    localDeclaration .number "formal_start" ["packages",".","formal_count_type"] [] (some (.number 0)),
    localDeclaration .number "open" ["literal_position"] ["first","last","next","mode_end"],
    localDeclaration .mode "mode" ["procedures",".","parameter_mode"],
    localDeclaration .packageType "mark" ["package_type_result"],
    localDeclaration .formal "parameter" ["packages",".","formal"],
    localDeclaration .number "slot" ["packages",".","formal_count_type"],
    localDeclaration .number "before" ["literal_position"] ]
  entry := entry
  guarded := some (present opened.expression, .assign position opened.expression)
  iteration := iteration
  finish := finish

def scope : Scope := [(.source,"text"),(.state,"outer"),(.metadata,"info"),(.truth,"completing"),(.state,"header")]

structure CheckedTree : Prop where
  formed : body.wellFormed functionNames = true
  bodyScopes : body.scoped scope ["info","header"] = true
  named : body.namedCorrect (fun _ => []) = true

theorem checkedTree : CheckedTree := by constructor <;> decide +kernel

end Silver.ApplicationPackageDeclarations.SignatureNative
