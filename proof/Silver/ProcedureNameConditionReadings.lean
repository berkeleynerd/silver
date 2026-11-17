module

public import Silver.ProcedureNameRelationReadings
public import Silver.ProcedureNameValidityReading

@[expose] public section

set_option maxHeartbeats 1200000

namespace Silver.Predicate
open Compose ScalarProcedures

mutual
  theorem ActualNameFreeTrace.primarySyntax {text : Source} {context : ParseContext} {facts : ActiveFlow}
      {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
      {target : Cell} {condition : Condition} {result : ConditionResult}
      (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
      (source : PrimaryAt text context position facts condition result initials)
      (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
      (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
      conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
    cases source with
    | group _ opening _ inner closing =>
        have openBound := fixedAfter_result_bound text position "(" false (by decide)
        have innerBound := condition_source_bound inner openBound
        have innerAdvance := condition_source_advance inner
        have closed := Compose.Expressions.model_fixed_advances text _ ")" false innerBound (by decide) closing
        dsimp only at finishBound
        have afterOpen := trace.fixedSymbol (byte := '(') positionBound (by unfold OrdinarySymbol; decide) opening
          (by change fixedAfter text position "(" false ≤ limit; omega)
        obtain ⟨free, afterInner⟩ := afterOpen.conditionSyntax inner openBound (by omega) spelling targetBound
        exact ⟨free, afterInner.fixedSymbol (byte := ')') innerBound (by unfold OrdinarySymbol; decide) closing finishBound⟩
    | booleanArray _ _ _ _ atom => exact trace.booleanArray atom positionBound finishBound spelling targetBound
    | boolean positive _ _ _ _ atom => exact trace.booleanAtom atom positive positionBound finishBound spelling
    | valid _ _ _ _ _ accepted => exact ⟨rfl, trace.validityOperation positionBound accepted finishBound⟩
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem ActualNameFreeTrace.booleanFactorSyntax {text : Source} {context : ParseContext} {facts : ActiveFlow}
      {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
      {target : Cell} {condition : Condition} {result : ConditionResult}
      (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
      (source : BooleanFactorAt text context position facts condition result initials)
      (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
      (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
      conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
    cases source with
    | primary _ inner => exact trace.primarySyntax inner positionBound finishBound spelling targetBound
    | negated opening _ inner =>
        have openBound := fixedAfter_result_bound text position "not" true (by decide)
        have innerAdvance := primary_source_advance inner openBound
        dsimp only at finishBound
        have afterNot := trace.fixedWord (word := "not") positionBound (by decide) (by decide) opening (by omega)
        have free := afterNot.primarySyntax inner openBound finishBound spelling targetBound
        exact free
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem ActualNameFreeTrace.booleanRelationSyntax {text : Source} {context : ParseContext} {facts : ActiveFlow}
      {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
      {target : Cell} {condition : Condition} {result : ConditionResult}
      (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
      (source : BooleanRelationAt text context position facts condition result initials)
      (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
      (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
      conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
    cases source with
    | factor inner _ _ => exact trace.booleanFactorSyntax inner positionBound finishBound spelling targetBound
    | comparison left _ compared _ _ right _ =>
        have leftBound := booleanFactor_source_bound left positionBound
        have compareBound := comparison_bound text _ leftBound
        have compareAdvance := comparison_source_advance leftBound compared
        have rightAdvance := booleanFactor_source_advance right compareBound
        dsimp only at finishBound
        obtain ⟨leftFree, afterLeft⟩ := trace.booleanFactorSyntax left positionBound (by omega) spelling targetBound
        have afterComparison := afterLeft.comparison leftBound compared (by omega)
        obtain ⟨rightFree, afterRight⟩ := afterComparison.booleanFactorSyntax right compareBound finishBound spelling targetBound
        exact ⟨Bool.or_eq_false_iff.mpr ⟨leftFree, rightFree⟩, afterRight⟩
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem ActualNameFreeTrace.relationSyntax {text : Source} {context : ParseContext} {facts : ActiveFlow}
      {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
      {target : Cell} {condition : Condition} {result : ConditionResult}
      (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
      (source : RelationAt text context position facts condition result initials)
      (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
      (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
      conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
    cases source with
    | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner | primary _ _ _ _ _ _ inner _ =>
        exact trace.booleanRelationSyntax inner positionBound finishBound spelling targetBound
    | length _ _ _ left right _ => exact ⟨rfl, trace.lengthPair left right positionBound finishBound⟩
    | scalars _ _ _ _ left right _ =>
        obtain ⟨leftFree, rightFree, following⟩ := trace.scalarPair left right finishBound spelling targetBound
        refine ⟨?_, following⟩
        cases target with
        | integer => exact Bool.or_eq_false_iff.mpr ⟨leftFree, rightFree⟩
        | boolean => rfl
    | strings _ _ _ _ left right _ _ _ =>
        obtain ⟨leftFree, rightFree, following⟩ := trace.stringPair left right positionBound finishBound spelling targetBound
        refine ⟨?_, following⟩
        cases target with
        | integer => exact Bool.or_eq_false_iff.mpr ⟨leftFree, rightFree⟩
        | boolean => rfl
    | character _ _ _ _ _ inner _ => exact trace.characterPair inner positionBound finishBound spelling targetBound
  termination_by (remainingAt text position, 4)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.right _ (by decide)

  theorem ActualNameFreeTrace.chainSyntax {text : Source} {context : ParseContext}
      {initials : ArrayBindings.Initials} {incoming : ActiveFlow} {originalStart limit targetFirst targetAfter : Nat}
      {target : Cell} {condition final : Condition} {result finalResult : ConditionResult} {chained : Option ChainKind}
      (trace : ActualNameFreeTrace text limit targetFirst targetAfter result.after)
      (source : ChainAt text context condition result chained final finalResult incoming initials originalStart)
      (positionBound : result.after ≤ text.length + 1) (finishBound : finalResult.after ≤ limit)
      (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace)
      (firstFree : conditionMentions target condition = false) :
      conditionMentions target final = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter finalResult.after := by
    cases source with
    | done => exact ⟨firstFree, trace⟩
    | @next _ _ _ _ _ operator right rightResult _ _ _ _ _ _ _ opened _ rightSource _ _ _ rest =>
        have operatorBound := chainAfter_bound text _ operator positionBound
        have rightBound := relation_source_bound rightSource operatorBound
        have rightAdvance := relation_source_advance rightSource operatorBound
        have remaining := chain_source_nondecreasing rest
        have joinAfter : (chainJoin result rightResult operator incoming).after = rightResult.after := by
          cases operator <;> rfl
        rw [joinAfter] at remaining
        have afterOperator := trace.logicalChain positionBound opened (by omega)
        obtain ⟨rightFree, afterRight⟩ := afterOperator.relationSyntax rightSource operatorBound (by omega) spelling targetBound
        have joinedFree : conditionMentions target (chainCondition condition right operator) = false := by
          cases operator <;> exact Bool.or_eq_false_iff.mpr ⟨firstFree, rightFree⟩
        rw [← joinAfter] at afterRight
        exact afterRight.chainSyntax rest (by rw [joinAfter]; exact rightBound) finishBound spelling targetBound joinedFree
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem ActualNameFreeTrace.conditionSyntax {text : Source} {context : ParseContext} {facts : ActiveFlow}
      {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
      {target : Cell} {condition : Condition} {result : ConditionResult}
      (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
      (source : ConditionAt text context position facts condition result initials)
      (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
      (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
      conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
    cases source with
    | condition _ first _ _ tail =>
        have firstBound := relation_source_bound first positionBound
        have advance := chain_source_nondecreasing tail
        obtain ⟨firstFree, afterFirst⟩ := trace.relationSyntax first positionBound (by omega) spelling targetBound
        exact afterFirst.chainSyntax tail firstBound finishBound spelling targetBound firstFree
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate
