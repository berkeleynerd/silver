module

public import Silver.ComposeStringBoundSafety

@[expose] public section

/-! Dynamic String metadata uses canonical bounds. Actual null Strings may
retain another valid null range; that difference cannot alter concatenation
safety. This relation preserves exact bounds whenever the value is nonnull. -/

namespace Silver.StringObjectBounds

def Bounds.NullEquivalent (actual modeled : Bounds) : Prop :=
  actual.Valid ∧ modeled.Valid ∧
    ((actual.isNull = true ∧ modeled.isNull = true) ∨ actual = modeled)

theorem Bounds.NullEquivalent.refl {bounds : Bounds} (valid : bounds.Valid) :
    bounds.NullEquivalent bounds := ⟨valid, valid, Or.inr rfl⟩

theorem Bounds.NullEquivalent.symm {left right : Bounds}
    (related : left.NullEquivalent right) : right.NullEquivalent left := by
  refine ⟨related.2.1, related.1, ?_⟩
  rcases related.2.2 with null | same
  · exact Or.inl ⟨null.2, null.1⟩
  · exact Or.inr same.symm

theorem Bounds.NullEquivalent.isNull_eq {left right : Bounds}
    (related : left.NullEquivalent right) : left.isNull = right.isNull := by
  rcases related.2.2 with null | same
  · exact null.1.trans null.2.symm
  · rw [same]

theorem Bounds.NullEquivalent.length_eq {left right : Bounds}
    (related : left.NullEquivalent right) : left.length = right.length := by
  rcases related.2.2 with null | same
  · exact ((left.null_iff_length_zero).mp null.1).trans
      ((right.null_iff_length_zero).mp null.2).symm
  · rw [same]

theorem Bounds.NullEquivalent.eq_of_nonnull {left right : Bounds}
    (related : left.NullEquivalent right) (nonnull : left.isNull = false) :
    left = right := by
  rcases related.2.2 with null | same
  · simp [nonnull] at null
  · exact same

theorem Bounds.NullEquivalent.trans {left middle right : Bounds}
    (first : left.NullEquivalent middle) (second : middle.NullEquivalent right) :
    left.NullEquivalent right := by
  refine ⟨first.1, second.2.1, ?_⟩
  by_cases null : left.isNull = true
  · exact Or.inl ⟨null, (first.isNull_eq.trans second.isNull_eq).symm.trans null⟩
  · have nonnull : left.isNull = false := Bool.eq_false_iff.mpr null
    exact Or.inr ((first.eq_of_nonnull nonnull).trans
      (second.eq_of_nonnull (first.isNull_eq.symm.trans nonnull)))

theorem Bounds.NullEquivalent.canonical_zero {bounds : Bounds}
    (valid : bounds.Valid) (null : bounds.isNull = true) :
    bounds.NullEquivalent (Bounds.canonical 0) :=
  ⟨valid, by decide, Or.inl ⟨null, by decide⟩⟩

theorem Bounds.NullEquivalent.firstBound_iff {left right : Bounds}
    (related : left.NullEquivalent right) (ceiling : Int) :
    left.FirstBound ceiling ↔ right.FirstBound ceiling := by
  rcases related.2.2 with null | same
  · simp [Bounds.FirstBound, null.1, null.2]
  · rw [same]

theorem Bounds.NullEquivalent.canConcatenate_eq {left modeledLeft right modeledRight : Bounds}
    (lefts : left.NullEquivalent modeledLeft) (rights : right.NullEquivalent modeledRight) :
    left.canConcatenate right = modeledLeft.canConcatenate modeledRight := by
  by_cases null : left.isNull = true
  · have modeledNull := lefts.isNull_eq.symm.trans null
    simp [Bounds.canConcatenate, null, modeledNull]
  · have same := lefts.eq_of_nonnull (Bool.eq_false_iff.mpr null)
    simp only [Bounds.canConcatenate, same, rights.length_eq]

