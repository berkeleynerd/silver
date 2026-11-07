module

public import Silver.FunctionDeclarationNative

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

theorem functionType_model (text : Source) (state : ParserState) (position : Nat) :
    functionTypeBody.eval modelCalls ({text, state, position} : Frame).locals =
      functionTypeAt text state position := by
  simp [functionTypeBody, Expr.eval, apply2, apply3, apply4, Frame.locals, Locals.set,
    modelCalls, Field.get, Token.shell, tokenAfter, ShellToken.word, functionTypeAt,
    Bool.or_eq_true, or_assoc]

theorem parameterStep_model (text : Source) (state : ParserState) (arguments : Bool) :
    parameterStepBody.eval modelCalls ({text, state, arguments} : Frame).locals =
      parameterStep text state arguments := by
  simp [parameterStepBody, Expr.eval, apply2, apply3, apply4, apply5, Frame.locals, Locals.set,
    modelCalls, Field.get, StateField.set, Token.shell, tokenAfter, ShellToken.word, ShellToken.symbol, parameterStep,
    Bool.or_eq_true, or_assoc, Capacity.value]

theorem functionLocal_model (text : Source) (state : ParserState) (arguments : Bool) :
    functionLocalBody.eval modelCalls ({text, state, arguments} : Frame).locals =
      functionLocalAt text state arguments := by
  simp [functionLocalBody, Expr.eval, apply2, apply3, Frame.locals, Locals.set,
    modelCalls, Field.get, functionLocalAt]

theorem appendParameter_model (frame : ParserState) (parameter : FunctionBindings.Formal) :
    appendParameterBody.eval modelCalls ({frame, parameter} : Frame).locals =
      appendParameter frame parameter := by
  cases kindEq : parameter.kind <;>
    simp [appendParameterBody, Expr.eval, apply2, Frame.locals,
      modelCalls, Field.get, StateField.set, appendParameter, Capacity.value, kindEq]

theorem returnAfter_model (text : Source) (context : Predicate.ParseContext) (scan : Predicate.BodyScan)
    (resultType : FunctionTypeResult) :
    returnAfterBody.eval modelCalls ({text, context, scan, resultType} : Frame).locals =
      functionReturnAfter text context scan resultType := by
  rfl

theorem functionBody_model (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) :
    functionBodyBody.eval modelCalls ({text, outer, frame, first, after, resultType, arguments} : Frame).locals =
      functionBodyAt text outer frame first after resultType arguments := by
  simp [functionBodyBody, Command.eval, Expr.eval, apply2, apply3, apply4, apply5,
    Frame.locals, Locals.set, modelCalls, Field.get, StateField.set, Token.shell,
    tokenAfter, ShellToken.word, ShellToken.symbol, functionBodyAt, Bool.or_eq_true, or_assoc, IntegerSubtypes.CallHiding.add,
    Names.Operation.name]

theorem functionDeclaration_model (text : Source) (state : ParserState) (arguments : Bool) :
    functionDeclarationBody.eval modelCalls ({text, state, arguments} : Frame).locals =
      functionDeclarationAt text state arguments := by
  simp [functionDeclarationBody, Command.eval, Expr.eval, apply2, apply3, apply4, apply5,
    Frame.locals, Locals.set, modelCalls, Field.get, StateField.set, Token.shell,
    tokenAfter, ShellToken.word, ShellToken.symbol, functionDeclarationAt, Bool.or_eq_true, or_assoc, Capacity.value]

end Silver.Compose.FunctionDeclarationNative
