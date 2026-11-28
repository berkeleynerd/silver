module

public import Silver.ApplicationPackageHiddenFlow
public import Silver.ApplicationPackageVisibleStateLayout

@[expose] public section

namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageEffects

theorem global_integer_original {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} {bound slot identity : Nat}
    (declarations : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity) :
    OriginalRow context (.integer slot) := by
  have live := slotAddress_global selected
  have state := stateIndex_some live.2.2
  rw [scalarRows_get] at state
  dsimp only at state
  have domain := (ApplicationPackageNames.Native.validName_domain
    (declarations.name state.1 state.2.1)).2
  exact ⟨Nat.ne_of_gt live.1, by simpa only [scalarRows, List.length_map] using live.2.1,
    state.2.2.1, by rw [← state.2.2.2.2.1]; exact Nat.ne_of_gt domain.1,
    by rw [← state.2.2.2.2.1, ← state.2.2.2.2.2]; exact domain.2.1⟩

/-- The hidden global keeps its persistent state identity, but an original
source expression cannot resolve to the hidden native row. This conclusion
comes from actual name lookup, including nested scalar loop shadowing. -/
theorem hidden_global_condition_unread {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} {bound slot identity position : Nat}
    {facts : ActiveFlow} {condition : Condition} {result : ConditionResult}
    {initials : ArrayBindings.Initials}
    (declarations : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity)
    (hidden : ¬OriginalLookup text context (.integer slot))
    (source : ConditionAt text context position facts condition result initials) :
    ScalarProcedures.Cell.integer slot ∉ conditionReads condition :=
  fun read => hidden (condition_source_original_lookup source
    (global_integer_original declarations selected) read)

theorem hidden_global_scalar_unread {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} {bound slot identity position maskFirst maskAfter : Nat}
    {facts : ActiveFlow} {expression : Integer.Expr} {result : ScalarExpression.Result}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    {elaborating allowSign : Bool} {mode : ScalarExpression.ArrayReadMode}
    (declarations : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity)
    (hidden : ¬OriginalLookup text context (.integer slot))
    (source : ScalarExpression.ArrayGrammar.At text (context.readingNames facts) position expression result
      maskFirst maskAfter allowSign arrays initials elaborating mode) :
    ScalarProcedures.Cell.integer slot ∉ integerReads expression :=
  fun read => hidden (scalar_original_in_flow source.source
    (global_integer_original declarations selected) read)

/-- Every original conditional outcome leaves an unread hidden global at its
declared interval. The proof includes all short-circuit intermediate guards and
the native join of paths. -/
theorem hidden_global_condition_range {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} {bound slot identity position : Nat}
    {facts : ActiveFlow} {condition : Condition} {result : ConditionResult}
    {initials : ArrayBindings.Initials} {bounds : Integer.Interval}
    (declarations : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity)
    (hidden : ¬OriginalLookup text context (.integer slot))
    (source : ConditionAt text context position facts condition result initials)
    (meaning : ConditionMeaning context facts condition result initials)
    (incoming : (context.flow facts initials).scalars slot = some bounds)
    (nonempty : bounds.isEmpty = false) :
    (context.flow result.whenTrue initials).scalars slot = some bounds ∧
      (context.flow result.whenFalse initials).scalars slot = some bounds := by
  have absent := hidden_global_condition_unread declarations selected hidden source
  constructor
  · rw [meaning.whenTrue]
    exact condition_refine_unread absent incoming nonempty
  · rw [meaning.whenFalse]
    exact condition_refine_unread absent incoming nonempty

end Silver.ApplicationPackageFrameLayout
