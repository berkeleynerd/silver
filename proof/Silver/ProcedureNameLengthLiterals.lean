module

public import Silver.ProcedureNameReadings
public import Silver.IntegerLiteral

@[expose] public section

namespace Silver.IntegerLiteral

private theorem magnitude_limit : maxSourceLength ≤ ScalarLiteral.maxMagnitude := by decide

theorem DigitsAt.scalar {text : Source} {base position start value finish : Nat} {need : Bool}
    (source : DigitsAt text base position start need value finish) :
    ScalarLiteral.DigitsAt text base position start need value finish := by
  induction source with
  | ending position bounded => exact .ending position (Nat.le_trans bounded magnitude_limit)
  | stopped position bounded digit separator =>
      exact .stopped position (Nat.le_trans bounded magnitude_limit) digit separator
  | digit position digit bounded _ ih =>
      exact .digit position digit (Nat.le_trans bounded magnitude_limit) ih
  | separator position byte base _ ih => exact .separator position byte base ih

theorem NumeralAt.scalar {text : Source} {base position value finish : Nat}
    (source : NumeralAt text base position value finish) :
    ScalarLiteral.NumeralAt text base position value finish :=
  ⟨source.1, source.2.1, source.2.2.1, source.2.2.2.scalar⟩

theorem MantissaAt.scalar {text : Source} {position value base finish : Nat}
    (source : MantissaAt text position value base finish) :
    ScalarLiteral.MantissaAt text position value base finish := by
  cases source with
  | decimal number boundary => exact .decimal number.scalar (fun present => boundary ⟨present.1, present.2.1⟩)
  | @based base value headEnd numberEnd leading delimiter number within closing =>
      have first := (numeral_first_digit number).2
      have baseBound := number.2.2.1
      have noAssignment : ¬(Cursor.byteAt text headEnd = 58 ∧ headEnd < text.length ∧
          Cursor.byteAt text (headEnd + 1) = 61) := by
        rintro ⟨_, _, equal⟩
        rw [equal] at first
        change 16 < _ at first
        omega
      exact .based leading.scalar ⟨delimiter.1, delimiter.2, noAssignment⟩ number.scalar within closing

theorem ExponentAt.scalar {text : Source} {position value finish : Nat}
    (source : ExponentAt text position value finish) :
    ScalarLiteral.ExponentAt text position value finish := by
  cases source with
  | unsigned number => exact .unsigned number.scalar
  | positive within plus number => exact .positive within plus number.scalar

theorem PoweredAt.scalar {text : Source} {number : Mantissa} {value finish : Nat}
    (source : PoweredAt text number value finish) :
    ScalarLiteral.PoweredAt text ⟨number.after, number.value, number.base⟩ value finish := by
  cases source with
  | unchanged boundary => exact .unchanged boundary
  | exponent marker exponent bounded =>
      exact .exponent marker exponent.scalar (exponent_bounds exponent).2.2
        (Nat.le_trans bounded magnitude_limit)

/-- Length-predicate numerals are also scalar lexical tokens: their value and
exponent limits are at most the scalar scanner's limits. No bound is inferred
from a successful prover run. -/
theorem IntegerAt.scalar {text : Source} {position value finish : Nat}
    (source : IntegerAt text position value finish) :
    ScalarLiteral.IntegerAt text position value finish := by
  cases source with
  | @literal number value finish mantissa powered boundary =>
      exact .literal (number := ⟨number.after, number.value, number.base⟩)
        mantissa.scalar powered.scalar boundary

end Silver.IntegerLiteral

namespace Silver.Predicate

theorem ActualNameFreeTrace.lengthNumber {text : Source}
    {position first value finish limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : Compose.skipAt text position = first)
    (number : IntegerLiteral.IntegerAt text first value finish) (bounded : finish ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter finish :=
  trace.number before skipped number.scalar bounded

end Silver.Predicate
