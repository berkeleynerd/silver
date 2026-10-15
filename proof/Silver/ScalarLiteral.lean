module

public import Silver.GuardedDecimal

@[expose] public section

/-! Bounded Ada integer literals. Separators, base delimiters and exponents
remain lexical structure; the result is the inherited natural-number value. -/
namespace Silver.ScalarLiteral

def maxMagnitude : Nat := 2147483648

set_option backward.dsimp.instances true

abbrev Result := Guarded.DecimalResult
abbrev invalid : Result := Guarded.invalidDecimal

def digitValue (byte : Nat) : Nat :=
  if 48 ≤ byte ∧ byte ≤ 57 then byte - 48
  else if 65 ≤ byte ∧ byte ≤ 70 then byte - 65 + 10
  else if 97 ≤ byte ∧ byte ≤ 102 then byte - 97 + 10
  else 16

theorem digitValue_bound (byte : Nat) : digitValue byte ≤ 16 := by
  unfold digitValue
  split <;> (try omega)
  split <;> (try omega)
  split <;> omega

def digitsTail (text : Source) (base position value : Nat) (needDigit : Bool) : Result :=
  if position > text.length then if needDigit then invalid else ⟨position, value⟩
  else
    let digit := digitValue (Cursor.byteAt text position)
    if digit < base then
      if value > (maxMagnitude - digit) / base then invalid
      else digitsTail text base (position + 1) (value * base + digit) false
    else if Cursor.byteAt text position = 95 then
      if needDigit then invalid else digitsTail text base (position + 1) value true
    else if needDigit then invalid else ⟨position, value⟩
termination_by text.length + 1 - position
decreasing_by all_goals omega

def numeral (text : Source) (position base : Nat) : Result :=
  if position = 0 then invalid else digitsTail text base position 0 true

structure Mantissa where
  after : Nat
  value : Nat
  base : Nat
  deriving DecidableEq, Repr

def mantissa (text : Source) (position : Nat) : Mantissa :=
  let leading := numeral text position 10
  if leading.after = 0 then ⟨0, 0, 10⟩ else
  if leading.after ≤ text.length ∧
      (Cursor.byteAt text leading.after = 35 ∨ Cursor.byteAt text leading.after = 58) then
    if leading.value < 2 ∨ 16 < leading.value then ⟨0, 0, 10⟩ else
    let number := numeral text (leading.after + 1) leading.value
    if number.after = 0 then ⟨0, 0, 10⟩ else
    if number.after > text.length ∨ Cursor.byteAt text number.after ≠ Cursor.byteAt text leading.after
    then ⟨0, 0, 10⟩ else ⟨number.after + 1, number.value, leading.value⟩
  else ⟨leading.after, leading.value, 10⟩

def scale (base value : Nat) : Nat → Option Nat
  | 0 => some value
  | exponent + 1 =>
      if value > maxMagnitude / base then none
      else scale base (value * base) exponent

def exponentStart (text : Source) (position : Nat) : Nat :=
  if position ≤ text.length ∧ Cursor.byteAt text position = 43 then position + 1 else position

def powerAt (text : Source) (number : Mantissa) : Result :=
  if number.after ≤ text.length ∧
      (Cursor.byteAt text number.after = 69 ∨ Cursor.byteAt text number.after = 101) then
    let exponent := numeral text (exponentStart text (number.after + 1)) 10
    if exponent.after = 0 then invalid else
    match scale number.base number.value exponent.value with
    | none => invalid
    | some value => ⟨exponent.after, value⟩
  else ⟨number.after, number.value⟩

def read (text : Source) (position : Nat) : Result :=
  let number := mantissa text position
  if number.after = 0 then invalid else
  let powered := powerAt text number
  if powered.after = 0 ∨ (powered.after ≤ text.length ∧ identifierCharacter (Cursor.byteAt text powered.after))
  then invalid else powered

