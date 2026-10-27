module

public import Silver.IntegerChecks

@[expose] public section

/-! Array elaboration and indexed mutation on the shared Integer store. Exact
initializer ranges and body Full ranges are explicit state transformations.
The source layer owns allocation, mutability and scalar/index separation. -/
namespace Silver.Integer

namespace ArrayDescriptor

def initialRanges (array : ArrayDescriptor) (ranges : Ranges) (items : List Int) : Ranges :=
  fun cell => if array.base ≤ cell ∧ cell - array.base < items.length
    then some (Interval.singleton items[cell - array.base]!) else ranges cell

theorem initialRanges_fits (array : ArrayDescriptor) {ranges : Ranges} {values : Store}
    (fits : Integer.Fits ranges values) (items : List Int) :
    Integer.Fits (array.initialRanges ranges items) (array.initializeValues values items) := by
  intro cell bounds found
  unfold initialRanges at found
  unfold initializeValues
  split at found
  · rename_i inside
    simp only [inside, Option.some.injEq] at found ⊢
    subst bounds
    exact (Interval.singleton_contains _ _).mpr rfl
  · rename_i outside
    simp only [outside, ↓reduceIte]
    exact fits cell bounds found

def bodyRanges (array : ArrayDescriptor) (ranges : Ranges) : Ranges :=
  fun cell => if array.ContainsCell cell then some Interval.full else ranges cell

theorem bodyRanges_fits {array : ArrayDescriptor} {ranges : Ranges} {values : Store}
    (fits : Integer.Fits ranges values) (arrayFits : array.Fits values) :
    Integer.Fits (array.bodyRanges ranges) values := by
  intro cell bounds found
  unfold bodyRanges at found
  split at found
  · rename_i inside
    simp only [Option.some.injEq] at found
    subst bounds
    have offsetBound : cell - array.base < array.length := by
      simp only [ContainsCell] at inside
      omega
    have safe := arrayFits (array.bounds.lower + ((cell - array.base : Nat) : Int)) (offset_within offsetBound)
    have cellEq : array.base + (cell - array.base) = cell := by
      simp only [ContainsCell] at inside
      omega
    simpa only [project, address_offset, cellEq, Interval.full_contains] using safe
  · exact fits cell bounds found

def FullRanges (array : ArrayDescriptor) (ranges : Ranges) : Prop :=
  ∀ index, array.bounds.Contains index → ranges (array.address index) = some Interval.full

def allCells (array : ArrayDescriptor) (predicate : Nat → Bool) : Bool :=
  (List.range array.length).all fun offset => predicate (array.base + offset)

theorem allCells_iff (array : ArrayDescriptor) (predicate : Nat → Bool) :
    array.allCells predicate = true ↔
      ∀ cell, array.ContainsCell cell → predicate cell = true := by
  simp only [allCells, List.all_eq_true, List.mem_range]
  constructor
  · intro all cell inside
    have within : cell - array.base < array.length := by
      simp only [ContainsCell] at inside
      omega
    have same : array.base + (cell - array.base) = cell := by
      simp only [ContainsCell] at inside
      omega
    simpa only [same] using all (cell - array.base) within
  · intro all offset inside
    exact all (array.base + offset) (by simp only [ContainsCell]; omega)

def fullRanges (array : ArrayDescriptor) (ranges : Ranges) : Bool :=
  array.allCells fun cell => decide (ranges cell = some Interval.full)

theorem fullRanges_iff (array : ArrayDescriptor) (ranges : Ranges) :
    array.fullRanges ranges = true ↔ array.FullRanges ranges := by
  simp only [fullRanges, allCells_iff, decide_eq_true_eq, FullRanges]
  constructor
  · intro full index inside
    exact full _ (address_within inside)
  · intro full cell inside
    have offsetBound : cell - array.base < array.length := by
      simp only [ContainsCell] at inside
      omega
    have same : array.base + (cell - array.base) = cell := by
      simp only [ContainsCell] at inside
      omega
    simpa only [address_offset, same] using
      full (array.bounds.lower + ((cell - array.base : Nat) : Int)) (offset_within offsetBound)

theorem bodyRanges_full (array : ArrayDescriptor) (ranges : Ranges) :
    array.FullRanges (array.bodyRanges ranges) := by
  intro index inside
  simp only [bodyRanges, address_within inside, ↓reduceIte]

theorem initialize_preserves_other {array other : ArrayDescriptor} {values : Store}
    {items : List Int} {index : Int} (count : items.length = array.length)
    (apart : other.Disjoint array) (inside : other.bounds.Contains index) :
    other.project (array.initializeValues values items) index = other.project values index := by
  have atCell := other.address_within inside
  have outside : ¬ (array.base ≤ other.address index ∧
      other.address index - array.base < items.length) := by
    simp only [Disjoint, ContainsCell] at *
    omega
  simp only [project, initializeValues, outside, ↓reduceIte]

