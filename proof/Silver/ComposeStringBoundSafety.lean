module

public import Silver.ComposeStringBounds

@[expose] public section

namespace Silver.Compose

variable {contextFirst : Nat}
open Bindings StringObjectBounds

def SourceAtoms (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (expression : Expression) (contextFirst : Nat := 1) : Prop :=
  ∀ atom ∈ expression, ∃ position result, ValueAt (contextFirst := contextFirst) (scalarNames := scalarNames)
    (integerHidden := integerHidden) (arrays := arrays) (initials := initials)
    (elaborating := elaborating) text names position atom result

theorem emission_sourceAtoms {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression}
    (parsed : EmissionAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression) :
    SourceAtoms (contextFirst := contextFirst) text names scalarNames integerHidden arrays initials elaborating expression := by
  unfold EmissionAt at parsed
  split at parsed
  · obtain ⟨atom, source, rfl⟩ := parsed
    intro item member
    have same := List.mem_singleton.mp member
    subst item
    exact ⟨_, _, source⟩
  · subst expression
    intro atom member
    cases member

theorem expressionTail_sourceAtoms {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) :
    SourceAtoms (contextFirst := contextFirst) text names scalarNames integerHidden arrays initials elaborating expression := by
  induction parsed with
  | done => intro atom member; cases member
  | last _ _ _ _ emitted => exact emission_sourceAtoms emitted
  | next _ _ _ _ _ emitted _ ih =>
      intro atom member
      rcases List.mem_append.mp member with first | rest
      · exact emission_sourceAtoms emitted atom first
      · exact ih atom rest

def GroupedExpression.objectBounds (names : BindingEnvironment) (input : Source)
    (integers : Integer.Store) : GroupedExpression → Bounds
  | .atom value => value.objectBounds names input integers
  | .concatenate left right => (left.objectBounds names input integers).concatenate (right.objectBounds names input integers)
  | .parenthesized inner => inner.objectBounds names input integers

def GroupedExpression.BoundsSafe (names : BindingEnvironment) (input : Source)
    (integers : Integer.Store) : GroupedExpression → Prop
  | .atom value => (value.objectBounds names input integers).Valid
  | .concatenate left right => left.BoundsSafe names input integers ∧ right.BoundsSafe names input integers ∧
      (left.objectBounds names input integers).canConcatenate (right.objectBounds names input integers) = true
  | .parenthesized inner => inner.BoundsSafe names input integers

theorem GroupedExpression.foldBounds (grouped : GroupedExpression) (names : BindingEnvironment)
    (input : Source) (integers : Integer.Store) (initial : Bounds) :
    grouped.flatten.foldBounds names input integers initial = initial.concatenate (grouped.objectBounds names input integers) := by
  induction grouped generalizing initial with
  | atom => rfl
  | concatenate left right leftIH rightIH =>
      simp only [flatten, Expression.foldBounds, List.foldl_append]
      change right.flatten.foldBounds names input integers
        (left.flatten.foldBounds names input integers initial) = _
      rw [leftIH, rightIH]
      exact Bounds.concatenate_assoc _ _ _
  | parenthesized inner ih => exact ih initial

theorem GroupedExpression.flatten_objectBounds (grouped : GroupedExpression) (names : BindingEnvironment)
    (input : Source) (integers : Integer.Store) :
    grouped.flatten.objectBounds names input integers = grouped.objectBounds names input integers := by
  rw [Expression.objectBounds, GroupedExpression.foldBounds]
  exact Bounds.concatenate_null_left _ _ (by decide)

theorem namesBoundCeiling_upper {names : BindingEnvironment} (bounded : names.length ≤ maxBindings) :
    namesBoundCeiling names + maxSourceLength - 1 ≤ Integer.maxValue := by
  simp only [namesBoundCeiling, maxBindings, maxSourceLength, Integer.maxValue] at *
  omega

theorem namesBoundCeiling_next (names : BindingEnvironment) :
    namesBoundCeiling names + maxSourceLength - 1 ≤ ((names.length : Int) + 1) * maxSourceLength := by
  simp only [namesBoundCeiling, maxSourceLength]
  omega

theorem grouped_source_bounds {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {grouped : GroupedExpression} {input : Source} {values : Values} {integers : Integer.Store}
    (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (namesBound : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
    (strings : Fits names.shape input values)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) integers)
    (sources : SourceAtoms (contextFirst := contextFirst) text names scalarNames integerHidden arrays initials elaborating grouped.flatten)
    (bounded : (grouped.evaluate values input integers).length ≤ maxSourceLength) :
    (grouped.objectBounds names input integers).Valid ∧
      (grouped.objectBounds names input integers).FirstBound (namesBoundCeiling names) ∧
      (grouped.objectBounds names input integers).length = (grouped.evaluate values input integers).length ∧
      grouped.BoundsSafe names input integers := by
  induction grouped with
  | atom atom =>
      obtain ⟨position, result, parsed⟩ := sources atom (by simp [GroupedExpression.flatten])
      have valid := value_objectBounds_valid textBound inputBound metadata scalars parsed
      exact ⟨valid, value_objectBounds_firstBound input metadata scalars parsed,
        value_objectBounds_length metadata.normal strings scalars parsed, valid⟩
  | concatenate left right leftIH rightIH =>
      have total := bounded
      simp only [GroupedExpression.evaluate, List.length_append] at total
      have a := leftIH (fun atom member => sources atom (List.mem_append_left _ member)) (by omega)
      have b := rightIH (fun atom member => sources atom (List.mem_append_right _ member)) (by omega)
      have checked : (left.objectBounds names input integers).canConcatenate (right.objectBounds names input integers) = true := by
        by_cases null : (left.objectBounds names input integers).isNull = true
        · simp [Bounds.canConcatenate, null]
        · have nonnull : (left.objectBounds names input integers).isNull = false := Bool.eq_false_iff.mpr null
          have exact := Bounds.nonnull_length (left.objectBounds names input integers) nonnull
          have first := a.2.1
          rcases first with empty | first
          · exact False.elim (null empty)
          · have ceiling := namesBoundCeiling_upper namesBound
            have leftLength := a.2.2.1
            have rightLength := b.2.2.1
            simp only [Bounds.canConcatenate, nonnull, Bool.false_or, decide_eq_true_eq]
            omega
      refine ⟨Bounds.concatenate_valid _ _ a.1 b.1 checked,
        Bounds.concatenate_firstBound _ _ _ a.2.1 b.2.1, ?_, a.2.2.2, b.2.2.2, checked⟩
      simp only [GroupedExpression.objectBounds, Bounds.concatenate_length, a.2.2.1, b.2.2.1,
        GroupedExpression.evaluate, List.length_append]
  | parenthesized inner ih => exact ih sources bounded

theorem expressionAt_grouped_objectBounds {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position capacity : Nat} {expression : Expression} {result : ExpressionResult}
    {grouped : GroupedExpression} {input : Source} {values : Values} {integers : Integer.Store}
    (textBound : text.length ≤ maxSourceLength) (inputMax : input.length ≤ maxSourceLength)
    (namesBound : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
    (parsed : ExpressionAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position expression result)
    (fitsResult : fits result capacity = true) (strings : Fits names.shape input values)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) integers)
    (inputBound : input.length ≤ capacity) (ordered : grouped.flatten = expression) :
    grouped.BoundsSafe names input integers ∧
      (expression.objectBounds names input integers).Valid ∧
      (expression.objectBounds names input integers).length = (expression.evaluate values input integers).length ∧
      (expression.objectBounds names input integers).FirstBound (namesBoundCeiling names) ∧
      ((expression.objectBounds names input integers).isNull = false →
        (expression.objectBounds names input integers).last ≤ ((names.length : Int) + 1) * maxSourceLength) := by
  have length := (expressionAt_grouped_semantics metadata.normal parsed fitsResult strings scalars inputBound ordered (.self grouped)).2
  have sources := expressionTail_sourceAtoms parsed
  rw [← ordered] at sources
  have result := grouped_source_bounds textBound inputMax namesBound metadata strings scalars sources length
  have same := GroupedExpression.flatten_objectBounds grouped names input integers
  rw [ordered] at same
  refine ⟨result.2.2.2, same.symm ▸ result.1, ?_, same.symm ▸ result.2.1, ?_⟩
  · rw [same, result.2.2.1, ← GroupedExpression.flatten_evaluate grouped values input integers, ordered]
  · intro nonnull
    rw [same] at nonnull ⊢
    exact Int.le_trans (Bounds.upper_from_first_and_length _ _ _ result.2.1
      (by rw [result.2.2.1]; exact length) nonnull) (namesBoundCeiling_next names)

end Silver.Compose
