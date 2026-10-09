import Silver.ArgumentsAdmission

namespace Silver.Guarded

structure DecimalResult where
  after : Nat
  value : Nat
  deriving DecidableEq, Repr

def invalidDecimal : DecimalResult := ⟨0, 0⟩

def digit (byte : Nat) : Prop := 48 ≤ byte ∧ byte ≤ 57
instance (byte : Nat) : Decidable (digit byte) := inferInstanceAs (Decidable (_ ∧ _))

/-- The numeric scanner follows the bounded Ada accumulator; the independent
derivation below exposes the decimal digits and their mathematical value. -/
def decimalTail (text : Source) (position value : Nat) : DecimalResult :=
  if position > text.length then ⟨position, value⟩
  else if ¬ digit (Cursor.byteAt text position) then
    if identifierCharacter (Cursor.byteAt text position) then invalidDecimal
    else ⟨position, value⟩
  else if value > (maxSourceLength - (Cursor.byteAt text position - 48)) / 10 then
    invalidDecimal
  else decimalTail text (position + 1) (10 * value + (Cursor.byteAt text position - 48))
termination_by text.length + 1 - position
decreasing_by all_goals omega

def decimalAt (text : Source) (position : Nat) : DecimalResult :=
  if position > text.length ∨ ¬ digit (Cursor.byteAt text position) then invalidDecimal
  else if Cursor.byteAt text position = 48 then
    if position < text.length ∧ identifierCharacter (Cursor.byteAt text (position + 1)) = true then
      invalidDecimal
    else ⟨position + 1, 0⟩
  else decimalTail text (position + 1) (Cursor.byteAt text position - 48)

inductive DecimalTailAt (text : Source) : Nat → Nat → Nat → Nat → Prop
  | ending {position value : Nat} : position = text.length + 1 → value ≤ maxSourceLength →
      DecimalTailAt text position value value position
  | separator {position value : Nat} : position ≤ text.length → value ≤ maxSourceLength →
      ¬ digit (Cursor.byteAt text position) → identifierCharacter (Cursor.byteAt text position) = false →
      DecimalTailAt text position value value position
  | next {position value result finish : Nat} : position ≤ text.length →
      digit (Cursor.byteAt text position) →
      10 * value + (Cursor.byteAt text position - 48) ≤ maxSourceLength →
      DecimalTailAt text (position + 1) (10 * value + (Cursor.byteAt text position - 48)) result finish →
      DecimalTailAt text position value result finish

inductive DecimalAt (text : Source) : Nat → Nat → Nat → Prop
  | zero {position : Nat} : position ≤ text.length → Cursor.byteAt text position = 48 →
      ¬ (position < text.length ∧ identifierCharacter (Cursor.byteAt text (position + 1)) = true) →
      DecimalAt text position 0 (position + 1)
  | positive {position value finish : Nat} : position ≤ text.length →
      49 ≤ Cursor.byteAt text position → Cursor.byteAt text position ≤ 57 →
      DecimalTailAt text (position + 1) (Cursor.byteAt text position - 48) value finish →
      DecimalAt text position value finish

theorem decimalTail_complete {text : Source} {position start value finish : Nat}
    (parsed : DecimalTailAt text position start value finish) :
    decimalTail text position start = ⟨finish, value⟩ := by
  induction parsed with
  | ending bound within => rw [decimalTail]; simp [bound]
  | separator bound within different ending => rw [decimalTail]; simp [Nat.not_lt.mpr bound, different, ending]
  | @next position start value finish bound isDigit within rest ih =>
      have bounded : ¬ start > (maxSourceLength - (Cursor.byteAt text position - 48)) / 10 := by
        simp only [digit, maxSourceLength] at isDigit within ⊢
        omega
      rw [decimalTail]
      simp [Nat.not_lt.mpr bound, isDigit, bounded, ih]

theorem decimalTail_sound (text : Source) (position value : Nat)
    (positionBound : position ≤ text.length + 1) (valueBound : value ≤ maxSourceLength)
    (nonzero : (decimalTail text position value).after ≠ 0) :
    DecimalTailAt text position value (decimalTail text position value).value
      (decimalTail text position value).after := by
  by_cases ending : position > text.length
  · have exactEnd : position = text.length + 1 := by omega
    simp only [decimalTail, ending, ↓reduceIte]
    exact .ending exactEnd valueBound
  · by_cases isDigit : digit (Cursor.byteAt text position)
    · by_cases overflow : value > (maxSourceLength - (Cursor.byteAt text position - 48)) / 10
      · rw [decimalTail] at nonzero
        simp [ending, isDigit, overflow, invalidDecimal] at nonzero
      · have nextBound : 10 * value + (Cursor.byteAt text position - 48) ≤ maxSourceLength := by
          simp only [digit, maxSourceLength] at isDigit overflow ⊢
          omega
        have equation : decimalTail text position value =
            decimalTail text (position + 1) (10 * value + (Cursor.byteAt text position - 48)) := by
          rw [decimalTail]; simp [ending, isDigit, overflow]
        rw [equation] at nonzero ⊢
        exact .next (by omega) isDigit nextBound
          (decimalTail_sound text _ _ (by omega) nextBound nonzero)
    · by_cases identifier : identifierCharacter (Cursor.byteAt text position) = true
      · rw [decimalTail] at nonzero
        simp [ending, isDigit, identifier, invalidDecimal] at nonzero
      · have notIdentifier : identifierCharacter (Cursor.byteAt text position) = false :=
          Bool.eq_false_iff.mpr identifier
        rw [decimalTail]
        simpa [ending, isDigit, notIdentifier] using
          DecimalTailAt.separator (text := text) (position := position) (value := value)
            (by omega) valueBound isDigit notIdentifier
