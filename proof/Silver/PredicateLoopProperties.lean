module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateConditionSound

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts Compose.Expressions

attribute [local irreducible] ScalarExpression.read

theorem scalarRead_bound (text : Source) (position : Nat) (names : ScalarExpression.Environment)
    (first after : Nat) (bounded : position ≤ text.length + 1) :
    (ScalarExpression.read text position names first after).after ≤ text.length + 1 := by
  by_cases zero : (ScalarExpression.read text position names first after).after = 0
  · simp [zero]
  · exact (ScalarExpression.read_bounds bounded zero).2.1

theorem loopLowerPosition_bound (text : Source) (scan : BodyScan) :
    loopLowerPosition text scan ≤ text.length + 1 := by
  have name := model_name_valid text (loopFirst text scan)
  have inside := model_fixed_valid text (loopNameAfter text scan) "in" true name
  unfold loopLowerPosition
  split
  · exact model_fixed_valid text (loopInAfter text scan) "reverse" true inside
  · exact inside

theorem loopHeader_bound (text : Source) (context : ParseContext) (scan : BodyScan) :
    (loopHeader text context scan).entry.position ≤ text.length + 1 := by
  have lower := scalarRead_bound text (loopLowerPosition text scan) (context.readingNames scan.facts)
    (loopFirst text scan) (loopNameAfter text scan) (loopLowerPosition_bound text scan)
  have delimiter := model_fixed_valid text _ ".." false lower
  have upper := scalarRead_bound text _ (context.readingNames scan.facts)
    (loopFirst text scan) (loopNameAfter text scan) delimiter
  exact model_fixed_valid text _ "loop" true upper

theorem loopHeader_readings {text : Source} {context : ParseContext} {scan : BodyScan}
    (positive : (loopHeader text context scan).entry.position ≠ 0) :
    ∃ lower upper,
      ScalarExpression.At text (context.readingNames scan.facts) (loopLowerPosition text scan)
        lower (loopHeader text context scan).lower (loopFirst text scan) (loopNameAfter text scan) ∧
      ScalarExpression.At text (context.readingNames scan.facts)
        (fixedAfter text (loopHeader text context scan).lower.after ".." false)
        upper (loopHeader text context scan).upper (loopFirst text scan) (loopNameAfter text scan) := by
  have upperPositive : (loopHeader text context scan).upper.after ≠ 0 := fixedAfter_nonzero positive
  have lowerBound := scalarRead_bound text (loopLowerPosition text scan) (context.readingNames scan.facts)
    (loopFirst text scan) (loopNameAfter text scan) (loopLowerPosition_bound text scan)
  have delimiter := model_fixed_valid text _ ".." false lowerBound
  obtain ⟨upper, upperRead⟩ := ScalarExpression.read_sound delimiter upperPositive
  have delimiterPositive := (ScalarExpression.syntax_bounds upperRead.positionBound upperRead.grammar).1
  have lowerPositive : (loopHeader text context scan).lower.after ≠ 0 :=
    fixedAfter_nonzero (Nat.ne_of_gt delimiterPositive)
  obtain ⟨lower, lowerRead⟩ := ScalarExpression.read_sound (loopLowerPosition_bound text scan) lowerPositive
  exact ⟨lower, upper, lowerRead, upperRead⟩

theorem loopInner_valid_environment {text : Source} {context : ParseContext} {scan : BodyScan}
    (valid : ScalarExpression.ValidEnvironment text context.scalarNames)
    (allowed : loopNameAllowed text context (loopHeader text context scan) = true)
    (positive : (loopHeader text context scan).entry.position ≠ 0) :
    ScalarExpression.ValidEnvironment text (loopInner context (loopHeader text context scan)).scalarNames := by
  obtain ⟨lower, upper, lowerRead, upperRead⟩ := loopHeader_readings positive
  simp only [loopNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
  have firstPositive := allowed.1.1.1.1
  have ordered := allowed.1.1.1.2
  have space := allowed.2
  have afterBound := model_name_valid text (loopFirst text scan)
  exact ScalarExpression.validEnvironment_append valid (by have := valid.1; omega)
    ⟨Nat.pos_of_ne_zero firstPositive, ordered, afterBound,
      Integer.loopBounds_bounded (Integer.Expr.infer_bounded lowerRead.inferred)
        (Integer.Expr.infer_bounded upperRead.inferred),
      Integer.loopBounds_bounded (Integer.Expr.infer_bounded lowerRead.inferred)
        (Integer.Expr.infer_bounded upperRead.inferred)⟩

theorem loopBody_shape {text : Source} {context : ParseContext} {scan : BodyScan}
    (positive : (loopBody text context scan).position ≠ 0) :
    let header := loopHeader text context scan
    let body := readBody text (loopInner context header) header.entry .endOnly
    loopNameAllowed text context header = true ∧
      scan.position < header.entry.position ∧
      bodyRemaining text header.entry < bodyRemaining text scan ∧
      scan.position < body.position ∧
      loopBody text context scan = bodyTokens text
        {body with facts := loopAfterFlow context scan.facts body.facts header.lower.bounds header.upper.bounds}
        [.word "end", .word "loop", .symbol ";"] ∧
      scan.position < (bodyTokens text
        {body with facts := loopAfterFlow context scan.facts body.facts header.lower.bounds header.upper.bounds}
        [.word "end", .word "loop", .symbol ";"]).position := by
  rw [loopBody] at positive ⊢
  dsimp only at positive ⊢
  split at positive
  · exact False.elim (positive rfl)
  · rename_i allowed
    have ready : loopNameAllowed text context (loopHeader text context scan) = true := by
      cases good : loopNameAllowed text context (loopHeader text context scan) <;> simp_all
    simp only [ready, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
    split at positive
    · exact False.elim (positive rfl)
    · rename_i advance
      simp only [advance, ↓reduceIte]
      split at positive
      · rename_i remaining
        simp only [remaining, ↓reduceDIte]
        split at positive
        · exact False.elim (positive rfl)
        · rename_i bodyAdvance
          simp only [bodyAdvance, ↓reduceIte]
          split at positive
          · exact False.elim (positive rfl)
          · rename_i finish
            simp only [finish, ↓reduceIte]
            exact ⟨trivial, Nat.lt_of_not_ge advance, trivial, Nat.lt_of_not_ge bodyAdvance, trivial, Nat.lt_of_not_ge finish⟩
      · exact False.elim (positive rfl)

theorem loopBody_progress (text : Source) (context : ParseContext) (scan : BodyScan)
    (positive : (loopBody text context scan).position ≠ 0) :
    scan.position < (loopBody text context scan).position := by
  have shape := loopBody_shape positive
  rw [shape.2.2.2.2.1]
  exact shape.2.2.2.2.2

end Silver.Predicate
