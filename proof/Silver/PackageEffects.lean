module

public import Silver.PackageState

@[expose] public section

/-! Finite state footprints and their composition. The capture selector preserves
declaration order. A later source/body derivation must compute these footprints
from resolved executable syntax; no correctness of such a derivation is assumed
by the algebra below. -/
namespace Silver.Packages
open ScalarFunctions (Frame)

structure Effects where
  reads : List Cell := []
  writes : List Cell := []
  deriving DecidableEq, Repr

def Effects.merge (first second : Effects) : Effects :=
  ⟨first.reads ++ second.reads, first.writes ++ second.writes⟩

def Effects.Captures (effects : Effects) (cell : Cell) : Prop :=
  cell ∈ effects.reads ∨ cell ∈ effects.writes

def Effects.captures (effects : Effects) (cell : Cell) : Bool :=
  effects.reads.contains cell || effects.writes.contains cell

@[simp] theorem Effects.captures_iff (effects : Effects) (cell : Cell) :
    effects.captures cell = true ↔ effects.Captures cell := by
  simp [captures, Captures]

@[simp] theorem Effects.merge_captures (first second : Effects) (cell : Cell) :
    (first.merge second).Captures cell ↔ first.Captures cell ∨ second.Captures cell := by
  simp only [Captures, merge, List.mem_append]
  constructor
  · rintro ((h | h) | h | h)
    · exact Or.inl (Or.inl h)
    · exact Or.inr (Or.inl h)
    · exact Or.inl (Or.inr h)
    · exact Or.inr (Or.inr h)
  · rintro ((h | h) | h | h)
    · exact Or.inl (Or.inl h)
    · exact Or.inr (Or.inl h)
    · exact Or.inl (Or.inr h)
    · exact Or.inr (Or.inr h)

def Effects.captureSchema (effects : Effects) (schema : StateSchema) : StateSchema :=
  schema.filter (fun declaration => effects.captures declaration.cell)

@[simp] theorem Effects.mem_captureSchema (effects : Effects) (schema : StateSchema)
    (declaration : StateDeclaration) :
    declaration ∈ effects.captureSchema schema ↔
      declaration ∈ schema ∧ effects.Captures declaration.cell := by
  simp [captureSchema]

theorem Effects.captureSchema_fits {effects : Effects} {schema : StateSchema} {frame : Frame}
    (fitting : schema.Fits frame) : (effects.captureSchema schema).Fits frame := by
  intro declaration present
  exact fitting declaration ((effects.mem_captureSchema schema declaration).mp present).1

/-- Only the returned state is compared; this relation promises no termination
or successful body checking. Those belong to the constructed execution theorem. -/
def ChangesOnly (writes : List Cell) (before after : Frame) : Prop :=
  ∀ cell, cell ∉ writes → readCell after cell = readCell before cell

theorem changesOnly_refl (writes : List Cell) (frame : Frame) : ChangesOnly writes frame frame :=
  fun _ _ => rfl

theorem changesOnly_mono {small large : List Cell} {before after : Frame}
    (included : ∀ cell ∈ small, cell ∈ large) (changes : ChangesOnly small before after) :
    ChangesOnly large before after := by
  intro cell absent
  exact changes cell (fun present => absent (included cell present))

theorem changesOnly_sequence {first second : List Cell} {before middle after : Frame}
    (left : ChangesOnly first before middle) (right : ChangesOnly second middle after) :
    ChangesOnly (first ++ second) before after := by
  intro cell absent
  have separate : cell ∉ first ∧ cell ∉ second := by
    simpa only [List.mem_append, not_or] using absent
  exact (right cell separate.2).trans (left cell separate.1)

theorem changesOnly_write (frame : Frame) (cell : Cell) (value : ScalarFunctions.Value) :
    ChangesOnly [cell] frame (writeCell frame cell value) := by
  intro other absent
  exact readCell_write_other (by simpa using absent) value frame

theorem changesOnly_preserves {writes : List Cell} {before after : Frame}
    (changes : ChangesOnly writes before after) {cell : Cell} (readonly : cell ∉ writes) :
    readCell after cell = readCell before cell := changes cell readonly

theorem changesOnly_empty {before after : Frame} (changes : ChangesOnly [] before after) :
    after = before := frame_ext (fun cell => changes cell (by simp))

/-- A body-completion-order table. Zero, its own index, and every later index
fail lookup, so a successful inference cannot invent a recursive dependency. -/
def effectLookup (earlier : List Effects) (identity : Nat) : Option Effects :=
  if identity = 0 then none else earlier[identity - 1]?

def includeCalls (earlier : List Effects) : List Nat → Effects → Option Effects
  | [], direct => some direct
  | identity :: rest, direct =>
      (effectLookup earlier identity).bind fun callee =>
        includeCalls earlier rest (direct.merge callee)

theorem effectLookup_before {earlier : List Effects} {identity : Nat} {effects : Effects}
    (found : effectLookup earlier identity = some effects) :
    0 < identity ∧ identity ≤ earlier.length := by
  by_cases zero : identity = 0
  · simp [effectLookup, zero] at found
  · simp only [effectLookup, zero, ↓reduceIte] at found
    have inside := (List.getElem?_eq_some_iff.mp found).1
    omega

theorem includeCalls_contains_direct {earlier : List Effects} {calls : List Nat}
    {direct result : Effects} (found : includeCalls earlier calls direct = some result) :
    (∀ cell ∈ direct.reads, cell ∈ result.reads) ∧
      (∀ cell ∈ direct.writes, cell ∈ result.writes) := by
  induction calls generalizing direct with
  | nil => cases Option.some.inj found; exact ⟨fun _ h => h, fun _ h => h⟩
  | cons identity rest ih =>
      simp only [includeCalls, Option.bind_eq_some_iff] at found
      obtain ⟨callee, _, following⟩ := found
      have included := ih following
      exact ⟨fun cell present => included.1 cell (by simp [Effects.merge, present]),
        fun cell present => included.2 cell (by simp [Effects.merge, present])⟩

theorem includeCalls_contains_callee {earlier : List Effects} {calls : List Nat}
    {direct result : Effects} (found : includeCalls earlier calls direct = some result)
    {identity : Nat} (present : identity ∈ calls) :
    ∃ callee, effectLookup earlier identity = some callee ∧
      (∀ cell ∈ callee.reads, cell ∈ result.reads) ∧
      (∀ cell ∈ callee.writes, cell ∈ result.writes) := by
  induction calls generalizing direct with
  | nil => simp at present
  | cons head rest ih =>
      simp only [includeCalls, Option.bind_eq_some_iff] at found
      obtain ⟨callee, known, following⟩ := found
      rcases List.mem_cons.mp present with rfl | present
      · have included := includeCalls_contains_direct following
        exact ⟨callee, known,
          fun cell member => included.1 cell (by simp [Effects.merge, member]),
          fun cell member => included.2 cell (by simp [Effects.merge, member])⟩
      · exact ih following present

theorem includeCalls_earlier {earlier : List Effects} {calls : List Nat}
    {direct result : Effects} (found : includeCalls earlier calls direct = some result)
    {identity : Nat} (present : identity ∈ calls) :
    0 < identity ∧ identity ≤ earlier.length := by
  obtain ⟨callee, known, _⟩ := includeCalls_contains_callee found present
  exact effectLookup_before known

end Silver.Packages