termination_by text.length + 1 - position
decreasing_by all_goals omega

theorem decimalTail_bounds {text : Source} {position start value finish : Nat}
    (parsed : DecimalTailAt text position start value finish) :
    position ≤ finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxSourceLength := by
  induction parsed with
  | ending bound within => omega
  | separator bound within different ending => omega
  | next bound isDigit within rest ih => omega

theorem decimalAt_complete {text : Source} {position value finish : Nat}
    (parsed : DecimalAt text position value finish) : decimalAt text position = ⟨finish, value⟩ := by
  cases parsed with
  | zero bound zero ending => simp [decimalAt, Nat.not_lt.mpr bound, zero, digit, ending]
  | positive bound nonzero digitBound rest =>
      have notZero : Cursor.byteAt text position ≠ 48 := by omega
      simpa [decimalAt, Nat.not_lt.mpr bound, digit, notZero, show 48 ≤ Cursor.byteAt text position by omega,
        digitBound] using decimalTail_complete rest

theorem decimalAt_sound (text : Source) (position : Nat)
    (nonzero : (decimalAt text position).after ≠ 0) :
    DecimalAt text position (decimalAt text position).value (decimalAt text position).after := by
  by_cases bad : position > text.length ∨ ¬ digit (Cursor.byteAt text position)
  · simp [decimalAt, bad, invalidDecimal] at nonzero
  · have bound : position ≤ text.length := by omega
    have digits : digit (Cursor.byteAt text position) := by
      by_cases present : digit (Cursor.byteAt text position)
      · exact present
      · exact False.elim (bad (Or.inr present))
    by_cases zero : Cursor.byteAt text position = 48
    · by_cases continuing : position < text.length ∧ identifierCharacter (Cursor.byteAt text (position + 1)) = true
      · simp [decimalAt, zero, continuing, invalidDecimal] at nonzero
      · simpa [decimalAt, Nat.not_lt.mpr bound, digit, zero, continuing] using DecimalAt.zero bound zero continuing
    · have digitBound : Cursor.byteAt text position - 48 ≤ maxSourceLength := by
        simp only [digit, maxSourceLength] at digits ⊢
        omega
      have equation : decimalAt text position = decimalTail text (position + 1) (Cursor.byteAt text position - 48) := by
        simp [decimalAt, bad, zero]
      rw [equation] at nonzero ⊢
      exact .positive bound (by rcases digits with ⟨_, _⟩; omega) digits.2
        (decimalTail_sound text _ _ (by omega) digitBound nonzero)

theorem decimalAt_bounds {text : Source} {position value finish : Nat}
    (parsed : DecimalAt text position value finish) :
    position < finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxSourceLength := by
  cases parsed with
  | zero bound zero ending => simp only [maxSourceLength]; omega
  | positive bound nonzero digitBound rest =>
      have facts := decimalTail_bounds rest
      omega

theorem decimalAt_unique {text : Source} {position left right leftEnd rightEnd : Nat}
    (first : DecimalAt text position left leftEnd) (second : DecimalAt text position right rightEnd) :
    left = right ∧ leftEnd = rightEnd := by
  have same := (decimalAt_complete first).symm.trans (decimalAt_complete second)
  cases same
  exact ⟨rfl, rfl⟩

def literalLength (text : Source) (position : Nat) : Nat :=
  if position > text.length then 0
  else if Cursor.byteAt text position = 34 then
    if position < text.length ∧ Cursor.byteAt text (position + 1) = 34 then
      1 + literalLength text (position + 2)
    else 0
  else if Output.printable (Cursor.byteAt text position) then 1 + literalLength text (position + 1)
  else 0
termination_by text.length + 1 - position
decreasing_by all_goals omega

theorem literalLength_decodes {text value : Source} {position finish : Nat}
    (parsed : Output.LiteralAt text position value finish) : literalLength text position = value.length := by
  induction parsed with
  | close bound quote ending => rw [literalLength]; simp [Nat.not_lt.mpr bound, quote, ending]
  | quote bound quote next previous ih =>
      rw [literalLength]
      simp [Nat.not_lt.mpr (Nat.le_of_lt bound), quote, bound, next, ih, Nat.add_comm]
  | character bound different character previous ih =>
      rw [literalLength]
      simp [Nat.not_lt.mpr bound, different, character, ih, Nat.add_comm]

theorem literalLength_bound (text : Source) (position : Nat) :
    literalLength text position ≤ text.length + 1 - position := by
  rw [literalLength]
  by_cases ending : position > text.length
  · simp [ending]
  · simp only [ending, ↓reduceIte]
    by_cases quote : Cursor.byteAt text position = 34
    · simp only [quote, ↓reduceIte]
      by_cases doubled : position < text.length ∧ Cursor.byteAt text (position + 1) = 34
      · simp [doubled]
        have rest := literalLength_bound text (position + 2)
        omega
      · simp [doubled]
    · simp only [quote, ↓reduceIte]
      by_cases printable : Output.printable (Cursor.byteAt text position) = true
      · simp only [printable, ↓reduceIte]
        have rest := literalLength_bound text (position + 1)
        omega
      · simp [printable]
termination_by text.length + 1 - position
decreasing_by all_goals omega

end Silver.Guarded
