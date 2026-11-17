module

public import Silver.ProcedureDeclarationValidity
public import Silver.ProcedureDeclarationHiding
public import Silver.FunctionDeclarationValidity

@[expose] public section

namespace Silver.Compose
open _root_.Silver.Compose.Expressions

/-- A proof view of the native scanner's two leading declaration alternatives.
The concrete declaration dispatcher remains function-first. -/
def callableDeclarationAt (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let function := functionDeclarationAt text state arguments
  if function.position ≠ 0 then function else procedureDeclarationAt text state arguments

theorem callableDeclarationAt_zero_iff (text : Source) (state : ParserState) (arguments : Bool) :
    (callableDeclarationAt text state arguments).position = 0 ↔
      (functionDeclarationAt text state arguments).position = 0 ∧
      (procedureDeclarationAt text state arguments).position = 0 := by
  dsimp only [callableDeclarationAt]
  split <;> simp_all

theorem declarationAt_callable_equation (text : Source) (state : ParserState) (arguments : Bool) :
    declarationAt text state arguments =
      if (callableDeclarationAt text state arguments).position ≠ 0 then callableDeclarationAt text state arguments
      else if (subtypeDeclarationAt text state arguments).position ≠ 0 then subtypeDeclarationAt text state arguments
      else if (scalarDeclarationAt text state arguments).position ≠ 0 then scalarDeclarationAt text state arguments
      else if (arrayDeclarationAt text state arguments).position ≠ 0 then arrayDeclarationAt text state arguments
      else if (booleanDeclarationAt text state arguments).position ≠ 0 then booleanDeclarationAt text state arguments
      else if (characterDeclarationAt text state arguments).position ≠ 0 then characterDeclarationAt text state arguments
      else stringDeclarationAt text state arguments := by
  dsimp only [declarationAt, callableDeclarationAt]
  split <;> simp_all

structure CallableOuterPreserved (before after : ParserState) : Prop where
  names : after.names = before.names
  scalarNames : after.scalarNames = before.scalarNames
  booleanNames : after.booleanNames = before.booleanNames
  arrayNames : after.arrayNames = before.arrayNames
  dynamicFirst : after.dynamicFirst = before.dynamicFirst
  dynamicAfter : after.dynamicAfter = before.dynamicAfter
  target : after.target = before.target
  capacity : after.capacity = before.capacity
  subtypeItems : after.subtypeNames.items = before.subtypeNames.items
  subtypeTrueHidden : after.subtypeNames.trueHidden = before.subtypeNames.trueHidden
  subtypeFalseHidden : after.subtypeNames.falseHidden = before.subtypeNames.falseHidden
  pure : after.pure = before.pure
  firstParameter : after.firstParameter = before.firstParameter
  firstProcedureParameter : after.firstProcedureParameter = before.firstProcedureParameter

theorem CallableOuterPreserved.ofFunction {before after : ParserState}
    (kept : FunctionOuterPreserved before after) : CallableOuterPreserved before after :=
  ⟨kept.names, kept.scalarNames, kept.booleanNames, kept.arrayNames, kept.dynamicFirst,
    kept.dynamicAfter, kept.target, kept.capacity, kept.subtypeItems, kept.subtypeTrueHidden,
    kept.subtypeFalseHidden, kept.pure, kept.firstParameter, kept.firstProcedureParameter⟩

theorem CallableOuterPreserved.ofProcedure {before after : ParserState}
    (kept : ProcedureOuterPreserved before after) : CallableOuterPreserved before after :=
  ⟨kept.names, kept.scalarNames, kept.booleanNames, kept.arrayNames, kept.dynamicFirst,
    kept.dynamicAfter, kept.target, kept.capacity, kept.subtypeItems, kept.subtypeTrueHidden,
    kept.subtypeFalseHidden, kept.pure, kept.firstParameter, kept.firstProcedureParameter⟩

theorem callableDeclarationAt_preserves_outer (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (callableDeclarationAt text state arguments).position ≠ 0) :
    CallableOuterPreserved state (callableDeclarationAt text state arguments) := by
  dsimp only [callableDeclarationAt] at accepted ⊢
  by_cases function : (functionDeclarationAt text state arguments).position ≠ 0
  · rw [ite_eq_left function]
    exact .ofFunction (functionDeclarationAt_preserves_outer text state arguments function)
  · rw [ite_eq_right function] at accepted ⊢
    exact .ofProcedure (procedureDeclarationAt_preserves_outer text state arguments accepted)

theorem callableDeclarationAt_valid (text : Source) (state : ParserState) (arguments : Bool)
    (valid : ValidState text state) : ValidState text (callableDeclarationAt text state arguments) := by
  dsimp only [callableDeclarationAt]
  split
  · exact functionDeclarationAt_valid text state arguments valid
  · exact procedureDeclarationAt_valid text state arguments valid

theorem callableDeclarationAt_hiding {text : Source} {state : ParserState} {arguments : Bool}
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (callableNames state))
    (accepted : (callableDeclarationAt text state arguments).position ≠ 0) :
    IntegerSubtypes.HidingCorrect text (callableDeclarationAt text state arguments).subtypeNames
      (callableNames (callableDeclarationAt text state arguments)) := by
  dsimp only [callableDeclarationAt] at accepted ⊢
  by_cases function : (functionDeclarationAt text state arguments).position ≠ 0
  · rw [ite_eq_left function]
    exact functionDeclarationAt_hiding correct function
  · rw [ite_eq_right function] at accepted ⊢
    exact procedureDeclarationAt_hiding correct accepted

theorem Expressions.model_callable_declaration_valid {text : Source} {state : ParserState} {arguments : Bool}
    (_textValid : ValidText text) (valid : ValidState text state) :
    ValidState text (callableDeclarationAt text state arguments) :=
  callableDeclarationAt_valid text state arguments valid

end Silver.Compose
