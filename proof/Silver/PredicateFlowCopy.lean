module

public import Silver.PredicateFlowOperations

@[expose] public section

namespace Silver.Predicate.ActiveFlow

/-- The native loop copies one one-based cell at each iteration. The target
array begins with Empty in every slot, including its extra index slot. -/
def copyCells (source : Nat → Integer.Interval) : Nat → Nat → Integer.Interval
  | 0 => fun _ => Integer.Interval.empty
  | count + 1 => Integer.put (copyCells source count) (count + 1) (source (count + 1))

theorem copyCells_inside (source : Nat → Integer.Interval) (count index : Nat)
    (positive : 0 < index) (bounded : index ≤ count) :
    copyCells source count index = source index := by
  induction count with
  | zero => omega
  | succ count ih =>
      by_cases last : index = count + 1
      · simp only [copyCells, Integer.put, last, ↓reduceIte]
      · simp only [copyCells, Integer.put, last, ↓reduceIte]
        exact ih (by omega)

theorem copyCells_outside (source : Nat → Integer.Interval) (count index : Nat)
    (outside : index = 0 ∨ count < index) :
    copyCells source count index = Integer.Interval.empty := by
  induction count with
  | zero => rfl
  | succ count ih =>
      have different : index ≠ count + 1 := by omega
      simp only [copyCells, Integer.put, different, ↓reduceIte]
      exact ih (by omega)

/-- Allocation, the complete prefix-copy loop, and assignment to the final
cell retain exactly the captured bounds and every outer scalar interval. -/
def copyAppend (flow : ActiveFlow) (bounds : Integer.Interval) : ActiveFlow :=
  let copied := copyCells (fun index => flow.values.getD (index - 1) Integer.Interval.empty) flow.count
  (Storage.mk (flow.count + 1) flow.path (Integer.put copied (flow.count + 1) bounds)).active

theorem copyAppend_eq (flow : ActiveFlow) (bounds : Integer.Interval) :
    flow.copyAppend bounds = flow.append bounds := by
  unfold copyAppend Storage.active append
  dsimp only
  congr 1
  apply List.ext_getElem
  · simp only [List.length_ofFn, List.length_append, List.length_singleton, count]
  · intro index leftBound rightBound
    have inside : index < flow.count + 1 := by simpa only [List.length_ofFn] using leftBound
    simp only [List.getElem_ofFn, Integer.put]
    by_cases final : index = flow.count
    · subst index
      simp only [↓reduceIte, count, List.getElem_append_right (Nat.le_refl _), Nat.sub_self,
        List.getElem_cons_zero]
    · have earlier : index < flow.values.length := by
        change index < flow.values.length + 1 at inside
        change index ≠ flow.values.length at final
        omega
      have different : index + 1 ≠ flow.count + 1 := by omega
      rw [ite_eq_right different,
        copyCells_inside (fun cell => flow.values.getD (cell - 1) Integer.Interval.empty)
          flow.count (index + 1) (Nat.succ_pos _) (by
            change index + 1 ≤ flow.values.length
            omega)]
      simp only [Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem earlier, Option.getD_some, List.getElem_append_left earlier]

end Silver.Predicate.ActiveFlow
