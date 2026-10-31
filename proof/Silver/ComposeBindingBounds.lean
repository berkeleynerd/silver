module

public import Silver.ComposeAtomAdmission
public import Silver.StringObjectBounds

@[expose] public section

namespace Silver.Compose
open Bindings StringObjectBounds

/-- Native declaration-slot invariant. Null Strings retain both Ada bounds;
only nonempty values contribute to the derived source-sized upper ceiling. -/
def fixedBoundsValid (length : Nat) (dynamic isCharacter : Bool)
    (firstIndex lastIndex : Int) (slot : Nat) : Bool :=
  if isCharacter then !dynamic && decide (length = 1 ∧ firstIndex = 1 ∧ lastIndex = 1)
  else if dynamic then decide (length = 0)
  else if length = 0 then decide (firstIndex > lastIndex)
  else decide (firstIndex ≥ 1 ∧ lastIndex ≥ firstIndex ∧
    lastIndex - firstIndex + 1 = (length : Int) ∧
    lastIndex ≤ (slot : Int) * maxSourceLength)

def BindingInfo.objectBounds (info : BindingInfo) : Bounds := ⟨info.firstIndex, info.lastIndex⟩

/-- The exact native slot predicate, with the Integer base-type domain carried
explicitly instead of inferred from a reachable declaration history. -/
def BindingInfo.BoundsValid (info : BindingInfo) (slot : Nat) : Prop :=
  Integer.InRange info.firstIndex ∧ Integer.InRange info.lastIndex ∧
    fixedBoundsValid info.staticLength info.dynamic info.isCharacter info.firstIndex info.lastIndex slot = true

def NamesBoundsValid (names : BindingEnvironment) : Prop :=
  ∀ slot info, names.get slot = some info → BindingInfo.BoundsValid info slot

theorem fixedBoundsValid_dynamic {length slot first last}
    (checked : fixedBoundsValid length true false first last slot = true) : length = 0 := by
  simpa [fixedBoundsValid] using checked

theorem fixedBoundsValid_character {length dynamic first last slot}
    (checked : fixedBoundsValid length dynamic true first last slot = true) :
    dynamic = false ∧ length = 1 ∧ first = 1 ∧ last = 1 := by
  simpa [fixedBoundsValid, Bool.and_eq_true] using checked

theorem fixedBoundsValid_length {length first last slot}
    (checked : fixedBoundsValid length false false first last slot = true) :
    (Bounds.mk first last).length = length := by
  by_cases empty : length = 0
  · simp only [fixedBoundsValid, Bool.false_eq_true, ↓reduceIte, empty, decide_eq_true_eq] at checked
    simp only [Bounds.length]
    omega
  · simp only [fixedBoundsValid, Bool.false_eq_true, ↓reduceIte, empty, decide_eq_true_eq] at checked
    simp only [Bounds.length]
    omega

theorem fixedBoundsValid_nonempty {length first last slot}
    (checked : fixedBoundsValid length false false first last slot = true) (nonempty : length ≠ 0) :
    1 ≤ first ∧ first ≤ last ∧ last ≤ (slot : Int) * maxSourceLength := by
  have fields : 1 ≤ first ∧ first ≤ last ∧ last - first + 1 = (length : Int) ∧
      last ≤ (slot : Int) * maxSourceLength := by
    simpa only [fixedBoundsValid, Bool.false_eq_true, ↓reduceIte, nonempty, decide_eq_true_eq] using checked
  exact ⟨fields.1, fields.2.1, fields.2.2.2⟩

theorem BindingInfo.boundsValid_length {info : BindingInfo} {slot : Nat}
    (checked : BindingInfo.BoundsValid info slot) (fixed : info.dynamic = false) :
    info.objectBounds.length = info.staticLength := by
  cases character : info.isCharacter with
  | false => exact fixedBoundsValid_length (by simpa [fixed, character] using checked.2.2)
  | true =>
      have fields := fixedBoundsValid_character (by simpa [character] using checked.2.2)
      simp [objectBounds, Bounds.length, fields.2.1, fields.2.2.1, fields.2.2.2]

theorem BindingInfo.boundsValid_valid {info : BindingInfo} {slot : Nat}
    (checked : BindingInfo.BoundsValid info slot) (fixed : info.dynamic = false) : info.objectBounds.Valid := by
  refine ⟨checked.1, checked.2.1, ?_⟩
  cases character : info.isCharacter with
  | true =>
      have fields := fixedBoundsValid_character (by simpa [character] using checked.2.2)
      exact Or.inr (by simp [objectBounds, fields.2.2.1])
  | false =>
      by_cases empty : info.staticLength = 0
      · have null : info.firstIndex > info.lastIndex := by
          simpa [fixedBoundsValid, character, fixed, empty] using checked.2.2
        exact Or.inl null
      · exact Or.inr (by
          change 1 ≤ info.firstIndex
          exact (fixedBoundsValid_nonempty (by simpa [fixed, character] using checked.2.2) empty).1)

theorem BindingInfo.boundsValid_firstBound {info : BindingInfo} {slot count : Nat}
    (checked : BindingInfo.BoundsValid info slot) (fixed : info.dynamic = false) (slotBound : slot ≤ count)
    (countPositive : 0 < count) : info.objectBounds.FirstBound ((count : Int) * maxSourceLength) := by
  cases character : info.isCharacter with
  | true =>
      have fields := fixedBoundsValid_character (by simpa [character] using checked.2.2)
      exact Or.inr (by simp only [objectBounds, fields.2.2.1, maxSourceLength]; omega)
  | false =>
      by_cases empty : info.staticLength = 0
      · exact Or.inl ((Bounds.null_iff_length_zero _).mpr (by rw [BindingInfo.boundsValid_length checked fixed, empty]))
      · have bound := fixedBoundsValid_nonempty (by simpa [fixed, character] using checked.2.2) empty
        exact Or.inr (by simp only [objectBounds, maxSourceLength] at *; omega)

end Silver.Compose
