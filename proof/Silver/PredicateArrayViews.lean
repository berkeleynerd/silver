module

public import Silver.PredicateArrayFlow
public import Silver.ArrayBindingsMetadata

@[expose] public section

/-! Formal cells occupy mathematical addresses above the physical initializer
pool. This projection reuses the ordinary cell-range algebra; its offsets are
not native allocation offsets and need not fit the physical pool. -/
namespace Silver.ArrayBindings

def Binding.effective (item : Binding) : Binding :=
  if item.viewSlot = 0 then item else {item with offset := item.viewSlot * maxElements}

@[simp] theorem Binding.effective_descriptor (item : Binding) :
    item.effective.descriptor = item.viewDescriptor := by
  unfold Binding.effective Binding.viewDescriptor Binding.descriptor
  split <;> rfl

@[simp] theorem Binding.effective_componentBounds (item : Binding) :
    item.effective.componentBounds = item.componentBounds := by
  unfold Binding.effective
  split <;> rfl

@[simp] theorem Binding.effective_isBoolean (item : Binding) :
    item.effective.isBoolean = item.isBoolean := by
  unfold Binding.effective
  split <;> rfl

@[simp] theorem Binding.effective_mutable (item : Binding) :
    item.effective.mutable = item.mutable := by
  unfold Binding.effective
  split <;> rfl

def viewNames (names : Metadata) : Metadata := names.map Binding.effective

def viewElaborating (names : Metadata) (elaborating : Bool) : Bool :=
  elaborating && !names.any (fun item => decide (item.viewSlot ≠ 0))

def viewRanges (names : Metadata) (initials : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) : Integer.Ranges :=
  integerRanges (viewNames names) initials (viewElaborating names elaborating) scalars

theorem viewNames_stored {names : Metadata} (stored : ∀ item ∈ names, item.viewSlot = 0) :
    viewNames names = names := by
  unfold viewNames
  have same : names.map Binding.effective = names.map id := by
    apply List.map_congr_left
    intro item member
    simp [Binding.effective, stored item member]
  rw [same, List.map_id]

theorem viewElaborating_stored {names : Metadata} (stored : ∀ item ∈ names, item.viewSlot = 0)
    (elaborating : Bool) : viewElaborating names elaborating = elaborating := by
  have absent : names.any (fun item => decide (item.viewSlot ≠ 0)) = false := by
    apply Bool.eq_false_iff.mpr
    intro found
    obtain ⟨item, member, different⟩ := List.any_eq_true.mp found
    simp [stored item member] at different
  rw [viewElaborating, absent]
  simp only [Bool.not_false, Bool.and_true]

theorem viewRanges_stored {names : Metadata} (stored : ∀ item ∈ names, item.viewSlot = 0)
    (initials : Initials) (elaborating : Bool) (scalars : Integer.Ranges) :
    viewRanges names initials elaborating scalars = integerRanges names initials elaborating scalars := by
  simp only [viewRanges, viewNames_stored stored, viewElaborating_stored stored]

theorem viewElaborating_formal {names : Metadata} {item : Binding}
    (member : item ∈ names) (formal : item.viewSlot ≠ 0) (elaborating : Bool) :
    viewElaborating names elaborating = false := by
  have present : names.any (fun item => decide (item.viewSlot ≠ 0)) = true :=
    List.any_eq_true.mpr ⟨item, member, by simp [formal]⟩
  rw [viewElaborating, present]
  simp only [Bool.not_true, Bool.and_false]

theorem viewRanges_scalar (names : Metadata) (initials : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) {cell : Nat} (low : cell ≤ scalarLimit) :
    viewRanges names initials elaborating scalars cell = scalars cell :=
  ranges_scalar (integerNames (viewNames names)) initials (viewElaborating names elaborating) scalars low

theorem viewRanges_put (names : Metadata) (initials : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) {cell : Nat} (low : cell ≤ scalarLimit)
    (bounds : Option Integer.Interval) :
    viewRanges names initials elaborating (Integer.put scalars cell bounds) =
      Integer.put (viewRanges names initials elaborating scalars) cell bounds :=
  ranges_put (integerNames (viewNames names)) initials (viewElaborating names elaborating) scalars low bounds

theorem viewRanges_join (names : Metadata) (initials : Initials) (elaborating : Bool)
    (left right : Integer.Ranges) :
    viewRanges names initials elaborating (left.join right) =
      (viewRanges names initials elaborating left).join (viewRanges names initials elaborating right) := by
  funext cell
  unfold viewRanges integerRanges ranges Integer.Ranges.join
  cases covered : covers (integerNames (viewNames names)) cell with
  | false => simp only [covered, Bool.false_eq_true, ↓reduceIte]
  | true =>
      simp only [covered, ↓reduceIte]
      cases viewElaborating names elaborating
      · exact congrArg some (componentRange_join_self (integerNames (viewNames names)) cell).symm
      · simp [Integer.Interval.join, Integer.Interval.singleton, Integer.Interval.isEmpty]

end Silver.ArrayBindings

namespace Silver.Predicate.ArrayViews

def analysis (names : ArrayBindings.Metadata) (scalars : Integer.Analysis) : Integer.Analysis :=
  ArrayFlow.analysis (ArrayBindings.viewNames names) scalars

theorem analysis_stored {names : ArrayBindings.Metadata}
    (stored : ∀ item ∈ names, item.viewSlot = 0) (scalars : Integer.Analysis) :
    analysis names scalars = ArrayFlow.analysis names scalars := by
  simp only [analysis, ArrayBindings.viewNames_stored stored]

end Silver.Predicate.ArrayViews
