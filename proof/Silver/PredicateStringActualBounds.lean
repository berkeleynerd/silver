module

public import Silver.PredicateStringBoundsAssurance
public import Silver.ComposeStringBoundEquivalence

@[expose] public section

namespace Silver.Compose
open Bindings StringObjectBounds

abbrev BoundsStore := Nat → Bounds

def namedModelBounds (info : BindingInfo) (input : Source) : Bounds :=
  if info.dynamic then Bounds.canonical input.length else info.objectBounds

def BoundsStore.Compatible (bounds : BoundsStore) (names : BindingEnvironment) (input : Source) : Prop :=
  ∀ index info, names.get index = some info → (bounds index).NullEquivalent (namedModelBounds info input)

def Operand.actualBounds (bounds : BoundsStore) (input : Source)
    (integers : Integer.Store) : Operand → Bounds
  | .reference index | .replace index _ _ _ => bounds index
  | other => other.objectBounds [] input integers

theorem Operand.actualBounds_equivalent {bounds : BoundsStore} {names : BindingEnvironment}
    {input : Source} {integers : Integer.Store} {atom : Operand}
    (compatible : bounds.Compatible names input) (origin : atom.BoundsOrigin names)
    (valid : (atom.objectBounds names input integers).Valid) :
    (atom.actualBounds bounds input integers).NullEquivalent (atom.objectBounds names input integers) := by
  cases atom with
  | reference index =>
      obtain ⟨info, selected, _⟩ := origin
      simpa only [actualBounds, objectBounds, selected, Option.getD_some, namedModelBounds] using compatible index info selected
  | replace index base indexExpression replacement =>
      obtain ⟨⟨info, selected, _⟩, _⟩ := origin
      simpa only [actualBounds, objectBounds, selected, Option.getD_some, namedModelBounds] using compatible index info selected
  | literal | argument | image | character | slice => exact Bounds.NullEquivalent.refl valid

def Expression.ActualBoundsSafe (expression : Expression) (bounds : BoundsStore)
    (_names : BindingEnvironment) (values : Values) (input : Source) (integers : Integer.Store) : Prop :=
  ∀ grouped : GroupedExpression, grouped.flatten = expression →
    grouped.BoundsSafeWith (fun atom => atom.actualBounds bounds input integers) ∧
      (grouped.boundsWith (fun atom => atom.actualBounds bounds input integers)).Valid ∧
      (grouped.boundsWith (fun atom => atom.actualBounds bounds input integers)).length =
        (expression.evaluate values input integers).length

theorem GroupedExpression.atom_valid_of_boundsSafe {grouped : GroupedExpression}
    {names : BindingEnvironment} {input : Source} {integers : Integer.Store}
    (safe : grouped.BoundsSafe names input integers) :
    ∀ atom ∈ grouped.flatten, (atom.objectBounds names input integers).Valid := by
  induction grouped with
  | atom atom => intro other member; have same := List.mem_singleton.mp member; subst other; exact safe
  | parenthesized inner ih => exact ih safe
  | concatenate left right leftIH rightIH =>
      intro atom member
      rcases List.mem_append.mp member with first | rest
      · exact leftIH safe.1 atom first
      · exact rightIH safe.2.1 atom rest

theorem Expression.actualBoundsSafe {expression : Expression} {bounds : BoundsStore}
    {names : BindingEnvironment} {values : Values} {input : Source} {integers : Integer.Store}
    (compatible : bounds.Compatible names input) (origin : expression.BoundsOrigin names)
    (safe : expression.ObjectBoundsSafe names values input integers) :
    expression.ActualBoundsSafe bounds names values input integers := by
  intro grouped ordered
  have modeled := safe grouped ordered
  have atoms : ∀ atom ∈ grouped.flatten,
      (atom.actualBounds bounds input integers).NullEquivalent (atom.objectBounds names input integers) := by
    intro atom member
    have singleton : (atom.objectBounds names input integers).Valid := by
      exact GroupedExpression.atom_valid_of_boundsSafe modeled.1 atom member
    exact Operand.actualBounds_equivalent compatible (origin atom (ordered ▸ member)) singleton
  have transferred := GroupedExpression.transfer_objectBounds atoms modeled.1
  exact ⟨transferred.1, transferred.2.1, transferred.2.length_eq.trans modeled.2.2⟩

/-- A frozen initializer with zero fixed contribution has only null fixed
operands and canonical dynamic operands. Its nonnull result therefore starts at1. -/
theorem Operand.argument_first {names : BindingEnvironment} {atom : Operand}
    (known : atom.infer names.shape = some .argument) (input : Source) (integers : Integer.Store) :
    (atom.objectBounds names input integers).first = 1 := by
  cases atom with
  | argument => rfl
  | literal | image => cases known
  | reference index =>
      simp only [Value.infer, BindingEnvironment.shape, Option.map_eq_some_iff] at known
      obtain ⟨cell, cells, bound⟩ := known
      obtain ⟨info, selected, rfl⟩ := cells
      cases dynamic : info.dynamic with
      | false => simp [BindingInfo.cell, BindingInfo.bound, dynamic] at bound
      | true => simp [Operand.objectBounds, selected, dynamic, Bounds.canonical]
  | slice | replace | character =>
      simp only [Value.infer, Option.bind_eq_some_iff] at known
      obtain ⟨range, _, result⟩ := known
      split at result <;> cases result

