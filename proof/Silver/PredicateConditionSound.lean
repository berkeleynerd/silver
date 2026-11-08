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

theorem chainAfter_bound (text : Source) (position : Nat) (operator : ChainKind)
    (bounded : position ≤ text.length + 1) : chainAfter text position operator ≤ text.length + 1 := by
  cases operator <;> first
    | exact model_fixed_valid text _ _ _ (model_fixed_valid text _ _ _ bounded)
    | exact model_fixed_valid text _ _ _ bounded

private theorem true_of_not_neg {value : Bool} (known : ¬(!value) = true) : value = true := by
  cases value <;> simp_all

private theorem length_name {text context position operand result}
    (parsed : LengthAt text context position false operand result) :
    ∃ index, operand = .binding index := by
  cases parsed with
  | number impossible _ => contradiction
  | binding => exact ⟨_, rfl⟩

theorem booleanArray_sound {text context position facts}
    (accepted : booleanArrayAfter text context position facts ≠ 0) :
    (∃ condition, BooleanArrayAt text context position facts condition
      (booleanArrayAfter text context position facts)) ∧
      booleanArrayAfter text context position facts ≤ text.length + 1 := by
  unfold booleanArrayAfter at accepted ⊢
  dsimp only at accepted ⊢
  split <;> (try simp only [*, ↓reduceIte] at accepted)
  · contradiction
  · rename_i allowed
    simp only [not_or] at allowed
    rcases allowed with ⟨_, _, target, kind, scalar, mask, operands, contains, close⟩
    have kindTrue : (ArrayBindings.binding context.arrayNames
        (ArrayBindings.lookup text context.arrayNames (skipAt text position)
          (nameAfter text (skipAt text position)))).isBoolean = true := by
      cases found : (ArrayBindings.binding context.arrayNames
        (ArrayBindings.lookup text context.arrayNames (skipAt text position)
          (nameAfter text (skipAt text position)))).isBoolean <;> simp_all
    have indexStart := model_fixed_valid text (nameAfter text (skipAt text position)) "(" false
      (model_name_valid text (skipAt text position))
    have indexPositive : (ScalarExpression.read text
        (fixedAfter text (nameAfter text (skipAt text position)) "(" false)
        (context.readingNames facts) context.maskFirst context.maskAfter).after ≠ 0 :=
      (model_fixed_input_nonzero _ _ _ _) (by omega)
    obtain ⟨index, reading⟩ := ScalarExpression.read_sound indexStart indexPositive
    have containsTrue : ArrayBindings.contains
        (ArrayBindings.binding context.arrayNames
          (ArrayBindings.lookup text context.arrayNames (skipAt text position)
            (nameAfter text (skipAt text position))))
        (ScalarExpression.read text (fixedAfter text (nameAfter text (skipAt text position)) "(" false)
          (context.readingNames facts) context.maskFirst context.maskAfter).bounds = true := by
      cases found : ArrayBindings.contains _ _ <;> simp_all
    exact ⟨⟨_, .read target kindTrue (Classical.not_not.mp scalar) mask reading operands containsTrue
      (by omega)⟩, model_fixed_valid text _ ")" false reading.cursorBounds.2.2⟩

