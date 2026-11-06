module

public import Silver.ComposeArrayDenotations
public import Silver.ComposeArrayNativeBounds

@[expose] public section

namespace Silver.Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
attribute [local irreducible] ScalarExpression.read

theorem model_arrayParts_equation (text : Source) (state : ParserState) :
    arrayPartsEquation modelCalls text state = arrayDeclarationParts text state := by
  dsimp +instances only [arrayPartsEquation, arrayDeclarationParts, modelCalls,
    declarationFirst, declarationAfter, declarationConstantAfter, declarationColonAfter,
    spelling, isWord, ShellToken.word, ShellToken.symbol]
  simp only [decide_eq_true_eq]

theorem model_arrayValues_zero (text : Source) (source result : ParserState) (length parsed : Nat) (componentBounds : Integer.Interval) :
    arrayValuesModel text source result 0 length parsed componentBounds = invalidState := by
  rw [arrayValuesModel]
  simp only [↓reduceIte]

attribute [local simp] model_arrayValues_zero booleanArrayValuesModel_zero

private theorem reject_or (p q : Prop) [Decidable p] [Decidable q] (value : ParserState) :
    (if p ∨ q then invalidState else value) =
      (if p then invalidState else if q then invalidState else value) := by
  by_cases hp : p <;> by_cases hq : q <;> simp [hp, hq]

theorem model_arrayDeclaration_equation (text : Source) (state : ParserState)
    (arguments executable : Bool) :
    arrayDeclarationEquation modelCalls executable text state arguments =
      arrayDeclarationAt text state arguments := by
  cases executable <;>
    simp only [arrayDeclarationEquation, model_arrayParts_equation] <;>
    dsimp +instances only [modelCalls, spelling, isWord, ShellToken.word, ShellToken.symbol] <;>
    simp only [arrayDeclarationAt, arrayDeclarationValues, Bool.decide_or, Bool.or_assoc, ite_self]
  all_goals
    generalize arrayDeclarationParts text state = parts
    rcases Bool.eq_false_or_eq_true parts.isBoolean with kind | kind <;>
      simp only [ArrayDeclarationParts.typeWord, kind, Bool.false_eq_true,
        Bool.false_and, Bool.true_and, decide_false, false_and, true_and,
        Bool.or_false, ↓reduceIte]
  all_goals
    split
    · rfl
    · by_cases single : (parts.upper.bounds.lower - parts.lower.bounds.lower + 1).toNat = 1
      · simp [single, arrayAggregatePosition, Bool.or_eq_true]
        split
        · simp_all [invalidState]
        · rename_i valid
          simp only [not_or] at valid
          rcases valid with ⟨nonzero, static, nonempty, low, high⟩
          simp_all [addArrayBinding, reject_or]
      · simp [single, arrayAggregatePosition, Bool.or_eq_true]
        by_cases zero : parts.position = 0
        · simp [zero, invalidState]
        · simp [zero, addArrayBinding, reject_or]

end Silver.Compose.Expressions