/-- Successful digit scanning is monotone, including underscores; the starting
call requires a digit, so a successful numeral consumes at least one byte. -/
theorem digitsTail_nondecreasing (text : Source) (base position value : Nat) (need : Bool)
    (accepted : (digitsTail text base position value need).after ≠ 0) :
    position ≤ (digitsTail text base position value need).after := by
  rw [digitsTail] at accepted ⊢
  dsimp only at accepted ⊢
  by_cases ended : position > text.length
  · simp only [ended, ↓reduceIte] at accepted ⊢
    cases need <;> simp_all [invalid, Guarded.invalidDecimal]
  · simp only [ended, ↓reduceIte] at accepted ⊢
    by_cases digit : digitValue (Cursor.byteAt text position) < base
    · simp only [digit, ↓reduceIte] at accepted ⊢
      by_cases overflow : value > (maxMagnitude - digitValue (Cursor.byteAt text position)) / base
      · simp [overflow, invalid, Guarded.invalidDecimal] at accepted
      · simp only [overflow, ↓reduceIte] at accepted ⊢
        have next := digitsTail_nondecreasing text base (position + 1)
          (value * base + digitValue (Cursor.byteAt text position)) false accepted
        omega
    · simp only [digit, ↓reduceIte] at accepted ⊢
      by_cases separator : Cursor.byteAt text position = 95
      · simp only [separator, ↓reduceIte] at accepted ⊢
        cases need with
        | true => simp [invalid, Guarded.invalidDecimal] at accepted
        | false =>
          simp only [Bool.false_eq_true, ↓reduceIte] at accepted ⊢
          have next := digitsTail_nondecreasing text base (position + 1) value true accepted
          omega
      · simp only [separator, ↓reduceIte] at accepted ⊢
        cases need <;> simp_all [invalid, Guarded.invalidDecimal]

termination_by text.length + 1 - position
decreasing_by all_goals omega


/-- The ordinary positional-value overflow test, stated in unbounded naturals. -/
theorem accumulation_fits {base digit value : Nat}
    (positive : 0 < base) (digitBound : digit ≤ maxMagnitude) :
    ¬ value > (maxMagnitude - digit) / base ↔ value * base + digit ≤ maxMagnitude := by
  rw [Nat.not_lt, Nat.le_div_iff_mul_le positive]
  omega

/-- A grammar derivation exposes each digit, each single separator and the
mathematical positional value. Its arithmetic bound is the selected literal
fragment, independent of the implementation's division-based overflow test. -/
inductive DigitsAt (text : Source) (base : Nat) : Nat → Nat → Bool → Nat → Nat → Prop
  | ending {position value : Nat} : position = text.length + 1 → value ≤ maxMagnitude →
      DigitsAt text base position value false value position
  | stopped {position value : Nat} : position ≤ text.length → value ≤ maxMagnitude →
      ¬ digitValue (Cursor.byteAt text position) < base → Cursor.byteAt text position ≠ 95 →
      DigitsAt text base position value false value position
  | digit {position start value finish : Nat} {need : Bool} : position ≤ text.length →
      digitValue (Cursor.byteAt text position) < base →
      start * base + digitValue (Cursor.byteAt text position) ≤ maxMagnitude →
      DigitsAt text base (position + 1) (start * base + digitValue (Cursor.byteAt text position)) false value finish →
      DigitsAt text base position start need value finish
  | separator {position start value finish : Nat} : position ≤ text.length →
      Cursor.byteAt text position = 95 → base ≤ 16 →
      DigitsAt text base (position + 1) start true value finish →
      DigitsAt text base position start false value finish

theorem digitsAt_complete {text : Source} {base position start value finish : Nat} {need : Bool}
    (basePositive : 0 < base) (baseBound : base ≤ 16)
    (parsed : DigitsAt text base position start need value finish) :
    digitsTail text base position start need = ⟨finish, value⟩ := by
  induction parsed with
  | ending last bounded => rw [digitsTail]; simp [last]
  | stopped last bounded notDigit notSeparator =>
      rw [digitsTail]
      simp [Nat.not_lt.mpr last, notDigit, notSeparator]
  | @digit position start value finish need last digit bounded rest ih =>
      have safe := (accumulation_fits basePositive
        (Nat.le_trans (digitValue_bound _) (by decide : 16 ≤ maxMagnitude))).mpr bounded
      rw [digitsTail]
      simp [Nat.not_lt.mpr last, digit, safe, ih]
  | @separator position start value finish last separator baseBound rest ih =>
      rw [digitsTail]
      have notDigit : ¬ digitValue (Cursor.byteAt text position) < base := by
        rw [separator]
        change ¬ 16 < base
        omega
      simp only [Nat.not_lt.mpr last, ↓reduceIte]
      rw [ite_eq_right notDigit]
      simp [separator, ih]

