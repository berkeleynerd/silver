module

public import Silver.IntegerLiteralExpressions

@[expose] public section

namespace Silver.IntegerLiteral.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ maxSourceLength
def ValidBase (base : Nat) : Prop := 2 ≤ base ∧ base ≤ 16

def tailEquation (calls : Calls) (text : Source) (base position value : Nat) (need : Bool) : Result :=
  if position > text.length then if need then invalid else ⟨position, value⟩
  else if calls.digit (Cursor.byteAt text position) < base then
    if value > (maxSourceLength - calls.digit (Cursor.byteAt text position)) / base then invalid
    else calls.tail text base (position + 1) (value * base + calls.digit (Cursor.byteAt text position)) false
  else if Cursor.byteAt text position = 95 then
    if need then invalid else calls.tail text base (position + 1) value true
  else if need then invalid else ⟨position, value⟩

def mantissaEquation (calls : Calls) (text : Source) (position : Nat) : Mantissa :=
  let leading := calls.numeral text position 10
  if leading.after = 0 then ⟨0, 0, 10⟩ else
  if leading.after ≤ text.length ∧
      (Cursor.byteAt text leading.after = 35 ∨ Cursor.byteAt text leading.after = 58) then
    if leading.value < 2 ∨ 16 < leading.value then ⟨0, 0, 10⟩ else
    let number := calls.numeral text (leading.after + 1) leading.value
    if number.after = 0 then ⟨0, 0, 10⟩ else
    if number.after > text.length ∨ Cursor.byteAt text number.after ≠ Cursor.byteAt text leading.after
    then ⟨0, 0, 10⟩ else ⟨number.after + 1, number.value, leading.value⟩
  else ⟨leading.after, leading.value, 10⟩

def scaleEquation (calls : Calls) (base value exponent : Nat) : Scaled :=
  if exponent = 0 then ⟨true, value⟩
  else if value > maxSourceLength / base then invalidScaled
  else calls.scale base (value * base) (exponent - 1)

def exponentEquation (calls : Calls) (text : Source) (number : Mantissa) : Result :=
  if number.after ≤ text.length ∧
      (Cursor.byteAt text number.after = 101 ∨ Cursor.byteAt text number.after = 69) then
    let exponent := calls.numeral text (calls.start text (number.after + 1)) 10
    if exponent.after = 0 then invalid else
    let scaled := calls.scale number.base number.value exponent.value
    if !scaled.valid then invalid else ⟨exponent.after, scaled.value⟩
  else ⟨number.after, number.value⟩

def modelEquation (calls : Calls) (text : Source) (position : Nat) : Result :=
  let number := calls.mantissa text position
  if number.after = 0 then invalid else
  let result := calls.exponent text number
  if result.after = 0 ∨ (result.after ≤ text.length ∧ calls.identifier (Cursor.byteAt text result.after))
  then invalid else result

theorem digit_denotation (calls : Calls) (item : Nat) :
    digitBody.eval calls ({item} : Context).locals = digitValue item := by
  dsimp +instances only [digitBody, Expr.eval, Context.locals]
  simp only [decide_eq_true_eq]
  rfl

theorem tail_denotation (calls : Calls) (text : Source) (base position value : Nat) (needDigit : Bool) :
    tailBody.eval calls ({text, base, position, value, needDigit} : Context).locals =
      tailEquation calls text base position value needDigit := by
  dsimp +instances only [tailBody, Expr.eval, Context.locals, Calls.get]
  simp only [decide_eq_true_eq]
  rfl

theorem numeral_denotation (calls : Calls) (text : Source) (position base : Nat) :
    numeralBody.eval calls ({text, position, base} : Context).locals =
      if position = 0 then invalid else calls.tail text base position 0 true := by
  dsimp +instances only [numeralBody, Expr.eval, Context.locals, Calls.get]
  simp only [decide_eq_true_eq]

theorem mantissa_denotation (calls : Calls) (text : Source) (position : Nat) :
    mantissaBody.eval calls ({text, position} : Context).locals = mantissaEquation calls text position := by
  dsimp +instances only [mantissaBody, Expr.eval, Context.locals, Calls.get, Field.get, Locals.set]
  simp [mantissaEquation]

theorem scale_denotation (calls : Calls) (base value exponent : Nat) :
    scaleBody.eval calls ({base, value, exponent} : Context).locals = scaleEquation calls base value exponent := by
  dsimp +instances only [scaleBody, Expr.eval, Context.locals, Calls.get]
  simp only [decide_eq_true_eq, scaleEquation]

