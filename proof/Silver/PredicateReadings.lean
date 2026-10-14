module

public import Silver.PredicateAdmission
public import Silver.PredicateStatements
public import Silver.ComposeModelRanges

@[expose] public section

set_option backward.dsimp.instances true

namespace Silver.Predicate
open Compose Bindings PathFacts
open Compose.Expressions (model_skip_valid model_name_valid model_fixed_valid)

/-- Names and integer spellings retain their source positions and inherited
meaning. Literal values never stand in for an unchecked source annotation. -/
inductive LengthAt (text : Source) (context : ParseContext) (position : Nat) (literal : Bool) :
    LengthOperand → LengthResult → Prop
  | number {value finish} : literal = true →
      IntegerLiteral.IntegerAt text (skipAt text position) value finish →
      LengthAt text context position literal (.literal value) ⟨finish, .fixed value⟩
  | binding {index info name after} :
      ¬(literal = true ∧ (IntegerLiteral.read text (skipAt text position)).after ≠ 0) →
      index = lookupName text context.names (skipAt text position) (nameAfter text (skipAt text position)) →
      context.names.get index = some info →
      Named.IdentifierAt text (skipAt text position) name (nameAfter text (skipAt text position)) →
      after = fixedAfter text (fixedAfter text (nameAfter text (skipAt text position)) "'" false) "length" true →
      after ≠ 0 →
      LengthAt text context position literal (.binding index) ⟨after, info.bound⟩

theorem lengthAt_sound {text : Source} {context : ParseContext} {position : Nat} {literal : Bool}
    (bounded : position ≤ text.length + 1) (accepted : (lengthAt text context position literal).after ≠ 0) :
    ∃ operand, LengthAt text context position literal operand (lengthAt text context position literal) := by
  unfold lengthAt at accepted ⊢
  dsimp only at accepted ⊢
  split
  · rename_i chosen
    simp only [Bool.and_eq_true, decide_eq_true_eq] at chosen
    exact ⟨_, .number chosen.1 (IntegerLiteral.read_sound (model_skip_valid text position bounded) chosen.2)⟩
  · rename_i notNumber
    simp only [notNumber, Bool.false_eq_true, ↓reduceIte] at accepted
    split
    · rename_i zero
      simp only [zero, ↓reduceIte] at accepted
      contradiction
    · rename_i indexNonzero
      simp only [indexNonzero, ↓reduceIte] at accepted
      obtain ⟨first, _, info, found, _⟩ := lookupName_found indexNonzero
      have endNonzero : Named.identifierEnd text (skipAt text position) ≠ 0 := by
        have advancing := (lookupName_found indexNonzero).2.1
        simpa only [nameAfter, first, ↓reduceIte] using (show nameAfter text (skipAt text position) ≠ 0 by omega)
      obtain ⟨name, identifier⟩ := Named.identifierEnd_sound text _ endNonzero
      refine ⟨.binding (lookupName text context.names (skipAt text position) (nameAfter text (skipAt text position))), ?_⟩
      simp only [found, Option.getD_some] at accepted ⊢
      refine .binding (name := name) ?_ rfl found ?_ rfl accepted
      · simpa only [Bool.and_eq_true, decide_eq_true_eq] using notNumber
      · simpa only [nameAfter, first, ↓reduceIte] using identifier

theorem lengthAt_complete {text context position literal operand result}
    (parsed : LengthAt text context position literal operand result) :
    lengthAt text context position literal = result := by
  cases parsed with
  | @number value finish allowed number =>
      have progress := (IntegerLiteral.integer_bounds number).1
      have nonzero : finish ≠ 0 := by omega
      simp [lengthAt, allowed, IntegerLiteral.read_complete number, nonzero]
  | @binding index info name after notNumber indexEq found identifier afterEq positive =>
      have nonzero : index ≠ 0 := by
        intro zero
        simp [Bindings.BindingEnvironment.get, zero] at found
      have notNumberBool : ¬ (literal && decide ((IntegerLiteral.read text (skipAt text position)).after ≠ 0)) = true := by
        simpa only [Bool.and_eq_true, decide_eq_true_eq] using notNumber
      simp only [lengthAt]
      rw [ite_eq_right notNumberBool]
      simp only [← indexEq, nonzero, ↓reduceIte, found, Option.getD_some, ← afterEq]

theorem lengthAt_readable {text context position literal operand result}
    (parsed : LengthAt text context position literal operand result) :
    operand.Readable context.names.shape ∧ operand.bound context.names.shape = some result.value := by
  cases parsed with
  | number _ number => exact ⟨(IntegerLiteral.integer_bounds number).2.2, rfl⟩
  | @binding index info name after _ _ found _ _ _ =>
      have shape : context.names.shape index = some info.cell := by
        simp only [Bindings.BindingEnvironment.shape, found, Option.map_some]
      exact ⟨⟨_, shape⟩, by simp only [LengthOperand.bound, shape, Option.map_some]; rfl⟩

theorem lengthAt_unique {text context position literal left right leftResult rightResult}
    (first : LengthAt text context position literal left leftResult)
    (second : LengthAt text context position literal right rightResult) :
    left = right ∧ leftResult = rightResult := by
  have resultEq := (lengthAt_complete first).symm.trans (lengthAt_complete second)
  refine ⟨?_, resultEq⟩
  cases first with
  | number allowed number =>
      cases second with
      | number _ other => exact congrArg LengthOperand.literal (IntegerLiteral.integer_unique number other).1
      | binding notNumber _ _ _ _ _ =>
          exact False.elim (notNumber ⟨allowed, by
            rw [IntegerLiteral.read_complete number]
            have progress := (IntegerLiteral.integer_bounds number).1
            dsimp only
            omega⟩)
  | binding notNumber indexEq _ _ _ _ =>
      cases second with
      | number allowed number =>
          exact False.elim (notNumber ⟨allowed, by
            rw [IntegerLiteral.read_complete number]
            have progress := (IntegerLiteral.integer_bounds number).1
            dsimp only
            omega⟩)
      | binding _ otherEq _ _ _ _ => exact congrArg LengthOperand.binding (indexEq.trans otherEq.symm)

theorem expression_reading_ready {text names position expression result}
    (normal : NamesNormal names) (parsed : ExpressionAt text names position expression result) :
    ExpressionReady names.shape expression ∧ expression.summary names.shape = summaryOf result := by
  have readable := expressionTail_readable parsed
  have count := expressionTail_count normal (by simp) parsed
  have nonempty := expressionTail_nonempty normal (by simp) rfl rfl parsed
  have summary := expressionTail_summary normal (by simp) parsed
  refine ⟨⟨readable.1, readable.2, nonempty, by simpa using count⟩, ?_⟩
  simp only [Expression.summary, summaryOf, Nat.zero_add] at summary ⊢
  rw [summary.1, summary.2]

end Silver.Predicate