theorem digitsTail_sound (text : Source) (base position value : Nat) (need : Bool)
    (basePositive : 0 < base) (baseBound : base ≤ 16)
    (positionBound : position ≤ text.length + 1) (valueBound : value ≤ maxMagnitude)
    (accepted : (digitsTail text base position value need).after ≠ 0) :
    DigitsAt text base position value need (digitsTail text base position value need).value
      (digitsTail text base position value need).after := by
  by_cases ended : position > text.length
  · rw [digitsTail]
    simp only [ended, ↓reduceIte]
    cases need with
    | true => rw [digitsTail] at accepted; simp [ended, invalid, Guarded.invalidDecimal] at accepted
    | false => exact .ending (by omega) valueBound
  · by_cases digit : digitValue (Cursor.byteAt text position) < base
    · by_cases overflow : value > (maxMagnitude - digitValue (Cursor.byteAt text position)) / base
      · rw [digitsTail] at accepted
        simp [ended, digit, overflow, invalid, Guarded.invalidDecimal] at accepted
      · have bounded := (accumulation_fits basePositive
          (Nat.le_trans (digitValue_bound _) (by decide : 16 ≤ maxMagnitude))).mp overflow
        have equation : digitsTail text base position value need =
            digitsTail text base (position + 1) (value * base + digitValue (Cursor.byteAt text position)) false := by
          rw [digitsTail]; simp [ended, digit, overflow]
        rw [equation] at accepted ⊢
        exact .digit (by omega) digit bounded
          (digitsTail_sound text base _ _ false basePositive baseBound (by omega) bounded accepted)
    · by_cases separator : Cursor.byteAt text position = 95
      · cases need with
        | true => rw [digitsTail] at accepted; simp only [ended, ↓reduceIte] at accepted; rw [ite_eq_right digit] at accepted; simp [separator, invalid, Guarded.invalidDecimal] at accepted
        | false =>
            have equation : digitsTail text base position value false =
                digitsTail text base (position + 1) value true := by
              rw [digitsTail]; simp only [ended, ↓reduceIte]; rw [ite_eq_right digit]; simp [separator]
            rw [equation] at accepted ⊢
            exact .separator (by omega) separator baseBound
              (digitsTail_sound text base _ value true basePositive baseBound (by omega) valueBound accepted)
      · cases need with
        | true => rw [digitsTail] at accepted; simp only [ended, ↓reduceIte] at accepted; rw [ite_eq_right digit] at accepted; simp [separator, invalid, Guarded.invalidDecimal] at accepted
        | false =>
            rw [digitsTail]
            simpa only [ended, digit, separator, ↓reduceIte, Bool.false_eq_true] using
              DigitsAt.stopped (text := text) (base := base) (position := position) (value := value)
                (by omega) valueBound digit separator
termination_by text.length + 1 - position
decreasing_by all_goals omega

theorem digitsAt_bounds {text : Source} {base position start value finish : Nat} {need : Bool}
    (parsed : DigitsAt text base position start need value finish) :
    position ≤ finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxMagnitude ∧
      (need = true → position < finish) := by
  induction parsed with
  | ending last bounded => simp only [Bool.false_eq_true, false_implies, and_true]; omega
  | stopped last bounded _ _ => simp only [Bool.false_eq_true, false_implies, and_true]; omega
  | digit last digit bounded rest ih => omega
  | separator last separator bounded rest ih => omega

def NumeralAt (text : Source) (base position value finish : Nat) : Prop :=
  0 < position ∧ 2 ≤ base ∧ base ≤ 16 ∧ DigitsAt text base position 0 true value finish

theorem numeral_complete {text : Source} {base position value finish : Nat}
    (parsed : NumeralAt text base position value finish) : numeral text position base = ⟨finish, value⟩ := by
  rw [numeral, ite_eq_right (Nat.ne_of_gt parsed.1)]
  exact digitsAt_complete (Nat.lt_of_lt_of_le (by decide : 0 < 2) parsed.2.1) parsed.2.2.1 parsed.2.2.2

