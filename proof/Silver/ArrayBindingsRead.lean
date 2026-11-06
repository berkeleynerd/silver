module

public import Silver.ArrayBindings

@[expose] public section

/-! The native prefix-fold hull equals the core selected-cell range scan.
The initial-value domain includes zero extension; source allocation invariants
are not required to justify a native metadata read. -/
namespace Silver.ArrayBindings

private theorem join_assoc (left right : Int) (middle : Integer.Interval) :
    ((Integer.Interval.singleton left).join middle).join (Integer.Interval.singleton right) =
      (Integer.Interval.singleton left).join (middle.join (Integer.Interval.singleton right)) := by
  have leftNonempty : (Integer.Interval.singleton left).isEmpty = false := by
    simp [Integer.Interval.singleton, Integer.Interval.isEmpty]
  have rightNonempty : (Integer.Interval.singleton right).isEmpty = false := by
    simp [Integer.Interval.singleton, Integer.Interval.isEmpty]
  have prefixNonempty : ((Integer.Interval.singleton left).join middle).isEmpty = false :=
    Integer.Interval.contains_nonempty (Integer.Interval.join_left
      ((Integer.Interval.singleton_contains left left).mpr rfl))
  have suffixNonempty : (middle.join (Integer.Interval.singleton right)).isEmpty = false :=
    Integer.Interval.contains_nonempty (Integer.Interval.join_right
      ((Integer.Interval.singleton_contains right right).mpr rfl))
  conv =>
    lhs
    rw [Integer.Interval.join, prefixNonempty, rightNonempty]
    simp only [Bool.false_eq_true, ↓reduceIte]
  conv =>
    rhs
    rw [Integer.Interval.join, leftNonempty, suffixNonempty]
    simp only [Bool.false_eq_true, ↓reduceIte]
  simp only [Integer.Interval.join, leftNonempty, rightNonempty, Bool.false_eq_true, ↓reduceIte]
  cases middle.isEmpty <;>
    simp [Integer.Interval.normalize, Integer.Interval.singleton, Integer.Interval.isEmpty,
      Int.min_assoc, Int.max_assoc]

theorem hullFrom_bounded {values : Initials} (valid : ValidInitials values) (first count : Nat) :
    (hullFrom values first count).Bounded := by
  induction count with
  | zero => exact Integer.Interval.empty_bounded
  | succ count ih =>
      exact Integer.Interval.join_bounded ih ⟨initialValue_inRange valid _, initialValue_inRange valid _⟩

theorem hullFrom_nonempty (values : Initials) (first : Nat) {count : Nat} (positive : 0 < count) :
    (hullFrom values first count).isEmpty = false := by
  cases count with
  | zero => omega
  | succ count =>
      apply Integer.Interval.contains_nonempty
      exact Integer.Interval.join_right ((Integer.Interval.singleton_contains _ _).mpr rfl)

theorem hullFrom_shift (values : Initials) (first count : Nat) :
    hullFrom values first (count + 1) =
      (Integer.Interval.singleton (initialValue values first)).join (hullFrom values (first + 1) count) := by
  induction count with
  | zero => simp [hullFrom, Integer.Interval.join, Integer.Interval.normalize,
      Integer.Interval.isEmpty, Integer.Interval.empty, Integer.Interval.singleton]
  | succ count ih =>
      simp only [hullFrom] at ih ⊢
      rw [ih, join_assoc]
      have same : first + 1 + count = first + (count + 1) := by omega
      rw [same]

theorem arraySpanRange_initials (names : Metadata) (values : Initials) (scalars : Integer.Ranges)
    (first count : Nat) (above : scalarLimit ≤ first)
    (covered : ∀ cell, first ≤ cell → cell < first + count → covers names cell = true) :
    Integer.arraySpanRange (ranges names values true scalars) first count =
      some (hullFrom values (first - scalarLimit) count) := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      rw [Integer.arraySpanRange, ranges_of_covered (covered first (by omega) (by omega))]
      simp only [↓reduceIte, Option.bind_some]
      rw [ih (first + 1) (by omega) (by intro cell lower upper; exact covered cell (by omega) (by omega))]
      simp only [Option.map_some]
      rw [hullFrom_shift]
      have same : first + 1 - scalarLimit = first - scalarLimit + 1 := by omega
      rw [same]

theorem contains_indexCheck {item : Binding} (valid : ValidBinding item) (indices : Integer.Interval) :
    contains item indices = Integer.arrayIndexCheck item.descriptor indices := by
  unfold contains Integer.arrayIndexCheck
  simp only [binding_descriptor_valid valid, true_and]
  rfl

