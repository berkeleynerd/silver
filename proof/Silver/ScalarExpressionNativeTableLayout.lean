module

public import Silver.PredicateArrayViews
public import Silver.ArrayBindingsRead

@[expose] public section

/-! Native table validity supplies the exact layout facts needed by scalar
component reads. The stored/formal distinction follows from adjacency in the
native metadata predicate; it is not an additional caller precondition. -/
namespace Silver.ArrayBindings

set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

theorem ValidTable.stored_iff_first {text : Source} {names : Table}
    (valid : ValidTable text names) {index : Nat} (positive : 0 < index)
    (within : index ≤ names.items.length) :
    (binding names.items index).viewSlot = 0 ↔ (binding names.items 1).viewSlot = 0 := by
  induction index with
  | zero => omega
  | succ index ih =>
      cases index with
      | zero => rfl
      | succ previous =>
          have checked := valid.2.2 (previous + 1) (List.mem_range.mpr (by omega))
          have adjacent := checked.2.2.2.2 (by omega : 0 < previous + 1)
          exact adjacent.1.trans (ih (by omega) (by omega))

theorem ValidTable.stored_of_member {text : Source} {names : Table}
    (valid : ValidTable text names) {item : Binding} (member : item ∈ names.items)
    (stored : item.viewSlot = 0) : ∀ other ∈ names.items, other.viewSlot = 0 := by
  obtain ⟨index, within, same⟩ := List.mem_iff_getElem.mp member
  have itemStored : (binding names.items (index + 1)).viewSlot = 0 := by
    simpa only [binding, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem within, Option.getD_some, same] using stored
  have firstStored := (valid.stored_iff_first (by omega) (by omega)).mp itemStored
  intro other present
  obtain ⟨otherIndex, otherWithin, otherSame⟩ := List.mem_iff_getElem.mp present
  have result := (valid.stored_iff_first (index := otherIndex + 1) (by omega) (by omega)).mpr firstStored
  simpa only [binding, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem otherWithin, Option.getD_some, otherSame] using result

theorem contains_viewIndexCheck {item : Binding} (valid : ValidBinding item)
    (indices : Integer.Interval) :
    contains item indices = Integer.arrayIndexCheck item.viewDescriptor indices := by
  unfold Binding.viewDescriptor
  split
  · exact contains_indexCheck valid indices
  · apply Bool.eq_iff_iff.mpr
    unfold contains Integer.arrayIndexCheck
    rw [decide_eq_true_eq, decide_eq_true_eq]
    constructor
    · intro inside
      exact ⟨⟨valid.1, valid.2.1⟩, inside⟩
    · intro inside
      exact inside.2

theorem viewDescriptor_componentValid {item : Binding} (valid : ValidBinding item) :
    item.viewDescriptor.ComponentValid := by
  unfold Binding.viewDescriptor
  split <;> exact ⟨valid.2.2.2.2.2.1, valid.2.2.2.2.2.2⟩

theorem readViewBounds_correspondence {text : Source} {names : Table}
    (metadata : ValidTable text names) {values : Initials} (valuesValid : ValidInitials values)
    {target : Nat} (member : binding names.items target ∈ names.items)
    (kind : (binding names.items target).isBoolean = false) {indices : Integer.Interval}
    (inside : contains (binding names.items target) indices = true)
    (elaborating : Bool) (scalars : Integer.Ranges) :
    Integer.arrayReadRange (viewRanges names.items values elaborating scalars)
      (binding names.items target).viewDescriptor indices =
        some (readViewBounds names.items values elaborating target indices) := by
  have valid := (metadata.member_valid member).2.1.1
  by_cases stored : (binding names.items target).viewSlot = 0
  · have allStored := metadata.stored_of_member member stored
    have ordered := metadata.viewNames_ordered
    rw [viewNames_stored allStored] at ordered
    rw [viewRanges_stored allStored, Binding.viewDescriptor_stored _ stored,
      readViewBounds_stored _ _ _ _ _ stored]
    exact readBounds_integer_correspondence valuesValid
      (fun entry present => (metadata.member_valid present).2.1.1)
      ordered member valid kind inside elaborating scalars
  · have checked : Integer.arrayIndexCheck (binding names.items target).viewDescriptor indices = true := by
      rw [← contains_viewIndexCheck valid]; exact inside
    have uniform := metadata.view_componentRanges member kind scalars
    have actual : (binding names.items target).viewDescriptor.ComponentRanges
        (viewRanges names.items values elaborating scalars) := by
      have sameRanges : viewRanges names.items values elaborating scalars =
          viewRanges names.items [] false scalars := by
        rw [viewRanges, viewElaborating_formal member stored elaborating]
        rfl
      rw [sameRanges]
      exact uniform
    rw [readViewBounds_formal _ _ _ _ _ stored]
    have result := Integer.arrayReadRange_components checked actual (viewDescriptor_componentValid valid)
    simpa only [Binding.viewDescriptor, stored, ↓reduceIte] using result

end Silver.ArrayBindings
