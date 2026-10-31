module

public import Silver.ComposeStringOrigins

@[expose] public section

namespace Silver.Compose
open Bindings StringObjectBounds

/-- The arithmetic conclusion supplied by an endpoint check. A covered whole
length also covers any shorter grouped intermediate. -/
def EndpointBound (ceiling : Int) (length : Nat) : Prop :=
  ∀ first : Int, 1 ≤ first → first ≤ ceiling →
    first + (length : Int) - 1 ≤ Integer.maxValue

theorem EndpointBound.mono {ceiling : Int} {small large : Nat}
    (bound : EndpointBound ceiling large) (within : small ≤ large) : EndpointBound ceiling small := by
  intro first positive bounded
  have upper := bound first positive bounded
  omega

private theorem named_objectBounds {names : BindingEnvironment} {index : Nat} {info : BindingInfo}
    {values : Values} {input : Source} (metadata : NamesBoundsValid names)
    (strings : Fits names.shape input values) (selected : names.get index = some info)
    (bounded : (values index).length ≤ maxSourceLength) :
    let bounds := if info.dynamic then Bounds.canonical input.length else info.objectBounds
    bounds.Valid ∧ bounds.FirstBound (namesBoundCeiling names) ∧ bounds.length = (values index).length := by
  have fit := (strings index info.cell (by simp [BindingEnvironment.shape, selected])).1
  cases dynamic : info.dynamic with
  | true =>
      have length : (values index).length = input.length := by
        simpa [BindingInfo.cell, BindingInfo.bound, dynamic, Bound.length] using fit
      exact ⟨canonical_bounds_valid (by omega), Or.inr (namesBoundCeiling_positive names),
        (Bounds.canonical_length _).trans length.symm⟩
  | false =>
      have length : (values index).length = info.staticLength := by
        simpa [BindingInfo.cell, BindingInfo.bound, dynamic, Bound.length] using fit
      have indices := selected_binding_bounds selected
      have first := BindingInfo.boundsValid_firstBound (metadata _ _ selected) dynamic indices.2 (by omega)
      refine ⟨BindingInfo.boundsValid_valid (metadata _ _ selected) dynamic, ?_,
        (BindingInfo.boundsValid_length (metadata _ _ selected) dynamic).trans length.symm⟩
      rcases first with null | first
      · exact Or.inl null
      · exact Or.inr (by change info.objectBounds.first ≤ namesBoundCeiling names; unfold namesBoundCeiling; omega)

theorem Operand.runtime_objectBounds {names : BindingEnvironment} {atom : Operand}
    {values : Values} {input : Source} {integers : Integer.Store}
    (metadata : NamesBoundsValid names) (strings : Fits names.shape input values)
    (origin : atom.BoundsOrigin names) (safe : atom.ImagesSafe integers values)
    (bounded : (atom.evaluate values input integers).length ≤ maxSourceLength) :
    (atom.objectBounds names input integers).Valid ∧
      (atom.objectBounds names input integers).FirstBound (namesBoundCeiling names) ∧
      (atom.objectBounds names input integers).length = (atom.evaluate values input integers).length := by
  cases atom with
  | literal bytes | argument | image scalar =>
      exact ⟨canonical_bounds_valid bounded, Or.inr (namesBoundCeiling_positive names), Bounds.canonical_length _⟩
  | character expression =>
      exact ⟨canonical_bounds_valid (by decide), Or.inr (namesBoundCeiling_positive names), rfl⟩
  | reference index =>
      obtain ⟨info, selected, _⟩ := origin
      simpa [objectBounds, selected, Value.evaluate] using named_objectBounds metadata strings selected bounded
  | replace target base index replacement =>
      obtain ⟨⟨info, selected, fixed, _, _⟩, _⟩ := origin
      have length : ((Value.replace target base index replacement).evaluate values input integers).length =
          (values target).length := by simp [Value.evaluate]
      rw [length] at bounded
      simpa [objectBounds, selected, Value.evaluate] using named_objectBounds metadata strings selected bounded
  | slice target base lower upper =>
      obtain ⟨info, selected, fixed, typed, rfl⟩ := origin
      have fit := (strings target info.cell (by simp [BindingEnvironment.shape, selected])).1
      have length : (values target).length = info.staticLength := by
        simpa [BindingInfo.cell, BindingInfo.bound, fixed, Bound.length] using fit
      have validSlice := safe.2.2
      have exactLength := StringIndexing.slice_length (values target) validSlice
      refine ⟨⟨Integer.Expr.safe_value safe.1, Integer.Expr.safe_value safe.2.1, ?_⟩, ?_, ?_⟩
      · by_cases null : upper.evaluate integers < lower.evaluate integers
        · exact Or.inl null
        · have inside := validSlice.resolve_left null
          have nonempty : info.staticLength ≠ 0 := by rw [length] at inside; omega
          have positive := (fixedBoundsValid_nonempty
            (by simpa [fixed, typed] using (metadata _ _ selected).2.2) nonempty).1
          exact Or.inr (by change 1 ≤ lower.evaluate integers; omega)
      · by_cases null : upper.evaluate integers < lower.evaluate integers
        · exact Or.inl (by change decide (upper.evaluate integers < lower.evaluate integers) = true; exact decide_eq_true null)
        · have inside := validSlice.resolve_left null
          have nonempty : info.staticLength ≠ 0 := by rw [length] at inside; omega
          have fields := fixedBoundsValid_nonempty
            (by simpa [fixed, typed] using (metadata _ _ selected).2.2) nonempty
          have actualLength := BindingInfo.boundsValid_length (metadata _ _ selected) fixed
          have indices := selected_binding_bounds selected
          apply Or.inr
          change lower.evaluate integers ≤ namesBoundCeiling names
          simp only [BindingInfo.objectBounds, Bounds.length] at actualLength
          rw [length] at inside
          simp only [namesBoundCeiling, maxSourceLength] at *
          omega
      · exact exactLength.symm

