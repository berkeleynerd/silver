module

public import Silver.PredicateFlowWidening

@[expose] public section

namespace Silver.Predicate.ScalarMetadata
open ScalarExpression

/-- The bounds used by native Valid_Flow: mutable cells use their declared
subtype, while immutable cells retain their captured bounds. This projection
does not change the declaration snapshots used by elaborating readers. -/
def flowBounds (names : Environment) : Integer.Ranges := ranges (bodyEnvironment names)

theorem flowBounds_active (names : Environment) (index : Nat)
    (positive : 0 < index) (bounded : index ≤ names.length) :
    flowBounds names index = some (if (binding names index).mutable then
      (binding names index).declaredBounds else (binding names index).bounds) := by
  simp only [flowBounds, ranges, bodyEnvironment_length, positive, bounded, and_self,
    ↓reduceIte, bodyEnvironment_binding, bodyBinding]

theorem flowBounds_eq_ranges {names : Environment} (ready : BodyReady names) :
    flowBounds names = ranges names := by
  funext index
  by_cases active : 0 < index ∧ index ≤ names.length
  · rw [flowBounds_active names index active.1 active.2]
    simp only [ranges, active]
    split
    · exact congrArg some (bodyReady_binding ready active.1 active.2 ‹_›).symm
    · rfl
  · simp only [flowBounds, ranges, bodyEnvironment_length, active, ↓reduceIte]

/-- The elaboration boundary that motivated the distinct native flow domain:
an initialized mutable snapshot need not contain every legal later flow value. -/
theorem flowBounds_elaboration_boundary :
    let item : Binding := ⟨1, 2, ⟨0, 0⟩, false, ⟨0, 10⟩, true, 0, 0⟩
    flowBounds [item] 1 = some ⟨0, 10⟩ ∧
      ((flowBounds [item] 1).getD Integer.Interval.empty).Contains 5 ∧
      ¬((ranges [item] 1).getD Integer.Interval.empty).Contains 5 := by
  decide +kernel

theorem BaseReady.flowBounds_eq_analysis {names declarations}
    (ready : BaseReady names declarations) :
    flowBounds names = (analysis names declarations).declared :=
  flowBounds_eq_ranges ready.body

end Silver.Predicate.ScalarMetadata

namespace Silver.Predicate.ActiveFlow
open ScalarExpression

theorem widen_bodyEnvironment (names : Environment) (flow : ActiveFlow) :
    widen (bodyEnvironment names) flow = widen names flow := by
  simp only [widen, bodyEnvironment, List.zipWith_map_left,
    bodyBinding_mutable, bodyBinding_declaredBounds]
  rfl

/-- Native widening uses declared mutable bounds in either context mode. -/
theorem widen_flow_model (names : Environment) (declarations : Nat) (flow : ActiveFlow)
    (same : flow.count = names.length) :
    (widen names flow).model =
      ⟨flow.path, (ScalarMetadata.analysis (bodyEnvironment names) declarations).widen flow.model.scalars⟩ := by
  rw [← widen_bodyEnvironment names flow]
  exact widen_model (bodyEnvironment names) declarations flow
    (by simpa only [bodyEnvironment_length] using same) (bodyEnvironment_ready names)

end Silver.Predicate.ActiveFlow
