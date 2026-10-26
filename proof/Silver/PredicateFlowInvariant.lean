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

structure BaseReady (names : Environment) (declarations : Nat) : Prop where
  body : BodyReady names
  count : declarations ≤ names.length
  declarationsNonempty : DeclarationsNonempty names declarations

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
