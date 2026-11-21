module

public import Silver.ProcedureDeclarationSyntax

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

def procedureParameterStepBody : Expr .procedureStep :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let colonEnd : Expr .number := .variable "colon_end"
  let inEnd : Expr .number := .variable "in_end"
  let outEnd : Expr .number := .variable "out_end"
  let parameterMode : Expr .mode := .variable "mode"
  let start : Expr .number := .variable "start"
  let value : Expr .typeResult := .variable "value"
  let next : Expr .state := .variable "next"
  let separator : Expr .number := .variable "separator"
  let close : Expr .number := .variable "close"
  let position := Expr.field .position state
  let valueAfter := Expr.field .typeAfter value
  let rejectedResult := Expr.procedureStepResult .invalid (.truth false)
  .declare <| .letValue "first" (apply2 (.function .skip) text position) <|
    .letValue "after" (apply2 (.function .nameAfter) text first) <|
    .letValue "colon_end" (apply3 (.function .take) text after (.token .colon)) <|
    .letValue "in_end" (apply3 (.function .take) text colonEnd (.token .inKeyword)) <|
    .letValue "out_end" (apply3 (.function .take) text
      (.group (.ite (.eq inEnd (.number 0)) colonEnd inEnd)) (.token .outKeyword)) <|
    .letValue "mode" (.group (.ite (.eq inEnd (.number 0)) (.mode .output)
      (.elsif (.eq outEnd (.number 0)) (.mode .input) (.mode .inputOutput)))) <|
    .letValue "start" (.group (.ite (.ne outEnd (.number 0)) outEnd inEnd)) <|
    .letValue "value" (apply3 (.function .formalType) text state start) <|
    .beginValue <| .group <| .ite
      (.orElse (.orElse (.orElse (.orElse (.orElse
        (.not (apply5 (.function .newName) text state first after arguments))
        (.eq start (.number 0))) (.le valueAfter position))
        (.group (.andThen (.ne (.field .typeTypeId value) (.number 0))
          (.neMode parameterMode (.mode .input)))))
        (.eq (.field .procedureParameterCount (.field .procedures state)) (.capacity .procedureFormals)))
        (apply5 (.function .equal) text first after (apply2 (.function .skip) text start) valueAfter))
      rejectedResult <| .group <| .declare <| .letValue "next"
        (.update .hiding
          (.update .procedures (.update .position state valueAfter)
            (apply2 (.function .appendProcedureFormal) (.field .procedures state)
              (.procedureFormal first after (.field .typeKind value) (.field .typeBounds value)
                (.field .typeTypeId value) parameterMode)))
          (apply4 (.function .hideName) text (.field .hiding state) first after)) <|
      .letValue "separator" (apply3 (.function .take) text valueAfter (.token .semicolon)) <|
      .letValue "close" (apply3 (.function .take) text valueAfter (.token .rightParenthesis)) <|
      .beginValue <| .group <| .ite (.ne close (.number 0))
        (.procedureStepResult (.update .position next close) (.truth true))
        (.elsif (.gt separator position)
          (.procedureStepResult (.update .position next separator) (.truth false)) rejectedResult)

def procedureParametersModelBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let next : Expr .procedureStep := .variable "next"
  let nextState := Expr.field .procedureStepState next
  .declare <| .letValue "next" (apply3 (.function .procedureParameterStep) text state arguments) <|
    .beginValue <| .group <| .ite (.eq (.field .position nextState) (.number 0)) .invalid
      (.elsif (.field .procedureStepClosed next) nextState
        (apply3 (.function .procedureParametersModel) text nextState arguments))

def appendProcedureParameterBody : Expr .state :=
  let frame : Expr .state := .variable "frame"
  let parameter : Expr .procedureFormal := .variable "parameter"
  .ite (.ne (.field .procedureFormalTypeId parameter) (.number 0))
    (.group (.ite (.neMode (.field .procedureFormalMode parameter) (.mode .input)) .invalid
      (apply4 (.function .appendArrayParameter) frame (.field .procedureFormalFirst parameter)
        (.field .procedureFormalAfter parameter) (.field .procedureFormalTypeId parameter))))
    (.elsif (.eqKind (.field .procedureFormalKind parameter) (.kind .integer))
    (.group (.ite (.eq (.field .scalarCount (.field .scalarNames frame)) (.capacity .scalars)) .invalid
      (.update .scalarNames frame (apply2 (.function .scalarAppend) (.field .scalarNames frame)
        (.procedureScalarBinding parameter)))))
    (.group (.ite (.eq (.field .booleanCount (.field .booleans frame)) (.capacity .booleans))
      .invalid (.appendProcedureBoolean frame parameter))))