theorem numeral_sound {text : Source} {base position : Nat}
    (baseFirst : 2 ≤ base) (baseLast : base ≤ 16) (positionBound : position ≤ text.length + 1)
    (accepted : (numeral text position base).after ≠ 0) :
    NumeralAt text base position (numeral text position base).value (numeral text position base).after := by
  have positive : position ≠ 0 := by intro zero; simp [numeral, zero, invalid, Guarded.invalidDecimal] at accepted
  simp only [numeral, positive, ↓reduceIte] at accepted ⊢
  refine ⟨by omega, baseFirst, baseLast, ?_⟩
  exact digitsTail_sound text base position 0 true (by omega) baseLast positionBound (by decide) accepted

theorem numeral_bounds {text : Source} {base position value finish : Nat}
    (parsed : NumeralAt text base position value finish) :
    position < finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxMagnitude := by
  have bounds := digitsAt_bounds parsed.2.2.2
  exact ⟨bounds.2.2.2 rfl, bounds.2.1, bounds.2.2.1⟩


abbrev DelimiterAt (text : Source) (position : Nat) : Prop :=
  position ≤ text.length ∧ (Cursor.byteAt text position = 35 ∨ Cursor.byteAt text position = 58)

inductive MantissaAt (text : Source) (position : Nat) : Nat → Nat → Nat → Prop
  | decimal {value finish : Nat} : NumeralAt text 10 position value finish →
      ¬ DelimiterAt text finish → MantissaAt text position value 10 finish
  | based {base value headEnd numberEnd : Nat} : NumeralAt text 10 position base headEnd →
      DelimiterAt text headEnd → NumeralAt text base (headEnd + 1) value numberEnd →
      numberEnd ≤ text.length → Cursor.byteAt text numberEnd = Cursor.byteAt text headEnd →
      MantissaAt text position value base (numberEnd + 1)

theorem mantissa_complete {text : Source} {position value base finish : Nat}
    (parsed : MantissaAt text position value base finish) : mantissa text position = ⟨finish, value, base⟩ := by
  cases parsed with
  | decimal numeral noDelimiter =>
      have afterPositive := (numeral_bounds numeral).1
      have positionPositive := numeral.1
      simp only [mantissa, numeral_complete numeral]
      simp [show finish ≠ 0 by omega, noDelimiter]
  | @based base value headEnd numberEnd leading delimiter number last matched =>
      have leadingPositive := (numeral_bounds leading).1
      have numberPositive := (numeral_bounds number).1
      have lower := number.2.1
      have upper := number.2.2.1
      have headPositive : headEnd ≠ 0 := by omega
      have numberNonzero : numberEnd ≠ 0 := by omega
      simp [mantissa, numeral_complete leading, headPositive, delimiter,
        Nat.not_lt.mpr lower, Nat.not_lt.mpr upper, numeral_complete number,
        numberNonzero, Nat.not_lt.mpr last, matched]


