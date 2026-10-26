module

public import Silver.PredicateFlowOverlay
public import Silver.PredicateFlowOperations

@[expose] public section

namespace Silver.Predicate.ScalarMetadata
open ScalarExpression

/-- Declaration snapshots and mutable declaration subtypes are nonempty.
Appended loop indexes are outside this prefix and may have empty intervals. -/
def DeclarationsNonempty (names : Environment) (declarations : Nat) : Prop :=
  ∀ index, 0 < index → index ≤ declarations → (binding names index).bounds.isEmpty = false

/-- The exact active-cell clauses of native Valid_Mutable_Bounds. Mutable
bindings are covered even when they are outside the declaration prefix. -/
def ValidMutableBounds (names : Environment) : Prop :=
  ∀ index, 0 < index → index ≤ names.length → (binding names index).mutable = true →
    (binding names index).bounds.isEmpty = false ∧
      (binding names index).declaredBounds.lower ≤ (binding names index).bounds.lower ∧
      (binding names index).bounds.upper ≤ (binding names index).declaredBounds.upper

structure BaseReady (names : Environment) (declarations : Nat) : Prop where
  body : BodyReady names
  count : declarations ≤ names.length
  declarationsNonempty : DeclarationsNonempty names declarations
  mutableNonempty : ∀ index, 0 < index → index ≤ names.length →
    (binding names index).mutable = true → (binding names index).bounds.isEmpty = false

theorem BaseReady.mutable_bounds {names : Environment} {declarations : Nat}
    (ready : BaseReady names declarations) : ValidMutableBounds names := by
  intro index positive bounded mutable
  refine ⟨ready.mutableNonempty index positive bounded mutable, ?_⟩
  rw [bodyReady_binding ready.body positive bounded mutable]
  exact ⟨Int.le_refl _, Int.le_refl _⟩

/-- Native Valid_Context supplies all four clauses. Conversely, body metadata
uses equal mutable Bounds/Declared_Bounds, so their containment inequalities
follow without an additional restriction on immutable suffix bindings. -/
theorem baseReady_iff_native (names : Environment) (declarations : Nat) :
    BaseReady names declarations ↔ BodyReady names ∧ declarations ≤ names.length ∧
      DeclarationsNonempty names declarations ∧ ValidMutableBounds names := by
  constructor
  · intro ready
    exact ⟨ready.body, ready.count, ready.declarationsNonempty, ready.mutable_bounds⟩
  · rintro ⟨body, count, declared, mutable⟩
    exact ⟨body, count, declared,
      fun index positive bounded isMutable => (mutable index positive bounded isMutable).1⟩

theorem overlayCompatible_of_preserved {names : Environment} {declarations : Nat}
    {before after : ActiveFlow} (initial : OverlayCompatible names declarations before)
    (count : after.count = names.length)
    (preserved : ∀ index, 0 < index → index ≤ names.length →
      (binding names index).mutable = false → index ≤ declarations →
      after.model.scalars index = before.model.scalars index) :
    OverlayCompatible names declarations after where
  count := count
  immutable index positive bounded mutable declared := by
    have same := preserved index positive bounded mutable declared
    change ActiveFlow.ranges after.values index = ActiveFlow.ranges before.values index at same
    simp only [ActiveFlow.ranges, show index ≠ 0 by omega, ↓reduceIte] at same
    have fields := congrArg (fun value : Option Integer.Interval => value.getD Integer.Interval.empty) same
    simp only [List.getD_eq_getElem?_getD]
    exact fields.trans (by
      simpa only [List.getD_eq_getElem?_getD] using
        initial.immutable index positive bounded mutable declared)

theorem OverlayCompatible.fixed_cell {names : Environment} {declarations : Nat}
    {flow : ActiveFlow} (compatible : OverlayCompatible names declarations flow)
    (index : Nat) (positive : 0 < index) (bounded : index ≤ names.length)
    (mutable : (binding names index).mutable = false) (declared : index ≤ declarations) :
    flow.model.scalars index = some (binding names index).bounds := by
  have active : index ≤ flow.values.length := by
    have count := compatible.count
    change flow.values.length = names.length at count
    omega
  change ActiveFlow.ranges flow.values index = _
  rw [ActiveFlow.ranges_inside flow.values index positive active]
  apply congrArg some
  have same := compatible.immutable index positive bounded mutable declared
  simpa only [List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem (show index - 1 < flow.values.length by omega), Option.getD_some] using same

@[simp] theorem readingBinding_first (declarations index : Nat) (item : Binding)
    (bounds : Integer.Interval) : (readingBinding declarations index item bounds).first = item.first := by
  unfold readingBinding
  split <;> rfl

@[simp] theorem readingBinding_after (declarations index : Nat) (item : Binding)
    (bounds : Integer.Interval) : (readingBinding declarations index item bounds).after = item.after := by
  unfold readingBinding
  split <;> rfl

theorem readingNames_lookupFrom (text : Source) (names : Environment) (declarations : Nat)
    (flow : ActiveFlow) (first after count : Nat) (bounded : count ≤ names.length) :
    lookupFrom text (readingNames names declarations flow) first after count =
      lookupFrom text names first after count := by
  induction count with
  | zero => rfl
  | succ count ih =>
    have active : count + 1 ≤ names.length := bounded
    simp only [lookupFrom, readingNames_binding names declarations flow (count + 1)
      (Nat.succ_pos _) active, readingBinding_first, readingBinding_after,
      ih (by omega)]

theorem readingNames_lookup (text : Source) (names : Environment) (declarations : Nat)
    (flow : ActiveFlow) (first after : Nat) :
    lookup text (readingNames names declarations flow) first after = lookup text names first after := by
  simp only [lookup, readingNames_length,
    readingNames_lookupFrom text names declarations flow first after names.length (Nat.le_refl _)]

theorem readingNames_valid {text : Source} {names : Environment} {declarations : Nat}
    {flow : ActiveFlow} (valid : ValidEnvironment text names)
    (count : flow.count = names.length) (bounded : flow.model.scalars.Bounded) :
    ValidEnvironment text (readingNames names declarations flow) := by
  refine ⟨by simpa only [readingNames_length] using valid.1, ?_⟩
  intro item present
  change item ∈ List.ofFn _ at present
  obtain ⟨index, rfl⟩ := List.mem_ofFn.mp present
  have old := valid.2 names[index.val] (List.getElem_mem index.isLt)
  unfold readingBinding
  split
  · refine ⟨old.1, old.2.1, old.2.2.1, ?_, old.2.2.2.2⟩
    apply bounded (index.val + 1)
    have within : index.val < flow.values.length := by
      change flow.values.length = names.length at count
      omega
    simp only [ActiveFlow.model, ActiveFlow.ranges, Nat.succ_ne_zero, ↓reduceIte,
      Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem within, Option.getD_some]
  · exact old

end Silver.Predicate.ScalarMetadata