theorem start_denotation (calls : Calls) (text : Source) (position : Nat) :
    startBody.eval calls ({text, position} : Context).locals = exponentStart text position := by
  dsimp +instances only [startBody, Expr.eval, Context.locals]
  simp only [decide_eq_true_eq, Bool.and_eq_true, exponentStart]

theorem exponent_denotation (calls : Calls) (text : Source) (number : Mantissa) :
    exponentBody.eval calls ({text, number} : Context).locals = exponentEquation calls text number := by
  dsimp +instances only [exponentBody, Expr.eval, Context.locals, Calls.get, Field.get, Locals.set]
  simp [exponentEquation]

theorem model_denotation (calls : Calls) (text : Source) (position : Nat) :
    modelBody.eval calls ({text, position} : Context).locals = modelEquation calls text position := by
  dsimp +instances only [modelBody, Expr.eval, Context.locals, Calls.get, Field.get, Locals.set]
  simp [modelEquation]

/-- Only the rendered functional bodies and inherited identifier predicate are
interpreted here. This record assumes no numeral or membership equivalence. -/
structure Equations (calls : Calls) : Prop where
  digit : ∀ item, calls.digit item = digitBody.eval calls ({item} : Context).locals
  identifier : ∀ item, calls.identifier item = identifierCharacter item
  tail : ∀ text, ValidText text → ∀ base position value needDigit,
    ValidBase base → 0 < position → position ≤ text.length + 1 → value ≤ maxSourceLength →
    calls.tail text base position value needDigit = tailBody.eval calls ({text,base,position,value,needDigit} : Context).locals
  numeral : ∀ text, ValidText text → ∀ position base, ValidBase base → position ≤ text.length + 1 →
    calls.numeral text position base = numeralBody.eval calls ({text,position,base} : Context).locals
  mantissa : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.mantissa text position = mantissaBody.eval calls ({text,position} : Context).locals
  scale : ∀ base value exponent, ValidBase base → value ≤ maxSourceLength → exponent ≤ maxSourceLength →
    calls.scale base value exponent = scaleBody.eval calls ({base,value,exponent} : Context).locals
  start : ∀ text, ValidText text → ∀ position, 0 < position → position ≤ text.length + 1 →
    calls.start text position = startBody.eval calls ({text,position} : Context).locals
  exponent : ∀ text, ValidText text → ∀ number,
    ValidBase number.base → 0 < number.after → number.after ≤ text.length + 1 → number.value ≤ maxSourceLength →
    calls.exponent text number = exponentBody.eval calls ({text,number} : Context).locals
  model : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.model text position = modelBody.eval calls ({text,position} : Context).locals

theorem interpreted_digit (calls : Calls) (equations : Equations calls) (item : Nat) :
    calls.digit item = digitValue item := by rw [equations.digit, digit_denotation]

theorem interpreted_tail (calls : Calls) (equations : Equations calls) (text : Source) (valid : ValidText text)
    (base position value : Nat) (need : Bool) (baseValid : ValidBase base)
    (positive : 0 < position) (positionBound : position ≤ text.length + 1) (valueBound : value ≤ maxSourceLength) :
    calls.tail text base position value need = digitsTail text base position value need := by
  rw [equations.tail text valid base position value need baseValid positive positionBound valueBound, tail_denotation, digitsTail]
  unfold tailEquation
  rw [interpreted_digit calls equations]
  by_cases ended : position > text.length
  · simp only [ended, ↓reduceIte]
  · simp only [ended, ↓reduceIte]
    by_cases digit : digitValue (Cursor.byteAt text position) < base
    · simp only [digit, ↓reduceIte]
      by_cases overflow : value > (maxSourceLength - digitValue (Cursor.byteAt text position)) / base
      · simp only [overflow, ↓reduceIte]
      · simp only [overflow, ↓reduceIte]
        have basePositive : 0 < base := by have lower := baseValid.1; omega
        have bound := (accumulation_fits basePositive
          (Nat.le_trans (digitValue_bound _) (by decide : 16 ≤ maxSourceLength))).mp overflow
        exact interpreted_tail calls equations text valid base (position + 1) _ false baseValid (by omega) (by omega) bound
    · simp only [digit, ↓reduceIte]
      by_cases separator : Cursor.byteAt text position = 95
      · rw [ite_eq_left separator, ite_eq_left separator]
        cases need with
        | true => rfl
        | false => exact interpreted_tail calls equations text valid base (position + 1) value true baseValid (by omega) (by omega) valueBound
      · rw [ite_eq_right separator, ite_eq_right separator]