theorem mantissa_sound {text : Source} {position : Nat}
    (positionBound : position ≤ text.length + 1)
    (accepted : (mantissa text position).after ≠ 0) :
    MantissaAt text position (mantissa text position).value (mantissa text position).base
      (mantissa text position).after := by
  have leadingPositive : (numeral text position 10).after ≠ 0 := by
    intro failed
    simp only [mantissa, failed, ↓reduceIte, ne_eq, not_true_eq_false] at accepted
  have leading := numeral_sound (by decide : 2 ≤ 10) (by decide : 10 ≤ 16) positionBound leadingPositive
  by_cases delimiter : DelimiterAt text (numeral text position 10).after
  · have baseFits : ¬ ((numeral text position 10).value < 2 ∨ 16 < (numeral text position 10).value) := by
      intro invalidBase
      simp only [mantissa, leadingPositive, delimiter, and_self, invalidBase, ↓reduceIte,
        ne_eq, not_true_eq_false] at accepted
    have baseFirst : 2 ≤ (numeral text position 10).value := by omega
    have baseLast : (numeral text position 10).value ≤ 16 := by omega
    have numberPositive : (numeral text ((numeral text position 10).after + 1) (numeral text position 10).value).after ≠ 0 := by
      intro failed
      simp only [mantissa, leadingPositive, delimiter, and_self, baseFits, failed, ↓reduceIte,
        ne_eq, not_true_eq_false] at accepted
    have number := numeral_sound baseFirst baseLast (by have bound := delimiter.1; omega) numberPositive
    have matched : ¬ ((numeral text ((numeral text position 10).after + 1) (numeral text position 10).value).after > text.length ∨
        Cursor.byteAt text (numeral text ((numeral text position 10).after + 1) (numeral text position 10).value).after ≠
          Cursor.byteAt text (numeral text position 10).after) := by
      intro badClose
      simp only [mantissa, leadingPositive, delimiter, and_self, baseFits, numberPositive, badClose,
        ↓reduceIte, ne_eq, not_true_eq_false] at accepted
    have last : (numeral text ((numeral text position 10).after + 1) (numeral text position 10).value).after ≤ text.length := by omega
    have closing : Cursor.byteAt text (numeral text ((numeral text position 10).after + 1) (numeral text position 10).value).after =
        Cursor.byteAt text (numeral text position 10).after := by omega
    simpa only [mantissa, leadingPositive, delimiter, and_self, baseFits, numberPositive, matched, ↓reduceIte] using
      MantissaAt.based leading delimiter number last closing
  · simpa only [mantissa, leadingPositive, delimiter, ↓reduceIte] using MantissaAt.decimal leading delimiter

theorem mantissa_bounds {text : Source} {position value base finish : Nat}
    (parsed : MantissaAt text position value base finish) :
    position < finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxMagnitude ∧ 2 ≤ base ∧ base ≤ 16 := by
  cases parsed with
  | decimal number _ =>
      have bounds := numeral_bounds number
      exact ⟨bounds.1, bounds.2.1, bounds.2.2, by decide, by decide⟩
  | based leading delimiter number last matched =>
      have leadingBounds := numeral_bounds leading
      have bounds := numeral_bounds number
      exact ⟨by omega, by omega, bounds.2.2, number.2.1, number.2.2.1⟩

theorem scale_value {base exponent value result : Nat}
    (accepted : scale base value exponent = some result) : result = value * base ^ exponent := by
  induction exponent generalizing value with
  | zero => simpa only [scale, Option.some.injEq, Nat.pow_zero, Nat.mul_one] using accepted.symm
  | succ exponent ih =>
      simp only [scale] at accepted
      split at accepted
      · contradiction
      · have rest := ih accepted
        simpa only [Nat.pow_succ, Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm] using rest

theorem scale_bound {base exponent value result : Nat} (positive : 0 < base)
    (bounded : value ≤ maxMagnitude) (accepted : scale base value exponent = some result) :
    result ≤ maxMagnitude := by
  induction exponent generalizing value with
  | zero => cases accepted; exact bounded
  | succ exponent ih =>
      simp only [scale] at accepted
      split at accepted
      · contradiction
      · rename_i noOverflow
        have nextBound : value * base ≤ maxMagnitude :=
          (Nat.le_div_iff_mul_le positive).mp (Nat.not_lt.mp noOverflow)
        exact ih nextBound accepted


theorem scale_complete {base value exponent : Nat} (positive : 0 < base)
    (fits : value * base ^ exponent ≤ maxMagnitude) :
    scale base value exponent = some (value * base ^ exponent) := by
  induction exponent generalizing value with
  | zero => simp [scale]
  | succ exponent ih =>
      have one : 1 ≤ base ^ exponent := Nat.one_le_pow exponent base positive
      have lower : value * base ≤ value * base ^ (exponent + 1) := by
        have bound := Nat.mul_le_mul_left (value * base) one
        simpa only [Nat.mul_one, Nat.pow_succ, Nat.mul_assoc, Nat.mul_comm, Nat.mul_left_comm] using bound
      have nextBound := Nat.le_trans lower fits
      have noOverflow : ¬ value > maxMagnitude / base :=
        Nat.not_lt.mpr ((Nat.le_div_iff_mul_le positive).mpr nextBound)
      rw [scale, ite_eq_right noOverflow]
      have result := ih (value := value * base)
        (by simpa only [Nat.pow_succ, Nat.mul_assoc, Nat.mul_comm, Nat.mul_left_comm] using fits)
      simpa only [Nat.pow_succ, Nat.mul_assoc, Nat.mul_comm, Nat.mul_left_comm] using result