theorem write_preserves_ranges {array : ArrayDescriptor} {ranges : Ranges} {values : Store}
    {index value : Int} (fits : Integer.Fits ranges values) (full : array.FullRanges ranges)
    (inside : array.bounds.Contains index) (safe : InRange value) :
    Integer.Fits ranges (array.write values index value) := by
  intro cell bounds found
  by_cases same : cell = array.address index
  · subst cell
    rw [full index inside] at found
    cases found
    simpa only [write, ↓reduceIte, Interval.full_contains] using safe
  · simpa only [write, same, ↓reduceIte] using fits cell bounds found

end ArrayDescriptor

theorem arraySpanRange_full {ranges : Ranges} {first count : Nat} (nonempty : 0 < count)
    (full : ∀ offset, offset < count → ranges (first + offset) = some Interval.full) :
    arraySpanRange ranges first count = some Interval.full := by
  induction count generalizing first with
  | zero => omega
  | succ count ih =>
      have head := full 0 (by omega)
      simp only [Nat.add_zero] at head
      cases count with
      | zero => simp only [arraySpanRange, head, Option.bind_some, Option.map_some]; decide +kernel
      | succ count =>
          have tail : arraySpanRange ranges (first + 1) (count + 1) = some Interval.full := by
            apply ih (by omega)
            intro offset inside
            simpa only [Nat.add_assoc, Nat.add_comm 1] using full (offset + 1) (by omega)
          rw [arraySpanRange, head, Option.bind_some, tail, Option.map_some]
          decide +kernel

theorem arrayReadRange_full {ranges : Ranges} {array : ArrayDescriptor} {indices : Interval}
    (checked : arrayIndexCheck array indices = true) (full : array.FullRanges ranges) :
    arrayReadRange ranges array indices = some Interval.full := by
  have ready := checked
  simp only [arrayIndexCheck, decide_eq_true_eq] at ready
  have positive : 0 < (indices.upper - indices.lower + 1).toNat := by omega
  have span : arraySpanRange ranges (array.address indices.lower)
      (indices.upper - indices.lower + 1).toNat = some Interval.full := by
    apply arraySpanRange_full positive
    intro offset inside
    have indexInside : array.bounds.Contains (indices.lower + (offset : Int)) := by
      simp only [Interval.Contains]
      omega
    have addressEq : array.address (indices.lower + (offset : Int)) =
        array.address indices.lower + offset := by
      simp only [ArrayDescriptor.address]
      omega
    rw [← addressEq]
    exact full _ indexInside
  simp only [arrayReadRange, checked, ↓reduceIte, span, Option.bind_some]
  decide +kernel

theorem arrayReadRange_singleton {ranges : Ranges} {array : ArrayDescriptor} {index value : Int}
    (valid : array.Valid) (inside : array.bounds.Contains index) (safe : InRange value)
    (present : ranges (array.address index) = some (Interval.singleton value)) :
    arrayReadRange ranges array (Interval.singleton index) = some (Interval.singleton value) := by
  have indexCheck : arrayIndexCheck array (Interval.singleton index) = true := by
    unfold arrayIndexCheck
    apply decide_eq_true
    exact ⟨valid, Int.le_refl _, inside.1, inside.2⟩
  have joined : (Interval.singleton value).join Interval.empty = Interval.singleton value := by
    simp [Interval.join, Interval.isEmpty, Interval.singleton, Interval.empty]
  have span : arraySpanRange ranges (array.address index) 1 = some (Interval.singleton value) := by
    simp only [arraySpanRange, present, Option.bind_some, Option.map_some]
    exact congrArg some joined
  have bounded : (Interval.singleton value).Bounded := ⟨safe, safe⟩
  have nonempty : (Interval.singleton value).isEmpty = false := by
    simp [Interval.isEmpty, Interval.singleton]
  unfold arrayReadRange
  rw [indexCheck]
  simp only [↓reduceIte, Interval.singleton, Int.sub_self, Int.zero_add, Int.toNat_one]
  rw [span, Option.bind_some]
  change accepted (checked (Interval.singleton value)) = some (Interval.singleton value)
  simp only [accepted, checked, nonempty, Bool.false_eq_true, ↓reduceIte, bounded]

/-- Each component has an exact elaboration value; all original expressions
are checked in the same incoming store, before the new object is introduced. -/
def arrayInitialValues (ranges : Ranges) : List Expr → Option (List Int)
  | [] => some []
  | expression :: rest => (expression.infer ranges).bind fun bounds =>
      if bounds.lower = bounds.upper then
        (arrayInitialValues ranges rest).map fun values => bounds.lower :: values
      else none

