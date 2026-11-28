module

public import Silver.StaticBooleanConditionExecution
public import Silver.ScalarExpressionAdmission
public import Silver.PredicateNativeModel

@[expose] public section

namespace Silver.BooleanElaboration.Native
open Compose Compose.Expressions

abbrev BoundedResult (text : Source) (position : Nat) (result : Result) : Prop :=
  result.after ≠ 0 → position < result.after ∧ result.after ≤ text.length + 1

abbrev BoundedReader (reader : Reader) (text : Source) (frame : ParserState) : Prop :=
  ∀ position, position ≤ text.length + 1 → BoundedResult text position (reader text frame position)

theorem BoundedResult.limit {text position result} (resultBound : BoundedResult text position result) :
    result.after ≤ text.length + 1 := by
  by_cases zero : result.after = 0
  · simp only [zero, Nat.zero_le]
  · exact (resultBound zero).2

theorem primary_bounds {condition : Reader} {text : Source} {frame : ParserState} {position}
    (positionBound : position ≤ text.length + 1) (conditionBound : BoundedReader condition text frame) :
    BoundedResult text position (primaryStep modelImports condition text frame position) := by
  have reference (present : (QualifiedNames.read text position).after ≠ 0) :=
    (QualifiedNames.read_success text position positionBound present).2.2
  dsimp only [BoundedResult, primaryStep, modelImports]
  split
  · intro accepted; exact False.elim (accepted rfl)
  · split
    · rename_i opened
      intro closed
      have openBound := model_fixed_valid text position "(" false positionBound
      have openProgress := model_fixed_advances text position "(" false positionBound (by decide) opened
      have inner := conditionBound _ openBound (model_fixed_input_nonzero text _ ")" false closed)
      exact ⟨Nat.lt_trans (Nat.lt_trans openProgress inner.1)
          (model_fixed_advances text _ ")" false inner.2 (by decide) closed),
        model_fixed_valid text _ ")" false inner.2⟩
    · split
      · exact reference
      · split
        · split
          · exact reference
          · split
            · exact reference
            · intro accepted; exact False.elim (accepted rfl)
        · intro accepted; exact False.elim (accepted rfl)

theorem factor_bounds {primary : Reader} {text : Source} {frame : ParserState} {position}
    (positionBound : position ≤ text.length + 1) (primaryBound : BoundedReader primary text frame) :
    BoundedResult text position (factorStep modelImports primary text frame position) := by
  dsimp only [BoundedResult, factorStep, modelImports]
  by_cases plain : fixedAfter text position "not" true = 0
  · simp only [ite_eq_right (not_not_intro plain), ite_eq_left plain]
    exact primaryBound position positionBound
  · simp only [ite_eq_left plain, ite_eq_right plain]
    intro accepted
    have operand := primaryBound _ (model_fixed_valid text position "not" true positionBound) accepted
    exact ⟨Nat.lt_trans (model_fixed_advances text position "not" true positionBound (by decide) plain)
      operand.1, operand.2⟩

theorem relation_bounds {factor : Reader} {text : Source} {frame : ParserState} {position}
    (positionBound : position ≤ text.length + 1) (factorBound : BoundedReader factor text frame) :
    BoundedResult text position (relationStep modelImports factor text frame position) := by
  dsimp only [BoundedResult, relationStep, modelImports]
  split
  · rename_i present
    split
    · intro accepted; exact False.elim (accepted rfl)
    · intro accepted
      have scalar := ScalarExpression.read_arrays_bounds positionBound present.1
      have operator := Predicate.Native.comparison_progress text _ scalar.2.1 present.2
      have right := ScalarExpression.read_arrays_bounds (Predicate.comparison_bound text _ scalar.2.1) accepted
      exact ⟨Nat.lt_trans (Nat.lt_trans scalar.1 operator) right.1, right.2.1⟩
  · split
    · intro accepted; exact False.elim (accepted rfl)
    · rename_i present
      have left := factorBound position positionBound present
      split
      · intro _; exact left
      · rename_i compared
        split
        · intro accepted; exact False.elim (accepted rfl)
        · split
          · intro accepted; exact False.elim (accepted rfl)
          · intro accepted
            have operator := Predicate.Native.comparison_progress text _ left.2 compared
            have right := factorBound _ (Predicate.comparison_bound text _ left.2) accepted
            exact ⟨Nat.lt_trans (Nat.lt_trans left.1 operator) right.1, right.2⟩

theorem TailExec.output_bounds {relation : Reader} {text frame selected input output}
    (run : TailExec modelImports relation text frame selected input output)
    (relationBound : BoundedReader relation text frame) (inputBound : input.after ≤ text.length + 1)
    (accepted : output.after ≠ 0) : input.after ≤ output.after ∧ output.after ≤ text.length + 1 := by
  induction run with
  | finished step =>
    obtain ⟨_, same⟩ := tail_finished_positive step accepted
    subst_vars
    exact ⟨Nat.le_refl _, inputBound⟩
  | @next input middle output step _ ih =>
    obtain ⟨operator, _, _, advance, update⟩ := tail_next_source step
    have middleBound : middle.after ≤ text.length + 1 := by
      rw [update]
      exact (relationBound _ (Predicate.chainAfter_bound text _ operator inputBound)).limit
    have rest := ih middleBound accepted
    exact ⟨Nat.le_trans (Nat.le_of_lt (tailStep_next_progress step)) rest.1, rest.2⟩

theorem condition_bounds {relation : Reader} {text : Source} {frame : ParserState} {position}
    (positionBound : position ≤ text.length + 1) (relationBound : BoundedReader relation text frame) :
    BoundedResult text position (runCondition relation text frame position) := by
  dsimp only [BoundedResult, runCondition]
  split
  · intro accepted; exact False.elim (accepted rfl)
  · rename_i present
    intro accepted
    have first := relationBound position positionBound present
    have run := runTail_execution relation text frame (modelImports.chain text (relation text frame position).after)
      (fun start bound => (relationBound start bound).limit) _ first.2
    have result := run.output_bounds relationBound first.2 accepted
    exact ⟨Nat.lt_of_lt_of_le first.1 result.1, result.2⟩

end Silver.BooleanElaboration.Native
