module

public import Silver.IntegerArrays
public import Silver.NamedIdentifier
public import Silver.BooleanArrays
public import Silver.BooleanBindings

@[expose] public section

/-! Active array metadata and the native initialization table. Initials are a
finite zero-extended list: arbitrary native tables can use all 2048 entries,
while source elaboration maintains the canonical initialized prefix. -/
namespace Silver.ArrayBindings

def maxBindings : Nat := 4096 / 7
def maxTypes : Nat := 4096 / 24
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
  isBoolean : Bool := false
  typeId : Nat := 0
  viewSlot : Nat := 0
  deriving DecidableEq, Repr

abbrev Metadata := List Binding
abbrev Initials := List Int

structure ArrayType where
  first : Nat
  after : Nat
  bounds : Integer.Interval
  componentBounds : Integer.Interval
  deriving DecidableEq, Repr

abbrev TypeEnvironment := List ArrayType

/-- The active native metadata prefixes. `Metadata` is the item projection;
the type prefix remains explicit at every native metadata boundary. -/
structure Table where
  items : Metadata := []
  types : TypeEnvironment := []
  deriving DecidableEq, Repr

structure Env where
  names : Metadata := []
  used : Nat := 0
  values : Initials := []
  types : TypeEnvironment := []
  deriving DecidableEq, Repr

def emptyBinding : Binding := ⟨0, 0, Integer.Interval.empty, 0, 0, false, .full, false, 0, 0⟩
def binding (names : Metadata) (index : Nat) : Binding := names.getD (index - 1) emptyBinding

def emptyType : ArrayType := ⟨0, 0, .empty, .empty⟩
def arrayType (types : TypeEnvironment) (index : Nat) : ArrayType :=
  types.getD (index - 1) emptyType

def Env.table (environment : Env) : Table :=
  { items := environment.names, types := environment.types }

def Binding.descriptor (item : Binding) : Integer.ArrayDescriptor :=
  ⟨scalarLimit + 1 + item.offset, item.bounds, item.componentBounds⟩

/-- Symbolic formals have disjoint semantic cells and never read native pool
values. Slot zero selects the existing stored-object layout. -/
def Binding.viewDescriptor (item : Binding) : Integer.ArrayDescriptor :=
  if item.viewSlot = 0 then item.descriptor
  else ⟨scalarLimit + 1 + item.viewSlot * maxElements, item.bounds, item.componentBounds⟩

@[simp] theorem Binding.viewDescriptor_stored (item : Binding) (stored : item.viewSlot = 0) :
    item.viewDescriptor = item.descriptor := by simp [Binding.viewDescriptor, stored]

def Binding.booleanDescriptor (item : Binding) : Boolean.ArrayDescriptor :=
  ⟨BooleanBindings.maxBindings + 1 + item.offset, item.bounds⟩

/-- Filtering is used only for typed semantic projections. Native lookup and
source target identities always use the full shared metadata list. -/
def integerNames (names : Metadata) : Metadata := names.filter fun item => !item.isBoolean

def booleanNames (names : Metadata) : Metadata := names.filter (·.isBoolean)

@[simp] theorem integerNames_append_boolean (names : Metadata) {item : Binding}
    (kind : item.isBoolean = true) : integerNames (names ++ [item]) = integerNames names := by
  simp [integerNames, kind]

@[simp] theorem integerNames_append_integer (names : Metadata) {item : Binding}
    (kind : item.isBoolean = false) : integerNames (names ++ [item]) = integerNames names ++ [item] := by
  simp [integerNames, kind]

@[simp] theorem booleanNames_append_integer (names : Metadata) {item : Binding}
    (kind : item.isBoolean = false) : booleanNames (names ++ [item]) = booleanNames names := by
  simp [booleanNames, kind]

@[simp] theorem booleanNames_append_boolean (names : Metadata) {item : Binding}
    (kind : item.isBoolean = true) : booleanNames (names ++ [item]) = booleanNames names ++ [item] := by
  simp [booleanNames, kind]

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

@[simp] theorem mem_integerNames {names : Metadata} {item : Binding} :
    item ∈ integerNames names ↔ item ∈ names ∧ item.isBoolean = false := by
  simp [integerNames]

@[simp] theorem mem_booleanNames {names : Metadata} {item : Binding} :
    item ∈ booleanNames names ↔ item ∈ names ∧ item.isBoolean = true := by
  simp [booleanNames]

theorem integerNames_validBindings {names : Metadata}
    (valid : ∀ item ∈ names, ValidBinding item) :
    ∀ item ∈ integerNames names, ValidBinding item := by
  intro item member
  exact valid item (mem_integerNames.mp member).1