theorem grouped_runtime_bounds {names : BindingEnvironment} {grouped : GroupedExpression}
    {values : Values} {input : Source} {integers : Integer.Store} {ceiling : Int}
    (metadata : NamesBoundsValid names) (strings : Fits names.shape input values)
    (origins : grouped.flatten.BoundsOrigin names)
    (safe : grouped.flatten.RuntimeSafe values input integers)
    (firstCeiling : namesBoundCeiling names ≤ ceiling)
    (endpoint : EndpointBound ceiling (grouped.evaluate values input integers).length) :
    grouped.BoundsSafe names input integers ∧
      (grouped.objectBounds names input integers).Valid ∧
      (grouped.objectBounds names input integers).length = (grouped.evaluate values input integers).length ∧
      (grouped.objectBounds names input integers).FirstBound ceiling := by
  induction grouped with
  | atom atom =>
      have bounded : (atom.evaluate values input integers).length ≤ maxSourceLength := by
        simpa [GroupedExpression.flatten, Expression.evaluate] using safe.2
      have facts := atom.runtime_objectBounds metadata strings (origins atom (by simp [GroupedExpression.flatten]))
        (safe.1 atom (by simp [GroupedExpression.flatten])) bounded
      refine ⟨facts.1, facts.1, facts.2.2, ?_⟩
      rcases facts.2.1 with null | first
      · exact Or.inl null
      · exact Or.inr (Int.le_trans first firstCeiling)
  | concatenate left right leftIH rightIH =>
      have total : (left.evaluate values input integers).length + (right.evaluate values input integers).length ≤ maxSourceLength := by
        simpa [← GroupedExpression.flatten_evaluate, GroupedExpression.flatten, Expression.evaluate_append,
          List.length_append] using safe.2
      have leftSafe : left.flatten.RuntimeSafe values input integers :=
        ⟨fun atom member => safe.1 atom (List.mem_append_left _ member), by
          rw [GroupedExpression.flatten_evaluate left values input integers]; omega⟩
      have rightSafe : right.flatten.RuntimeSafe values input integers :=
        ⟨fun atom member => safe.1 atom (List.mem_append_right _ member), by
          rw [GroupedExpression.flatten_evaluate right values input integers]; omega⟩
      have a := leftIH (fun atom member => origins atom (List.mem_append_left _ member)) leftSafe
        (endpoint.mono (by simp [GroupedExpression.evaluate]))
      have b := rightIH (fun atom member => origins atom (List.mem_append_right _ member)) rightSafe
        (endpoint.mono (by simp [GroupedExpression.evaluate]))
      have checked : (left.objectBounds names input integers).canConcatenate (right.objectBounds names input integers) = true := by
        by_cases null : (left.objectBounds names input integers).isNull = true
        · simp [Bounds.canConcatenate, null]
        · have nonnull := Bool.eq_false_iff.mpr null
          have length := Bounds.nonnull_length (left.objectBounds names input integers) nonnull
          have first : (left.objectBounds names input integers).first ≤ ceiling := a.2.2.2.resolve_left null
          have positive : 1 ≤ (left.objectBounds names input integers).first := by
            have ordered : ¬ (left.objectBounds names input integers).last < (left.objectBounds names input integers).first := by
              simpa [Bounds.isNull] using null
            exact a.2.1.2.2.resolve_left ordered
          have bound := endpoint _ positive first
          simp only [GroupedExpression.evaluate, List.length_append] at bound
          simp only [Bounds.canConcatenate, nonnull, Bool.false_or, decide_eq_true_eq]
          omega
      refine ⟨⟨a.1, b.1, checked⟩, Bounds.concatenate_valid _ _ a.2.1 b.2.1 checked, ?_,
        Bounds.concatenate_firstBound _ _ _ a.2.2.2 b.2.2.2⟩
      simp only [GroupedExpression.objectBounds, Bounds.concatenate_length, a.2.2.1, b.2.2.1,
        GroupedExpression.evaluate, List.length_append]
  | parenthesized inner ih => exact ih origins safe endpoint

/-- Every parenthesization of the same source operand order is covered. -/
def Expression.ObjectBoundsSafe (expression : Expression) (names : BindingEnvironment)
    (values : Values) (input : Source) (integers : Integer.Store) : Prop :=
  ∀ grouped : GroupedExpression, grouped.flatten = expression →
    grouped.BoundsSafe names input integers ∧ (grouped.objectBounds names input integers).Valid ∧
      (grouped.objectBounds names input integers).length = (expression.evaluate values input integers).length

theorem Expression.objectBoundsSafe_of_endpoint {expression : Expression} {names : BindingEnvironment}
    {values : Values} {input : Source} {integers : Integer.Store} {ceiling : Int}
    (metadata : NamesBoundsValid names) (strings : Fits names.shape input values)
    (origins : expression.BoundsOrigin names) (safe : expression.RuntimeSafe values input integers)
    (firstCeiling : namesBoundCeiling names ≤ ceiling)
    (endpoint : EndpointBound ceiling (expression.evaluate values input integers).length) :
    expression.ObjectBoundsSafe names values input integers := by
  intro grouped ordered
  have evaluation : grouped.evaluate values input integers = expression.evaluate values input integers := by
    rw [← GroupedExpression.flatten_evaluate grouped values input integers, ordered]
  have checked := grouped_runtime_bounds metadata strings (ordered ▸ origins) (ordered ▸ safe)
    firstCeiling (evaluation ▸ endpoint)
  exact ⟨checked.1, checked.2.1, checked.2.2.1.trans (congrArg List.length evaluation)⟩

end Silver.Compose