theorem readBounds_correspondence {names : Metadata} {values : Initials} {target : Nat}
    (valuesValid : ValidInitials values)
    (metadata : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : binding names target ∈ names)
    (itemValid : ValidBinding (binding names target)) {indices : Integer.Interval}
    (inside : contains (binding names target) indices = true) (elaborating : Bool)
    (scalars : Integer.Ranges) :
    Integer.arrayReadRange (ranges names values elaborating scalars)
      (binding names target).descriptor indices = some (readBounds names values elaborating target indices) := by
  have checked : Integer.arrayIndexCheck (binding names target).descriptor indices = true := by
    rw [← contains_indexCheck itemValid]; exact inside
  cases elaborating with
  | false =>
      exact Integer.arrayReadRange_components checked
        (body_ranges_components metadata ordered member values scalars) (binding_component_valid itemValid)
  | true =>
      have bounds := inside
      simp only [contains, decide_eq_true_eq] at bounds
      have positive : 0 < (indices.upper - indices.lower + 1).toNat := by omega
      have span := arraySpanRange_initials names values scalars
        ((binding names target).descriptor.address indices.lower)
        (indices.upper - indices.lower + 1).toNat
        (by simp only [Binding.descriptor, Integer.ArrayDescriptor.address]; omega)
        (by
          intro cell lower upper
          apply (covers_iff names cell).mpr
          refine ⟨binding names target, member, ?_⟩
          simp only [Integer.ArrayDescriptor.ContainsCell, Binding.descriptor,
            Integer.ArrayDescriptor.address, Integer.ArrayDescriptor.length] at *
          omega)
      have first : (binding names target).descriptor.address indices.lower - scalarLimit =
          elementSlot (binding names target) indices.lower := by rw [elementSlot_address]; omega
      have count : elementSlot (binding names target) indices.upper + 1 -
          elementSlot (binding names target) indices.lower = (indices.upper - indices.lower + 1).toNat := by
        simp only [elementSlot]; omega
      rw [first] at span
      simp only [Integer.arrayReadRange, checked, ↓reduceIte, span, Option.bind_some]
      have bounded := hullFrom_bounded valuesValid (elementSlot (binding names target) indices.lower)
        (indices.upper - indices.lower + 1).toNat
      have nonempty := hullFrom_nonempty values (elementSlot (binding names target) indices.lower) positive
      simp only [Integer.checked, nonempty, Bool.false_eq_true, ↓reduceIte, bounded,
        Integer.accepted, readBounds, hullModel, count]

theorem readBounds_integer_correspondence {names : Metadata} {values : Initials} {target : Nat}
    (valuesValid : ValidInitials values)
    (metadata : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : binding names target ∈ names)
    (itemValid : ValidBinding (binding names target))
    (kind : (binding names target).isBoolean = false) {indices : Integer.Interval}
    (inside : contains (binding names target) indices = true) (elaborating : Bool)
    (scalars : Integer.Ranges) :
    Integer.arrayReadRange (integerRanges names values elaborating scalars)
      (binding names target).descriptor indices = some (readBounds names values elaborating target indices) := by
  have selectedMember : binding names target ∈ integerNames names := mem_integerNames.mpr ⟨member, kind⟩
  have selectedMetadata := integerNames_validBindings metadata
  have selectedOrdered := integerNames_ordered ordered
  have checked : Integer.arrayIndexCheck (binding names target).descriptor indices = true := by
    rw [← contains_indexCheck itemValid]; exact inside
  cases elaborating with
  | false =>
      exact Integer.arrayReadRange_components checked
        (body_ranges_components selectedMetadata selectedOrdered selectedMember values scalars) (binding_component_valid itemValid)
  | true =>
      have bounds := inside
      simp only [contains, decide_eq_true_eq] at bounds
      have positive : 0 < (indices.upper - indices.lower + 1).toNat := by omega
      have span := arraySpanRange_initials (integerNames names) values scalars
        ((binding names target).descriptor.address indices.lower)
        (indices.upper - indices.lower + 1).toNat
        (by simp only [Binding.descriptor, Integer.ArrayDescriptor.address]; omega)
        (by
          intro cell lower upper
          apply (covers_iff (integerNames names) cell).mpr
          refine ⟨binding names target, selectedMember, ?_⟩
          simp only [Integer.ArrayDescriptor.ContainsCell, Binding.descriptor,
            Integer.ArrayDescriptor.address, Integer.ArrayDescriptor.length] at *
          omega)
      have first : (binding names target).descriptor.address indices.lower - scalarLimit =
          elementSlot (binding names target) indices.lower := by rw [elementSlot_address]; omega
      have count : elementSlot (binding names target) indices.upper + 1 -
          elementSlot (binding names target) indices.lower = (indices.upper - indices.lower + 1).toNat := by
        simp only [elementSlot]; omega
      rw [first] at span
      simp only [integerRanges, Integer.arrayReadRange, checked, ↓reduceIte, span, Option.bind_some]
      have bounded := hullFrom_bounded valuesValid (elementSlot (binding names target) indices.lower)
        (indices.upper - indices.lower + 1).toNat
      have nonempty := hullFrom_nonempty values (elementSlot (binding names target) indices.lower) positive
      simp only [Integer.checked, nonempty, Bool.false_eq_true, ↓reduceIte, bounded,
        Integer.accepted, readBounds, hullModel, count]

end Silver.ArrayBindings
