module

public import Silver.PredicateStringAssignmentReadings
public import Silver.PredicateBodyProperties
public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

private theorem fixedSummary_fits (context : Context) (length : Nat) (bound : length ≤ maxSourceLength) :
    fitsLengthSummary context ⟨length, length, 0, false⟩ = true := by
  cases region : context.validLengths <;>
    simp [fitsLengthSummary, fitsSummary, LengthSummary.upper, Summary.length, region, bound]

private theorem fixedSummary_equal (context : Context) (length : Nat) :
    equalLengthSummary context ⟨length, length, 0, false⟩ (Bound.fixed length).summary = true := by
  cases region : context.validLengths <;>
    simp [equalLengthSummary, equalSummary, LengthSummary.lower, LengthSummary.upper,
      Bound.summary, Summary.length, region]

theorem stringAssignment_target_index {text context scan}
    (positive : (stringAssignmentTarget text context scan).target ≠ 0) :
    (stringAssignmentTarget text context scan).target =
      lookupName text context.names (skipAt text scan.position) (nameAfter text (skipAt text scan.position)) := by
  unfold stringAssignmentTarget targetAt at positive ⊢
  dsimp only
  split
  · rename_i failed
    rw [ite_eq_left failed] at positive
    exact False.elim (positive rfl)
  · rfl

theorem stringAssignment_facts {text context scan}
    (positive : (stringAssignmentBody text context scan).position ≠ 0) :
    (stringAssignmentBody text context scan).facts = scan.facts := by
  unfold stringAssignmentBody at positive ⊢
  dsimp only at positive ⊢
  split
  · rename_i absent
    rw [ite_eq_left absent] at positive
    exact False.elim (positive rfl)
  · rename_i present
    rw [ite_eq_right present] at positive
    cases branch : stringAssignmentKind text context scan <;>
      simp only [branch] at positive ⊢
    all_goals
      split
      · rename_i failed
        rw [ite_eq_left failed] at positive
        exact False.elim (positive rfl)
      · rfl

private theorem single_ready {shape : Shape} {ranges : Integer.Ranges} {value : Value} {summary : LengthSummary}
    (known : Expression.inferLength [value] shape ranges = some summary)
    (printable : value.PrintableLiterals) : ExpressionReady shape [value] := by
  refine ⟨Expression.inferLength_readable known, ?_, by simp, by simp [maxExpressionOperands]⟩
  simpa [Expression.LiteralsPrintable] using printable

theorem indexedReplacement_inferLength {text names scalarNames arrays initials elaborating position info lower upper rhs rhsResult rhsPosition}
    (normal : NamesNormal names)
    (indexed : IndexedReading text names scalarNames arrays initials elaborating true position info lower upper)
    (source : CharacterAt text names scalarNames arrays initials elaborating rhsPosition rhs rhsResult) :
    Expression.inferLength
      [.replace (indexedParts text position names scalarNames arrays initials elaborating true).target info.firstIndex lower rhs]
      names.shape (ArrayBindings.integerRanges arrays initials elaborating (ScalarExpression.ranges scalarNames)) =
        some ⟨info.staticLength, info.staticLength, 0, false⟩ := by
  have checked := indexed_check normal indexed
  have replacement := character_check normal source
  simp only [Character.Expr.check, fixedLengths_of_info indexed.selected indexed.fixed,
    indexed.lowerSource.inferred] at checked
  simp [Expression.inferLength, Operand.inferLength, Value.extraRange,
    fixedLengths_of_info indexed.selected indexed.fixed, indexed.lowerSource.inferred,
    checked, replacement, LengthSummary.add]

private theorem condition_of_success (test : Prop) [Decidable test] (yes no : BodyScan)
    (zero : yes.position = 0) (positive : (if test then yes else no).position ≠ 0) : ¬test := by
  intro selected
  rw [ite_eq_left selected, zero] at positive
  contradiction

private theorem fixed_assignment_meaning {shape : Shape} {ranges : Integer.Ranges} {target length : Nat}
    {value : Expression} {context : Context}
    (selected : shape target = some ⟨.fixed length, true⟩)
    (known : value.inferLength shape ranges = some ⟨length, length, 0, false⟩)
    (ready : ExpressionReady shape value) (bound : length ≤ maxSourceLength) :
    SimpleWellFormed shape (.assign ⟨target, value⟩) ∧
      checkAssignment shape context ⟨target, value⟩ ranges = true := by
  refine ⟨⟨ready, .fixed length, selected⟩, ?_⟩
  simp only [checkAssignment, selected, known, fixedSummary_fits context length bound,
    fixedSummary_equal, Bool.and_self]

