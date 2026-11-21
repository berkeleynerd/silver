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

@[simp] theorem Binding.effective_length (item : Binding) :
    item.effective.length = item.length := by
  unfold Binding.effective
  split <;> rfl

@[simp] theorem Binding.effective_bounds (item : Binding) :
    item.effective.bounds = item.bounds := by
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

theorem ValidTable.effective_adjacent {text : Source} {names : Table}
    (valid : ValidTable text names) {index : Nat} (positive : 0 < index)
    (within : index + 1 ≤ names.items.length) :
    (binding names.items index).effective.offset + (binding names.items index).length ≤
      (binding names.items (index + 1)).effective.offset := by
  have left := valid.2.2 (index - 1) (List.mem_range.mpr (by omega))
  have right := valid.2.2 index (List.mem_range.mpr (by omega))
  have previous : index - 1 + 1 = index := by omega
  rw [previous] at left
  have adjacent := right.2.2.2.2 positive
  by_cases stored : (binding names.items index).viewSlot = 0
  · have nextStored := adjacent.1.mpr stored
    simpa only [Binding.effective, stored, nextStored, ↓reduceIte] using adjacent.2 nextStored
  · have nextView : (binding names.items (index + 1)).viewSlot ≠ 0 := by
      intro zero
      exact stored (adjacent.1.mp zero)
    have leftSlot := left.2.2.2.1 stored
    have rightSlot := right.2.2.2.1 nextView
    have capacity := left.2.1.1.2.2.2.1
    simp only [Binding.effective]
    rw [ite_eq_right stored, ite_eq_right nextView]
    simp only [leftSlot, rightSlot]
    simp only [maxElements] at capacity ⊢
    omega

theorem ValidTable.effective_order {text : Source} {names : Table}
    (valid : ValidTable text names) {first last : Nat}
    (positive : 0 < first) (ordered : first < last) (within : last ≤ names.items.length) :
    (binding names.items first).effective.offset + (binding names.items first).length ≤
      (binding names.items last).effective.offset := by
  induction last with
  | zero => omega
  | succ last ih =>
      by_cases equal : first = last
      · subst first
        exact valid.effective_adjacent positive within
      · have earlier : first < last := by omega
        have before := ih earlier (by omega)
        have next := valid.effective_adjacent (index := last) (by omega) within
        omega

theorem ValidTable.viewNames_ordered {text : Source} {names : Table}
    (valid : ValidTable text names) :
    (viewNames names.items).Pairwise (fun left right => left.offset + left.length ≤ right.offset) := by
  apply List.pairwise_map.mpr
  rw [List.pairwise_iff_getElem]
  intro first last firstBound lastBound ordered
  have bounds := valid.effective_order (first := first + 1) (last := last + 1)
    (by omega) (by omega) (by omega)
  simpa only [binding, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem firstBound, List.getElem?_eq_getElem lastBound,
    Option.getD_some, Binding.effective_length] using bounds

/-- Ordered semantic cell segments need no physical initializer-pool bound. -/
theorem ordered_view_componentRange {names : Metadata} {item : Binding} {cell : Nat}
    (layout : ∀ entry ∈ names, entry.descriptor.length = entry.length ∧
      entry.componentBounds.lower ≤ entry.componentBounds.upper)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : item ∈ names) (inside : item.descriptor.ContainsCell cell) :
    componentRange names cell = item.componentBounds := by
  induction names with
  | nil => simp at member
  | cons head tail ih =>
      have order := List.pairwise_cons.mp ordered
      rcases List.mem_cons.mp member with same | member
      · subst item
        have nonempty : head.componentBounds.isEmpty = false := by
          simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not, Int.not_lt]
          exact (layout head (by simp)).2
        simp only [componentRange, List.find?_cons, inside, decide_true,
          Integer.Interval.normalize, nonempty, Bool.false_eq_true, ↓reduceIte]
      · have separate := order.1 item member
        have headLength := (layout head (by simp)).1
        have absent : ¬head.descriptor.ContainsCell cell := by
          intro contained
          simp only [Integer.ArrayDescriptor.ContainsCell] at contained inside
          rw [headLength] at contained
          dsimp only [Binding.descriptor] at contained inside
          omega
        have rest := ih (fun entry found => layout entry (by simp [found])) order.2 member
        simpa only [componentRange, List.find?_cons, absent, decide_false, Bool.false_eq_true, ↓reduceIte] using rest

theorem ValidTable.view_componentRanges {text : Source} {names : Table}
    (valid : ValidTable text names) {item : Binding} (member : item ∈ names.items)
    (kind : item.isBoolean = false) (scalars : Integer.Ranges) :
    item.viewDescriptor.ComponentRanges (viewRanges names.items [] false scalars) := by
  have selected : item.effective ∈ integerNames (viewNames names.items) :=
    mem_integerNames.mpr ⟨List.mem_map.mpr ⟨item, member, rfl⟩, by simpa using kind⟩
  have layout : ∀ entry ∈ integerNames (viewNames names.items),
      entry.descriptor.length = entry.length ∧
      entry.componentBounds.lower ≤ entry.componentBounds.upper := by
    intro entry found
    obtain ⟨source, sourceMember, same⟩ := List.mem_map.mp (mem_integerNames.mp found).1
    subst entry
    have shape := (valid.member_valid sourceMember).2.1.1
    constructor
    · simpa only [Binding.effective_bounds, Binding.effective_length,
        Binding.descriptor, Integer.ArrayDescriptor.length] using binding_descriptor_length shape
    · simpa using shape.2.2.2.2.2.2
  have ordered := integerNames_ordered valid.viewNames_ordered
  intro index inside
  have atCell := item.viewDescriptor.address_within inside
  have effectiveCell : item.effective.descriptor.ContainsCell (item.viewDescriptor.address index) := by
    simpa using atCell
  have covered := (covers_iff _ _).mpr ⟨item.effective, selected, effectiveCell⟩
  have range := ordered_view_componentRange layout ordered selected effectiveCell
  simp only [viewRanges, viewElaborating, Bool.false_and, integerRanges,
    ranges, covered, ↓reduceIte, Bool.false_eq_true, range,
    Binding.effective_componentBounds]
  congr 1
  unfold Binding.viewDescriptor
  split <;> rfl

end Silver.ArrayBindings

namespace Silver.Predicate.ArrayViews

def analysis (names : ArrayBindings.Metadata) (scalars : Integer.Analysis) : Integer.Analysis :=
  ArrayFlow.analysis (ArrayBindings.viewNames names) scalars

theorem analysis_stored {names : ArrayBindings.Metadata}
    (stored : ∀ item ∈ names, item.viewSlot = 0) (scalars : Integer.Analysis) :
    analysis names scalars = ArrayFlow.analysis names scalars := by
  simp only [analysis, ArrayBindings.viewNames_stored stored]

end Silver.Predicate.ArrayViews
