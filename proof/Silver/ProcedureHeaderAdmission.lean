module

public import Silver.FunctionDeclarationAdmission

@[expose] public section

/-! Procedure headers and the ordered initialization prefix. The fixed reader
frame contains locals and input-capable formals; a completed source assignment
introduces each output into the separate body frame. -/
namespace Silver.Compose
open Named

structure ProcedureParameterStepResult where
  state : ParserState
  closed : Bool
  deriving DecidableEq, Repr

def procedureParameterStep (text : Source) (state : ParserState)
    (arguments : Bool) : ProcedureParameterStepResult :=
  let first := skipAt text state.position
  let after := nameAfter text first
  let colonEnd := fixedAfter text after ":" false
  let inEnd := fixedAfter text colonEnd "in" true
  let outEnd := fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true
  let mode : ProcedureBindings.Mode :=
    if inEnd = 0 then .output else if outEnd = 0 then .input else .inputOutput
  let start := if outEnd ≠ 0 then outEnd else inEnd
  let value := formalTypeAt text state start
  if !newNameAllowed text state first after arguments ∨ start = 0 ∨ value.after ≤ state.position ∨
      state.procedures.parameters.length = ProcedureBindings.maxFormals ∨
      equalName text first after (skipAt text start) value.after ∨
      (value.typeId ≠ 0 ∧ mode ≠ .input)
    then ⟨invalidState, false⟩ else
  let next := {state with
    position := value.after,
    procedures := ProcedureBindings.appendFormal state.procedures ⟨first, after, value.kind, value.bounds, mode, value.typeId⟩,
    «hiding» := hideName text state.hiding first after}
  let separator := fixedAfter text value.after ";" false
  let close := fixedAfter text value.after ")" false
  if close ≠ 0 then ⟨{next with position := close}, true⟩
  else if separator > state.position then ⟨{next with position := separator}, false⟩
  else ⟨invalidState, false⟩

def procedureParametersModel (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let next := procedureParameterStep text state arguments
  if next.state.position = 0 then invalidState
  else if next.closed then next.state
  else if _advanced : Predicate.remainingAt text next.state.position < Predicate.remainingAt text state.position
    then procedureParametersModel text next.state arguments
  else invalidState
termination_by Predicate.remainingAt text state.position
decreasing_by exact _advanced

def procedureParametersAt := procedureParametersModel

def appendProcedureParameter (frame : ParserState) (parameter : ProcedureBindings.Formal) : ParserState :=
  if parameter.typeId ≠ 0 then
    if parameter.mode ≠ .input then invalidState
    else appendArrayParameter frame parameter.first parameter.after parameter.typeId
  else if parameter.kind = .integer then
    if frame.scalarNames.length = ScalarExpression.maxBindings then invalidState
    else {frame with scalarNames := frame.scalarNames ++
      [⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds,
        decide (parameter.mode ≠ .input)⟩]}
  else if frame.booleanNames.length = BooleanBindings.maxBindings then invalidState
  else {frame with booleanNames := frame.booleanNames ++
    [⟨parameter.first, parameter.after, decide (parameter.mode ≠ .input)⟩]}

def procedureInputFrameModel (frame : ParserState) (index : Nat) : ParserState :=
  if frame.position = 0 then invalidState
  else if outside : index > frame.procedures.parameters.length then frame
  else if (ProcedureBindings.parameter frame.procedures index).mode = .output then
    procedureInputFrameModel frame (index + 1)
  else let next := appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)
    if next.position = 0 then invalidState
    else if _advanced : next.procedures.parameters.length + 1 - (index + 1) <
        frame.procedures.parameters.length + 1 - index
      then procedureInputFrameModel next (index + 1)
    else invalidState
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | simpa only [Nat.add_sub_add_right] using _advanced

def procedureInputFrame (_text : Source) (frame : ParserState) : ParserState :=
  procedureInputFrameModel frame frame.firstProcedureParameter

def procedurePrefixStep (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat) : ParserState :=
  let first := skipAt text frame.position
  let after := nameAfter text first
  let context := {Predicate.contextOf ⟨readFrame, false, false⟩ with declarationCount}
  let valueAfter := Predicate.actualAfter text context (fixedAfter text after ":=" false)
    (Predicate.ActiveFlow.initial context.scalarNames (Predicate.initialFacts context.hasArguments))
    ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds, parameter.typeId⟩
  let following := fixedAfter text valueAfter ";" false
  if first = 0 ∨ after ≤ first ∨ !equalName text first after parameter.first parameter.after ∨
      valueAfter = 0 ∨ following ≤ frame.position then invalidState
  else appendProcedureParameter {frame with position := following} parameter

def procedurePrefixModel (text : Source) (readFrame frame : ParserState)
    (index declarationCount : Nat) : ParserState :=
  if frame.position = 0 then invalidState
  else if outside : index > frame.procedures.parameters.length then frame
  else if (ProcedureBindings.parameter frame.procedures index).mode ≠ .output then
    procedurePrefixModel text readFrame frame (index + 1) declarationCount
  else
    let next := procedurePrefixStep text readFrame frame
      (ProcedureBindings.parameter frame.procedures index) declarationCount
    if next.position = 0 then invalidState
    else if _advanced : next.procedures.parameters.length + 1 - (index + 1) <
        frame.procedures.parameters.length + 1 - index
      then procedurePrefixModel text readFrame next (index + 1) declarationCount
    else invalidState
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | simpa only [Nat.add_sub_add_right] using _advanced

def procedurePrefix (text : Source) (frame : ParserState) (declarationCount : Nat) : ParserState :=
  procedurePrefixModel text frame frame frame.firstProcedureParameter declarationCount

end Silver.Compose
