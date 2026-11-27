module

public import Silver.StaticBooleanModel

@[expose] public section

namespace Silver.BooleanElaboration.Native

theorem exact_chain (frame : Compose.ParserState) (left right : Predicate.Condition)
    (a b : Bool) (operator : Predicate.ChainKind)
    (leftValue : evaluate frame.scalarNames frame.booleanNames left = some a)
    (rightValue : evaluate frame.scalarNames frame.booleanNames right = some b) :
    evaluate frame.scalarNames frame.booleanNames (Predicate.chainCondition left right operator) =
      some (combine (some operator) a b) := by
  cases operator <;> simp [Predicate.chainCondition, evaluate, binary, combine, leftValue, rightValue]
  all_goals cases a <;> cases b <;> rfl

theorem tail_finished_positive {imports : Imports} {relation text frame selected input output}
    (step : tailStep imports relation text frame selected input = .finished output)
    (accepted : output.after ≠ 0) : imports.chain text input.after = none ∧ output = input := by
  dsimp only [tailStep] at step
  split at step
  · rename_i absent
    exact ⟨absent, (LoopStep.finished.inj step).symm⟩
  · split at step
    · cases step
      exact False.elim (accepted rfl)
    · split at step
      · cases step
        exact False.elim (accepted rfl)
      · cases step

theorem tail_next_source {imports : Imports} {relation text frame selected input next}
    (step : tailStep imports relation text frame selected input = .next next) :
    ∃ operator, imports.chain text input.after = some operator ∧ some operator = selected ∧
      let right := relation text frame (imports.chainAfter text input.after (some operator))
      input.after < right.after ∧ next = ⟨right.after, combine (some operator) input.value right.value⟩ := by
  dsimp only [tailStep] at step
  cases current : imports.chain text input.after with
  | none => simp only [current, ↓reduceIte, reduceCtorEq] at step
  | some operator =>
    have present : some operator ≠ (none : Chain) := by intro h; cases h
    rw [current, ite_eq_right present] at step
    split at step
    · cases step
    · rename_i matchesSelector
      have same : some operator = selected := Classical.not_not.mp matchesSelector
      split at step
      · cases step
      · rename_i growing
        exact ⟨operator, rfl, same, Nat.lt_of_not_ge growing, (LoopStep.next.inj step).symm⟩

/-- Each right operand begins after the operator obtained from the original
source. A parenthesized subexpression may start another operator category. -/
inductive ChainAt (text : Source) (operandAt : Nat → Predicate.Condition → Nat → Prop)
    (selected : Chain) : Predicate.Condition → Nat → Predicate.Condition → Nat → Prop
  | done {left after} : Predicate.chainOperator text after = none →
      ChainAt text operandAt selected left after left after
  | append {left after op right rightAfter final finish} :
      Predicate.chainOperator text after = some op →
      some op = selected →
      operandAt (Predicate.chainAfter text after op) right rightAfter →
      after < rightAfter →
      ChainAt text operandAt selected (Predicate.chainCondition left right op) rightAfter final finish →
      ChainAt text operandAt selected left after final finish

theorem TailExec.exact_source {relation : Reader} {text frame selected input output}
    (run : TailExec modelImports relation text frame selected input output)
    (operandAt : Nat → Predicate.Condition → Nat → Prop)
    (operand : ∀ position, (relation text frame position).after ≠ 0 →
      ∃ right, operandAt position right (relation text frame position).after ∧
        evaluate frame.scalarNames frame.booleanNames right = some (relation text frame position).value)
    (left : Predicate.Condition) (leftValue : evaluate frame.scalarNames frame.booleanNames left = some input.value)
    (accepted : output.after ≠ 0) :
    ∃ final, ChainAt text operandAt selected left input.after final output.after ∧
      evaluate frame.scalarNames frame.booleanNames final = some output.value := by
  induction run generalizing left with
  | finished step =>
    obtain ⟨absent, same⟩ := tail_finished_positive step accepted
    subst_vars
    exact ⟨left, .done absent, leftValue⟩
  | @next input middle output step rest ih =>
    obtain ⟨operator, current, selectedOp, progress, nextValue⟩ := tail_next_source step
    let start := Predicate.chainAfter text input.after operator
    have advancing : input.after < (relation text frame start).after := progress
    obtain ⟨right, parsed, rightValue⟩ := operand start (Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advancing))
    have combined : evaluate frame.scalarNames frame.booleanNames (Predicate.chainCondition left right operator) =
        some middle.value := by
      rw [nextValue]
      exact exact_chain frame left right _ _ operator leftValue rightValue
    obtain ⟨final, continued, result⟩ := ih _ combined accepted
    rw [nextValue] at continued
    exact ⟨final, .append current selectedOp parsed advancing continued, result⟩

end Silver.BooleanElaboration.Native
