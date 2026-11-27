module

public import Silver.ApplicationPackageExpressionEffects
public import Silver.PackageReadMentions

@[expose] public section

/-! A semantic scalar read resolves its original declaration spelling even in
arbitrary shadowed metadata. This uses the parsed lookup itself, without assuming
that unrelated environment rows have distinct names. -/
namespace Silver.ApplicationPackageEffects
open Compose Predicate

private theorem atom_original_lookup {text : Source} {names : ScalarExpression.Environment}
    {maskFirst maskAfter position target : Nat} {allowSign : Bool} {value : ScalarExpression.Parsed}
    (source : ScalarExpression.AtomAt text names maskFirst maskAfter allowSign position value)
    (bare : (ScalarExpression.binding names target).qualifierFirst = 0)
    (firstPositive : (ScalarExpression.binding names target).first ≠ 0)
    (ordered : (ScalarExpression.binding names target).first < (ScalarExpression.binding names target).after)
    (read : .integer target ∈ Packages.integerReads value.expression) :
    ScalarExpression.lookup text names (ScalarExpression.binding names target).first
      (ScalarExpression.binding names target).after = target := by
  cases source with
  | unsigned | signed => simp [Packages.integerReads] at read
  | @name reference index _ _ _ _ referenceSource found positive _ =>
      have equal : target = index := by simpa [Packages.integerReads] using read
      subst target
      cases referenceSource with
      | bare namePositive identifier _ =>
          have bounds := Named.identifier_bounds identifier
          have spelling := equalName_symm (scalarLookupFrom_spelling found positive)
          exact (scalarLookup_retarget (Nat.ne_of_gt namePositive) bounds.2.2.1
            firstPositive ordered spelling).symm.trans found
      | qualified qualifierPositive _ _ _ _ =>
          have qualifier := scalarLookupFrom_qualifier found positive
          simp only [QualifiedNames.qualifierMatches, Nat.ne_of_gt qualifierPositive,
            ite_false, bare, Nat.lt_irrefl, decide_false, Bool.false_and, Bool.false_eq_true] at qualifier

private theorem binary_reads {left right combined : ScalarExpression.Parsed} {operator : Nat}
    (source : ScalarExpression.binary left right operator = some combined) :
    Packages.integerReads combined.expression =
      Packages.integerReads left.expression ++ Packages.integerReads right.expression := by
  unfold ScalarExpression.binary at source
  repeat' first | split at source | (cases source <;> rfl)

theorem scalar_source_original_lookup {text : Source} {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {mode : ScalarExpression.ArrayReadMode}
    {maskFirst maskAfter position target : Nat} {allowSign : Bool} {value : ScalarExpression.Parsed}
    (source : ScalarExpression.ArrayGrammar.SourceAt text names arrays maskFirst maskAfter mode allowSign position value)
    (bare : (ScalarExpression.binding names target).qualifierFirst = 0)
    (firstPositive : (ScalarExpression.binding names target).first ≠ 0)
    (ordered : (ScalarExpression.binding names target).first < (ScalarExpression.binding names target).after)
    (read : .integer target ∈ Packages.integerReads value.expression) :
    ScalarExpression.lookup text names (ScalarExpression.binding names target).first
      (ScalarExpression.binding names target).after = target := by
  induction source with
  | ordinary _ _ _ atom => exact atom_original_lookup atom bare firstPositive ordered read
  | shape | signed => simp [Packages.integerReads] at read
  | indexed _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ ih => exact ih read
  | unary _ _ _ _ _ ih =>
      simp only [ScalarExpression.unary] at read
      split at read <;> exact ih read
  | grouped _ _ _ _ ih => exact ih read
  | binary _ _ _ _ _ _ _ combination _ ihl ihr =>
      rw [binary_reads combination] at read
      exact (List.mem_append.mp read).elim ihl ihr

/-- Complete scalar syntax supplies the lookup premise of the source-effect
bridge. Only the original row's native name/kind/span facts remain for the
source-frame decoder to supply. -/
theorem scalar_read_cell_from_source {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {position limit identity slot maskFirst maskAfter : Nat}
    {expression : Integer.Expr} {result : ScalarExpression.Result}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    {elaborating allowSign : Bool} {mode : ScalarExpression.ArrayReadMode}
    (source : ScalarExpression.ArrayGrammar.At text context.scalarNames position expression result
      maskFirst maskAfter allowSign arrays initials elaborating mode)
    (finishBound : result.after ≤ limit)
    (identityPositive : 0 < identity) (active : identity ≤ info.states.length)
    (capacity : identity ≤ PackageBindings.maxStates)
    (nameValid : PackageBindings.validName (ApplicationPackageNames.metadataText text)
      (info.stateAt identity).name = true)
    (kind : (info.stateAt identity).kind = .integer)
    (slotPositive : slot ≠ 0) (slotBound : slot ≤ ArrayBindings.scalarLimit)
    (bare : (ScalarExpression.binding context.scalarNames slot).qualifierFirst = 0)
    (firstSpan : (ScalarExpression.binding context.scalarNames slot).first =
      (info.stateAt identity).name.first)
    (afterSpan : (ScalarExpression.binding context.scalarNames slot).after =
      (info.stateAt identity).name.after)
    (read : .integer slot ∈ Packages.integerReads expression) :
    (info.stateAt identity).cell identity ∈
      info.effectCells (stateReads modelCalls text context info position limit) := by
  have domain := (ApplicationPackageNames.Native.validName_domain nameValid).2
  have found := scalar_source_original_lookup source.source bare
    (by rw [firstSpan]; exact Nat.ne_of_gt domain.1) (by rw [firstSpan, afterSpan]; exact domain.2.1) read
  rw [firstSpan, afterSpan] at found
  exact scalar_read_cell source finishBound identityPositive active capacity nameValid kind
    found slotPositive slotBound firstSpan afterSpan (Packages.integerReads_integer expression slot read)

end Silver.ApplicationPackageEffects