theorem Bounds.NullEquivalent.concatenate {left modeledLeft right modeledRight : Bounds}
    (lefts : left.NullEquivalent modeledLeft) (rights : right.NullEquivalent modeledRight)
    (checked : left.canConcatenate right = true) :
    (left.concatenate right).NullEquivalent (modeledLeft.concatenate modeledRight) := by
  by_cases null : left.isNull = true
  · have modeledNull := lefts.isNull_eq.symm.trans null
    simpa only [Bounds.concatenate_null_left _ _ null,
      Bounds.concatenate_null_left _ _ modeledNull] using rights
  · have same := lefts.eq_of_nonnull (Bool.eq_false_iff.mpr null)
    have modeledNonnull : modeledLeft.isNull = false :=
      lefts.isNull_eq.symm.trans (Bool.eq_false_iff.mpr null)
    have modeledChecked : modeledLeft.canConcatenate modeledRight = true :=
      (lefts.canConcatenate_eq rights).symm.trans checked
    refine ⟨Bounds.concatenate_valid _ _ lefts.1 rights.1 checked,
      Bounds.concatenate_valid _ _ lefts.2.1 rights.2.1 modeledChecked, Or.inr ?_⟩
    simp only [Bounds.concatenate, same, modeledNonnull, Bool.false_eq_true,
      ↓reduceIte, rights.length_eq]

theorem Value.slide_nullEquivalent (target source : Value)
    (compatible : source.bytes.length = target.bytes.length) {modeled : Bounds}
    (related : target.bounds.NullEquivalent modeled) :
    (target.slide source compatible).bounds.NullEquivalent modeled := related

end Silver.StringObjectBounds

namespace Silver.Compose
open Bindings StringObjectBounds

def GroupedExpression.boundsWith (atoms : Operand → Bounds) : GroupedExpression → Bounds
  | .atom value => atoms value
  | .concatenate left right => (left.boundsWith atoms).concatenate (right.boundsWith atoms)
  | .parenthesized inner => inner.boundsWith atoms

def GroupedExpression.BoundsSafeWith (atoms : Operand → Bounds) : GroupedExpression → Prop
  | .atom value => (atoms value).Valid
  | .concatenate left right => left.BoundsSafeWith atoms ∧ right.BoundsSafeWith atoms ∧
      (left.boundsWith atoms).canConcatenate (right.boundsWith atoms) = true
  | .parenthesized inner => inner.BoundsSafeWith atoms

theorem GroupedExpression.boundsWith_objectBounds (grouped : GroupedExpression)
    (names : BindingEnvironment) (input : Source) (integers : Integer.Store) :
    grouped.boundsWith (fun atom => atom.objectBounds names input integers) =
      grouped.objectBounds names input integers := by
  induction grouped with
  | atom => rfl
  | concatenate left right leftIH rightIH =>
      simp only [boundsWith, objectBounds, leftIH, rightIH]
  | parenthesized inner ih => exact ih

/-- Transfer every grouped concatenation check to actual atom bounds. The
source bridge supplies the atom relation; arbitrary different nonnull bounds
cannot be hidden behind the dynamic placeholder. -/
theorem GroupedExpression.transfer_objectBounds {grouped : GroupedExpression}
    {atoms : Operand → Bounds} {names : BindingEnvironment} {input : Source}
    {integers : Integer.Store}
    (related : ∀ atom ∈ grouped.flatten,
      (atoms atom).NullEquivalent (atom.objectBounds names input integers))
    (safe : grouped.BoundsSafe names input integers) :
    grouped.BoundsSafeWith atoms ∧
      (grouped.boundsWith atoms).NullEquivalent (grouped.objectBounds names input integers) := by
  induction grouped with
  | atom value =>
      have relation := related value (by simp [GroupedExpression.flatten])
      exact ⟨relation.1, relation⟩
  | concatenate left right leftIH rightIH =>
      have leftRelation := leftIH
        (fun atom member => related atom (List.mem_append_left _ member)) safe.1
      have rightRelation := rightIH
        (fun atom member => related atom (List.mem_append_right _ member)) safe.2.1
      have checked : (left.boundsWith atoms).canConcatenate (right.boundsWith atoms) = true := by
        rw [leftRelation.2.canConcatenate_eq rightRelation.2]
        exact safe.2.2
      exact ⟨⟨leftRelation.1, rightRelation.1, checked⟩,
        leftRelation.2.concatenate rightRelation.2 checked⟩
  | parenthesized inner ih => exact ih related safe

end Silver.Compose