termination_by text.length + 1 - position
decreasing_by all_goals omega

theorem interpreted_numeral (calls : Calls) (equations : Equations calls) (text : Source) (valid : ValidText text)
    (position base : Nat) (baseValid : ValidBase base) (positionBound : position ≤ text.length + 1) :
    calls.numeral text position base = numeral text position base := by
  rw [equations.numeral text valid position base baseValid positionBound, numeral_denotation]
  unfold numeral
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    exact interpreted_tail calls equations text valid base position 0 true baseValid (by omega) positionBound (by decide)

theorem scaleResult_equation (base value exponent : Nat) :
    scaleResult base value exponent =
      if exponent = 0 then ⟨true, value⟩
      else if value > maxSourceLength / base then invalidScaled
      else scaleResult base (value * base) (exponent - 1) := by
  cases exponent with
  | zero => rfl
  | succ exponent =>
      simp only [Nat.add_eq_zero_iff, Nat.one_ne_zero, and_false, ↓reduceIte, Nat.add_sub_cancel]
      unfold scaleResult
      rw [scale]
      by_cases overflow : value > maxSourceLength / base
      · simp only [overflow, ↓reduceIte]
      · simp only [overflow, ↓reduceIte]

theorem interpreted_scale (calls : Calls) (equations : Equations calls) (base value exponent : Nat)
    (baseValid : ValidBase base) (valueBound : value ≤ maxSourceLength) (exponentBound : exponent ≤ maxSourceLength) :
    calls.scale base value exponent = scaleResult base value exponent := by
  rw [equations.scale base value exponent baseValid valueBound exponentBound, scale_denotation, scaleResult_equation]
  unfold scaleEquation
  by_cases zero : exponent = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases overflow : value > maxSourceLength / base
    · simp only [overflow, ↓reduceIte]
    · simp only [overflow, ↓reduceIte]
      have positive : 0 < base := by have lower := baseValid.1; omega
      have nextBound := (Nat.le_div_iff_mul_le positive).mp (Nat.not_lt.mp overflow)
      exact interpreted_scale calls equations base (value * base) (exponent - 1) baseValid nextBound (by omega)
termination_by exponent

theorem interpreted_mantissa (calls : Calls) (equations : Equations calls) (text : Source) (valid : ValidText text)
    (position : Nat) (positionBound : position ≤ text.length + 1) :
    calls.mantissa text position = mantissa text position := by
  rw [equations.mantissa text valid position positionBound, mantissa_denotation]
  unfold mantissaEquation mantissa
  rw [interpreted_numeral calls equations text valid position 10 (by constructor <;> decide) positionBound]
  by_cases failed : (numeral text position 10).after = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte]
    by_cases delimiter : (numeral text position 10).after ≤ text.length ∧
        (Cursor.byteAt text (numeral text position 10).after = 35 ∨ Cursor.byteAt text (numeral text position 10).after = 58)
    · simp only [delimiter]
      by_cases badBase : (numeral text position 10).value < 2 ∨ 16 < (numeral text position 10).value
      · simp only [badBase, ↓reduceIte]
      · simp only [badBase, ↓reduceIte]
        rw [interpreted_numeral calls equations text valid _ _ (by constructor <;> omega) (by omega)]
    · simp only [delimiter, ↓reduceIte]

theorem interpreted_start (calls : Calls) (equations : Equations calls) (text : Source) (valid : ValidText text)
    (position : Nat) (positive : 0 < position) (positionBound : position ≤ text.length + 1) :
    calls.start text position = exponentStart text position := by
  rw [equations.start text valid position positive positionBound, start_denotation]

theorem exponentStart_bounds (text : Source) (position : Nat) (positive : 0 < position)
    (positionBound : position ≤ text.length + 1) :
    0 < exponentStart text position ∧ exponentStart text position ≤ text.length + 1 := by
  unfold exponentStart
  split <;> omega

