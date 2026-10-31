module

public import Silver.PredicateConditionReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts
open Compose.Expressions

set_option backward.dsimp.instances true

theorem comparison_bound (text : Source) (position : Nat) (bounded : position ≤ text.length + 1) :
    (Predicate.comparisonAt text position).after ≤ text.length + 1 := by
  unfold Predicate.comparisonAt
  split <;> first | exact model_fixed_valid text position _ _ bounded | skip
  split <;> first | exact model_fixed_valid text position _ _ bounded | skip
  split <;> first | exact model_fixed_valid text position _ _ bounded | skip
  split <;> first | exact model_fixed_valid text position _ _ bounded | skip
  split <;> first | exact model_fixed_valid text position _ _ bounded | skip
  split <;> first | exact model_fixed_valid text position _ _ bounded | exact Nat.zero_le _

theorem length_bound (text : Source) (context : ParseContext) (position : Nat) (literal : Bool)
    (bounded : position ≤ text.length + 1) : (lengthAt text context position literal).after ≤ text.length + 1 := by
  unfold lengthAt
  dsimp only
  split
  · rename_i number
    simp only [Bool.and_eq_true, decide_eq_true_eq] at number
    exact (IntegerLiteral.integer_bounds (IntegerLiteral.read_sound (model_skip_valid text position bounded) number.2)).2.1
  · split
    · exact Nat.zero_le _
    · exact model_fixed_valid text _ _ _ (model_fixed_valid text _ _ _ (model_name_valid text _))

theorem chainAfter_bound (text : Source) (position : Nat) (operator : Bool)
    (bounded : position ≤ text.length + 1) : chainAfter text position operator ≤ text.length + 1 :=
  model_fixed_valid text _ _ _ (model_fixed_valid text _ _ _ bounded)

private theorem true_of_not_neg {value : Bool} (known : ¬(!value) = true) : value = true := by
  cases value <;> simp_all

private theorem length_name {text context position operand result}
    (parsed : LengthAt text context position false operand result) :
    ∃ index, operand = .binding index := by
  cases parsed with
  | number impossible _ => contradiction
  | binding => exact ⟨_, rfl⟩

