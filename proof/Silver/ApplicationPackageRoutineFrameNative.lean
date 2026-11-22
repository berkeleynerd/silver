module

public import Silver.ApplicationPackageRoutineFrameControl
public import Silver.ApplicationPackageRoutineFrame

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame.Native
open ApplicationNative

inductive Fn : Ty → Type
  | bodyEnvironment : Fn (.arrow .scalars .scalars)
  | validName : Fn (.arrow .source (.arrow .nameSpan .truth))
  | hideOuter : Fn (.arrow .source (.arrow .state (.arrow .metadata (.arrow .nameSpan .state))))
  | validState : Fn (.arrow .source (.arrow .state .truth))

def functionNames : FunctionNames Fn
  | _, .bodyEnvironment => ["scalar_expressions", ".", "body_environment"]
  | _, .validName => ["packages", ".", "valid_name"]
  | _, .hideOuter => ["hide_outer"]
  | _, .validState => ["valid_state"]

def modelFunctions (calls : ApplicationPackageRoutineFrame.Calls) : ApplicationNative.Calls Fn
  | _, .bodyEnvironment => calls.bodyEnvironment
  | _, .validName => calls.validName
  | _, .hideOuter => calls.hideOuter
  | _, .validState => calls.validState

/-- The command tree calls only appendFormal. Other primitive variants cannot
be reached by this tree; they retain explicit total values here. -/
def modelProcedures (calls : ApplicationPackageRoutineFrame.Calls) : ApplicationPackageProcedure.ProcedureCalls where
  signature := fun _ _ info _ => {info}
  appendFormal := calls.appendFormal
  completion := fun _ _ info => ApplicationPackageBodies.completionFailed info

abbrev E := Expr Fn
abbrev P := Place Fn
abbrev C := Control.Command Fn
abbrev text : E .source := .variable "text"
abbrev globals : E .state := .variable "globals"
abbrev info : E .metadata := .variable "info"
abbrev result : P .state := .variable "result"
abbrev item : E .routine := .variable "item"
abbrev parameter : E .formal := .variable "parameter"
abbrev mark : P .packageType := .variable "mark"
abbrev formalFirst : E .number := .field .routineFormalFirst item
abbrev formalCount : E .number := .field .routineFormalCount item
abbrev formalLast : E .number := .sub (.add formalFirst formalCount) (.number 1)

def declarations : List (Declaration Fn) := [
  {
    type := .state
    name := "result"
    typeName := ["parser_state"]
    initial := some (.update globals (.more .statePosition (.variable "position")
      (.more .statePure (.truth true) (.one .stateScalarNames
        (.app (.function .bodyEnvironment) (.field .stateScalarNames globals))))))},
  {
    type := .routine
    name := "item"
    typeName := ["packages", ".", "routine"]
    constant := true
    initial := some (.index .routine info (.variable "routine"))},
  {type := .formal, name := "parameter", typeName := ["packages", ".", "formal"], initial := none},
  {type := .packageType, name := "mark", typeName := ["package_type_result"], initial := none}]

def forgetBody : C :=
  let selected : P .booleanBinding := .index .boolean (.field .stateBooleanNames result) (.variable "i")
  .choose (.field .booleanMutable selected.expression)
    (.assign (.field .booleanKnown selected) (.truth false)) .nothing

def forgetLoop : C := .forRange "i" (.number 1)
  (.field .booleanCount (.field .stateBooleanNames result.expression)) forgetBody

def formalGuard : E .truth := .orElse
  (.orElse (.eq formalFirst (.number 0)) (.gt formalFirst (.field .parameterCount info)))
  (.gt formalCount (.add (.sub (.field .parameterCount info) formalFirst) (.number 1)))

def hideBody : C := .list [
  .assign (.variable "parameter") (.index .formal info (.variable "i")),
  .choose (.not (.app (.app (.function .validName) text) (.field .formalBodyName parameter)))
    (.returned .invalidState) .nothing,
  .assign result (.app (.app (.app (.app (.function .hideOuter) text) result.expression) info)
    (.field .formalBodyName parameter)),
  .choose (.eq (.field .statePosition result.expression) (.number 0)) (.returned .invalidState) .nothing]

def appendBody : C := .list [
  .assign (.variable "parameter") (.index .formal info (.variable "i")),
  .choose (.modeNe (.field .formalMode parameter) (.mode .output)) (.list [
    .namedMark mark (.field .formalBodyTypeName parameter)
      (.field .nameAfter (.field .formalBodyTypeName parameter)) (.field .formalKind parameter)
      (.field .formalBounds parameter) (.field .formalTypeIdentity parameter),
    .primitive (.appendFormal result (.field .formalBodyName parameter) mark.expression (.field .formalMode parameter)),
    .choose (.eq (.field .statePosition result.expression) (.number 0)) (.returned .invalidState) .nothing]) .nothing]

def parameters : C := .choose (.gt formalCount (.number 0)) (.list [
  .choose formalGuard (.returned .invalidState) .nothing,
  .forRange "i" formalFirst formalLast hideBody,
  .forRange "i" formalFirst formalLast appendBody]) .nothing

def finalState : C := .sequence
  (.choose (.not (.app (.app (.function .validState) text) result.expression))
    (.returned .invalidState) .nothing)
  (.returned result.expression)

def commands : C := .list [
  .choose (.gt (.variable "routine") (.field .routineCount info)) (.returned .invalidState) .nothing,
  forgetLoop, parameters, finalState]

def body : Control.Body Fn := {name := "routine_frame", declarations, commands}

abbrev CheckedTree : Prop := body.wellFormed functionNames = true ∧
  body.scoped [(.source, "text"), (.state, "globals"), (.metadata, "info"),
    (.number, "routine"), (.number, "position")] [] = true

theorem checked_tree : CheckedTree := by decide +kernel

end Silver.ApplicationPackageRoutineFrame.Native