theorem arrayInitialValues_sound {ranges : Ranges} {values : Store}
    {expressions : List Expr} {items : List Int}
    (checked : arrayInitialValues ranges expressions = some items) (fits : Fits ranges values) :
    items = expressions.map (Expr.evaluate values) ∧
      (∀ expression ∈ expressions, expression.Safe values) ∧
      (∀ value ∈ items, InRange value) := by
  induction expressions generalizing items with
  | nil =>
      simp only [arrayInitialValues, Option.some.injEq] at checked
      subst items
      simp
  | cons expression rest ih =>
      simp only [arrayInitialValues, Option.bind_eq_some_iff] at checked
      obtain ⟨bounds, inferred, checked⟩ := checked
      split at checked
      · rename_i exactValue
        simp only [Option.map_eq_some_iff] at checked
        obtain ⟨tail, tailChecked, rfl⟩ := checked
        have first := Expr.infer_sound inferred fits
        have equal : bounds.lower = expression.evaluate values := by
          have within := first.1
          simp only [Interval.Contains] at within
          omega
        have following := ih tailChecked
        refine ⟨by simp only [List.map_cons, equal, following.1], ?_, ?_⟩
        · intro item present
          rcases List.mem_cons.mp present with rfl | present
          · exact first.2
          · exact following.2.1 item present
        · intro item present
          rcases List.mem_cons.mp present with rfl | present
          · rw [equal]; exact Expr.safe_value first.2
          · exact following.2.2 item present
      · contradiction

structure ArrayDeclaration where
  array : ArrayDescriptor
  values : List Expr
  deriving DecidableEq, Repr

def ArrayDeclaration.check (ranges : Ranges) (declaration : ArrayDeclaration) : Option (List Int) :=
  if declaration.array.Valid ∧ declaration.values.length = declaration.array.length
  then arrayInitialValues ranges declaration.values else none

def ArrayDeclaration.execute (values : Store) (declaration : ArrayDeclaration) : Store :=
  declaration.array.initializeValues values (declaration.values.map (Expr.evaluate values))

theorem ArrayDeclaration.check_sound {ranges : Ranges} {values : Store}
    {declaration : ArrayDeclaration} {items : List Int}
    (checked : declaration.check ranges = some items) (fits : Fits ranges values) :
    declaration.array.Valid ∧ items.length = declaration.array.length ∧
      items = declaration.values.map (Expr.evaluate values) ∧
      (∀ expression ∈ declaration.values, expression.Safe values) ∧
      declaration.array.Fits (declaration.execute values) ∧
      Fits (declaration.array.initialRanges ranges items) (declaration.execute values) := by
  unfold check at checked
  split at checked
  · rename_i ready
    obtain ⟨same, safe, itemSafe⟩ := arrayInitialValues_sound checked fits
    have count : items.length = declaration.array.length := by rw [same, List.length_map]; exact ready.2
    refine ⟨ready.1, count, same, safe, ?_, ?_⟩
    · simpa only [execute, ← same] using declaration.array.initialize_fits (values := values) count itemSafe
    · simpa only [execute, ← same] using declaration.array.initialRanges_fits fits items
  · contradiction

structure ArrayAssignment where
  array : ArrayDescriptor
  index : Expr
  value : Expr
  deriving DecidableEq, Repr

def ArrayAssignment.check (ranges : Ranges) (mutable : Mutability) (update : ArrayAssignment) : Bool :=
  update.array.fullRanges ranges && (update.array.allCells mutable &&
    match update.index.infer ranges, update.value.infer ranges with
    | some indices, some values => arrayIndexCheck update.array indices && !values.isEmpty
    | _, _ => false)

/-- Outside the safe domain, use identity as the mathematical totalization.
Checked execution still rejects the invalid index; admitted execution always
uses the actual single-component write. -/
def ArrayAssignment.execute (values : Store) (update : ArrayAssignment) : Store :=
  if update.array.bounds.Contains (update.index.evaluate values) then
    update.array.write values (update.index.evaluate values) (update.value.evaluate values)
  else values

def ArrayAssignment.checkedExecute (values : Store) (update : ArrayAssignment) : Option Store :=
  (update.index.checkedEvaluate values).bind fun index =>
    if update.array.bounds.Contains index then
      (update.value.checkedEvaluate values).map fun value => update.array.write values index value
    else none

theorem ArrayAssignment.check_sound {ranges : Ranges} {values : Store}
    {mutable : Mutability} {update : ArrayAssignment}
    (checked : update.check ranges mutable = true) (fits : Fits ranges values) :
    update.index.Safe values ∧ update.value.Safe values ∧
      update.array.bounds.Contains (update.index.evaluate values) ∧
      Fits ranges (update.execute values) ∧
      update.checkedExecute values = some (update.execute values) := by
  simp only [check, Bool.and_eq_true] at checked
  have full := (ArrayDescriptor.fullRanges_iff _ _).mp checked.1
  have accepted := checked.2.2
  split at accepted
  · rename_i indices results indexKnown valueKnown
    simp only [Bool.and_eq_true, arrayIndexCheck, decide_eq_true_eq] at accepted
    have indexSound := Expr.infer_sound indexKnown fits
    have valueSound := Expr.infer_sound valueKnown fits
    have within : update.array.bounds.Contains (update.index.evaluate values) := by
      have inIndices := indexSound.1
      simp only [Interval.Contains] at *
      omega
    refine ⟨indexSound.2, valueSound.2, within, ?_, ?_⟩
    · simpa only [execute, within, ↓reduceIte] using
        update.array.write_preserves_ranges fits full within (Expr.safe_value valueSound.2)
    · simp only [checkedExecute, Expr.checkedEvaluate_agrees indexSound.2,
        Option.bind_some, Expr.checkedEvaluate_agrees valueSound.2,
        Option.map_some, execute, within, ↓reduceIte]
  · contradiction

theorem ArrayAssignment.unchanged_scalar {update : ArrayAssignment} {values : Store}
    {scalar limit : Nat} (reserved : limit < update.array.base) (bounded : scalar ≤ limit) :
    update.execute values scalar = values scalar := by
  unfold execute
  split
  · exact ArrayDescriptor.write_preserves_scalar reserved bounded
  · rfl

theorem ArrayAssignment.unchanged {update : ArrayAssignment} {ranges : Ranges}
    {mutable : Mutability} {values : Store} {cell : Nat}
    (checked : update.check ranges mutable = true) (readonly : mutable cell = false) :
    update.execute values cell = values cell := by
  simp only [check, Bool.and_eq_true] at checked
  have writable := (ArrayDescriptor.allCells_iff _ _).mp checked.2.1
  unfold execute
  split
  · rename_i inside
    have different : cell ≠ update.array.address (update.index.evaluate values) := by
      intro same
      have changed := writable _ (update.array.address_within inside)
      rw [← same, readonly] at changed
      contradiction
    simp only [ArrayDescriptor.write, different, ↓reduceIte]
  · rfl

def ArrayAssignment.obligations (ranges : Ranges) (update : ArrayAssignment) : List Obligation :=
  update.index.obligations ranges ++ update.value.obligations ranges ++
    [unaryObligation (Obligation.arrayIndex update.array) (update.index.infer ranges)]

theorem ArrayAssignment.obligations_discharge {ranges : Ranges} {mutable : Mutability}
    {update : ArrayAssignment} (checked : update.check ranges mutable = true) :
    discharged (update.obligations ranges) = true := by
  simp only [check, Bool.and_eq_true] at checked
  have good := checked.2.2
  split at good
  · rename_i indices values indexKnown valueKnown
    simp only [Bool.and_eq_true] at good
    rw [obligations, discharged_append, discharged_append,
      Expr.obligations_discharge indexKnown, Expr.obligations_discharge valueKnown]
    simp [indexKnown, unaryObligation, discharged, Obligation.discharge, good.1]
  · contradiction

def ArrayDeclaration.obligations (ranges : Ranges) (declaration : ArrayDeclaration) : List Obligation :=
  declaration.values.flatMap (Expr.obligations ranges) ++
    [.arrayIndex declaration.array declaration.array.bounds,
      .arrayLength declaration.values.length declaration.array.length]

theorem arrayInitialValues_obligations {ranges : Ranges} {expressions : List Expr} {items : List Int}
    (checked : arrayInitialValues ranges expressions = some items) :
    discharged (expressions.flatMap (Expr.obligations ranges)) = true := by
  induction expressions generalizing items with
  | nil => rfl
  | cons expression rest ih =>
      simp only [arrayInitialValues, Option.bind_eq_some_iff] at checked
      obtain ⟨bounds, inferred, tail⟩ := checked
      split at tail
      · simp only [Option.map_eq_some_iff] at tail
        obtain ⟨remaining, checkedRest, _⟩ := tail
        simp only [List.flatMap_cons, discharged_append, Expr.obligations_discharge inferred,
          ih checkedRest, Bool.and_self]
      · contradiction

theorem ArrayDeclaration.obligations_discharge {ranges : Ranges} {declaration : ArrayDeclaration}
    {items : List Int} (checked : declaration.check ranges = some items) :
    discharged (declaration.obligations ranges) = true := by
  unfold check at checked
  split at checked
  · rename_i ready
    have indexCheck : arrayIndexCheck declaration.array declaration.array.bounds = true := by
      simp only [arrayIndexCheck, decide_eq_true_eq]
      exact ⟨ready.1, ready.1.2, Int.le_refl _, Int.le_refl _⟩
    rw [obligations, discharged_append, arrayInitialValues_obligations checked]
    simp [discharged, Obligation.discharge, indexCheck, ready.2]
  · contradiction

end Silver.Integer