theorem interpreted_exponent (calls : Calls) (equations : Equations calls) (text : Source) (valid : ValidText text)
    (number : Mantissa) (baseValid : ValidBase number.base) (positive : 0 < number.after)
    (positionBound : number.after ≤ text.length + 1) (valueBound : number.value ≤ maxSourceLength) :
    calls.exponent text number = powerAt text number := by
  rw [equations.exponent text valid number baseValid positive positionBound valueBound, exponent_denotation]
  unfold exponentEquation powerAt
  simp +instances only [or_comm (a := Cursor.byteAt text number.after = 69)]
  by_cases hasExponent : number.after ≤ text.length ∧
      (Cursor.byteAt text number.after = 101 ∨ Cursor.byteAt text number.after = 69)
  · simp +instances only [hasExponent, and_self, ↓reduceIte]
    rw [interpreted_start calls equations text valid (number.after + 1) (by omega) (by omega)]
    have startBound := exponentStart_bounds text (number.after + 1) (by omega) (by omega)
    rw [interpreted_numeral calls equations text valid _ 10 (by constructor <;> decide) startBound.2]
    by_cases failed : (numeral text (exponentStart text (number.after + 1)) 10).after = 0
    · simp only [failed, ↓reduceIte]
    · simp only [failed, ↓reduceIte]
      have parsed := numeral_sound (by decide : 2 ≤ 10) (by decide : 10 ≤ 16) startBound.2 failed
      have bounds := numeral_bounds parsed
      rw [interpreted_scale calls equations _ _ _ baseValid valueBound bounds.2.2]
      unfold scaleResult
      cases scale number.base number.value (numeral text (exponentStart text (number.after + 1)) 10).value <;> rfl
  · simp +instances only [hasExponent, ↓reduceIte]

theorem interpreted_model (calls : Calls) (equations : Equations calls) (text : Source) (valid : ValidText text)
    (position : Nat) (positionBound : position ≤ text.length + 1) :
    calls.model text position = read text position := by
  rw [equations.model text valid position positionBound, model_denotation]
  unfold modelEquation read
  rw [interpreted_mantissa calls equations text valid position positionBound]
  by_cases failed : (mantissa text position).after = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte]
    have parsed := mantissa_sound positionBound failed
    have bounds := mantissa_bounds parsed
    rw [interpreted_exponent calls equations text valid _ ⟨bounds.2.2.2.1, bounds.2.2.2.2⟩
      (by omega) bounds.2.1 bounds.2.2.1, equations.identifier]

theorem exponentEquation_model (text : Source) (number : Mantissa) :
    exponentEquation modelCalls text number = powerAt text number := by
  unfold exponentEquation powerAt
  dsimp only [modelCalls]
  simp +instances only [or_comm (a := Cursor.byteAt text number.after = 69)]
  split
  · split
    · rfl
    · unfold scaleResult
      cases scale number.base number.value (numeral text (exponentStart text (number.after + 1)) 10).value <;> rfl
  · rfl

/-- The source equations have a concrete witness; none of the contract premises
are used merely as inconsistent assumptions. -/
theorem model_equations : Equations modelCalls where
  digit item := (digit_denotation modelCalls item).symm
  identifier _ := rfl
  tail text _ base position value need _ _ _ _ := by
    rw [tail_denotation]
    change digitsTail text base position value need = tailEquation modelCalls text base position value need
    rw [digitsTail]
    rfl
  numeral text _ position base _ _ := by
    rw [numeral_denotation]
    rfl
  mantissa text _ position _ := by
    rw [mantissa_denotation]
    rfl
  scale base value exponent _ _ _ := by
    rw [scale_denotation]
    exact scaleResult_equation base value exponent
  start text _ position _ _ := (start_denotation modelCalls text position).symm
  exponent text _ number _ _ _ _ := by
    rw [exponent_denotation]
    exact (exponentEquation_model text number).symm
  model text _ position _ := by
    rw [model_denotation]
    rfl

/-- The native postcondition supplies runtime equality with its own Model. The
rendered equations uniquely determine that Model as the independent scanner. -/
theorem executable_refinement (calls : Calls) (equations : Equations calls)
    (runtime : Source → Nat → Result)
    (contract : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
      runtime text position = calls.model text position)
    (text : Source) (valid : ValidText text) (position : Nat) (positionBound : position ≤ text.length + 1) :
    runtime text position = read text position := by
  rw [contract text valid position positionBound, interpreted_model calls equations text valid position positionBound]

end Silver.IntegerLiteral.Native
