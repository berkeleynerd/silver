module

public import Silver.ApplicationPackageDeclarationsControl
public import Silver.ApplicationPackageDeclarationsSpecificationModel

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.SpecificationNative
open Compose ApplicationNative Control

inductive Function : Ty → Type
  | skip : Function (.arrow .source (.arrow .number .number))
  | nameAfter : Function (.arrow .source (.arrow .number .number))
  | pragmaAfter : Function (.arrow .source (.arrow .number .number))
  | word : Function (.arrow .source (.arrow .number (.arrow .spelling .number)))
  | take : Function (.arrow .source (.arrow .number (.arrow .token .number)))
  | allowed : Function (.arrow .source (.arrow .nameSpan .truth))
  | fresh : Function (.arrow .source (.arrow .metadata (.arrow .nameSpan .truth)))
  | sameName : Function (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | hide : Function (.arrow .source (.arrow .hiding (.arrow .number (.arrow .number .hiding))))
  | subtype : Function (.arrow .source (.arrow .state (.arrow .truth .state)))
  | object : Function (.arrow .source (.arrow .state (.arrow .metadata .objectResult)))
  | validState : Function (.arrow .source (.arrow .state .truth))
  | initialState : Function .state
  | maxExports : Function .number

def functionNames : FunctionNames Function
  | _, .skip => ["skip_at"] | _, .nameAfter => ["name_after"] | _, .pragmaAfter => ["spark_pragma_after"]
  | _, .word => ["package_word"] | _, .take => ["take_token"] | _, .allowed => ["package_name_allowed"]
  | _, .fresh => ["package_name_fresh"] | _, .sameName => ["packages",".","same_name"] | _, .hide => ["hide_name"]
  | _, .subtype => ["subtype_declaration_at"] | _, .object => ["package_object_at"]
  | _, .validState => ["valid_state"] | _, .initialState => ["initial_state"]
  | _, .maxExports => ["packages",".","max_exports"]

def functions (calls : SpecificationCalls) : Calls Function
  | _, .skip => calls.skip | _, .nameAfter => calls.nameAfter | _, .pragmaAfter => calls.pragmaAfter
  | _, .word => calls.word | _, .take => calls.take | _, .allowed => calls.allowed
  | _, .fresh => calls.fresh | _, .sameName => calls.sameName | _, .hide => calls.hide
  | _, .subtype => calls.subtype | _, .object => fun text state info => calls.object text state info false
  | _, .validState => calls.stateValid | _, .initialState => Compose.initialState
  | _, .maxExports => PackageBindings.maxExports

abbrev E := Expr Function
abbrev P := Place Function
abbrev S := Statement Function

def text : E .source := .variable "text"
def info : P .metadata := .variable "info"
def exports : P .state := .variable "exports"
def nextFrame : P .state := .variable "next"
def object : P .objectResult := .variable "object"
def exportItem : P .exportItem := .variable "export"
def first : E .number := .variable "first"
def last : E .number := .variable "last"
def name : E .nameSpan := .nameSpan first last
def position : P .number := .field .statePosition exports
def nextPosition : E .number := .field .statePosition nextFrame.expression
def exportCount : E .number := .field .exportCount info.expression
def routineCount : E .number := .field .routineCount info.expression
def lastRoutine : E .routine := .index .routine info.expression routineCount
def before : P .number := .variable "before"
def endFirst : P .number := .variable "end_first"
def endLast : P .number := .variable "end_last"
def following : P .number := .variable "following"

def take (pos : E .number) (token : ShellToken) : E .number := call3 .take text pos (.token token)
def rejected : S := .sequence (.assign exports .invalidState) .returned
def rejectIf (test : E .truth) : S := .choose test rejected .nothing

def entry : S := .list [
  .assign exports .invalidState,
  .choose (.not (call2 .allowed text name)) .returned .nothing,
  .assign (.field .infoNameFirst info) first,
  .assign (.field .infoNameAfter info) last,
  .assign exports (.update (.function .initialState)
    (.more .statePosition (call2 .pragmaAfter text (take last (.word "is")))
      (.more .statePackageFirst first (.one .statePackageAfter last)))),
  .choose (.eq position.expression (.number 0)) .returned .nothing ]

def signatureBranch : S := .list [
  .call (.signature text exports.expression info (.truth false) nextFrame),
  rejectIf (.orElse (.eq nextPosition (.number 0)) (.eq routineCount (.number 0))),
  .assign position nextPosition,
  .assign (.field .stateHiding exports) (call4 .hide text (.field .stateHiding exports.expression)
    (.field .nameFirst (.field .routineSpecName lastRoutine)) (.field .nameAfter (.field .routineSpecName lastRoutine))) ]

def item : E .subtypeBinding := .variable "item"
def itemName : E .nameSpan := .nameSpan (.field .subtypeFirst item) (.field .subtypeAfter item)

def subtypeBranch : S := .list [
  .assign nextFrame (call3 .subtype text exports.expression (.truth false)),
  rejectIf (.eq nextPosition (.number 0)),
  .block [constant .subtypeBinding "item" ["subtype_binding"]
    (.index .subtype (.field .stateSubtypeNames nextFrame.expression)
      (.field .subtypeCount (.field .stateSubtypeNames nextFrame.expression)))]
    (.list [
      rejectIf (.not (call3 .fresh text info.expression itemName)),
      .assign exportItem (.recordValue .exportItem true
        (.more .exportName itemName (.more .exportKind (.exportKind .integerSubtype)
          (.more .exportBounds (.field .subtypeBounds item) (.one .exportTypeIdentity (.add exportCount (.number 2))))))) ]) ]

def mark : E .packageType := .field .objectMark object.expression

def objectBranch : S := .list [
  .assign object (call3 .object text exports.expression info.expression),
  rejectIf (.orElse (.eq (.field .statePosition (.field .objectFrame object.expression)) (.number 0))
    (.not (.field .objectConstantObject object.expression))),
  .assign nextFrame (.field .objectFrame object.expression),
  .assign exportItem (.recordValue .exportItem false
    (.more .exportName (.field .objectName object.expression)
    (.more .exportKind (.exportKind .booleanConstant) (.more .exportBounds .full
    (.more .exportTypeName (.field .markName mark) (.more .exportTypeIdentity (.field .markIdentity mark)
    (.more .exportInitializerFirst (.field .objectInitFirst object.expression)
    (.more .exportInitializerAfter (.field .objectInitAfter object.expression)
      (.one .exportBooleanValue (.field .objectBooleanValue object.expression)))))))))),
  .choose (.kindEq (.field .markKind mark) (.scalarKind .integer)) (.list [
    .assign (.field .exportKind exportItem) (.exportKind .integerConstant),
    .assign (.field .exportBounds exportItem) (.field .objectInitialBounds object.expression)]) .nothing ]

def storeExport : S := .list [
  .resize .exports info (.add exportCount (.number 1)),
  .assign (.index .export info exportCount) exportItem.expression,
  .assign exports nextFrame.expression ]

def exportBranch : S := .list [
  rejectIf (.eq exportCount (.function .maxExports)),
  .choose (.ne (take position.expression (.word "subtype")) (.number 0)) subtypeBranch objectBranch,
  storeExport ]

def progressCheck : S :=
  rejectIf (.orElse (.le position.expression before.expression) (.not (call2 .validState text exports.expression)))

def iteration : S := .list [
  .annotate (.invariant (call2 .validState text exports.expression)),
  .annotate (.invariant (.gt position.expression (.number 0))),
  .annotate (.increases position.expression),
  .assign before position.expression,
  .exitWhen (.ne (take position.expression (.word "end")) (.number 0)),
  .choose (.orElse (.ne (take position.expression (.word "function")) (.number 0))
    (.ne (take position.expression (.word "procedure")) (.number 0))) signatureBranch exportBranch,
  progressCheck ]

def finish : S := .list [
  .assign endFirst (call2 .skip text (take position.expression (.word "end"))),
  .assign endLast (call2 .nameAfter text endFirst.expression),
  .assign following (take endLast.expression (.symbol ";")),
  .choose (.orElse (.orElse (.orElse (.eq routineCount (.number 0))
    (.not (call3 .sameName text name (.nameSpan endFirst.expression endLast.expression))))
    (.eq following.expression (.number 0)))
    (.ne (call2 .skip text following.expression) (.add (.sourceLast text) (.number 1))))
    (.assign exports .invalidState) (.assign position following.expression) ]

def body : Control.Body Function where
  name := "package_spec_at"
  declarations := [
    constant .number "first" ["literal_position"] (call2 .skip text (call3 .word text (.number 1) (.word "package"))),
    constant .number "last" ["literal_position"] (call2 .nameAfter text first),
    localDeclaration .state "next" ["parser_state"],
    localDeclaration .objectResult "object" ["package_object_result"],
    localDeclaration .exportItem "export" ["packages",".","export_declaration"],
    localDeclaration .number "end_first" ["literal_position"] ["end_last","following"],
    localDeclaration .number "before" ["literal_position"] ]
  entry := entry
  guarded := none
  iteration := iteration
  finish := finish

def scope : Scope := [(.source,"text"),(.metadata,"info"),(.state,"exports")]

structure CheckedTree : Prop where
  formed : body.wellFormed functionNames = true
  bodyScopes : body.scoped scope ["info","exports"] = true
  named : body.namedCorrect (fun _ => []) = true

theorem checkedTree : CheckedTree := by constructor <;> decide +kernel

end Silver.ApplicationPackageDeclarations.SpecificationNative