theorem stringAssignment_meaning {text context scan update}
    (normal : NamesNormal context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (namesValid : Compose.Expressions.ValidNames text context.names)
    (bodyMode : context.elaborating = false)
    (reading : StringAssignmentReading text context scan update)
    (accepted : (stringAssignmentBody text context scan).position ≠ 0) :
    SimpleWellFormed context.names.shape (.assign update) ∧
      checkAssignment context.names.shape scan.facts.path update (context.flow scan.facts).scalars = true := by
  have rangesEq := context.reading_ranges compatible
  have characterRanges : ArrayBindings.integerRanges context.arrayNames [] false
      (ScalarExpression.ranges (context.readingNames scan.facts)) = (context.flow scan.facts).scalars := by
    simpa only [bodyMode] using rangesEq
  cases reading with
  | whole target kind source =>
      have ready := expression_reading_ready normal source
      rw [rangesEq] at ready
      obtain ⟨name, info, _, found, _, mutable, _, _⟩ := target
      change context.names.get (stringAssignmentTarget text context scan).target = some info at found
      have positive : (stringAssignmentTarget text context scan).target ≠ 0 := by
        intro zero
        simp [BindingEnvironment.get, zero] at found
      have selected : context.names.shape (stringAssignmentTarget text context scan).target = some ⟨info.bound, true⟩ := by
        simp only [BindingEnvironment.shape, found, Option.map_some, BindingInfo.cell, mutable]
      simp only [stringAssignmentBody, stringAssignmentStart, positive, ↓reduceIte, kind,
        bodyToken, tokenAfter, ShellToken.symbol] at accepted
      have guards := condition_of_success _ _ _ rfl accepted
      simp only [not_or, Bool.not_eq_true'] at guards
      refine ⟨⟨ready.1, info.bound, selected⟩, ?_⟩
      simp only [checkAssignment, selected, ready.2]
      have compatibleLength := guards.2.2
      simp only [found, Option.getD_some] at compatibleLength
      simpa only [summaryOf, stringAssignmentStart, Bool.and_eq_true, Bool.not_eq_false] using
        And.intro guards.2.1 compatibleLength
  | character target kind source =>
      obtain ⟨name, info, _, found, _, mutable, _, _⟩ := target
      change context.names.get (stringAssignmentTarget text context scan).target = some info at found
      have typed : info.isCharacter = true := by
        simp only [stringAssignmentKind, found, Option.getD_some] at kind
        cases flag : info.isCharacter with
        | true => rfl
        | false =>
            simp only [flag, Bool.false_eq_true, ↓reduceIte] at kind
            split at kind <;> cases kind
      have metadata := (normal.typed _ _ found).1 typed
      have selected : context.names.shape (stringAssignmentTarget text context scan).target = some ⟨.fixed 1, true⟩ := by
        simp only [BindingEnvironment.shape, found, Option.map_some, BindingInfo.cell, mutable,
          BindingInfo.bound, metadata.1, metadata.2, Bool.false_eq_true, ↓reduceIte]
      have known := characterExpression_inferLength normal source
      rw [characterRanges] at known
      exact fixed_assignment_meaning selected known (single_ready known (character_literals source)) (by decide)
  | @element info index upper value result target kind indexed source =>
      obtain ⟨name, targetInfo, _, found, _, mutable, _, _⟩ := target
      change context.names.get (stringAssignmentTarget text context scan).target = some targetInfo at found
      have positive : (stringAssignmentTarget text context scan).target ≠ 0 := by
        intro zero
        simp [BindingEnvironment.get, zero] at found
      have targetEq : (indexedParts text scan.position context.names (context.readingNames scan.facts)
          context.arrayNames [] false true).target = (stringAssignmentTarget text context scan).target :=
        (stringAssignment_target_index positive).symm
      have same : info = targetInfo := by
        have selected := indexed.selected
        rw [targetEq, found] at selected
        exact (Option.some.inj selected).symm
      subst targetInfo
      have selected : context.names.shape (stringAssignmentTarget text context scan).target =
          some ⟨.fixed info.staticLength, true⟩ := by
        simp only [BindingEnvironment.shape, found, Option.map_some, BindingInfo.cell, mutable,
          BindingInfo.bound, indexed.fixed, Bool.false_eq_true, ↓reduceIte]
      have known := indexedReplacement_inferLength normal indexed source
      rw [targetEq, characterRanges] at known
      have bound : info.staticLength ≤ maxSourceLength := (namesValid.2 _ (List.mem_of_getElem? (by
        simpa only [BindingEnvironment.get, positive, ↓reduceIte] using found))).2.2
      exact fixed_assignment_meaning selected known (single_ready known (character_literals source)) bound

end Silver.Predicate
