module

public import Silver.IntegerArrays

@[expose] public section

/-! A named constrained Integer array carries a nominal declaration identity
and one fixed index and component subtype. A call receives the incoming cells
in index order. Each formal has an immutable, disjoint segment in its callee's
mathematical Integer store. The compiler needs no initializer cells for it. -/
namespace Silver.NamedArrayParameters
open Integer

def maxLength : Nat := 4096 / 2
def scalarLimit : Nat := 4096 / 7

structure Domain where
  identity : Nat
  bounds : Interval
  componentBounds : Interval
  deriving DecidableEq, Repr

def Domain.atBase (domain : Domain) (base : Nat) : ArrayDescriptor :=
  ⟨base, domain.bounds, domain.componentBounds⟩

def Domain.length (domain : Domain) : Nat :=
  (domain.bounds.upper - domain.bounds.lower + 1).toNat

def Domain.Valid (domain : Domain) : Prop :=
  0 < domain.identity ∧ domain.bounds.Bounded ∧ domain.bounds.lower ≤ domain.bounds.upper ∧
    domain.length ≤ maxLength ∧ domain.componentBounds.Bounded ∧
    domain.componentBounds.lower ≤ domain.componentBounds.upper

instance (domain : Domain) : Decidable domain.Valid :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))

theorem Domain.length_positive {domain : Domain} (valid : domain.Valid) : 0 < domain.length := by
  have ordered := valid.2.2.1
  simp only [Domain.length]
  omega

inductive Attribute
  | first | last | length
  deriving DecidableEq, Repr

/-- Ada 3.6.2. The default dimension is the sole index range. This also
applies to an anonymous constrained Integer array, independently of values. -/
def Attribute.value : Attribute → Interval → Int
  | .first, bounds => bounds.lower
  | .last, bounds => bounds.upper
  | .length, bounds => bounds.upper - bounds.lower + 1

theorem Attribute.inRange (query : Attribute) (bounds : Interval)
    (bounded : bounds.Bounded) (ordered : bounds.lower ≤ bounds.upper)
    (size : (bounds.upper - bounds.lower + 1).toNat ≤ maxLength) :
    InRange (query.value bounds) := by
  cases query with
  | first => exact bounded.1
  | last => exact bounded.2
  | length =>
    simp only [Attribute.value, InRange, minValue, maxValue]
    have cap : maxLength = 2048 := by decide
    rw [cap] at size
    omega

structure Argument where
  identity : Nat
  cells : List Int
  deriving DecidableEq, Repr

def Domain.Contains (domain : Domain) (argument : Argument) : Prop :=
  argument.identity = domain.identity ∧ argument.cells.length = domain.length ∧
    ∀ cell ∈ argument.cells, domain.componentBounds.Contains cell

instance (domain : Domain) (argument : Argument) : Decidable (domain.Contains argument) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ ∀ cell ∈ argument.cells, domain.componentBounds.Contains cell))

def Domain.Matches (domain : Domain) (identity : Nat) (source : ArrayDescriptor) : Prop :=
  0 < identity ∧ identity = domain.identity ∧
    source.bounds = domain.bounds ∧ source.componentBounds = domain.componentBounds

instance (domain : Domain) (identity : Nat) (source : ArrayDescriptor) :
    Decidable (domain.Matches identity source) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _))

def capture (identity : Nat) (source : ArrayDescriptor) (store : Store) : Argument :=
  ⟨identity, (List.range source.length).map fun offset => store (source.base + offset)⟩

theorem capture_congr (identity : Nat) (source : ArrayDescriptor) {first second : Store}
    (same : ∀ cell, source.ContainsCell cell → first cell = second cell) :
    capture identity source first = capture identity source second := by
  unfold capture
  congr 1
  apply List.map_congr_left
  intro offset member
  apply same
  have below := List.mem_range.mp member
  simp only [ArrayDescriptor.ContainsCell]
  omega

theorem capture_put_outside (identity : Nat) (source : ArrayDescriptor) (store : Store)
    (cell : Nat) (value : Int) (outside : ¬ source.ContainsCell cell) :
    capture identity source (Integer.put store cell value) = capture identity source store := by
  apply capture_congr
  intro observed inside
  have different : observed ≠ cell := fun equal => outside (equal ▸ inside)
  simp only [Integer.put, different, ↓reduceIte]

theorem capture_contains {domain : Domain} {identity : Nat} {source : ArrayDescriptor} {store : Store}
    (matched : domain.Matches identity source) (fits : source.Fits store) :
    domain.Contains (capture identity source store) := by
  refine ⟨matched.2.1, ?_, ?_⟩
  · simp [capture, ArrayDescriptor.length, Domain.length, matched.2.2.1]
  · intro value member
    simp only [capture, List.mem_map, List.mem_range] at member
    obtain ⟨offset, below, rfl⟩ := member
    have inside := source.offset_within below
    have safe := fits _ inside
    simpa only [ArrayDescriptor.project, ArrayDescriptor.address_offset, matched.2.2.2] using safe

theorem capture_of_checked_ranges {domain : Domain} {identity : Nat} {source : ArrayDescriptor}
    {ranges : Ranges} {store : Store} (matched : domain.Matches identity source)
    (rangesChecked : source.componentRanges ranges = true) (fits : Integer.Fits ranges store) :
    domain.Contains (capture identity source store) := by
  apply capture_contains matched
  intro index inside
  exact fits _ _ ((ArrayDescriptor.componentRanges_iff ..).mp rangesChecked index inside)

