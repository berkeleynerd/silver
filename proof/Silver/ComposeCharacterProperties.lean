module

public import Silver.ComposeCharacterReading

@[expose] public section

namespace Silver.Compose
open Named Bindings

theorem character_positive {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
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
    {scalarNames : ScalarExpression.Environment} {arrays : ArrayBindings.Metadata}
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

end Silver.Compose