theorem booleanAtom_sound {text context position}
    (accepted : booleanAtomAfter text context position ≠ 0) :
    (∃ condition, BooleanAtomAt text context position condition (booleanAtomAfter text context position)) ∧
      booleanAtomAfter text context position ≤ text.length + 1 := by
  unfold booleanAtomAfter at accepted ⊢
  dsimp only at accepted ⊢
  split
  · simp_all only [↓reduceIte, ne_eq, not_true_eq_false]
  · rename_i allowed
    have firstNonzero : skipAt text position ≠ 0 := fun bad => allowed (Or.inl bad)
    have afterNonzero : nameAfter text (skipAt text position) ≠ 0 := by
      intro bad
      exact allowed (Or.inr (Or.inl (by rw [bad]; exact Nat.zero_le _)))
    obtain ⟨spelling, identifier⟩ := Named.identifierEnd_sound text (skipAt text position)
      (by simpa only [nameAfter, firstNonzero, ↓reduceIte] using afterNonzero)
    have parsed : Named.IdentifierAt text (skipAt text position) spelling
        (nameAfter text (skipAt text position)) := by
      simpa only [nameAfter, firstNonzero, ↓reduceIte] using identifier
    split
    · rename_i found
      exact ⟨⟨_, .name parsed found⟩, model_name_valid text _⟩
    · rename_i absent
      have noName := Classical.not_not.mp absent
      split
      · rename_i literal
        simp only [Bool.or_eq_true, Bool.and_eq_true] at literal
        rcases literal with trueName | falseName
        · exact ⟨⟨.booleanLiteral true, .literal parsed noName trueName.1⟩,
            model_name_valid text _⟩
        · exact ⟨⟨.booleanLiteral false, .literal parsed noName falseName.1⟩,
            model_name_valid text _⟩
      · simp_all only [Bool.false_eq_true, ↓reduceIte, ne_eq, not_true_eq_false]

