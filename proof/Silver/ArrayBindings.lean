module

public import Silver.IntegerArrays
public import Silver.NamedIdentifier

@[expose] public section

/-! Active array metadata and the native initialization table. Initials are a
finite zero-extended list: arbitrary native tables can use all 2048 entries,
while source elaboration maintains the canonical initialized prefix. -/
namespace Silver.ArrayBindings

def maxBindings : Nat := 4096 / 24
def maxElements : Nat := 4096 / 2
def scalarLimit : Nat := 4096 / 7

structure Binding where
  first : Nat
  after : Nat
  bounds : Integer.Interval
  offset : Nat
  length : Nat
  mutable : Bool
  componentBounds : Integer.Interval := .full
  deriving DecidableEq, Repr

abbrev Metadata := List Binding
abbrev Initials := List Int

structure Env where
  names : Metadata := []
  used : Nat := 0
  values : Initials := []
  deriving DecidableEq, Repr

def emptyBinding : Binding := ⟨0, 0, Integer.Interval.empty, 0, 0, false, .full⟩
def binding (names : Metadata) (index : Nat) : Binding := names.getD (index - 1) emptyBinding

def Binding.descriptor (item : Binding) : Integer.ArrayDescriptor :=
  ⟨scalarLimit + 1 + item.offset, item.bounds, item.componentBounds⟩

def initialValue (values : Initials) (slot : Nat) : Int := values.getD (slot - 1) 0

def putInitial (values : Initials) (slot : Nat) (value : Int) : Initials :=
  (List.range (max values.length slot)).map fun offset =>
    if offset + 1 = slot then value else values.getD offset 0

theorem putInitial_length (values : Initials) (slot : Nat) (value : Int) :
    (putInitial values slot value).length = max values.length slot := by
  simp [putInitial]

theorem initialValue_putInitial (values : Initials) (slot : Nat) (value : Int)
    {observed : Nat} (positive : 0 < observed) :
    initialValue (putInitial values slot value) observed =
      if observed = slot then value else initialValue values observed := by
  unfold initialValue putInitial
  by_cases inside : observed - 1 < max values.length slot
  · simp only [List.getD_eq_getElem?_getD, List.getElem?_map,
      List.getElem?_eq_getElem (by simpa using inside : observed - 1 < (List.range (max values.length slot)).length),
      List.getElem_range, Option.map_some, Option.getD_some]
    have next : observed - 1 + 1 = observed := by omega
    simp only [next]
  · have oldOutside : values.length ≤ observed - 1 := by omega
    have distinct : observed ≠ slot := by omega
    simp only [List.getD_eq_getElem?_getD, List.getElem?_map,
      List.getElem?_eq_none (by simpa using Nat.le_of_not_gt inside :
        (List.range (max values.length slot)).length ≤ observed - 1),
      Option.map_none, Option.getD_none, distinct, ↓reduceIte, List.getElem?_eq_none oldOutside]

theorem putInitial_append (values : Initials) (value : Int) :
    putInitial values (values.length + 1) value = values ++ [value] := by
  apply List.ext_getElem
  · simp [putInitial_length]
  · intro index leftBound rightBound
    simp only [putInitial, List.getElem_map, List.getElem_range]
    by_cases old : index < values.length
    · rw [List.getElem_append_left old]
      have different : index ≠ values.length := by omega
      simp [different, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem old]
    · have last : index = values.length := by simp only [List.length_append, List.length_singleton] at rightBound; omega
      subst index
      simp

def ValidBinding (item : Binding) : Prop :=
  item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper ∧
    0 < item.length ∧ item.offset + item.length ≤ maxElements ∧
    item.bounds.upper - item.bounds.lower = (item.length : Int) - 1 ∧
    item.componentBounds.Bounded ∧ item.componentBounds.lower ≤ item.componentBounds.upper

instance (item : Binding) : Decidable (ValidBinding item) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))

def ValidMetadata (text : Source) (names : Metadata) : Prop :=
  names.length ≤ maxBindings ∧
    (∀ item ∈ names, 0 < item.first ∧ item.first < item.after ∧
      item.after ≤ text.length + 1 ∧ ValidBinding item) ∧
    names.Pairwise (fun left right => left.offset + left.length ≤ right.offset)

def ValidInitials (values : Initials) : Prop :=
  values.length ≤ maxElements ∧ ∀ value ∈ values, Integer.InRange value

def ValidEnvironment (text : Source) (environment : Env) : Prop :=
  ValidMetadata text environment.names ∧ environment.used ≤ maxElements ∧
    ValidInitials environment.values ∧
    ∀ item ∈ environment.names, item.offset + item.length ≤ environment.used

/-- Exact initial values fit every declared component interval. This source
elaboration property is distinct from the native table's integer-value domain. -/
def InitialsFit (names : Metadata) (values : Initials) : Prop :=
  ∀ item ∈ names, item.componentBounds.Bounded ∧
    ∀ offset ∈ List.range item.descriptor.length,
      item.componentBounds.Contains (initialValue values (item.offset + 1 + offset))

instance (names : Metadata) (values : Initials) : Decidable (InitialsFit names values) :=
  inferInstanceAs (Decidable (∀ item ∈ names, _ ∧ ∀ offset ∈ List.range item.descriptor.length, _))

/-- Source elaboration additionally maintains a canonical table prefix and
exact values within each declared component subtype. -/
def SourceReady (text : Source) (environment : Env) : Prop :=
  ValidEnvironment text environment ∧ environment.values.length = environment.used ∧
    environment.names.Pairwise (fun left right => left.offset + left.length ≤ right.offset) ∧
    InitialsFit environment.names environment.values

def lookupFrom (text : Source) (names : Metadata) (first after : Nat) : Nat → Nat
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (binding names (index + 1)).first
          (binding names (index + 1)).after first after then index + 1
      else lookupFrom text names first after index

def lookup (text : Source) (names : Metadata) (first after : Nat) : Nat :=
  lookupFrom text names first after names.length

def contains (item : Binding) (indices : Integer.Interval) : Bool :=
  decide (indices.lower ≤ indices.upper ∧ item.bounds.lower ≤ indices.lower ∧
    indices.upper ≤ item.bounds.upper)

def elementSlot (item : Binding) (index : Int) : Nat :=
  item.offset + 1 + (index - item.bounds.lower).toNat

def hullFrom (values : Initials) (first : Nat) : Nat → Integer.Interval
  | 0 => Integer.Interval.empty
  | count + 1 => (hullFrom values first count).join
      (Integer.Interval.singleton (initialValue values (first + count)))

def hullModel (values : Initials) (first last : Nat) : Integer.Interval :=
  hullFrom values first (last + 1 - first)

def readBounds (names : Metadata) (values : Initials) (elaborating : Bool)
    (target : Nat) (indices : Integer.Interval) : Integer.Interval :=
  if elaborating then
    hullModel values (elementSlot (binding names target) indices.lower)
      (elementSlot (binding names target) indices.upper)
  else (binding names target).componentBounds

def covers (names : Metadata) (cell : Nat) : Bool :=
  names.any fun item => decide (item.descriptor.ContainsCell cell)

def componentRange (names : Metadata) (cell : Nat) : Integer.Interval :=
  match names.find? (fun item => decide (item.descriptor.ContainsCell cell)) with
  | some item => item.componentBounds.normalize
  | none => .full

def ranges (names : Metadata) (values : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) : Integer.Ranges := fun cell =>
  if covers names cell then some
    (if elaborating then Integer.Interval.singleton (initialValue values (cell - scalarLimit))
     else componentRange names cell)
  else scalars cell

def store (names : Metadata) (values : Initials) (scalars : Integer.Store) : Integer.Store := fun cell =>
  if covers names cell then initialValue values (cell - scalarLimit) else scalars cell

def mutability (names : Metadata) (scalars : Integer.Mutability) : Integer.Mutability := fun cell =>
  match names.find? (fun item => decide (item.descriptor.ContainsCell cell)) with
  | some item => item.mutable
  | none => scalars cell

def refinability (names : Metadata) (scalars : Integer.Mutability) : Integer.Mutability := fun cell =>
  if covers names cell then false else scalars cell

@[simp] theorem ranges_nil (values : Initials) (elaborating : Bool) (scalars : Integer.Ranges) :
    ranges [] values elaborating scalars = scalars := rfl

@[simp] theorem store_nil (values : Initials) (scalars : Integer.Store) :
    store [] values scalars = scalars := rfl

@[simp] theorem mutability_nil (scalars : Integer.Mutability) : mutability [] scalars = scalars := rfl

@[simp] theorem refinability_nil (scalars : Integer.Mutability) : refinability [] scalars = scalars := rfl

theorem binding_descriptor_valid {item : Binding} (valid : ValidBinding item) : item.descriptor.Valid :=
  ⟨valid.1, valid.2.1⟩

theorem binding_descriptor_length {item : Binding} (valid : ValidBinding item) :
    item.descriptor.length = item.length := by
  simp only [Binding.descriptor, Integer.ArrayDescriptor.length]
  have exactLength := valid.2.2.2.2.1
  omega

theorem binding_component_valid {item : Binding} (valid : ValidBinding item) :
    item.descriptor.ComponentValid := valid.2.2.2.2.2

theorem ordered_componentRange {names : Metadata} {item : Binding} {cell : Nat}
    (valid : ∀ entry ∈ names, ValidBinding entry)
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
          exact (valid head (by simp)).2.2.2.2.2.2
        simp only [componentRange, List.find?_cons, inside, decide_true,
          Integer.Interval.normalize, nonempty, Bool.false_eq_true, ↓reduceIte]
      · have separate := order.1 item member
        have headLength := binding_descriptor_length (valid head (by simp))
        have absent : ¬head.descriptor.ContainsCell cell := by
          intro contained
          simp only [Integer.ArrayDescriptor.ContainsCell] at contained inside
          rw [headLength] at contained
          dsimp only [Binding.descriptor] at contained inside
          omega
        have rest := ih (fun entry found => valid entry (by simp [found])) order.2 member
        simpa only [componentRange, List.find?_cons, absent, decide_false, Bool.false_eq_true, ↓reduceIte] using rest

theorem componentRange_bounded {names : Metadata} {values : Initials}
    (fits : InitialsFit names values) (cell : Nat) : (componentRange names cell).Bounded := by
  unfold componentRange
  cases found : names.find? (fun item => decide (item.descriptor.ContainsCell cell)) with
  | none => exact Integer.Interval.full_bounded
  | some item => exact Integer.Interval.normalize_bounded (fits item (List.mem_of_find?_eq_some found)).1

theorem componentRange_join_self (names : Metadata) (cell : Nat) :
    (componentRange names cell).join (componentRange names cell) = componentRange names cell := by
  unfold componentRange
  cases found : names.find? (fun item => decide (item.descriptor.ContainsCell cell)) with
  | none => decide +kernel
  | some item =>
      simp only [Integer.Interval.normalize]
      split
      · decide +kernel
      · rename_i present
        have nonempty : item.componentBounds.isEmpty = false := by simpa using present
        simp [Integer.Interval.join, nonempty]

theorem elementSlot_address (item : Binding) (index : Int) :
    item.descriptor.address index = scalarLimit + elementSlot item index := by
  simp only [Binding.descriptor, Integer.ArrayDescriptor.address, elementSlot]
  omega

theorem covers_iff (names : Metadata) (cell : Nat) :
    covers names cell = true ↔ ∃ item ∈ names, item.descriptor.ContainsCell cell := by
  simp [covers, List.any_eq_true]

theorem covers_scalar (names : Metadata) {cell : Nat} (low : cell ≤ scalarLimit) :
    covers names cell = false := by
  apply Bool.eq_false_iff.mpr
  intro covered
  obtain ⟨item, _, inside⟩ := (covers_iff names cell).mp covered
  simp only [Binding.descriptor, Integer.ArrayDescriptor.ContainsCell] at inside
  omega

theorem ranges_scalar (names : Metadata) (values : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) {cell : Nat} (low : cell ≤ scalarLimit) :
    ranges names values elaborating scalars cell = scalars cell := by
  simp only [ranges, covers_scalar names low, Bool.false_eq_true, ↓reduceIte]

theorem ranges_of_covered {names : Metadata} {cell : Nat} (covered : covers names cell = true)
    (values : Initials) (elaborating : Bool) (scalars : Integer.Ranges) :
    ranges names values elaborating scalars cell = some
      (if elaborating then Integer.Interval.singleton (initialValue values (cell - scalarLimit))
       else componentRange names cell) := by simp only [ranges, covered, ↓reduceIte]

theorem ranges_of_not_covered {names : Metadata} {cell : Nat} (absent : covers names cell = false)
    (values : Initials) (elaborating : Bool) (scalars : Integer.Ranges) :
    ranges names values elaborating scalars cell = scalars cell := by
  simp only [ranges, absent, Bool.false_eq_true, ↓reduceIte]

theorem ranges_put (names : Metadata) (values : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) {index : Nat} (low : index ≤ scalarLimit) (bounds : Option Integer.Interval) :
    ranges names values elaborating (Integer.put scalars index bounds) =
      Integer.put (ranges names values elaborating scalars) index bounds := by
  funext cell
  by_cases same : cell = index
  · subst cell
    simp only [ranges_scalar names values elaborating _ low, Integer.put, ↓reduceIte]
  · simp only [ranges, Integer.put, same, ↓reduceIte]

theorem ranges_idempotent (names : Metadata) (values : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) :
    ranges names values elaborating (ranges names values elaborating scalars) =
      ranges names values elaborating scalars := by
  funext cell
  simp only [ranges]
  split <;> rfl

theorem store_scalar (names : Metadata) (values : Initials) (scalars : Integer.Store)
    {cell : Nat} (low : cell ≤ scalarLimit) : store names values scalars cell = scalars cell := by
  simp only [store, covers_scalar names low, Bool.false_eq_true, ↓reduceIte]

theorem store_put (names : Metadata) (values : Initials) (scalars : Integer.Store)
    {index : Nat} (low : index ≤ scalarLimit) (value : Int) :
    store names values (Integer.put scalars index value) =
      Integer.put (store names values scalars) index value := by
  funext cell
  by_cases same : cell = index
  · subst cell
    simp only [store_scalar names values _ low, Integer.put, ↓reduceIte]
  · simp only [store, Integer.put, same, ↓reduceIte]

theorem mutability_of_not_covered {names : Metadata} {cell : Nat} (absent : covers names cell = false)
    (scalars : Integer.Mutability) : mutability names scalars cell = scalars cell := by
  have missing : names.find? (fun item => decide (item.descriptor.ContainsCell cell)) = none := by
    apply List.find?_eq_none.mpr
    intro item member covered
    have present := (covers_iff names cell).mpr ⟨item, member, of_decide_eq_true covered⟩
    simp only [absent, Bool.false_eq_true] at present
  simp only [mutability, missing]

theorem mutability_scalar (names : Metadata) (scalars : Integer.Mutability)
    {cell : Nat} (low : cell ≤ scalarLimit) : mutability names scalars cell = scalars cell :=
  mutability_of_not_covered (covers_scalar names low) scalars

theorem refinability_scalar (names : Metadata) (scalars : Integer.Mutability)
    {cell : Nat} (low : cell ≤ scalarLimit) : refinability names scalars cell = scalars cell := by
  simp only [refinability, covers_scalar names low, Bool.false_eq_true, ↓reduceIte]

theorem mutability_put (names : Metadata) (scalars : Integer.Mutability)
    {index : Nat} (low : index ≤ scalarLimit) (value : Bool) :
    mutability names (Integer.put scalars index value) =
      Integer.put (mutability names scalars) index value := by
  funext cell
  by_cases same : cell = index
  · subst cell
    simp only [mutability_scalar names _ low, Integer.put, ↓reduceIte]
  · simp only [mutability, Integer.put, same, ↓reduceIte]

theorem refinability_put (names : Metadata) (scalars : Integer.Mutability)
    {index : Nat} (low : index ≤ scalarLimit) (value : Bool) :
    refinability names (Integer.put scalars index value) =
      Integer.put (refinability names scalars) index value := by
  funext cell
  by_cases same : cell = index
  · subst cell
    simp only [refinability_scalar names _ low, Integer.put, ↓reduceIte]
  · simp only [refinability, Integer.put, same, ↓reduceIte]

theorem initial_ranges_fits (names : Metadata) (values : Initials)
    {rangesBefore : Integer.Ranges} {valuesBefore : Integer.Store}
    (fits : Integer.Fits rangesBefore valuesBefore) :
    Integer.Fits (ranges names values true rangesBefore) (store names values valuesBefore) := by
  intro cell bounds found
  unfold ranges at found
  unfold store
  split at found
  · rename_i covered
    simp only [covered, ↓reduceIte, Option.some.injEq] at found ⊢
    subst bounds
    exact (Integer.Interval.singleton_contains _ _).mpr rfl
  · rename_i absent
    simp only [absent]
    exact fits cell bounds found

theorem initialValue_inRange {values : Initials} (valid : ValidInitials values) (slot : Nat) :
    Integer.InRange (initialValue values slot) := by
  unfold initialValue
  simp only [List.getD_eq_getElem?_getD]
  cases found : values[slot - 1]? with
  | none => decide +kernel
  | some value => exact valid.2 value (List.mem_of_getElem? found)

theorem body_ranges_fits (names : Metadata) {values : Initials} (initials : InitialsFit names values)
    {rangesBefore : Integer.Ranges} {valuesBefore : Integer.Store}
    (fits : Integer.Fits rangesBefore valuesBefore) :
    Integer.Fits (ranges names values false rangesBefore) (store names values valuesBefore) := by
  intro cell bounds found
  unfold ranges at found
  unfold store
  split at found
  · rename_i covered
    simp only [Bool.false_eq_true, ↓reduceIte, Option.some.injEq] at found
    subst bounds
    simp only [covered, ↓reduceIte]
    unfold componentRange
    cases selected : names.find? (fun item => decide (item.descriptor.ContainsCell cell)) with
    | none =>
        have missing := List.find?_eq_none.mp selected
        obtain ⟨item, member, inside⟩ := (covers_iff names cell).mp covered
        have impossible := missing item member
        exact False.elim (impossible (by simp only [inside, decide_true]))
    | some item =>
        have member := List.mem_of_find?_eq_some selected
        have inside : item.descriptor.ContainsCell cell := by
          have foundTrue := List.find?_some (p := fun (entry : Binding) => decide (entry.descriptor.ContainsCell cell)) selected
          exact of_decide_eq_true foundTrue
        have offset : cell - item.descriptor.base < item.descriptor.length := by
          simp only [Integer.ArrayDescriptor.ContainsCell] at inside
          omega
        have cellEq : item.offset + 1 + (cell - item.descriptor.base) = cell - scalarLimit := by
          simp only [Integer.ArrayDescriptor.ContainsCell, Binding.descriptor] at inside ⊢
          omega
        apply Integer.Interval.normalize_contains
        simpa only [cellEq] using (initials item member).2
          (cell - item.descriptor.base) (List.mem_range.mpr offset)
  · rename_i absent
    simp only [absent]
    exact fits cell bounds found

theorem body_ranges_components {names : Metadata} {item : Binding}
    (valid : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : item ∈ names) (values : Initials) (scalars : Integer.Ranges) :
    item.descriptor.ComponentRanges (ranges names values false scalars) := by
  intro index inside
  have atCell := item.descriptor.address_within inside
  have covered := (covers_iff names _).mpr ⟨item, member, atCell⟩
  change ranges names values false scalars (item.descriptor.address index) = some item.componentBounds
  simp only [ranges, covered, ↓reduceIte, Bool.false_eq_true,
    ordered_componentRange valid ordered member atCell]

end Silver.ArrayBindings