/-- Slots start at one. The stored-object segment occupies the first 2048
addresses above the scalar limit. Positive formal slots use separate blocks
even when the caller passes the same object twice. -/
def Domain.formal (domain : Domain) (slot : Nat) : ArrayDescriptor :=
  domain.atBase (scalarLimit + 1 + slot * maxLength)

theorem formal_disjoint {left right : Domain} {first next : Nat} (before : first < next)
    (bounded : left.length ≤ maxLength) :
    (left.formal first).Disjoint (right.formal next) := by
  left
  change scalarLimit + 1 + first * maxLength + left.length ≤ scalarLimit + 1 + next * maxLength
  have stride := Nat.mul_le_mul_right maxLength (Nat.succ_le_of_lt before)
  rw [Nat.succ_mul] at stride
  omega

theorem formal_above_scalars (domain : Domain) (slot : Nat) :
    scalarLimit < (domain.formal slot).base := by
  change scalarLimit < scalarLimit + 1 + slot * maxLength
  omega

def bind (domain : Domain) (slot : Nat) (argument : Argument) (locals : Store) : Store :=
  (domain.formal slot).initializeValues locals argument.cells

theorem bind_fits {domain : Domain} {argument : Argument} (contained : domain.Contains argument)
    (slot : Nat) (locals : Store) :
    (domain.formal slot).Fits (bind domain slot argument locals) :=
  ArrayDescriptor.initialize_fits contained.2.1 contained.2.2

theorem bind_preserves_scalar (domain : Domain) (slot : Nat) (argument : Argument)
    (locals : Store) {identity : Nat} (low : identity ≤ scalarLimit) :
    bind domain slot argument locals identity = locals identity :=
  ArrayDescriptor.initialize_preserves_scalar (formal_above_scalars domain slot) low

theorem bind_preserves_outside {domain : Domain} {argument : Argument}
    (contained : domain.Contains argument) (slot : Nat) (locals : Store) {cell : Nat}
    (outside : ¬ (domain.formal slot).ContainsCell cell) :
    bind domain slot argument locals cell = locals cell := by
  have count : argument.cells.length = (domain.formal slot).length := contained.2.1
  simp only [ArrayDescriptor.ContainsCell] at outside
  have omitted : ¬ ((domain.formal slot).base ≤ cell ∧
      cell - (domain.formal slot).base < argument.cells.length) := by omega
  simp only [bind, ArrayDescriptor.initializeValues, omitted, ↓reduceIte]

theorem bind_declared_fits {domain : Domain} {argument : Argument} {ranges : Ranges}
    {locals : Store} (contained : domain.Contains argument) (slot : Nat)
    (localFits : Integer.Fits ranges locals) :
    Integer.Fits ((domain.formal slot).bodyRanges ranges) (bind domain slot argument locals) := by
  have emptyFits : Integer.Fits (fun _ => none) (bind domain slot argument locals) := by
    intro cell bounds found
    contradiction
  have arrayFits := ArrayDescriptor.bodyRanges_fits emptyFits (bind_fits contained slot locals)
  intro cell bounds found
  by_cases inside : (domain.formal slot).ContainsCell cell
  · apply arrayFits cell bounds
    simpa only [ArrayDescriptor.bodyRanges, inside, ↓reduceIte] using found
  · rw [bind_preserves_outside contained slot locals inside]
    exact localFits cell bounds (by simpa only [ArrayDescriptor.bodyRanges, inside, ↓reduceIte] using found)

/-- Copy-in maps each original index to its value at call entry. Negative
and non-one lower bounds use exactly the same address calculation. -/
theorem bind_read {domain : Domain} {argument : Argument} (contained : domain.Contains argument)
    (slot : Nat) (locals : Store) {index : Int} (inside : domain.bounds.Contains index) :
    (domain.formal slot).project (bind domain slot argument locals) index =
      argument.cells[(index - domain.bounds.lower).toNat]! := by
  let offset := (index - domain.bounds.lower).toNat
  have below : offset < argument.cells.length := by
    rw [contained.2.1]
    simp only [offset, Domain.length, Interval.Contains] at *
    omega
  have equal : domain.bounds.lower + (offset : Int) = index := by
    simp only [offset, Interval.Contains] at *
    omega
  have read := ArrayDescriptor.initialize_at (array := domain.formal slot)
    (values := locals) below
  change (domain.formal slot).project (bind domain slot argument locals)
    (domain.bounds.lower + (offset : Int)) = argument.cells[offset]! at read
  simpa only [equal] using read

/-- Passing a formal on to another call yields its complete incoming value. -/
theorem capture_bind {domain : Domain} {argument : Argument} (contained : domain.Contains argument)
    (slot : Nat) (locals : Store) :
    capture domain.identity (domain.formal slot) (bind domain slot argument locals) = argument := by
  obtain ⟨identity, cells⟩ := argument
  obtain ⟨rfl, count, _⟩ := contained
  unfold capture
  congr 1
  apply List.ext_getElem
  · simpa [Domain.formal, Domain.atBase, Domain.length, ArrayDescriptor.length] using count.symm
  · intro index _ inside
    have read := ArrayDescriptor.initialize_at (array := domain.formal slot)
      (values := locals) inside
    simpa only [bind, List.getElem_map, List.getElem_range, ArrayDescriptor.project,
      ArrayDescriptor.address_offset, getElem!_pos cells index inside] using read

end Silver.NamedArrayParameters