/-- The native scanner handles zero directly and rejects an exponent above 31
for a positive mantissa. This is a proved shortcut, not an exponent-sized loop. -/
theorem scale_zero (base exponent : Nat) (positive : 0 < base) :
    scale base 0 exponent = some 0 := by
  simpa using scale_complete (value := 0) (exponent := exponent) positive (by simp)

theorem scale_large_none {base value exponent : Nat} (baseBound : 2 ≤ base)
    (valuePositive : 0 < value) (valueBound : value ≤ maxMagnitude)
    (large : 31 < exponent) : scale base value exponent = none := by
  cases result : scale base value exponent with
  | none => rfl
  | some output =>
      have bounded := scale_bound (by omega : 0 < base) valueBound result
      have meaning := scale_value result
      have powerBound : 2 ^ 32 ≤ base ^ exponent :=
        Nat.le_trans (Nat.pow_le_pow_left baseBound 32)
          (Nat.pow_le_pow_right (by omega : 0 < base) (by omega))
      have productBound : base ^ exponent ≤ value * base ^ exponent := by
        simpa using Nat.mul_le_mul_right (base ^ exponent) valuePositive
      have fixed : maxMagnitude < 2 ^ 32 := by decide
      omega

theorem numeral_first_digit {text : Source} {base position value finish : Nat}
    (parsed : NumeralAt text base position value finish) :
    position ≤ text.length ∧ digitValue (Cursor.byteAt text position) < base := by
  cases parsed.2.2.2 with
  | digit last digit _ _ => exact ⟨last, digit⟩

inductive ExponentAt (text : Source) (position : Nat) : Nat → Nat → Prop
  | unsigned {value finish : Nat} : NumeralAt text 10 position value finish → ExponentAt text position value finish
  | positive {value finish : Nat} : position ≤ text.length → Cursor.byteAt text position = 43 →
      NumeralAt text 10 (position + 1) value finish → ExponentAt text position value finish

theorem exponent_complete {text : Source} {position value finish : Nat}
    (parsed : ExponentAt text position value finish) :
    numeral text (exponentStart text position) 10 = ⟨finish, value⟩ := by
  cases parsed with
  | unsigned number =>
      have digit := (numeral_first_digit number).2
      have notPlus : Cursor.byteAt text position ≠ 43 := by
        intro plus
        rw [plus] at digit
        change 16 < 10 at digit
        contradiction
      simpa only [exponentStart, notPlus, and_false, ↓reduceIte] using numeral_complete number
  | positive last plus number =>
      simpa only [exponentStart, last, plus, and_self, ↓reduceIte] using numeral_complete number

theorem exponent_sound {text : Source} {position : Nat}
    (positionBound : position ≤ text.length + 1)
    (accepted : (numeral text (exponentStart text position) 10).after ≠ 0) :
    ExponentAt text position (numeral text (exponentStart text position) 10).value
      (numeral text (exponentStart text position) 10).after := by
  by_cases plus : position ≤ text.length ∧ Cursor.byteAt text position = 43
  · simp only [exponentStart, plus, and_self, ↓reduceIte] at accepted ⊢
    exact .positive plus.1 plus.2 (numeral_sound (by decide) (by decide) (by have last := plus.1; omega) accepted)
  · simp only [exponentStart, plus, ↓reduceIte] at accepted ⊢
    exact .unsigned (numeral_sound (by decide) (by decide) positionBound accepted)

theorem exponent_bounds {text : Source} {position value finish : Nat}
    (parsed : ExponentAt text position value finish) :
    position < finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxMagnitude := by
  cases parsed with
  | unsigned number => exact numeral_bounds number
  | positive last plus number =>
      have bounds := numeral_bounds number
      exact ⟨by omega, bounds.2⟩

abbrev ExponentMarker (text : Source) (position : Nat) : Prop :=
  position ≤ text.length ∧ (Cursor.byteAt text position = 69 ∨ Cursor.byteAt text position = 101)

