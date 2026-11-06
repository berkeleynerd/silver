module

public import Silver.ComposeContracts

@[expose] public section

namespace Silver.Compose.Expressions
variable {domain : StateDomain}
set_option backward.dsimp.instances true
set_option maxRecDepth 10000

@[simp] theorem interpreted_fixedBounds (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (length : Nat) (dynamic isCharacter : Bool) (firstIndex lastIndex : Int) (slot : Nat)
    (lengthBound : length ≤ maxSourceLength) (firstBound : Integer.InRange firstIndex)
    (lastBound : Integer.InRange lastIndex) (slotPositive : 1 ≤ slot) (slotBound : slot ≤ maxBindings) :
    calls.function .fixedBoundsValid length dynamic isCharacter firstIndex lastIndex slot =
      fixedBoundsValid length dynamic isCharacter firstIndex lastIndex slot := by
  rw [equations.fixedBounds length dynamic isCharacter firstIndex lastIndex slot lengthBound firstBound lastBound slotPositive slotBound]
  dsimp +instances only [StringNative.fixedBoundsBody, Expr.eval, Context.locals, Calls.get, Field.get]
  cases isCharacter <;> cases dynamic <;>
    simp [fixedBoundsValid, Bool.decide_and, Bool.and_assoc]

@[simp] theorem interpreted_characterLiteral (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .characterLiteral text position = characterLiteralAfter text position := by
  rw [equations.characterLiteral text valid position bound]
  dsimp +instances only [StringNative.characterLiteralBody, Expr.eval, Context.locals, Calls.get]
  simp only [characterLiteralAfter, Bool.and_eq_true, decide_eq_true_eq, and_assoc]

@[simp] theorem interpreted_concatenatedFirst (calls : Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (left : ExpressionState) (right : ValueResult)
    (leftValid : NativeScan text left) (rightValid : NativeValue text right) :
    calls.function .concatenatedFirst left right = concatenatedFirst left right := by
  rw [equations.concatenatedFirst text left right leftValid rightValid]
  dsimp +instances only [StringNative.concatenatedFirstBody, Expr.eval, Context.locals,
    Calls.get, Field.get]
  simp only [concatenatedFirst, Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]

end Silver.Compose.Expressions
