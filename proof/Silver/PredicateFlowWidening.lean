module

public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate.ActiveFlow
open ScalarExpression

def widen (names : Environment) (flow : ActiveFlow) : ActiveFlow :=
  ⟨flow.path, List.zipWith (fun item bounds => if item.mutable then item.declaredBounds else bounds)
    names flow.values⟩

@[simp] theorem widen_path (names : Environment) (flow : ActiveFlow) :
    (widen names flow).path = flow.path := rfl

theorem widen_count (names : Environment) (flow : ActiveFlow) (same : flow.count = names.length) :
    (widen names flow).count = flow.count := by
  simp only [widen, count, List.length_zipWith]
  change flow.values.length = names.length at same
  rw [same, Nat.min_self]

theorem widen_model (names : Environment) (declarations : Nat) (flow : ActiveFlow)
    (same : flow.count = names.length) (ready : BodyReady names) :
    (widen names flow).model =
      ⟨flow.path, (ScalarMetadata.analysis names declarations).widen flow.model.scalars⟩ := by
  unfold widen model
  congr 1
  funext index
  by_cases active : 0 < index ∧ index ≤ names.length
  · have inNames : index - 1 < names.length := by omega
    have inValues : index - 1 < flow.values.length := by
      change flow.values.length = names.length at same
      omega
    have item : binding names index = names[index - 1] := by
      simp only [binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inNames, Option.getD_some]
    simp only [ranges, show index ≠ 0 by omega, ↓reduceIte, List.getElem?_zipWith,
      List.getElem?_eq_getElem inNames, List.getElem?_eq_getElem inValues,
      ScalarMetadata.analysis, Integer.Analysis.widen, ScalarExpression.mutability,
      active, and_self, decide_true, Bool.true_and, ScalarExpression.ranges, item]
    cases mutable : names[index - 1].mutable with
    | false => simp only [Bool.false_eq_true, ↓reduceIte]
    | true =>
      have declared := bodyReady_binding ready active.1 active.2 (by simpa only [item] using mutable)
      simp only [item] at declared
      simp only [↓reduceIte, declared]
  · have outsideValues : index = 0 ∨ flow.values.length < index := by
      change flow.values.length = names.length at same
      omega
    have outsideWidened : index = 0 ∨
        (List.zipWith (fun item bounds => if item.mutable then item.declaredBounds else bounds)
          names flow.values).length < index := by
      simp only [List.length_zipWith]
      omega
    rw [ranges_outside _ _ outsideWidened]
    simp only [ScalarMetadata.analysis, Integer.Analysis.widen, ScalarExpression.mutability,
      active, decide_false, Bool.false_and, Bool.false_eq_true, ↓reduceIte,
      ranges_outside _ _ outsideValues]

end Silver.Predicate.ActiveFlow
