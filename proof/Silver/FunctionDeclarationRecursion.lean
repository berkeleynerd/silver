module

public import Silver.FunctionDeclarationDenotations
public import Silver.FunctionHeaderValidity
public import Silver.ComposeBounds

@[expose] public section

namespace Silver.Compose
open Silver.Compose.Expressions

private theorem scalarTypeAt_position_bound (text : Source) (state : ParserState) (position : Nat) :
    (scalarTypeAt text state position).after ≤ text.length + 1 := by
  dsimp only [scalarTypeAt]
  split
  · exact Nat.zero_le _
  · split
    · exact function_nameAfter_bound text _
    · split
      · exact function_nameAfter_bound text _
      · exact Nat.zero_le _

theorem functionTypeAt_position_bound (text : Source) (state : ParserState) (position : Nat) :
    (functionTypeAt text state position).after ≤ text.length + 1 := by
  dsimp only [functionTypeAt]
  split
  · exact scalarTypeAt_position_bound text state position
  · split
    · exact Nat.zero_le _
    · exact fixedAfter_result_bound text _ "boolean" true (by decide)

theorem parameterStep_position (text : Source) (state : ParserState) (arguments : Bool) :
    (parameterStep text state arguments).state.position ≤ text.length + 1 ∧
      ((parameterStep text state arguments).state.position = 0 ∨
        state.position < (parameterStep text state arguments).state.position) := by
  dsimp only [parameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize startEq : fixedAfter text (fixedAfter text after ":" false) "in" true = start
  generalize valueEq : functionTypeAt text state start = value
  have valueBound := functionTypeAt_position_bound text state start
  rw [valueEq] at valueBound
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · rename_i accepted
    have advances : state.position < value.after := by
      simp only [not_or] at accepted
      omega
    split
    · rename_i nonzero
      have later := model_fixed_advances text value.after ")" false valueBound (by decide) nonzero
      exact ⟨fixedAfter_result_bound text _ ")" false (by decide), .inr (Nat.lt_trans advances later)⟩
    · split
      · rename_i later
        exact ⟨fixedAfter_result_bound text _ ";" false (by decide), .inr later⟩
      · exact ⟨Nat.zero_le _, .inl rfl⟩

private theorem scalarDeclaration_position (text : Source) (state : ParserState) (arguments : Bool) :
    (scalarDeclarationAt text state arguments).position ≤ text.length + 1 ∧
      ((scalarDeclarationAt text state arguments).position = 0 ∨
        state.position < (scalarDeclarationAt text state arguments).position) := by
  dsimp only [scalarDeclarationAt]
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · rename_i accepted
    have advances : state.position < (scalarDeclarationParts text state).following := by
      simp only [Bool.or_eq_true, decide_eq_true_eq, not_or] at accepted
      omega
    exact ⟨fixedAfter_result_bound text _ ";" false (by decide), .inr advances⟩

private theorem booleanDeclaration_position (text : Source) (state : ParserState) (arguments : Bool) :
    (booleanDeclarationAt text state arguments).position ≤ text.length + 1 ∧
      ((booleanDeclarationAt text state arguments).position = 0 ∨
        state.position < (booleanDeclarationAt text state arguments).position) := by
  dsimp only [booleanDeclarationAt]
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · split
    · exact ⟨Nat.zero_le _, .inl rfl⟩
    · rename_i accepted
      exact ⟨fixedAfter_result_bound text _ ";" false (by decide), .inr (Nat.lt_of_not_ge accepted)⟩

theorem functionLocalAt_position (text : Source) (state : ParserState) (arguments : Bool) :
    (functionLocalAt text state arguments).position ≤ text.length + 1 ∧
      ((functionLocalAt text state arguments).position = 0 ∨
        state.position < (functionLocalAt text state arguments).position) := by
  dsimp only [functionLocalAt]
  split
  · exact scalarDeclaration_position text state arguments
  · exact booleanDeclaration_position text state arguments

theorem appendParameter_functions (frame : ParserState) (parameter : FunctionBindings.Formal) :
    (appendParameter frame parameter).position = 0 ∨
      (appendParameter frame parameter).functions = frame.functions := by
  dsimp only [appendParameter]
  split
  · split
    · exact .inl rfl
    · exact .inr rfl
  · split
    · exact .inl rfl
    · exact .inr rfl

namespace FunctionDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

theorem parametersModel_model (text : Source) (state : ParserState) (arguments : Bool) :
    parametersModelBody.eval modelCalls ({text, state, arguments} : Frame).locals =
      parametersModel text state arguments := by
  have progress := parameterStep_position text state arguments
  conv => rhs; rw [parametersModel]
  by_cases zero : (parameterStep text state arguments).state.position = 0
  · simp [parametersModelBody, Expr.eval, apply3, apply2, Frame.locals, Locals.set, modelCalls, Field.get, zero]
  · have advanced : Predicate.remainingAt text (parameterStep text state arguments).state.position <
        Predicate.remainingAt text state.position := by
      have later := progress.2.resolve_left zero
      unfold Predicate.remainingAt
      omega
    simp [parametersModelBody, Expr.eval, apply3, apply2, Frame.locals, Locals.set, modelCalls, Field.get, zero, advanced]

theorem functionLocalsModel_model (text : Source) (state : ParserState) (arguments : Bool) :
    functionLocalsModelBody.eval modelCalls ({text, state, arguments} : Frame).locals =
      functionLocalsModel text state arguments := by
  have progress := functionLocalAt_position text state arguments
  conv => rhs; rw [functionLocalsModel]
  by_cases zero : (functionLocalAt text state arguments).position = 0
  · simp [functionLocalsModelBody, Expr.eval, apply3, apply2, Frame.locals, Locals.set, modelCalls, Field.get, Token.shell, tokenAfter, ShellToken.word, zero]
  · have advanced : Predicate.remainingAt text (functionLocalAt text state arguments).position <
        Predicate.remainingAt text state.position := by
      have later := progress.2.resolve_left zero
      unfold Predicate.remainingAt
      omega
    simp [functionLocalsModelBody, Expr.eval, apply3, apply2, Frame.locals, Locals.set, modelCalls, Field.get, Token.shell, tokenAfter, ShellToken.word, zero, advanced]

theorem parameterFrameModel_model (frame : ParserState) (index : Nat) :
    parameterFrameModelBody.eval modelCalls ({frame, index} : Frame).locals = parameterFrameModel frame index := by
  have preserved := appendParameter_functions frame (FunctionBindings.parameter frame.functions index)
  conv => rhs; rw [parameterFrameModel]
  by_cases beyond : index > frame.functions.parameters.length
  · simp [parameterFrameModelBody, Expr.eval, apply2, Frame.locals, Field.get, beyond]
  · by_cases zero : (appendParameter frame (FunctionBindings.parameter frame.functions index)).position = 0
    · simp [parameterFrameModelBody, Expr.eval, apply2, Frame.locals, Locals.set, modelCalls, Field.get, zero]
    · have same := preserved.resolve_left zero
      have advanced : (appendParameter frame (FunctionBindings.parameter frame.functions index)).functions.parameters.length + 1 - (index + 1) <
          frame.functions.parameters.length + 1 - index := by rw [same]; omega
      have advancedReduced : (appendParameter frame (FunctionBindings.parameter frame.functions index)).functions.parameters.length - index <
          frame.functions.parameters.length + 1 - index := by
        simpa only [Nat.add_sub_add_right] using advanced
      simp [parameterFrameModelBody, Expr.eval, apply2, Frame.locals, Locals.set, modelCalls, Field.get, zero, advancedReduced]

end FunctionDeclarationNative
end Silver.Compose