inductive PoweredAt (text : Source) (number : Mantissa) : Nat → Nat → Prop
  | unchanged : ¬ ExponentMarker text number.after → PoweredAt text number number.value number.after
  | exponent {exponent finish : Nat} : ExponentMarker text number.after →
      ExponentAt text (number.after + 1) exponent finish →
      number.value * number.base ^ exponent ≤ maxMagnitude →
      PoweredAt text number (number.value * number.base ^ exponent) finish

theorem powered_complete {text : Source} {number : Mantissa} {value finish : Nat}
    (basePositive : 0 < number.base) (parsed : PoweredAt text number value finish) :
    powerAt text number = ⟨finish, value⟩ := by
  cases parsed with
  | unchanged noExponent => simp only [powerAt, noExponent, ↓reduceIte]
  | exponent marker exponent bounded =>
      have progress := (exponent_bounds exponent).1
      simp only [powerAt, marker, and_self, ↓reduceIte, exponent_complete exponent,
        show finish ≠ 0 by omega, scale_complete basePositive bounded]

theorem powered_sound {text : Source} {number : Mantissa}
    (basePositive : 0 < number.base) (valueBound : number.value ≤ maxMagnitude)
    (_positionBound : number.after ≤ text.length + 1)
    (accepted : (powerAt text number).after ≠ 0) :
    PoweredAt text number (powerAt text number).value (powerAt text number).after := by
  by_cases marker : ExponentMarker text number.after
  · have exponentPositive : (numeral text (exponentStart text (number.after + 1)) 10).after ≠ 0 := by
      intro failed
      simp only [powerAt, marker, and_self, failed, ↓reduceIte, invalid, Guarded.invalidDecimal,
        ne_eq, not_true_eq_false] at accepted
    have exponent := exponent_sound (by have last := marker.1; omega) exponentPositive
    cases scaled : scale number.base number.value (numeral text (exponentStart text (number.after + 1)) 10).value with
    | none => simp only [powerAt, marker, and_self, exponentPositive, scaled, ↓reduceIte,
        invalid, Guarded.invalidDecimal, ne_eq, not_true_eq_false] at accepted
    | some value =>
        have mathematical := scale_value scaled
        have bounded := scale_bound basePositive valueBound scaled
        have derivation := PoweredAt.exponent marker exponent (mathematical ▸ bounded)
        simpa only [powerAt, marker, and_self, exponentPositive, scaled, ↓reduceIte, ← mathematical] using derivation
  · simpa only [powerAt, marker, ↓reduceIte] using PoweredAt.unchanged marker

theorem powered_bounds {text : Source} {number : Mantissa} {value finish : Nat}
    (positionBound : number.after ≤ text.length + 1) (valueBound : number.value ≤ maxMagnitude)
    (parsed : PoweredAt text number value finish) :
    number.after ≤ finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxMagnitude := by
  cases parsed with
  | unchanged _ => exact ⟨Nat.le_refl _, positionBound, valueBound⟩
  | exponent marker exponent bounded =>
      have bounds := exponent_bounds exponent
      exact ⟨by omega, bounds.2.1, bounded⟩


/-- A whole integer token: one decimal or based mantissa, an optional
nonnegative exponent, and no attached identifier character. The enclosing
language grammar determines the next token and any required trivia. -/
inductive IntegerAt (text : Source) (position : Nat) : Nat → Nat → Prop
  | literal {number : Mantissa} {value finish : Nat} :
      MantissaAt text position number.value number.base number.after →
      PoweredAt text number value finish →
      ¬ (finish ≤ text.length ∧ identifierCharacter (Cursor.byteAt text finish) = true) →
      IntegerAt text position value finish

theorem integer_bounds {text : Source} {position value finish : Nat}
    (parsed : IntegerAt text position value finish) :
    position < finish ∧ finish ≤ text.length + 1 ∧ value ≤ maxMagnitude := by
  cases parsed with
  | literal number powered boundary =>
      have first := mantissa_bounds number
      have last := powered_bounds first.2.1 first.2.2.1 powered
      exact ⟨Nat.lt_of_lt_of_le first.1 last.1, last.2⟩