mutual
  theorem primary_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readPrimary text context position facts).after ≠ 0) :
      (∃ condition, PrimaryAt text context position facts condition (readPrimary text context position facts)) ∧
        (readPrimary text context position facts).after ≤ text.length + 1 := by
    by_cases zero : position = 0
    · simp [readPrimary, zero, invalidCondition] at accepted
    · by_cases opening : fixedAfter text position "(" false ≠ 0
      · by_cases advanced : remainingAt text (fixedAfter text position "(" false) < remainingAt text position
        · have closed : fixedAfter text (readCondition text context (fixedAfter text position "(" false) facts).after ")" false ≠ 0 := by
            intro failed
            simp [readPrimary, zero, opening, advanced, failed, invalidCondition] at accepted
          have innerPositive := fixedAfter_nonzero closed
          have inner := condition_sound text context (fixedAfter text position "(" false) facts
            textValid namesValid (model_fixed_valid text position _ _ bounded) innerPositive
          obtain ⟨condition, parsed⟩ := inner.1
          rw [readPrimary]
          simp [zero, opening, advanced, closed]
          exact ⟨⟨.parenthesized condition, .group zero opening advanced parsed closed⟩,
            model_fixed_valid text _ _ _ inner.2⟩
        · simp [readPrimary, zero, opening, advanced, invalidCondition] at accepted
      · have noOpening : fixedAfter text position "(" false = 0 := by omega
        have arguments : context.hasArguments = true := by
          cases arguments : context.hasArguments with
          | false => simp [readPrimary, zero, noOpening, arguments, invalidCondition] at accepted
          | true => rfl
        have finalPositive : callAfter (arrays := context.arrayNames) (subtypeHidden := context.subtypeHiding.get .validity) text context.names position .validity context.scalarNames ≠ 0 := by
          intro failed
          simp [readPrimary, zero, noOpening, arguments, failed, invalidCondition] at accepted
        simp [readPrimary, zero, noOpening, arguments, finalPositive]
        exact ⟨⟨.inputValid, .valid zero noOpening arguments finalPositive⟩,
          model_callAfter_valid (arrays := context.arrayNames) (scalarNames := context.scalarNames) (subtypeHidden := context.subtypeHiding.get .validity) text context.names position .validity bounded⟩
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem relation_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readRelation text context position facts).after ≠ 0) :
      (∃ condition, RelationAt text context position facts condition (readRelation text context position facts)) ∧
        (readRelation text context position facts).after ≤ text.length + 1 := by
    by_cases zero : position = 0
    · simp [readRelation, zero, invalidCondition] at accepted
    · by_cases negation : fixedAfter text position "not" true ≠ 0
      · by_cases advanced : remainingAt text (fixedAfter text position "not" true) < remainingAt text position
        · have primaryPositive : (readPrimary text context (fixedAfter text position "not" true) facts).after ≠ 0 := by
            simpa [readRelation, zero, negation, advanced] using accepted
          have inner := primary_sound text context (fixedAfter text position "not" true) facts
            textValid namesValid (model_fixed_valid text _ _ _ bounded) primaryPositive
          obtain ⟨condition, parsed⟩ := inner.1
          rw [readRelation]
          simp [zero, negation, advanced]
          exact ⟨⟨.negated condition, .negated zero negation advanced parsed⟩, inner.2⟩
        · simp [readRelation, zero, negation, advanced, invalidCondition] at accepted
      · have noNot : fixedAfter text position "not" true = 0 := by omega
        by_cases lengthPresent : (lengthAt text context position false).after ≠ 0
        · have rightAdvanced : position < (lengthAt text context (Predicate.comparisonAt text
              (lengthAt text context position false).after).after true).after := by
            by_cases failed : (lengthAt text context (Predicate.comparisonAt text
              (lengthAt text context position false).after).after true).after ≤ position
            · simp [readRelation, zero, noNot, lengthPresent, failed, invalidCondition] at accepted
            · omega
          have rightPositive : (lengthAt text context (Predicate.comparisonAt text
              (lengthAt text context position false).after).after true).after ≠ 0 := by omega
          obtain ⟨left, leftRead⟩ := lengthAt_sound bounded lengthPresent
          obtain ⟨index, rfl⟩ := length_name leftRead
          have rightBound := comparison_bound text _ (length_bound text context position false bounded)
          obtain ⟨right, rightRead⟩ := lengthAt_sound rightBound rightPositive
          simp only [readRelation, zero, noNot, ne_eq, not_true_eq_false, lengthPresent,
            not_false_eq_true, ↓reduceIte, Nat.not_le.mpr rightAdvanced]
          exact ⟨⟨_, .length zero noNot lengthPresent leftRead rightRead rightAdvanced⟩,
            length_bound text context _ true rightBound⟩
        · have noLength : (lengthAt text context position false).after = 0 := by omega
          by_cases scalarPresent : (ScalarExpression.read (arrays := context.arrayNames) text position (context.readingNames facts)).after ≠ 0
          · let left := ScalarExpression.read (arrays := context.arrayNames) text position (context.readingNames facts)
            let operator := Predicate.comparisonAt text left.after
            let right := ScalarExpression.read (arrays := context.arrayNames) text operator.after (context.readingNames facts)
            have advanced : position < right.after := by
              by_cases failed : right.after ≤ position
              · have resultEq : readRelation text context position facts = invalidCondition facts := by
                  simp only [readRelation, zero, noNot, noLength, ne_eq, not_true_eq_false,
                    scalarPresent, not_false_eq_true, ↓reduceIte]
                  exact ite_eq_left failed
                exact False.elim (accepted (congrArg ConditionResult.after resultEq))
              · omega
            have rightPositive : right.after ≠ 0 := by omega
            obtain ⟨leftExpr, leftRead⟩ := ScalarExpression.read_sound bounded scalarPresent
            have leftBound := leftRead.cursorBounds.2.2
            have operatorBound := comparison_bound text left.after leftBound
            obtain ⟨rightExpr, rightRead⟩ := ScalarExpression.read_sound operatorBound rightPositive
            have resultEq : readRelation text context position facts = scalarCondition text context position operator.after facts left right operator.operator := by
              simp only [readRelation, zero, noNot, noLength, ne_eq, not_true_eq_false,
                scalarPresent, not_false_eq_true, ↓reduceIte]
              exact ite_eq_right (Nat.not_le.mpr advanced)
            rw [resultEq]
            exact ⟨⟨_, .scalars zero noNot noLength scalarPresent leftRead rightRead advanced⟩,
              rightRead.cursorBounds.2.2⟩
          · have noScalar : (ScalarExpression.read (arrays := context.arrayNames) text position (context.readingNames facts)).after = 0 := by omega
            by_cases expressionPresent : (expressionAt (arrays := context.arrayNames) text position context.names (context.readingNames facts)).after ≠ 0
            · let left := expressionAt (arrays := context.arrayNames) text position context.names (context.readingNames facts)
              let operator := Predicate.comparisonAt text left.after
              let right := expressionAt (arrays := context.arrayNames) text operator.after context.names (context.readingNames facts)
              have allowed : ¬(operator.after = 0 ∨ (operator.operator ≠ .eq ∧ operator.operator ≠ .ne)) := by
                intro failed
                have resultEq : readRelation text context position facts = invalidCondition facts := by
                  rw [readRelation]
                  simp only [zero, noNot, noLength, noScalar, ne_eq, not_true_eq_false, expressionPresent,
                    not_false_eq_true, ↓reduceIte]
                  change (if operator.after = 0 ∨ _ then _ else _) = _
                  rw [ite_eq_left failed]
                exact accepted (congrArg ConditionResult.after resultEq)
              have boundedValues : ¬(right.after ≤ position ∨ !(left.namedSeen || right.namedSeen) ∨
                  !fitsLengthSummary facts.path (summaryOf left) ∨ !fitsLengthSummary facts.path (summaryOf right)) := by
                intro failed
                have unfolded : readRelation text context position facts = invalidCondition facts := by
                  simp only [readRelation, zero, noNot, noLength, noScalar, ne_eq, not_true_eq_false,
                    expressionPresent, not_false_eq_true, ↓reduceIte]
                  change (if operator.after = 0 ∨ _ then _ else _) = _
                  rw [ite_eq_right allowed, ite_eq_left failed]
                rw [unfolded] at accepted
                exact accepted rfl
              have rightAdvanced : position < right.after := by
                have h : ¬ right.after ≤ position := fun bad => boundedValues (Or.inl bad)
                omega
              have ready : StringRelationReady facts left right operator := by
                refine ⟨expressionPresent, fun bad => allowed (Or.inl bad), ?_, ?_, ?_, ?_, ?_⟩
                · by_cases equal : operator.operator = .eq
                  · exact Or.inl equal
                  · by_cases different : operator.operator = .ne
                    · exact Or.inr different
                    · exact False.elim (allowed (Or.inr ⟨equal, different⟩))
                · omega
                · exact true_of_not_neg (fun bad => boundedValues (Or.inr (Or.inl bad)))
                · exact true_of_not_neg (fun bad => boundedValues (Or.inr (Or.inr (Or.inl bad))))
                · exact true_of_not_neg (fun bad => boundedValues (Or.inr (Or.inr (Or.inr bad))))
              obtain ⟨leftExpr, leftRead⟩ := expressionAt_sound (scalarNames := (context.readingNames facts)) text context.names position ready.1
              obtain ⟨rightExpr, rightRead⟩ := expressionAt_sound (scalarNames := (context.readingNames facts)) text context.names operator.after ready.2.2.2.1
              have resultEq : readRelation text context position facts = stringResult facts left right operator := by
                simp only [readRelation, zero, noNot, noLength, noScalar, ne_eq, not_true_eq_false,
                  expressionPresent, not_false_eq_true, ↓reduceIte]
                change (if operator.after = 0 ∨ _ then _ else _) = _
                rw [ite_eq_right allowed, ite_eq_right boundedValues]
                rfl
              rw [resultEq]
              exact ⟨⟨_, .strings zero noNot noLength noScalar leftRead rightRead ready rightAdvanced⟩,
                (model_expression_valid (scalarNames := (context.readingNames facts)) text textValid operator.after context.names
                  (comparison_bound text left.after (model_expression_valid (scalarNames := (context.readingNames facts)) text textValid position context.names bounded namesValid).1)
                  namesValid).1⟩
            · have noExpression : (expressionAt (arrays := context.arrayNames) text position context.names (context.readingNames facts)).after = 0 := by omega
              have primaryPositive : (readPrimary text context position facts).after ≠ 0 := by
                simpa [readRelation, zero, noNot, noLength, noScalar, noExpression] using accepted
              have primary := primary_sound text context position facts textValid namesValid bounded primaryPositive
              obtain ⟨condition, parsed⟩ := primary.1
              simp only [readRelation, zero, noNot, noLength, noScalar, noExpression, ne_eq, not_true_eq_false, ↓reduceIte]
              exact ⟨⟨_, .primary zero noNot noLength noScalar noExpression parsed⟩, primary.2⟩
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem chain_sound (text : Source) (context : ParseContext) (condition : Condition) (result : ConditionResult)
      (chained : Option Bool) (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : result.after ≤ text.length + 1) (accepted : (conditionTail text context result chained).after ≠ 0) :
      (∃ final, ChainAt text context condition result chained final (conditionTail text context result chained)) ∧
        (conditionTail text context result chained).after ≤ text.length + 1 := by
    by_cases zero : result.after = 0
    · simp [conditionTail, zero, invalidCondition] at accepted
    · cases operatorEq : chainOperator text result.after with
      | none =>
          simp only [conditionTail, zero, operatorEq, ↓reduceIte]
          exact ⟨⟨condition, .done zero operatorEq⟩, bounded⟩
      | some operator =>
          by_cases compatible : (chained.isSome && decide (chained ≠ some operator)) = true
          · rw [conditionTail] at accepted
            simp only [zero, operatorEq, compatible, ↓reduceIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
          · by_cases afterZero : chainAfter text result.after operator = 0
            · rw [conditionTail] at accepted
              simp only [zero, operatorEq, compatible, Bool.false_eq_true, afterZero, ↓reduceIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
            · by_cases advanced : remainingAt text (chainAfter text result.after operator) < remainingAt text result.after
              · let right := readRelation text context (chainAfter text result.after operator) (chainContext result operator)
                by_cases rightZero : right.after = 0
                · rw [conditionTail] at accepted
                  simp only [zero, operatorEq, compatible, Bool.false_eq_true, afterZero, advanced, ↓reduceIte, ↓reduceDIte] at accepted
                  change (if right.after = 0 then invalidCondition result.whenTrue else _).after ≠ 0 at accepted
                  simp only [rightZero, ↓reduceIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
                · let next := chainJoin result right operator
                  by_cases nextAdvanced : remainingAt text next.after < remainingAt text result.after
                  · have recursivePositive : (conditionTail text context next (some operator)).after ≠ 0 := by
                      rw [conditionTail] at accepted
                      simp only [zero, operatorEq, compatible, Bool.false_eq_true, afterZero, advanced,
                        ↓reduceIte, ↓reduceDIte] at accepted
                      change (if right.after = 0 then invalidCondition result.whenTrue else
                        if _ : remainingAt text next.after < remainingAt text result.after then _ else invalidCondition result.whenTrue).after ≠ 0 at accepted
                      simpa only [rightZero, nextAdvanced, ↓reduceIte, ↓reduceDIte] using accepted
                    have rightReading := relation_sound text context (chainAfter text result.after operator)
                      (chainContext result operator) textValid namesValid (chainAfter_bound text result.after operator bounded) rightZero
                    obtain ⟨rightCondition, rightRead⟩ := rightReading.1
                    have nextBound : next.after ≤ text.length + 1 := by
                      cases operator <;> exact rightReading.2
                    have recursive := chain_sound text context (chainCondition condition rightCondition operator) next
                      (some operator) textValid namesValid nextBound recursivePositive
                    obtain ⟨final, finalRead⟩ := recursive.1
                    have equation : conditionTail text context result chained = conditionTail text context next (some operator) := by
                      rw [conditionTail]
                      simp only [zero, operatorEq, compatible, Bool.false_eq_true, afterZero, advanced,
                        ↓reduceIte, ↓reduceDIte]
                      change (if right.after = 0 then invalidCondition result.whenTrue else
                        if _ : remainingAt text next.after < remainingAt text result.after then _ else invalidCondition result.whenTrue) = _
                      simp only [rightZero, nextAdvanced, ↓reduceIte, ↓reduceDIte]
                      rfl
                    rw [equation]
                    exact ⟨⟨final, .next equation zero operatorEq
                      (by simpa only [Bool.and_eq_true, decide_eq_true_eq] using compatible)
                      afterZero advanced rightRead rightZero nextAdvanced finalRead⟩, recursive.2⟩
                  · rw [conditionTail] at accepted
                    simp only [zero, operatorEq, compatible, Bool.false_eq_true, afterZero, advanced,
                      ↓reduceIte, ↓reduceDIte] at accepted
                    change (if right.after = 0 then invalidCondition result.whenTrue else
                      if _ : remainingAt text next.after < remainingAt text result.after then _ else invalidCondition result.whenTrue).after ≠ 0 at accepted
                    simp only [rightZero, nextAdvanced, ↓reduceIte, ↓reduceDIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
              · rw [conditionTail] at accepted
                simp only [zero, operatorEq, compatible, Bool.false_eq_true, afterZero, advanced, ↓reduceIte, ↓reduceDIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
  termination_by (remainingAt text result.after, 4)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem condition_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readCondition text context position facts).after ≠ 0) :
      (∃ condition, ConditionAt text context position facts condition (readCondition text context position facts)) ∧
        (readCondition text context position facts).after ≤ text.length + 1 := by
    by_cases zero : (readRelation text context position facts).after = 0
    · simp [readCondition, zero, invalidCondition] at accepted
    · by_cases advanced : remainingAt text (readRelation text context position facts).after < remainingAt text position
      · have first := relation_sound text context position facts textValid namesValid bounded zero
        obtain ⟨condition, firstRead⟩ := first.1
        have tailPositive : (conditionTail text context (readRelation text context position facts) none).after ≠ 0 := by
          intro failed
          simp only [readCondition, zero, advanced, ↓reduceIte, ↓reduceDIte,
            failed, invalidCondition, ne_eq, not_true_eq_false] at accepted
        have tail := chain_sound text context condition (readRelation text context position facts) none
          textValid namesValid first.2 tailPositive
        obtain ⟨final, finalRead⟩ := tail.1
        have equation : readCondition text context position facts = conditionTail text context (readRelation text context position facts) none := by
          simp only [readCondition, zero, advanced, ↓reduceIte, ↓reduceDIte, tailPositive]
        rw [equation]
        exact ⟨⟨final, .condition equation firstRead zero advanced finalRead⟩, tail.2⟩
      · simp [readCondition, zero, advanced, invalidCondition] at accepted
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate
