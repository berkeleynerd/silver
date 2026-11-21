module

public import Silver.ComposeCharacterReading
public import Silver.StringFreezing

@[expose] public section

namespace Silver.Compose
open Named Bindings

theorem character_positive {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    result.after ≠ 0 := by
  cases parsed with
  | literal _ source => simp only [characterValue, source.following]; omega
  | reference _ _ selected nonzero _ _ _ =>
      have found := lookupName_found (selected ▸ nonzero)
      simp only [characterValue]
      omega
  | indexed _ _ _ source =>
      have following := source.following
      simpa only [indexedValue, ↓reduceIte] using (show _ ≠ 0 by omega)
  | parenthesized _ _ _ close => exact close

theorem character_after_bounded {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    result.after ≤ text.length + 1 := by
  cases parsed with
  | literal _ source =>
      simp only [characterValue, source.following]
      have bound := source.bounded
      omega
  | reference _ _ selected nonzero _ _ _ =>
      have found := lookupName_found (selected ▸ nonzero)
      have namePositive : nameAfter text (skipAt text position) ≠ 0 := by omega
      simp only [nameAfter, found.1, ↓reduceIte] at namePositive
      simpa only [characterValue, nameAfter, found.1, ↓reduceIte] using
        (Named.identifierEnd_bounds text (skipAt text position) namePositive).2
  | indexed _ _ _ _ =>
      exact fixedAfter_result_bound text _ ")" false (by decide)
  | parenthesized _ _ _ _ =>
      exact fixedAfter_result_bound text _ ")" false (by decide)

theorem characterExpression_inferLength {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult} (normal : NamesNormal names)
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    Expression.inferLength [Value.character expression] names.shape
      (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) = some ⟨1, 1, 0, false⟩ := by
  simp [Expression.inferLength, Operand.inferLength, Value.extraRange, character_check normal parsed,
    LengthSummary.add]

theorem characterExpression_frozen_safe {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Character.Expr} {result : ValueResult} {integers : Integer.Store}
    (normal : NamesNormal names)
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) integers) :
    SafeExpression (Expression.freezeImages [Value.character expression] integers) names.shape maxSourceLength := by
  apply Expression.freezeImages_safe (characterExpression_inferLength normal parsed) scalars
  · simp only [Expression.LiteralsPrintable, List.mem_singleton]
    intro value same
    subst value
    exact character_literals parsed
  · simp
  · change 1 ≤ 64
    decide
  · decide

end Silver.Compose