theorem integerNames_ordered {names : Metadata}
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset)) :
    (integerNames names).Pairwise (fun left right => left.offset + left.length ≤ right.offset) := by
  exact List.Pairwise.filter (fun (item : Binding) => !item.isBoolean) ordered

theorem integerNames_initialsFit {names : Metadata} {values : Initials}
    (ready : InitialsFit names values) : InitialsFit (integerNames names) values := by
  intro item member
  exact ready item (mem_integerNames.mp member).1

theorem integerNames_validMetadata {text : Source} {names : Metadata}
    (valid : ValidMetadata text names) : ValidMetadata text (integerNames names) := by
  refine ⟨Nat.le_trans (List.length_filter_le (fun (item : Binding) => !item.isBoolean) names)
    valid.1, ?_, integerNames_ordered valid.2.2⟩
  intro item member
  exact valid.2.1 item (mem_integerNames.mp member).1

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

def readViewBounds (names : Metadata) (values : Initials) (elaborating : Bool)
    (target : Nat) (indices : Integer.Interval) : Integer.Interval :=
  readBounds names values (elaborating && decide ((binding names target).viewSlot = 0)) target indices

@[simp] theorem readViewBounds_stored (names : Metadata) (values : Initials) (elaborating : Bool)
    (target : Nat) (indices : Integer.Interval) (stored : (binding names target).viewSlot = 0) :
    readViewBounds names values elaborating target indices = readBounds names values elaborating target indices := by
  simp [readViewBounds, stored]

theorem readViewBounds_formal (names : Metadata) (values : Initials) (elaborating : Bool)
    (target : Nat) (indices : Integer.Interval) (formal : (binding names target).viewSlot ≠ 0) :
    readViewBounds names values elaborating target indices = (binding names target).componentBounds := by
  simp [readViewBounds, readBounds, formal]

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

def integerRanges (names : Metadata) (values : Initials) (elaborating : Bool)
    (scalars : Integer.Ranges) : Integer.Ranges :=
  ranges (integerNames names) values elaborating scalars

def integerStore (names : Metadata) (values : Initials) (scalars : Integer.Store) : Integer.Store :=
  store (integerNames names) values scalars

def integerMutability (names : Metadata) (scalars : Integer.Mutability) : Integer.Mutability :=
  mutability (integerNames names) scalars

def integerRefinability (names : Metadata) (scalars : Integer.Mutability) : Integer.Mutability :=
  refinability (integerNames names) scalars

def booleanAnalysis (names : Metadata) (scalars : Boolean.Analysis) : Boolean.Analysis :=
  { initialized := fun cell =>
      (booleanNames names).any (fun item => decide (item.booleanDescriptor.ContainsCell cell)) ||
        scalars.initialized cell
    mutable := fun cell =>
      match (booleanNames names).find? (fun item => decide (item.booleanDescriptor.ContainsCell cell)) with
      | some item => item.mutable
      | none => scalars.mutable cell }

theorem booleanDescriptor_preserves_scalar (item : Binding) {scalar : Nat}
    (bounded : scalar ≤ BooleanBindings.maxBindings) :
    ¬ item.booleanDescriptor.ContainsCell scalar := by
  simp only [Boolean.ArrayDescriptor.ContainsCell, Boolean.ArrayDescriptor.layout,
    Integer.ArrayDescriptor.ContainsCell, Binding.booleanDescriptor]
  omega

theorem booleanAnalysis_scalar (names : Metadata) (scalars : Boolean.Analysis) {scalar : Nat}
    (bounded : scalar ≤ BooleanBindings.maxBindings) :
    (booleanAnalysis names scalars).initialized scalar = scalars.initialized scalar ∧
      (booleanAnalysis names scalars).mutable scalar = scalars.mutable scalar := by
  have absent : ∀ item ∈ booleanNames names,
      decide (item.booleanDescriptor.ContainsCell scalar) = false := by
    intro item _
    exact decide_eq_false (booleanDescriptor_preserves_scalar item bounded)
  have noAny : (booleanNames names).any
      (fun item => decide (item.booleanDescriptor.ContainsCell scalar)) = false := by
    apply List.any_eq_false.mpr
    intro item member
    simp [absent item member]
  have noFind : (booleanNames names).find?
      (fun item => decide (item.booleanDescriptor.ContainsCell scalar)) = none := by
    apply List.find?_eq_none.mpr
    intro item member
    simp [absent item member]
  simp [booleanAnalysis, noAny, noFind]

theorem booleanAnalysis_canWrite_scalar (names : Metadata) (scalars : Boolean.Analysis) {scalar : Nat}
    (bounded : scalar ≤ BooleanBindings.maxBindings) :
    (booleanAnalysis names scalars).canWrite scalar = scalars.canWrite scalar := by
  simp only [Boolean.Analysis.canWrite, (booleanAnalysis_scalar names scalars bounded).1,
    (booleanAnalysis_scalar names scalars bounded).2]