def procedureInputFrameModelBody : Expr .state :=
  let frame : Expr .state := .variable "frame"
  let index : Expr .number := .variable "index"
  let next : Expr .state := .variable "next"
  let parameter := Expr.procedureFormalAt (.field .procedures frame) index
  .ite (.eq (.field .position frame) (.number 0)) .invalid
    (.elsif (.gt index (.field .procedureParameterCount (.field .procedures frame))) frame
      (.elsif (.eqMode (.field .procedureFormalMode parameter) (.mode .output))
        (apply2 (.function .procedureInputFrameModel) frame (.add index (.number 1)))
        (.group <| .declare <| .letValue "next" (apply2 (.function .appendProcedureParameter) frame parameter) <|
          .beginValue <| .group <| .ite (.eq (.field .position next) (.number 0)) .invalid
            (apply2 (.function .procedureInputFrameModel) next (.add index (.number 1))))))

def procedurePrefixStepBody : Command .state :=
  let text : Expr .source := .variable "text"
  let readFrame : Expr .state := .variable "read_frame"
  let frame : Expr .state := .variable "frame"
  let parameter : Expr .procedureFormal := .variable "parameter"
  let declarationCount : Expr .number := .variable "declaration_count"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let context : Expr .context := .variable "context"
  let valueAfter : Expr .number := .variable "value_after"
  let following : Expr .number := .variable "following"
  .letValue "first" (apply2 (.function .skip) text (.field .position frame)) <|
    .letValue "after" (apply2 (.function .nameAfter) text first) <|
    .letValue "context" (.updateDeclarationCount
      (.app (.function .contextOf) (.scan readFrame (.truth false) (.truth false))) declarationCount) <|
    .letValue "value_after" (apply5 (.function .actualAfter) text context
      (apply3 (.function .take) text after (.token .assignment)) (.app (.function .initialFlow) context)
      (.formal (.field .procedureFormalFirst parameter) (.field .procedureFormalAfter parameter)
        (.field .procedureFormalKind parameter) (.field .procedureFormalBounds parameter)
        (.field .procedureFormalTypeId parameter))) <|
    .letValue "following" (apply3 (.function .take) text valueAfter (.token .semicolon)) <|
    .beginBody <| .guard
      (.orElse (.orElse (.orElse (.orElse (.eq first (.number 0)) (.le after first))
        (.not (apply5 (.function .equal) text first after
          (.field .procedureFormalFirst parameter) (.field .procedureFormalAfter parameter))))
        (.eq valueAfter (.number 0))) (.le following (.field .position frame))) .invalid <|
    .returned (apply2 (.function .appendProcedureParameter) (.update .position frame following) parameter)

def procedurePrefixModelBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let readFrame : Expr .state := .variable "read_frame"
  let frame : Expr .state := .variable "frame"
  let index : Expr .number := .variable "index"
  let declarationCount : Expr .number := .variable "declaration_count"
  let next : Expr .state := .variable "next"
  let parameter := Expr.procedureFormalAt (.field .procedures frame) index
  .ite (.eq (.field .position frame) (.number 0)) .invalid
    (.elsif (.gt index (.field .procedureParameterCount (.field .procedures frame))) frame
      (.elsif (.neMode (.field .procedureFormalMode parameter) (.mode .output))
        (apply5 (.function .procedurePrefixModel) text readFrame frame (.add index (.number 1)) declarationCount)
        (.group <| .declare <| .letValue "next"
          (apply5 (.function .procedurePrefixStep) text readFrame frame parameter declarationCount) <|
          .beginValue <| .group <| .ite (.eq (.field .position next) (.number 0)) .invalid
            (apply5 (.function .procedurePrefixModel) text readFrame next (.add index (.number 1)) declarationCount))))

def stateScope : Scope := [(.source,"text"),(.state,"state"),(.truth,"arguments")]
def appendScope : Scope := [(.state,"frame"),(.procedureFormal,"parameter")]
def frameScope : Scope := [(.state,"frame"),(.number,"index")]
def prefixStepScope : Scope := [(.source,"text"),(.state,"read_frame"),(.state,"frame"),
  (.procedureFormal,"parameter"),(.number,"declaration_count")]
def prefixModelScope : Scope := [(.source,"text"),(.state,"read_frame"),(.state,"frame"),
  (.number,"index"),(.number,"declaration_count")]

abbrev CheckedHelperTrees : Prop :=
  procedureParameterStepBody.wellFormed = true ∧ procedureParameterStepBody.scoped stateScope = true ∧
  procedureParametersModelBody.wellFormed = true ∧ procedureParametersModelBody.scoped stateScope = true ∧
  appendProcedureParameterBody.wellFormed = true ∧ appendProcedureParameterBody.scoped appendScope = true ∧
  procedureInputFrameModelBody.wellFormed = true ∧ procedureInputFrameModelBody.scoped frameScope = true ∧
  procedurePrefixStepBody.wellFormed = true ∧ procedurePrefixStepBody.scoped prefixStepScope = true ∧
  procedurePrefixModelBody.wellFormed = true ∧ procedurePrefixModelBody.scoped prefixModelScope = true

theorem checked_helper_trees : CheckedHelperTrees := by decide +kernel

end Silver.Compose.ProcedureDeclarationNative
