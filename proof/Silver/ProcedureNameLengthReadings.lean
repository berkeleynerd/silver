module

public import Silver.ProcedureNameCompoundTokens
public import Silver.ProcedureNameLengthLiterals
public import Silver.PredicateReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings

theorem ActualNameFreeTrace.lengthSyntax {text : Source} {context : ParseContext}
    {position limit targetFirst targetAfter : Nat} {literal : Bool}
    {operand : LengthOperand} {result : LengthResult}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : LengthAt text context position literal operand result)
    (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
  cases source with
  | number _ number =>
      have bounds := IntegerLiteral.integer_bounds number
      have skipped := ScalarExpression.skip_bounds text position positionBound
      change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at skipped
      exact trace.lengthNumber (by dsimp only at finishBound; omega) rfl number finishBound
  | @binding index info name after _ indexEq found _ _ identifier afterEq nonzero =>
      have indexPositive : index ≠ 0 := by
        intro zero
        simp [Bindings.BindingEnvironment.get, zero] at found
      have nameFields := lookupName_found (indexEq ▸ indexPositive)
      have bounds := Named.identifier_bounds identifier
      have skipped := skipAt_advances text position positionBound nameFields.1
      have tickBound := fixedAfter_result_bound text (nameAfter text (skipAt text position)) "'" false (by decide)
      have fullPositive : fixedAfter text (fixedAfter text (nameAfter text (skipAt text position)) "'" false) "length" true ≠ 0 := by
        simpa only [afterEq] using nonzero
      have tickPositive := Compose.Expressions.model_fixed_input_nonzero text _ "length" true fullPositive
      have tickAdvance := Compose.Expressions.model_fixed_advances text _ "'" false bounds.2.2.2 (by decide) tickPositive
      have attributeAdvance := Compose.Expressions.model_fixed_advances text _ "length" true tickBound (by decide) fullPositive
      have afterName := (trace.identifier (by dsimp only at finishBound; omega) rfl nameFields.1 identifier (by
        dsimp only at finishBound
        omega)).2
      have afterAttribute := afterName.fixedAttribute bounds.2.2.2 (by decide) (by decide) fullPositive (by
        simpa only [afterEq] using finishBound)
      simpa only [afterEq] using afterAttribute

end Silver.Predicate
