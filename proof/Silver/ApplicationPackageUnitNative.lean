module

public import Silver.ApplicationPackageProcedureControl
public import Silver.ApplicationPackageBodiesUnit

@[expose] public section

/-! Typed Package_Body_At source, including both original while loops, partial
metadata writes, exact state-table growth and the complete end-of-unit test. -/
namespace Silver.ApplicationPackageUnit.Native
open ApplicationNative
open ApplicationPackageProcedure

inductive Fn : Ty → Type
  | packageWord : Fn (.arrow .source (.arrow .number (.arrow .spelling .number)))
  | skipAt : Fn (.arrow .source (.arrow .number .number))
  | nameAfter : Fn (.arrow .source (.arrow .number .number))
  | takeToken : Fn (.arrow .source (.arrow .number (.arrow .token .number)))
  | sparkPragmaAfter : Fn (.arrow .source (.arrow .number .number))
  | sameName : Fn (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | maxStates : Fn .number
  | objectAt : Fn (.arrow .source (.arrow .state (.arrow .metadata .objectResult)))

def functionNames : FunctionNames Fn
  | _, .packageWord => ["package_word"]
  | _, .skipAt => ["skip_at"]
  | _, .nameAfter => ["name_after"]
  | _, .takeToken => ["take_token"]
  | _, .sparkPragmaAfter => ["spark_pragma_after"]
  | _, .sameName => ["packages", ".", "same_name"]
  | _, .maxStates => ["packages", ".", "max_states"]
  | _, .objectAt => ["package_object_at"]

def modelFunctions (calls : ApplicationPackageBodies.UnitCalls) : Calls Fn
  | _, .packageWord => calls.packageWord
  | _, .skipAt => calls.skipAt
  | _, .nameAfter => calls.nameAfter
  | _, .takeToken => calls.takeToken
  | _, .sparkPragmaAfter => calls.sparkPragmaAfter
  | _, .sameName => calls.sameName
  | _, .maxStates => PackageBindings.maxStates
  | _, .objectAt => fun text frame info => calls.objectAt text frame info false

def modelProcedures (calls : ApplicationPackageBodies.UnitCalls) : ProcedureCalls where
  signature := fun _ _ info _ => ⟨info, Compose.invalidState⟩
  appendFormal := fun _ _ _ _ => Compose.invalidState
  completion := calls.completionAt

abbrev text : Expr Fn .source := .variable "text"
abbrev info : Expr Fn .metadata := .variable "info"
abbrev globals : Expr Fn .state := .variable "globals"
abbrev object : Expr Fn .objectResult := .variable "object"
abbrev position : Expr Fn .number := .field .statePosition globals
abbrev token (first : Expr Fn .number) (kind : Compose.ShellToken) : Expr Fn .number :=
  .app (.app (.app (.function .takeToken) text) first) (.token kind)
abbrev skip (first : Expr Fn .number) : Expr Fn .number := .app (.app (.function .skipAt) text) first
abbrev after (first : Expr Fn .number) : Expr Fn .number := .app (.app (.function .nameAfter) text) first
abbrev word (first : Expr Fn .number) (value : String) : Expr Fn .number :=
  .app (.app (.app (.function .packageWord) text) first) (.word value)
abbrev same (first last : Expr Fn .number) : Expr Fn .truth :=
  .app (.app (.app (.function .sameName) text) (.nameSpan first last))
    (.nameSpan (.field .infoNameFirst info) (.field .infoNameAfter info))

def declarations : List (Declaration Fn) := [
  {
    type := .number
    name := "first"
    typeName := ["literal_position"]
    constant := true
    initial := some (skip (word (word (.field .unitFirst (.index .unit info (.unitKind .packageBody))) "package") "body"))},
  {
    type := .number
    name := "last"
    typeName := ["literal_position"]
    constant := true
    initial := some (after (.variable "first"))},
  {type := .state, name := "globals", typeName := ["parser_state"], initial := some (.variable "exports")},
  {type := .objectResult, name := "object", typeName := ["package_object_result"], initial := none},
  {
    type := .number
    name := "end_first"
    additionalNames := ["end_last", "following", "before"]
    typeName := ["literal_position"]
    initial := none}]

def objectLoopTest : Expr Fn .truth :=
  .andThen (.andThen (.eq (token position (.word "function")) (.number 0))
    (.eq (token position (.word "procedure")) (.number 0)))
    (.eq (token position (.word "end")) (.number 0))

def declarationValue : Expr Fn .stateDeclaration :=
  .stateDeclarationValue (.field .objectName object) (.field .markKind (.field .objectMark object))
    (.field .markName (.field .objectMark object)) (.field .markIdentity (.field .objectMark object))
    (.field .markBounds (.field .objectMark object)) (.field .objectInitialBounds object)
    (.field .objectInitFirst object) (.field .objectInitAfter object) (.field .objectBooleanValue object)

def objectLoopBody : ApplicationPackageProcedure.Command Fn := .list [
  .increases position,
  .choose (.eq (.field .stateCount info) (.function .maxStates)) .returned .nothing,
  .assign (.variable "before") position,
  .assign (.variable "object") (.app (.app (.app (.function .objectAt) text) globals) info),
  .choose (.orElse (.le (.field .statePosition (.field .objectFrame object)) (.variable "before"))
    (.field .objectConstantObject object)) .returned .nothing,
  .primitive (.growState (.variable "info") declarationValue),
  .assign (.variable "globals") (.field .objectFrame object)]

def routineLoopBody : ApplicationPackageProcedure.Command Fn := .list [
  .increases (.field .infoCompleted info),
  .assign (.variable "before") position,
  .primitive (.completion text (.variable "globals") (.variable "info")),
  .choose (.le position (.variable "before")) .returned .nothing]

def commands : ApplicationPackageProcedure.Command Fn := .list [
  .assign (.variable "accepted") (.truth false),
  .choose (.not (same (.variable "first") (.variable "last"))) .returned .nothing,
  .assign (.field .infoBodyNameFirst (.variable "info")) (.variable "first"),
  .assign (.field .infoBodyNameAfter (.variable "info")) (.variable "last"),
  .assign (.field .statePosition (.variable "globals"))
    (.app (.app (.function .sparkPragmaAfter) text) (token (.variable "last") (.word "is"))),
  .choose (.eq position (.number 0)) .returned .nothing,
  .whileLoop objectLoopTest objectLoopBody,
  .whileLoop (.lt (.field .infoCompleted info) (.field .routineCount info)) routineLoopBody,
  .assign (.variable "end_first") (skip (token position (.word "end"))),
  .assign (.variable "end_last") (after (.variable "end_first")),
  .assign (.variable "following") (token (.variable "end_last") (.symbol ";")),
  .assign (.variable "accepted") (.andThen
    (.andThen (same (.variable "end_first") (.variable "end_last")) (.ne (.variable "following") (.number 0)))
    (.eq (skip (.variable "following")) (.add (.sourceLast text) (.number 1))))]

def body : ApplicationPackageProcedure.Body Fn :=
  {name := "package_body_at", declarations, commands}

abbrev CheckedTree : Prop := body.wellFormed functionNames = true ∧
  body.scoped [(.source, "text"), (.state, "exports"), (.metadata, "info"), (.truth, "accepted")]
    ["info", "accepted"] = true ∧
  body.namedCorrect (fun _ => []) = true

theorem checked_tree : CheckedTree := by decide +kernel

end Silver.ApplicationPackageUnit.Native