theorem Operand.zero_static_first {names : BindingEnvironment} {atom : Operand}
    {values : Values} {input : Source}
    (strings : Fits names.shape input values) (readable : ∃ bound, atom.infer names.shape = some bound)
    (zero : atom.staticLength names.shape = 0)
    (length : (atom.objectBounds names input Integer.emptyStore).length = (atom.evaluate values input).length) :
    (atom.objectBounds names input Integer.emptyStore).isNull = true ∨
      (atom.objectBounds names input Integer.emptyStore).first = 1 := by
  obtain ⟨bound, known⟩ := readable
  cases bound with
  | argument => exact Or.inr (Operand.argument_first known _ _)
  | fixed amount =>
      have amountZero : amount = 0 := by simpa [Operand.staticLength, Operand.bound, known, Bound.staticPart] using zero
      have bytes := value_length strings known
      apply Or.inl
      apply (Bounds.null_iff_length_zero _).mpr
      rw [length, bytes, amountZero]
      rfl

theorem GroupedExpression.first_one_or_null {grouped : GroupedExpression}
    {names : BindingEnvironment} {input : Source} {integers : Integer.Store}
    (atoms : ∀ atom ∈ grouped.flatten, (atom.objectBounds names input integers).isNull = true ∨
      (atom.objectBounds names input integers).first = 1) :
    (grouped.objectBounds names input integers).isNull = true ∨
      (grouped.objectBounds names input integers).first = 1 := by
  induction grouped with
  | atom atom => exact atoms atom (by simp [GroupedExpression.flatten])
  | parenthesized inner ih => exact ih atoms
  | concatenate left right leftIH rightIH =>
      have first := leftIH (fun atom member => atoms atom (List.mem_append_left _ member))
      have second := rightIH (fun atom member => atoms atom (List.mem_append_right _ member))
      by_cases empty : (left.objectBounds names input integers).isNull = true
      · simpa only [GroupedExpression.objectBounds, Bounds.concatenate_null_left _ _ empty] using second
      · apply Or.inr
        rw [GroupedExpression.objectBounds, Bounds.concatenate_first _ _ (Bool.eq_false_iff.mpr empty)]
        exact first.resolve_left empty


theorem Expression.exists_grouped {expression : Expression} (nonempty : expression ≠ []) :
    ∃ grouped : GroupedExpression, grouped.flatten = expression := by
  induction expression with
  | nil => contradiction
  | cons atom rest ih =>
      cases rest with
      | nil => exact ⟨.atom atom, rfl⟩
      | cons next tail =>
          obtain ⟨grouped, ordered⟩ := ih (by simp)
          exact ⟨.concatenate (.atom atom) grouped, by simp [GroupedExpression.flatten, ordered]⟩

theorem Expression.zero_static_atom {expression : Expression} {shape : Shape}
    (zero : expression.staticLength shape = 0) : ∀ atom ∈ expression, atom.staticLength shape = 0 := by
  induction expression with
  | nil => simp
  | cons first rest ih =>
      simp only [Expression.staticLength] at zero
      intro atom member
      rcases List.mem_cons.mp member with rfl | member
      · omega
      · exact ih (by omega) atom member

theorem Expression.member_length_le {expression : Expression} {atom : Operand}
    (values : Values) (input : Source) (integers : Integer.Store) (member : atom ∈ expression) :
    (atom.evaluate values input integers).length ≤ (expression.evaluate values input integers).length := by
  induction expression with
  | nil => cases member
  | cons first rest ih =>
      simp only [Expression.evaluate, List.length_append]
      rcases List.mem_cons.mp member with rfl | member
      · omega
      · exact Nat.le_trans (ih member) (Nat.le_add_left _ _)

