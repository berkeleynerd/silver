module

public import Silver.PredicateFlowStorage

@[expose] public section

namespace Silver.Predicate.ScalarMetadata
open ScalarExpression

/-- Exactly the active binding overlay. Native inactive slots are handled by
the complete array contract, and never become scalar identities here. -/
def readingNames (names : Environment) (declarations : Nat) (flow : ActiveFlow) : Environment :=
  List.ofFn fun index : Fin names.length =>
    readingBinding declarations (index.val + 1) names[index.val]
      (flow.values.getD index.val Integer.Interval.empty)

@[simp] theorem readingNames_length (names : Environment) (declarations : Nat) (flow : ActiveFlow) :
    (readingNames names declarations flow).length = names.length := by
  simp [readingNames]

/-- Immutable declarations are copied literally. This premise is part of native
Valid_Flow; it is separate from interval containment for refinable bindings. -/
structure OverlayCompatible (names : Environment) (declarations : Nat) (flow : ActiveFlow) : Prop where
  count : flow.count = names.length
  immutable : ∀ index, 0 < index → index ≤ names.length →
    (binding names index).mutable = false → index ≤ declarations →
    flow.values.getD (index - 1) Integer.Interval.empty = (binding names index).bounds

theorem readingNames_binding (names : Environment) (declarations : Nat) (flow : ActiveFlow)
    (index : Nat) (positive : 0 < index) (bounded : index ≤ names.length) :
    binding (readingNames names declarations flow) index =
      readingBinding declarations index (binding names index)
        (flow.values.getD (index - 1) Integer.Interval.empty) := by
  have within : index - 1 < names.length := by omega
  simp only [binding, readingNames, List.getD_eq_getElem?_getD, List.getElem?_ofFn,
    within, ↓reduceDIte, Option.getD_some, List.getElem?_eq_getElem within]
  congr 1
  omega

theorem readingNames_bounds {names : Environment} {declarations : Nat} {flow : ActiveFlow}
    (compatible : OverlayCompatible names declarations flow) :
    (readingNames names declarations flow).map (·.bounds) = flow.values := by
  apply List.ext_getElem
  · simpa only [List.length_map, readingNames_length, ActiveFlow.count] using compatible.count.symm
  · intro index leftBound rightBound
    have within : index < names.length := by
      simpa only [List.length_map, readingNames_length] using leftBound
    have positive : 0 < index + 1 := Nat.succ_pos _
    have bounded : index + 1 ≤ names.length := Nat.succ_le_of_lt within
    have item : binding names (index + 1) = names[index] := by
      simp only [binding, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem within, Option.getD_some]
    have value : flow.values.getD index Integer.Interval.empty = flow.values[index] := by
      simp only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem rightBound, Option.getD_some]
    simp only [List.getElem_map, readingNames, List.getElem_ofFn, readingBinding, value]
    split
    · rfl
    · rename_i unchanged
      have mutable : (binding names (index + 1)).mutable = false := by
        rw [item]
        exact Bool.eq_false_iff.mpr (fun yes => unchanged (by simp only [yes, Bool.true_or]))
      have declared : index + 1 ≤ declarations := by
        by_cases inside : index + 1 ≤ declarations
        · exact inside
        · exact False.elim (unchanged (by
            simp only [show declarations < index + 1 by omega, decide_true, Bool.or_true]))
      have saved := compatible.immutable (index + 1) positive bounded mutable declared
      simpa only [Nat.add_sub_cancel, item, value] using saved.symm

theorem readingNames_ranges {names : Environment} {declarations : Nat} {flow : ActiveFlow}
    (compatible : OverlayCompatible names declarations flow) :
    ScalarExpression.ranges (readingNames names declarations flow) = flow.model.scalars := by
  rw [← ActiveFlow.ranges_map_bounds, readingNames_bounds compatible]
  rfl

theorem readingNames_mutability (names : Environment) (declarations : Nat) (flow : ActiveFlow) :
    mutability (readingNames names declarations flow) = mutability names := by
  funext index
  by_cases active : 0 < index ∧ index ≤ names.length
  · simp only [mutability, readingNames_length, active, and_self, decide_true, Bool.true_and,
      readingNames_binding names declarations flow index active.1 active.2, readingBinding_mutable]
  · simp only [mutability, readingNames_length, active, decide_false, Bool.false_and]

theorem readingNames_staticness (names : Environment) (declarations : Nat) (flow : ActiveFlow) :
    staticness (readingNames names declarations flow) = staticness names := by
  funext index
  by_cases active : 0 < index ∧ index ≤ names.length
  · simp only [staticness, readingNames_length, active, and_self, decide_true, Bool.true_and,
      readingNames_binding names declarations flow index active.1 active.2, readingBinding_static]
  · simp only [staticness, readingNames_length, active, decide_false, Bool.false_and]

theorem initial_compatible (names : Environment) (declarations : Nat) (path : PathFacts.Context) :
    OverlayCompatible names declarations (ActiveFlow.initial names path) where
  count := ActiveFlow.initial_count names path
  immutable index positive bounded _ _ := by
    have within : index - 1 < names.length := by omega
    simp only [ActiveFlow.initial, binding, List.getD_eq_getElem?_getD,
      List.getElem?_map, List.getElem?_eq_getElem within, Option.map_some, Option.getD_some]

end Silver.Predicate.ScalarMetadata