theorem read_complete {text : Source} {position value finish : Nat}
    (parsed : IntegerAt text position value finish) : read text position = ⟨finish, value⟩ := by
  have progress := (integer_bounds parsed).1
  cases parsed with
  | @literal number value finish mantissa powered boundary =>
      have first := mantissa_bounds mantissa
      have positive : number.after ≠ 0 := by omega
      have reconstructed : ScalarLiteral.mantissa text position = number := by
        cases number
        exact mantissa_complete mantissa
      have poweredEquation := powered_complete (by have base := first.2.2.2.1; omega) powered
      simp only [read, reconstructed, positive, ↓reduceIte, poweredEquation,
        show finish ≠ 0 by omega, boundary, or_self]

theorem read_sound {text : Source} {position : Nat} (positionBound : position ≤ text.length + 1)
    (accepted : (read text position).after ≠ 0) :
    IntegerAt text position (read text position).value (read text position).after := by
  have mantissaPositive : (mantissa text position).after ≠ 0 := by
    intro failed
    simp only [read, failed, ↓reduceIte, invalid, Guarded.invalidDecimal, ne_eq, not_true_eq_false] at accepted
  have number := mantissa_sound positionBound mantissaPositive
  have bounds := mantissa_bounds number
  have validEnd : ¬ ((powerAt text (mantissa text position)).after = 0 ∨
      ((powerAt text (mantissa text position)).after ≤ text.length ∧
       identifierCharacter (Cursor.byteAt text (powerAt text (mantissa text position)).after) = true)) := by
    intro bad
    simp only [read, mantissaPositive, bad, ↓reduceIte, invalid, Guarded.invalidDecimal,
      ne_eq, not_true_eq_false] at accepted
  have poweredPositive : (powerAt text (mantissa text position)).after ≠ 0 := fun h => validEnd (Or.inl h)
  have boundary : ¬ ((powerAt text (mantissa text position)).after ≤ text.length ∧
      identifierCharacter (Cursor.byteAt text (powerAt text (mantissa text position)).after) = true) :=
    fun h => validEnd (Or.inr h)
  have powered := powered_sound (by have lower := bounds.2.2.2.1; omega) bounds.2.2.1 bounds.2.1 poweredPositive
  simpa only [read, mantissaPositive, validEnd, ↓reduceIte] using IntegerAt.literal number powered boundary

theorem integer_unique {text : Source} {position first second firstEnd secondEnd : Nat}
    (left : IntegerAt text position first firstEnd) (right : IntegerAt text position second secondEnd) :
    first = second ∧ firstEnd = secondEnd := by
  have same := (read_complete left).symm.trans (read_complete right)
  cases same
  exact ⟨rfl, rfl⟩

theorem integer_iff_read {text : Source} {position value finish : Nat}
    (positionBound : position ≤ text.length + 1) :
    IntegerAt text position value finish ↔ read text position = ⟨finish, value⟩ ∧ finish ≠ 0 := by
  constructor
  · intro parsed
    exact ⟨read_complete parsed, by have progress := (integer_bounds parsed).1; omega⟩
  · rintro ⟨equation, positive⟩
    have accepted : (read text position).after ≠ 0 := by simpa only [equation] using positive
    simpa only [equation] using read_sound positionBound accepted

instance (text : Source) (position value finish : Nat) : Decidable (IntegerAt text position value finish) :=
  if bounded : position ≤ text.length + 1 then
    decidable_of_iff (read text position = ⟨finish, value⟩ ∧ finish ≠ 0) (integer_iff_read bounded).symm
  else isFalse (fun parsed => by have bounds := integer_bounds parsed; omega)

theorem integer_exists_iff_read {text : Source} {position : Nat}
    (positionBound : position ≤ text.length + 1) :
    (∃ value finish, IntegerAt text position value finish) ↔ (read text position).after ≠ 0 := by
  constructor
  · rintro ⟨value, finish, parsed⟩
    rw [read_complete parsed]
    have progress := (integer_bounds parsed).1
    dsimp only
    omega
  · intro accepted
    exact ⟨_, _, read_sound positionBound accepted⟩

instance (text : Source) (position : Nat) : Decidable (∃ value finish, IntegerAt text position value finish) :=
  if bounded : position ≤ text.length + 1 then
    decidable_of_iff ((read text position).after ≠ 0) (integer_exists_iff_read bounded).symm
  else isFalse (fun ⟨_, _, parsed⟩ => by have bounds := integer_bounds parsed; omega)

end Silver.ScalarLiteral