theorem booleanAnalysis_initialize_scalar (names : Metadata) (scalars : Boolean.Analysis)
    {index : Nat} (bounded : index ≤ BooleanBindings.maxBindings) (mutable : Bool) :
    booleanAnalysis names (scalars.initialize index mutable) =
      (booleanAnalysis names scalars).initialize index mutable := by
  have atIndex := booleanAnalysis_scalar names (scalars.initialize index mutable) bounded
  unfold Boolean.Analysis.initialize at atIndex
  unfold booleanAnalysis Boolean.Analysis.initialize
  congr 1 <;> funext cell <;> by_cases same : cell = index
  · subst cell
    simpa only [booleanAnalysis, ↓reduceIte] using atIndex.1
  · simp only [same, ↓reduceIte]
  · subst cell
    simpa only [booleanAnalysis, ↓reduceIte] using atIndex.2
  · simp only [same, ↓reduceIte]

theorem booleanAnalysis_append_scalar (names : Metadata) (scalars : BooleanBindings.Environment)
    (item : BooleanBindings.Binding) (space : scalars.length < BooleanBindings.maxBindings) :
    booleanAnalysis names (BooleanBindings.analysis (scalars ++ [item])) =
      (booleanAnalysis names (BooleanBindings.analysis scalars)).initialize
        (scalars.length + 1) item.mutable := by
  rw [BooleanBindings.analysis_append]
  exact booleanAnalysis_initialize_scalar names _ (by omega) item.mutable

theorem booleanAnalysis_append_fresh {names : Metadata} {item : Binding} {scalars : Boolean.Analysis}
    (kind : item.isBoolean = true)
    (fresh : ∀ cell, item.booleanDescriptor.ContainsCell cell →
      (booleanAnalysis names scalars).initialized cell = false) :
    booleanAnalysis (names ++ [item]) scalars =
      item.booleanDescriptor.initializeAnalysis (booleanAnalysis names scalars) item.mutable := by
  have noFind (cell : Nat) (inside : item.booleanDescriptor.ContainsCell cell) :
      (booleanNames names).find? (fun entry => decide (entry.booleanDescriptor.ContainsCell cell)) = none := by
    have empty := fresh cell inside
    simp only [booleanAnalysis, Bool.or_eq_false_iff] at empty
    apply List.find?_eq_none.mpr
    intro entry member
    exact List.any_eq_false.mp empty.1 entry member
  unfold booleanAnalysis Boolean.ArrayDescriptor.initializeAnalysis
  rw [booleanNames_append_boolean names kind]
  congr 1 <;> funext cell <;> by_cases inside : item.booleanDescriptor.ContainsCell cell
  · simp [List.any_append, inside]
  · simp [List.any_append, inside]
  · simp [List.find?_append, noFind cell inside, inside]
  · simp [List.find?_append, inside]

@[simp] theorem booleanAnalysis_append_integer (names : Metadata) (scalars : Boolean.Analysis)
    {item : Binding} (kind : item.isBoolean = false) :
    booleanAnalysis (names ++ [item]) scalars = booleanAnalysis names scalars := by
  simp only [booleanAnalysis, booleanNames_append_integer names kind]

theorem booleanAnalysis_initialized {names : Metadata} {item : Binding}
    (member : item ∈ names) (kind : item.isBoolean = true) (scalars : Boolean.Analysis) :
    item.booleanDescriptor.initialized (booleanAnalysis names scalars) = true := by
  apply (Boolean.ArrayDescriptor.allCells_iff _ _).mpr
  intro cell inside
  apply Bool.or_eq_true_iff.mpr
  left
  apply List.any_eq_true.mpr
  exact ⟨item, by simp [booleanNames, member, kind], by simpa using inside⟩

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

theorem binding_booleanDescriptor_valid {item : Binding} (valid : ValidBinding item) :
    item.booleanDescriptor.Valid := ⟨valid.1, valid.2.1⟩

theorem binding_booleanDescriptor_length {item : Binding} (valid : ValidBinding item) :
    item.booleanDescriptor.length = item.length := by
  simpa only [Binding.booleanDescriptor, Boolean.ArrayDescriptor.length,
    Boolean.ArrayDescriptor.layout, Binding.descriptor, Integer.ArrayDescriptor.length] using
      binding_descriptor_length valid

theorem binding_component_valid {item : Binding} (valid : ValidBinding item) :
    item.descriptor.ComponentValid := valid.2.2.2.2.2

theorem binding_components_valid {names : Metadata}
    (valid : ∀ entry ∈ names, ValidBinding entry) (target : Nat) :
    (binding names target).descriptor.ComponentValid := by
  unfold binding
  simp only [List.getD_eq_getElem?_getD]
  cases found : names[target - 1]? with
  | none => exact ⟨Integer.Interval.full_bounded, by decide⟩
  | some item => exact binding_component_valid (valid item (List.mem_of_getElem? found))

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

