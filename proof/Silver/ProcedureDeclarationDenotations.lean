module

public import Silver.ProcedureDeclarationNative

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 5000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

theorem appendProcedureParameter_model (frame : ParserState) (parameter : ProcedureBindings.Formal) :
    appendProcedureParameterBody.eval modelCalls ({frame, procedureParameter := parameter} : Frame).locals =
      appendProcedureParameter frame parameter := by
  dsimp +instances only [appendProcedureParameterBody, Expr.eval, apply2, apply3, apply4, Frame.locals,
    modelCalls, Field.get, StateField.set, appendProcedureParameter, Capacity.value]
  simp

theorem procedurePrefixStep_model (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat) :
    procedurePrefixStepBody.eval modelCalls
      ({text, readFrame, frame, procedureParameter := parameter, declarationCount} : Frame).locals =
        procedurePrefixStep text readFrame frame parameter declarationCount := by
  simp [procedurePrefixStepBody, Command.eval, Expr.eval, apply2, apply3, apply4, apply5,
    Frame.locals, Locals.set, modelCalls, Field.get, StateField.set, Token.shell,
    tokenAfter, ShellToken.symbol, procedurePrefixStep,
    Bool.or_eq_true, or_assoc, nativeContextOf, Predicate.Native.Context.model, Predicate.contextOf]

/-- Recursive calls stay arbitrary in these equations. Their meanings follow
later by induction from the exact native domains and checked callee contracts. -/
def parametersEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let next := calls .procedureParameterStep text state arguments
  if next.state.position = 0 then invalidState
  else if next.closed then next.state else calls .procedureParametersModel text next.state arguments

theorem parameters_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    procedureParametersModelBody.eval calls ({text, state, arguments} : Frame).locals =
      parametersEquation calls text state arguments := by
  dsimp +instances only [procedureParametersModelBody, Expr.eval, apply2, apply3,
    Frame.locals, Locals.set, Field.get, parametersEquation]
  simp

def inputFrameEquation (calls : Calls) (frame : ParserState) (index : Nat) : ParserState :=
  if frame.position = 0 then invalidState
  else if index > frame.procedures.parameters.length then frame
  else if (ProcedureBindings.parameter frame.procedures index).mode = .output then
    calls .procedureInputFrameModel frame (index + 1)
  else let next := calls .appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)
    if next.position = 0 then invalidState else calls .procedureInputFrameModel next (index + 1)

theorem inputFrame_denotation (calls : Calls) (frame : ParserState) (index : Nat) :
    procedureInputFrameModelBody.eval calls ({frame, index} : Frame).locals =
      inputFrameEquation calls frame index := by
  dsimp +instances only [procedureInputFrameModelBody, Expr.eval, apply2,
    Frame.locals, Locals.set, Field.get, inputFrameEquation]
  simp

def prefixEquation (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (index declarationCount : Nat) : ParserState :=
  if frame.position = 0 then invalidState
  else if index > frame.procedures.parameters.length then frame
  else if (ProcedureBindings.parameter frame.procedures index).mode ≠ .output then
    calls .procedurePrefixModel text readFrame frame (index + 1) declarationCount
  else
    let next := calls .procedurePrefixStep text readFrame frame
      (ProcedureBindings.parameter frame.procedures index) declarationCount
    if next.position = 0 then invalidState else
      calls .procedurePrefixModel text readFrame next (index + 1) declarationCount

theorem prefix_denotation (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (index declarationCount : Nat) :
    procedurePrefixModelBody.eval calls ({text, readFrame, frame, index, declarationCount} : Frame).locals =
      prefixEquation calls text readFrame frame index declarationCount := by
  dsimp +instances only [procedurePrefixModelBody, Expr.eval, apply2, apply3, apply4, apply5,
    Frame.locals, Locals.set, Field.get, prefixEquation]
  simp

end Silver.Compose.ProcedureDeclarationNative
