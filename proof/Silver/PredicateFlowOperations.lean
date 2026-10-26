module

public import Silver.PredicateFlowStorage

@[expose] public section

namespace Silver.PathFacts

theorem Region.join_comm (left right : Region) : left.join right = right.join left := by
  cases left <;> cases right <;> simp [Region.join, Interval.hull, Nat.min_comm, Nat.max_comm]

theorem Context.join_comm (left right : Context) : left.join right = right.join left := by
  simp only [Context.join, Region.join_comm left.validLengths right.validLengths,
    Bool.or_comm, Bool.and_comm]

end Silver.PathFacts

namespace Silver.Predicate.ActiveFlow

@[simp] theorem model_path (flow : ActiveFlow) : flow.model.path = flow.path := rfl

@[simp] theorem replace_path (flow : ActiveFlow) (index : Nat) (bounds : Integer.Interval) :
    (flow.replace index bounds).path = flow.path := by
  unfold replace
  split <;> rfl

@[simp] theorem refine_path (flow : ActiveFlow) (index : Nat) (operator : Integer.Comparison)
    (threshold : Int) (truth : Bool) :
    (flow.refine index operator threshold truth).path = flow.path := by
  unfold refine
  split
  · rfl
  · exact replace_path ..

theorem ranges_present {values : List Integer.Interval} {index : Nat} {bounds : Integer.Interval}
    (present : ranges values index = some bounds) : 0 < index ∧ index ≤ values.length := by
  by_cases zero : index = 0
  · simp only [ranges, zero, ↓reduceIte] at present
    contradiction
  · simp only [ranges, zero, ↓reduceIte] at present
    obtain ⟨within, _⟩ := List.getElem?_eq_some_iff.mp present
    omega

@[simp] theorem replace_count (flow : ActiveFlow) (index : Nat) (bounds : Integer.Interval) :
    (flow.replace index bounds).count = flow.count := by
  unfold replace
  split
  · rfl
  · simp [count]

theorem replace_model (flow : ActiveFlow) (index : Nat) (bounds : Integer.Interval)
    (positive : 0 < index) (bounded : index ≤ flow.count) :
    (flow.replace index bounds).model =
      ⟨flow.path, Integer.put flow.model.scalars index (some bounds)⟩ := by
  simp only [replace, show index ≠ 0 by omega, ↓reduceIte, model]
  congr 1
  funext other
  by_cases same : other = index
  · subst other
    simp only [ranges, show index ≠ 0 by omega, ↓reduceIte, Integer.put,
      List.getElem?_set_self (show index - 1 < flow.values.length by
        change index ≤ flow.values.length at bounded
        omega)]
  · by_cases zero : other = 0
    · subst other
      simp only [ranges, ↓reduceIte, Integer.put, show 0 ≠ index by omega]
    · have different : index - 1 ≠ other - 1 := by omega
      simp only [ranges, zero, ↓reduceIte, Integer.put, same,
        List.getElem?_set_ne different]

theorem refine_model (flow : ActiveFlow) (index : Nat) (operator : Integer.Comparison)
    (threshold : Int) (truth : Bool) :
    (flow.refine index operator threshold truth).model =
      ⟨flow.path, flow.model.scalars.refineName index operator threshold truth⟩ := by
  cases present : ranges flow.values index with
  | none =>
      simp only [refine, present, model, Integer.Ranges.refineName]
  | some bounds =>
      have active := ranges_present present
      simp only [refine, present]
      rw [replace_model flow index _ active.1 active.2]
      simp only [model, Integer.Ranges.refineName, present]

@[simp] theorem refine_count (flow : ActiveFlow) (index : Nat) (operator : Integer.Comparison)
    (threshold : Int) (truth : Bool) :
    (flow.refine index operator threshold truth).count = flow.count := by
  unfold refine
  split
  · rfl
  · exact replace_count ..

theorem join_count (left right : ActiveFlow) (same : left.count = right.count) :
    (left.join right).count = left.count := by
  simp only [count, join, List.length_zipWith]
  change left.values.length = right.values.length at same
  rw [same, Nat.min_self]

theorem join_comm (left right : ActiveFlow) : left.join right = right.join left := by
  have values : List.zipWith Integer.Interval.join left.values right.values =
      List.zipWith Integer.Interval.join right.values left.values := by
    generalize left.values = a, right.values = b
    induction a generalizing b with
    | nil => cases b <;> rfl
    | cons head rest ih =>
        cases b with
        | nil => rfl
        | cons other tail =>
            simp only [List.zipWith_cons_cons, Integer.Interval.join_comm head other, ih]
  unfold join
  rw [PathFacts.Context.join_comm left.path right.path, values]

end Silver.Predicate.ActiveFlow