/-- Appending a fresh segment retains every earlier component subtype and
establishes the new segment's interval from its checked initializer values. -/
theorem initialsFit_append {names : Metadata} {values : Initials} {item : Binding} {items : List Int}
    (fits : InitialsFit names values)
    (occupied : ∀ entry ∈ names, entry.offset + entry.descriptor.length ≤ values.length)
    (offset : item.offset = values.length) (count : items.length = item.descriptor.length)
    (bounded : item.componentBounds.Bounded)
    (safe : ∀ value ∈ items, item.componentBounds.Contains value) :
    InitialsFit (names ++ [item]) (values ++ items) := by
  intro entry member
  rcases List.mem_append.mp member with old | fresh
  · refine ⟨(fits entry old).1, ?_⟩
    intro index within
    have indexBound := List.mem_range.mp within
    have before : entry.offset + 1 + index - 1 < values.length := by
      have last := occupied entry old
      omega
    simpa only [initialValue, List.getD_eq_getElem?_getD, List.getElem?_append_left before] using
      (fits entry old).2 index within
  · have same := List.mem_singleton.mp fresh
    subst entry
    refine ⟨bounded, ?_⟩
    intro index within
    have indexBound : index < items.length := by simpa only [count] using List.mem_range.mp within
    have after : values.length ≤ item.offset + 1 + index - 1 := by omega
    have relative : item.offset + 1 + index - 1 - values.length = index := by omega
    simp only [initialValue, List.getD_eq_getElem?_getD, List.getElem?_append_right after,
      relative, List.getElem?_eq_getElem indexBound, Option.getD_some]
    exact safe _ (List.getElem_mem (l := items) (n := index) (h := indexBound))

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

private theorem ordered_booleanFind {names : Metadata} {item : Binding} {cell : Nat}
    (valid : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : item ∈ names) (inside : item.booleanDescriptor.ContainsCell cell) :
    names.find? (fun entry => decide (entry.booleanDescriptor.ContainsCell cell)) = some item := by
  induction names with
  | nil => simp at member
  | cons head tail ih =>
      have order := List.pairwise_cons.mp ordered
      rcases List.mem_cons.mp member with same | member
      · subst item
        simp only [List.find?_cons, inside, decide_true]
      · have separate := order.1 item member
        have headLength := binding_booleanDescriptor_length (valid head (by simp))
        have absent : ¬ head.booleanDescriptor.ContainsCell cell := by
          intro contained
          change head.booleanDescriptor.base ≤ cell ∧
            cell < head.booleanDescriptor.base + head.booleanDescriptor.length at contained
          change item.booleanDescriptor.base ≤ cell ∧
            cell < item.booleanDescriptor.base + item.booleanDescriptor.length at inside
          rw [headLength] at contained
          simp only [Binding.booleanDescriptor] at contained inside
          omega
        have rest := ih (fun entry found => valid entry (by simp [found])) order.2 member
        simpa only [List.find?_cons, absent, decide_false, Bool.false_eq_true, ↓reduceIte] using rest

theorem booleanAnalysis_mutability {names : Metadata} {item : Binding} {cell : Nat}
    (valid : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : item ∈ names) (kind : item.isBoolean = true)
    (inside : item.booleanDescriptor.ContainsCell cell) (scalars : Boolean.Analysis) :
    (booleanAnalysis names scalars).mutable cell = item.mutable := by
  have found := ordered_booleanFind
    (names := booleanNames names)
    (fun entry present => valid entry (mem_booleanNames.mp present).1)
    (List.Pairwise.filter (fun (entry : Binding) => entry.isBoolean) ordered)
    (mem_booleanNames.mpr ⟨member, kind⟩) inside
  simp only [booleanAnalysis, found]

theorem booleanAnalysis_writable {names : Metadata} {item : Binding}
    (valid : ∀ entry ∈ names, ValidBinding entry)
    (ordered : names.Pairwise (fun left right => left.offset + left.length ≤ right.offset))
    (member : item ∈ names) (kind : item.isBoolean = true) (writable : item.mutable = true)
    (scalars : Boolean.Analysis) :
    item.booleanDescriptor.writable (booleanAnalysis names scalars) = true := by
  apply (Boolean.ArrayDescriptor.allCells_iff _ _).mpr
  intro cell inside
  apply Bool.and_eq_true_iff.mpr
  refine ⟨?_, (booleanAnalysis_mutability valid ordered member kind inside scalars).trans writable⟩
  exact (Boolean.ArrayDescriptor.allCells_iff _ _).mp
    (booleanAnalysis_initialized member kind scalars) cell inside

end Silver.ArrayBindings