theorem Expression.zero_static_bounds_equivalent {expression : Expression} {names : BindingEnvironment}
    {input : Source} {values : Values}
    (metadata : NamesBoundsValid names) (strings : Fits names.shape input values)
    (origin : expression.BoundsOrigin names) (readable : expression.Readable names.shape)
    (safe : expression.RuntimeSafe values input Integer.emptyStore)
    (zero : expression.staticLength names.shape = 0)
    (length : (expression.evaluate values input).length = input.length)
    (boundsSafe : expression.ObjectBoundsSafe names values input Integer.emptyStore) :
    (expression.objectBounds names input Integer.emptyStore).NullEquivalent (Bounds.canonical input.length) := by
  by_cases empty : expression = []
  · subst expression
    have inputEmpty : input.length = 0 := by simpa [Expression.evaluate] using length.symm
    simp only [Expression.objectBounds, Expression.foldBounds, List.foldl_nil, inputEmpty]
    exact Bounds.NullEquivalent.refl (by decide)
  · obtain ⟨grouped, ordered⟩ := Expression.exists_grouped empty
    have groupSafe := boundsSafe grouped ordered
    have first : (grouped.objectBounds names input Integer.emptyStore).isNull = true ∨
        (grouped.objectBounds names input Integer.emptyStore).first = 1 := by
      apply GroupedExpression.first_one_or_null
      intro atom member
      have present : atom ∈ expression := ordered ▸ member
      have atomBounds := Operand.runtime_objectBounds metadata strings (origin atom present) (safe.1 atom present)
        (Nat.le_trans (Expression.member_length_le values input Integer.emptyStore present) safe.2)
      exact Operand.zero_static_first strings (readable atom present)
        (Expression.zero_static_atom zero atom present) atomBounds.2.2
    have groupLength := groupSafe.2.2.trans length
    have canonicalValid := canonical_bounds_valid (length ▸ safe.2)
    have related : (grouped.objectBounds names input Integer.emptyStore).NullEquivalent
        (Bounds.canonical input.length) := by
      refine ⟨groupSafe.2.1, canonicalValid, ?_⟩
      by_cases null : (grouped.objectBounds names input Integer.emptyStore).isNull = true
      · apply Or.inl
        refine ⟨null, ?_⟩
        apply (Bounds.null_iff_length_zero _).mpr
        rw [Bounds.canonical_length, ← groupLength]
        exact (Bounds.null_iff_length_zero _).mp null
      · apply Or.inr
        have firstEq := first.resolve_left null
        have lastEq := Bounds.nonnull_length (grouped.objectBounds names input Integer.emptyStore)
          (Bool.eq_false_iff.mpr null)
        rw [groupLength, firstEq] at lastEq
        cases actualEq : grouped.objectBounds names input Integer.emptyStore with
        | mk lower upper =>
            simp only [actualEq] at firstEq lastEq
            simp only [Bounds.canonical]
            congr 1 <;> omega
    simpa only [← GroupedExpression.flatten_objectBounds, ordered] using related

def Expression.actualBounds (expression : Expression) (bounds : BoundsStore) (input : Source)
    (integers : Integer.Store := Integer.emptyStore) : Bounds :=
  expression.foldl (fun prior atom => prior.concatenate (atom.actualBounds bounds input integers)) (.canonical 0)

theorem GroupedExpression.fold_actualBounds (grouped : GroupedExpression) (bounds : BoundsStore)
    (input : Source) (integers : Integer.Store) (initial : Bounds) :
    grouped.flatten.foldl (fun prior atom => prior.concatenate (atom.actualBounds bounds input integers)) initial =
      initial.concatenate (grouped.boundsWith (fun atom => atom.actualBounds bounds input integers)) := by
  induction grouped generalizing initial with
  | atom => rfl
  | parenthesized inner ih => exact ih initial
  | concatenate left right leftIH rightIH =>
      simp only [GroupedExpression.flatten, List.foldl_append]
      rw [leftIH, rightIH]
      exact Bounds.concatenate_assoc _ _ _

theorem GroupedExpression.flatten_actualBounds (grouped : GroupedExpression) (bounds : BoundsStore)
    (input : Source) (integers : Integer.Store) :
    grouped.flatten.actualBounds bounds input integers =
      grouped.boundsWith (fun atom => atom.actualBounds bounds input integers) := by
  rw [Expression.actualBounds, GroupedExpression.fold_actualBounds]
  exact Bounds.concatenate_null_left _ _ (by decide)

theorem Expression.actualBounds_equivalent {expression : Expression} {bounds : BoundsStore}
    {names : BindingEnvironment} {values : Values} {input : Source} {integers : Integer.Store}
    (compatible : bounds.Compatible names input) (origin : expression.BoundsOrigin names)
    (safe : expression.ObjectBoundsSafe names values input integers) :
    (expression.actualBounds bounds input integers).NullEquivalent (expression.objectBounds names input integers) := by
  by_cases empty : expression = []
  · subst expression
    change (Bounds.canonical 0).NullEquivalent (Bounds.canonical 0)
    exact Bounds.NullEquivalent.refl (by decide)
  · obtain ⟨grouped, ordered⟩ := Expression.exists_grouped empty
    have modeled := safe grouped ordered
    have transferred := GroupedExpression.transfer_objectBounds
      (fun atom member => Operand.actualBounds_equivalent compatible (origin atom (ordered ▸ member))
        (GroupedExpression.atom_valid_of_boundsSafe modeled.1 atom member)) modeled.1
    simpa only [← GroupedExpression.flatten_actualBounds, ← GroupedExpression.flatten_objectBounds, ordered] using transferred.2

end Silver.Compose

namespace Silver.Bindings
open Compose StringObjectBounds

def Declaration.executeBounds (declaration : Declaration) (bounds : BoundsStore) (input : Source) : BoundsStore :=
  Bindings.put bounds declaration.index (declaration.initializer.actualBounds bounds input)

end Silver.Bindings

namespace Silver.Compose
open Bindings StringObjectBounds

def executeDeclarationsBounds (input : Source) : List Declaration → BoundsStore → BoundsStore
  | [], bounds => bounds
  | declaration :: rest, bounds => executeDeclarationsBounds input rest (declaration.executeBounds bounds input)

end Silver.Compose