mutual
  theorem primary_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      {initials : ArrayBindings.Initials} (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readPrimary text context position facts initials).after ≠ 0) :
      (∃ condition, PrimaryAt text context position facts condition (readPrimary text context position facts initials) initials) ∧
        (readPrimary text context position facts initials).after ≤ text.length + 1 := by
    by_cases zero : position = 0
    · simp [readPrimary, zero, invalidCondition] at accepted
    · by_cases opening : fixedAfter text position "(" false ≠ 0
      · by_cases advanced : remainingAt text (fixedAfter text position "(" false) < remainingAt text position
        · have closed : fixedAfter text (readCondition text context (fixedAfter text position "(" false) facts initials).after ")" false ≠ 0 := by
            intro failed
            simp [readPrimary, zero, opening, advanced, failed, invalidCondition] at accepted
          have innerPositive := (model_fixed_input_nonzero _ _ _ _) closed
          have inner := condition_sound text context (fixedAfter text position "(" false) facts
            textValid namesValid (model_fixed_valid text position _ _ bounded) innerPositive
          obtain ⟨condition, parsed⟩ := inner.1
          rw [readPrimary]
          simp [zero, opening, advanced, closed]
          exact ⟨⟨.parenthesized condition, .group zero opening advanced parsed closed⟩,
            model_fixed_valid text _ _ _ inner.2⟩
        · simp [readPrimary, zero, opening, advanced, invalidCondition] at accepted
      · have noOpening : fixedAfter text position "(" false = 0 := by omega
        by_cases array : booleanArrayAfter text context position facts ≠ 0
        · obtain ⟨⟨condition, parsed⟩, bound⟩ := booleanArray_sound array
          simp only [readPrimary, zero, noOpening, array, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
          exact ⟨⟨condition, .booleanArray zero noOpening rfl array parsed⟩, bound⟩
        · have noArray : booleanArrayAfter text context position facts = 0 := by omega
          by_cases atom : booleanAtomAfter text context position ≠ 0
          · obtain ⟨⟨condition, parsed⟩, bound⟩ := booleanAtom_sound atom
            simp only [readPrimary, zero, noOpening, noArray, atom, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
            exact ⟨⟨condition, .boolean zero noOpening noArray rfl atom parsed⟩, bound⟩
          · have noAtom : booleanAtomAfter text context position = 0 := by omega
            have arguments : context.hasArguments = true := by
              cases arguments : context.hasArguments with
              | false => simp [readPrimary, zero, noOpening, noArray, noAtom, arguments, invalidCondition] at accepted
              | true => rfl
            have finalPositive : callAfter text context.names position .validity context.scalarNames context.arrayNames
                (context.validityHidden text) context.booleanNames ≠ 0 := by
              intro failed
              simp [readPrimary, zero, noOpening, noArray, noAtom, arguments, failed, invalidCondition] at accepted
            simp [readPrimary, zero, noOpening, noArray, noAtom, arguments, finalPositive]
            exact ⟨⟨.inputValid, .valid zero noOpening noArray noAtom arguments finalPositive⟩,
              Names.operationAfter_bound text position .validity _ bounded⟩
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem booleanFactor_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      {initials : ArrayBindings.Initials} (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readBooleanFactor text context position facts initials).after ≠ 0) :
      (∃ condition, BooleanFactorAt text context position facts condition (readBooleanFactor text context position facts initials) initials) ∧
        (readBooleanFactor text context position facts initials).after ≤ text.length + 1 := by
    by_cases noNot : fixedAfter text position "not" true = 0
    · have positive : (readPrimary text context position facts initials).after ≠ 0 := by
        simpa only [readBooleanFactor, noNot, ↓reduceIte] using accepted
      obtain ⟨⟨condition, parsed⟩, bound⟩ := primary_sound text context position facts textValid namesValid bounded positive
      simp only [readBooleanFactor, noNot, ↓reduceIte]
      exact ⟨⟨condition, .primary noNot parsed⟩, bound⟩
    · by_cases advanced : remainingAt text (fixedAfter text position "not" true) < remainingAt text position
      · have positive : (readPrimary text context (fixedAfter text position "not" true) facts initials).after ≠ 0 := by
          simpa only [readBooleanFactor, noNot, advanced, ↓reduceIte, ↓reduceDIte] using accepted
        obtain ⟨⟨condition, parsed⟩, bound⟩ := primary_sound text context (fixedAfter text position "not" true) facts
          textValid namesValid (model_fixed_valid text position _ _ bounded) positive
        simp only [readBooleanFactor, noNot, advanced, ↓reduceIte, ↓reduceDIte]
        exact ⟨⟨.negated condition, .negated noNot advanced parsed⟩, bound⟩
      · simp only [readBooleanFactor, noNot, advanced, ↓reduceIte, ↓reduceDIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem booleanRelation_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      {initials : ArrayBindings.Initials} (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readBooleanRelation text context position facts initials).after ≠ 0) :
      (∃ condition, BooleanRelationAt text context position facts condition (readBooleanRelation text context position facts initials) initials) ∧
        (readBooleanRelation text context position facts initials).after ≤ text.length + 1 := by
    let left := readBooleanFactor text context position facts initials
    let operator := comparisonAt text left.after
    let right := readBooleanFactor text context operator.after facts initials
    have equation : readBooleanRelation text context position facts initials =
        (if left.after = 0 then invalidCondition facts
         else if operator.after = 0 then left
         else if operator.operator ≠ .eq ∧ operator.operator ≠ .ne then invalidCondition facts
         else if _ : remainingAt text operator.after < remainingAt text position then
           if right.after = 0 then invalidCondition facts else ⟨right.after, facts, facts⟩
         else invalidCondition facts) := by rw [readBooleanRelation]
    have positive : left.after ≠ 0 := by
      intro failed
      rw [equation] at accepted
      simp only [failed, ↓reduceIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
    obtain ⟨⟨leftCondition, leftRead⟩, leftBound⟩ := booleanFactor_sound text context position facts textValid namesValid bounded positive
    by_cases noComparison : operator.after = 0
    · rw [equation]
      simp only [positive, noComparison, ↓reduceIte]
      exact ⟨⟨leftCondition, .factor leftRead positive noComparison⟩, leftBound⟩
    · have allowed : ¬(operator.operator ≠ .eq ∧ operator.operator ≠ .ne) := by
        intro bad
        rw [equation] at accepted
        simp [positive, noComparison, bad, invalidCondition] at accepted
      have advanced : remainingAt text operator.after < remainingAt text position := by
        by_cases good : remainingAt text operator.after < remainingAt text position
        · exact good
        · rw [equation] at accepted
          simp only [positive, noComparison, allowed, good, ↓reduceIte, ↓reduceDIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
      have rightPositive : right.after ≠ 0 := by
        intro bad
        rw [equation] at accepted
        simp only [positive, noComparison, allowed, advanced, bad, ↓reduceIte, ↓reduceDIte,
          invalidCondition, ne_eq, not_true_eq_false] at accepted
      obtain ⟨⟨rightCondition, rightRead⟩, rightBound⟩ := booleanFactor_sound text context operator.after facts textValid namesValid
        (comparison_bound text left.after leftBound) rightPositive
      have kinds : operator.operator = .eq ∨ operator.operator = .ne := by
        by_cases equal : operator.operator = .eq
        · exact Or.inl equal
        · by_cases unequal : operator.operator = .ne
          · exact Or.inr unequal
          · exact False.elim (allowed ⟨equal, unequal⟩)
      rw [equation]
      simp only [positive, noComparison, allowed, advanced, rightPositive, ↓reduceIte, ↓reduceDIte]
      exact ⟨⟨_, .comparison leftRead positive noComparison kinds advanced rightRead rightPositive⟩, rightBound⟩
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem relation_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      {initials : ArrayBindings.Initials}
      (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readRelation text context position facts initials).after ≠ 0) :
      (∃ condition, RelationAt text context position facts condition (readRelation text context position facts initials) initials) ∧
        (readRelation text context position facts initials).after ≤ text.length + 1 := by
    by_cases zero : position = 0
    · simp [readRelation, zero, invalidCondition] at accepted
    · by_cases negation : fixedAfter text position "not" true ≠ 0
      · have positive : (readBooleanRelation text context position facts initials).after ≠ 0 := by
          simpa only [readRelation, zero, negation, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte] using accepted
        obtain ⟨⟨condition, parsed⟩, bound⟩ := booleanRelation_sound text context position facts textValid namesValid bounded positive
        simp only [readRelation, zero, negation, ne_eq, ↓reduceIte]
        exact ⟨⟨condition, .booleanNot zero negation parsed⟩, bound⟩
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
          by_cases scalarPresent : (readScalarInFlow text context position facts (initials := initials)).after ≠ 0
          · let left := readScalarInFlow text context position facts (initials := initials)
            let operator := Predicate.comparisonAt text left.after
            let right := readScalarInFlow text context operator.after facts (initials := initials)
            have advanced : position < right.after := by
              by_cases failed : right.after ≤ position
              · have resultEq : readRelation text context position facts initials = invalidCondition facts := by
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
            have resultEq : readRelation text context position facts initials = scalarCondition text context position operator.after facts left right operator.operator := by
              simp only [readRelation, zero, noNot, noLength, ne_eq, not_true_eq_false,
                scalarPresent, not_false_eq_true, ↓reduceIte]
              exact ite_eq_right (Nat.not_le.mpr advanced)
            rw [resultEq]
            exact ⟨⟨_, .scalars zero noNot noLength scalarPresent leftRead rightRead advanced⟩,
              rightRead.cursorBounds.2.2⟩
          · have noScalar : (readScalarInFlow text context position facts (initials := initials)).after = 0 := by omega
            by_cases pure : context.pure = true
            · have positive : (readBooleanRelation text context position facts initials).after ≠ 0 := by
                simpa only [readRelation, zero, noNot, noLength, noScalar, pure,
                  ne_eq, not_true_eq_false, ↓reduceIte] using accepted
              obtain ⟨⟨condition, parsed⟩, bound⟩ :=
                booleanRelation_sound text context position facts textValid namesValid bounded positive
              simp only [readRelation, zero, noNot, noLength, noScalar, pure,
                ne_eq, not_true_eq_false, ↓reduceIte]
              exact ⟨⟨condition, .pureBoolean zero noNot noLength noScalar pure parsed⟩, bound⟩
            · have impure : context.pure = false := Bool.eq_false_iff.mpr pure
              by_cases expressionPresent : (readStringInFlow text context position facts initials).after ≠ 0
              · let left := readStringInFlow text context position facts initials
                let operator := Predicate.comparisonAt text left.after
                let right := readStringInFlow text context operator.after facts initials
                have allowed : ¬(operator.after = 0 ∨ (operator.operator ≠ .eq ∧ operator.operator ≠ .ne)) := by
                  intro failed
                  have resultEq : readRelation text context position facts initials = invalidCondition facts := by
                    rw [readRelation]
                    simp only [zero, noNot, noLength, noScalar, impure, Bool.false_eq_true, ne_eq, not_true_eq_false, expressionPresent,
                      not_false_eq_true, ↓reduceIte]
                    change (if operator.after = 0 ∨ _ then _ else _) = _
                    rw [ite_eq_left failed]
                  exact accepted (congrArg ConditionResult.after resultEq)
                have boundedValues : ¬(right.after ≤ position ∨ !(left.namedSeen || right.namedSeen) ∨
                    !fitsLengthSummary facts.path (summaryOf left) ∨ !fitsLengthSummary facts.path (summaryOf right)) := by
                  intro failed
                  have unfolded : readRelation text context position facts initials = invalidCondition facts := by
                    simp only [readRelation, zero, noNot, noLength, noScalar, impure, Bool.false_eq_true, ne_eq, not_true_eq_false,
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
                obtain ⟨leftExpr, leftRead⟩ := expressionAt_sound (scalarNames := context.readingNames facts) (integerHidden := context.integerHidden text) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) text context.names position ready.1
                obtain ⟨rightExpr, rightRead⟩ := expressionAt_sound (scalarNames := context.readingNames facts) (integerHidden := context.integerHidden text) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) text context.names operator.after ready.2.2.2.1
                have resultEq : readRelation text context position facts initials = stringResult facts left right operator := by
                  simp only [readRelation, zero, noNot, noLength, noScalar, impure, Bool.false_eq_true, ne_eq, not_true_eq_false,
                    expressionPresent, not_false_eq_true, ↓reduceIte]
                  change (if operator.after = 0 ∨ _ then _ else _) = _
                  rw [ite_eq_right allowed, ite_eq_right boundedValues]
                  rfl
                rw [resultEq]
                exact ⟨⟨_, .strings zero noNot noLength noScalar leftRead rightRead ready rightAdvanced impure⟩,
                  (model_expression_valid (scalarNames := context.readingNames facts) (integerHidden := context.integerHidden text) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) text textValid operator.after context.names
                    (comparison_bound text left.after (model_expression_valid (scalarNames := context.readingNames facts) (integerHidden := context.integerHidden text) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) text textValid position context.names bounded namesValid).1)
                    namesValid).1⟩
              · have noExpression : (readStringInFlow text context position facts initials).after = 0 := by omega
                by_cases characterPositive : (characterCondition text context position facts initials).after ≠ 0
                · obtain ⟨condition, parsed⟩ := characterRelation_sound characterPositive
                  simp only [readRelation, zero, noNot, noLength, noScalar, impure, Bool.false_eq_true, noExpression,
                    characterPositive, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
                  exact ⟨⟨_, .character zero noNot noLength noScalar noExpression parsed impure⟩,
                    characterRelation_after_bounded parsed⟩
                · have noCharacter : (characterCondition text context position facts initials).after = 0 := by omega
                  have primaryPositive : (readBooleanRelation text context position facts initials).after ≠ 0 := by
                    simpa [readRelation, zero, noNot, noLength, noScalar, impure, Bool.false_eq_true, noExpression, noCharacter] using accepted
                  have primary := booleanRelation_sound text context position facts textValid namesValid bounded primaryPositive
                  obtain ⟨condition, parsed⟩ := primary.1
                  simp only [readRelation, zero, noNot, noLength, noScalar, impure, Bool.false_eq_true, noExpression, noCharacter,
                    ne_eq, not_true_eq_false, ↓reduceIte]
                  exact ⟨⟨_, .primary zero noNot noLength noScalar noExpression noCharacter parsed impure⟩, primary.2⟩
  termination_by (remainingAt text position, 4)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem chain_sound (text : Source) (context : ParseContext) (condition : Condition) (result : ConditionResult)
      (chained : Option ChainKind) (incoming : ActiveFlow) (originalStart : Nat) {initials : ArrayBindings.Initials} (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : result.after ≤ text.length + 1) (accepted : (conditionTail text context result chained incoming initials originalStart).after ≠ 0) :
      (∃ final, ChainAt text context condition result chained final (conditionTail text context result chained incoming initials originalStart) incoming initials originalStart) ∧
        (conditionTail text context result chained incoming initials originalStart).after ≤ text.length + 1 := by
    by_cases zero : result.after = 0
    · simp [conditionTail, zero, invalidCondition] at accepted
    · cases operatorEq : chainOperator text result.after with
      | none =>
          simp only [conditionTail, zero, operatorEq, ↓reduceIte]
          exact ⟨⟨condition, .done zero operatorEq⟩, bounded⟩
      | some operator =>
          by_cases rejected : ((chained.isSome && decide (chained ≠ some operator)) ||
              (decide (operator = .eagerXor) && !xorFree text originalStart result.after)) = true
          · rw [conditionTail] at accepted
            simp only [zero, operatorEq, rejected, ↓reduceIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
          · have compatible : ¬(chained.isSome = true ∧ chained ≠ some operator) := by
              intro bad
              apply rejected
              simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]
              exact Or.inl bad
            have leftFree : operator = .eagerXor → xorFree text originalStart result.after = true := by
              intro selected
              cases free : xorFree text originalStart result.after with
              | true => rfl
              | false => simp [selected, free] at rejected
            by_cases afterZero : chainAfter text result.after operator = 0
            · rw [conditionTail] at accepted
              simp only [zero, operatorEq, rejected, Bool.false_eq_true, afterZero, ↓reduceIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
            · by_cases advanced : remainingAt text (chainAfter text result.after operator) < remainingAt text result.after
              · let right := readRelation text context (chainAfter text result.after operator) (chainContext result operator incoming) initials
                by_cases rightRejected : right.after = 0 ∨
                    (operator = .eagerXor ∧ xorFree text (chainAfter text result.after operator) right.after = false)
                · rw [conditionTail] at accepted
                  simp only [zero, operatorEq, rejected, Bool.false_eq_true, afterZero, advanced, ↓reduceIte, ↓reduceDIte] at accepted
                  change (if right.after = 0 ∨ (operator = .eagerXor ∧
                    xorFree text (chainAfter text result.after operator) right.after = false) then invalidCondition result.whenTrue else _).after ≠ 0 at accepted
                  simp only [rightRejected, ↓reduceIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
                · have rightZero : right.after ≠ 0 := fun bad => rightRejected (Or.inl bad)
                  have rightFree : operator = .eagerXor → xorFree text (chainAfter text result.after operator) right.after = true := by
                    intro selected
                    cases free : xorFree text (chainAfter text result.after operator) right.after with
                    | true => rfl
                    | false => exact False.elim (rightRejected (Or.inr ⟨selected, free⟩))
                  let next := chainJoin result right operator incoming
                  by_cases nextAdvanced : remainingAt text next.after < remainingAt text result.after
                  · have recursivePositive : (conditionTail text context next (some operator) incoming initials originalStart).after ≠ 0 := by
                      rw [conditionTail] at accepted
                      simp only [zero, operatorEq, rejected, Bool.false_eq_true, afterZero, advanced,
                        ↓reduceIte, ↓reduceDIte] at accepted
                      change (if right.after = 0 ∨ (operator = .eagerXor ∧
                    xorFree text (chainAfter text result.after operator) right.after = false) then invalidCondition result.whenTrue else
                        if _ : remainingAt text next.after < remainingAt text result.after then _ else invalidCondition result.whenTrue).after ≠ 0 at accepted
                      simpa only [rightRejected, nextAdvanced, ↓reduceIte, ↓reduceDIte] using accepted
                    have rightReading := relation_sound text context (chainAfter text result.after operator)
                      (chainContext result operator incoming) textValid namesValid (chainAfter_bound text result.after operator bounded) rightZero
                    obtain ⟨rightCondition, rightRead⟩ := rightReading.1
                    have nextBound : next.after ≤ text.length + 1 := by
                      cases operator <;> exact rightReading.2
                    have recursive := chain_sound text context (chainCondition condition rightCondition operator) next
                      (some operator) incoming originalStart textValid namesValid nextBound recursivePositive
                    obtain ⟨final, finalRead⟩ := recursive.1
                    have equation : conditionTail text context result chained incoming initials originalStart = conditionTail text context next (some operator) incoming initials originalStart := by
                      rw [conditionTail]
                      simp only [zero, operatorEq, rejected, Bool.false_eq_true, afterZero, advanced,
                        ↓reduceIte, ↓reduceDIte]
                      change (if right.after = 0 ∨ (operator = .eagerXor ∧
                    xorFree text (chainAfter text result.after operator) right.after = false) then invalidCondition result.whenTrue else
                        if _ : remainingAt text next.after < remainingAt text result.after then _ else invalidCondition result.whenTrue) = _
                      simp only [rightRejected, nextAdvanced, ↓reduceIte, ↓reduceDIte]
                      rfl
                    rw [equation]
                    exact ⟨⟨final, .next equation zero operatorEq
                      compatible leftFree afterZero advanced rightRead rightZero rightFree nextAdvanced finalRead⟩, recursive.2⟩
                  · rw [conditionTail] at accepted
                    simp only [zero, operatorEq, rejected, Bool.false_eq_true, afterZero, advanced,
                      ↓reduceIte, ↓reduceDIte] at accepted
                    change (if right.after = 0 ∨ (operator = .eagerXor ∧
                    xorFree text (chainAfter text result.after operator) right.after = false) then invalidCondition result.whenTrue else
                      if _ : remainingAt text next.after < remainingAt text result.after then _ else invalidCondition result.whenTrue).after ≠ 0 at accepted
                    simp only [rightRejected, nextAdvanced, ↓reduceIte, ↓reduceDIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
              · rw [conditionTail] at accepted
                simp only [zero, operatorEq, rejected, Bool.false_eq_true, afterZero, advanced, ↓reduceIte, ↓reduceDIte, invalidCondition, ne_eq, not_true_eq_false] at accepted
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem condition_sound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      {initials : ArrayBindings.Initials}
      (textValid : ValidText text) (namesValid : ValidNames text context.names)
      (bounded : position ≤ text.length + 1) (accepted : (readCondition text context position facts initials).after ≠ 0) :
      (∃ condition, ConditionAt text context position facts condition (readCondition text context position facts initials) initials) ∧
        (readCondition text context position facts initials).after ≤ text.length + 1 := by
    by_cases zero : (readRelation text context position facts initials).after = 0
    · simp [readCondition, zero, invalidCondition] at accepted
    · by_cases advanced : remainingAt text (readRelation text context position facts initials).after < remainingAt text position
      · have first := relation_sound text context position facts textValid namesValid bounded zero
        obtain ⟨condition, firstRead⟩ := first.1
        have tailPositive : (conditionTail text context (readRelation text context position facts initials) none facts initials position).after ≠ 0 := by
          intro failed
          simp only [readCondition, zero, advanced, ↓reduceIte, ↓reduceDIte,
            failed, invalidCondition, ne_eq, not_true_eq_false] at accepted
        have tail := chain_sound text context condition (readRelation text context position facts initials) none facts position
          textValid namesValid first.2 tailPositive
        obtain ⟨final, finalRead⟩ := tail.1
        have equation : readCondition text context position facts initials = conditionTail text context (readRelation text context position facts initials) none facts initials position := by
          simp only [readCondition, zero, advanced, ↓reduceIte, ↓reduceDIte, tailPositive]
        rw [equation]
        exact ⟨⟨final, .condition equation firstRead zero advanced finalRead⟩, tail.2⟩
      · simp [readCondition, zero, advanced, invalidCondition] at accepted
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate
