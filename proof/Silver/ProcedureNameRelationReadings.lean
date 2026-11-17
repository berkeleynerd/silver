module

public import Silver.ProcedureNameConditionCursors
public import Silver.ProcedureNameConditionTokens
public import Silver.ProcedureNameStringReadings
public import Silver.ProcedureNameBooleanReadings

@[expose] public section

set_option maxHeartbeats 800000

namespace Silver.Predicate
open Compose ScalarProcedures

theorem comparison_source_advance {text : Source} {position : Nat}
    (bounded : position ≤ text.length + 1) (accepted : (comparisonAt text position).after ≠ 0) :
    position < (comparisonAt text position).after := by
  unfold comparisonAt at accepted ⊢
  split <;> first | exact Compose.Expressions.model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact Compose.Expressions.model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact Compose.Expressions.model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact Compose.Expressions.model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split <;> first | exact Compose.Expressions.model_fixed_advances text position _ _ bounded (by decide) (by assumption) | skip
  split
  · exact Compose.Expressions.model_fixed_advances text position _ _ bounded (by decide) (by assumption)
  · simp_all

private theorem mantissa_input_positive {text position value base finish}
    (source : IntegerLiteral.MantissaAt text position value base finish) : 0 < position := by
  cases source with
  | decimal numeral _ | based numeral _ _ _ _ => exact numeral.1

theorem length_source_input {text context position literal operand result}
    (source : LengthAt text context position literal operand result) : position ≠ 0 := by
  cases source with
  | number _ literal =>
      cases literal with
      | literal number _ _ =>
          have positive : 0 < skipAt text position := mantissa_input_positive number
          intro zero
          simp only [zero, skipAt, ↓reduceIte, Nat.lt_irrefl] at positive
  | @binding index info name after _ indexEq found _ _ _ _ _ =>
      have indexPositive : index ≠ 0 := by
        intro zero
        simp only [Bindings.BindingEnvironment.get, zero, ↓reduceIte, reduceCtorEq] at found
      have positive := (lookupName_found (indexEq ▸ indexPositive)).1
      intro zero
      simp only [zero, skipAt, ↓reduceIte, ne_eq, not_true_eq_false] at positive

theorem ActualNameFreeTrace.lengthPair {text : Source} {context : ParseContext}
    {position limit targetFirst targetAfter : Nat} {leftLiteral rightLiteral : Bool}
    {left right : LengthOperand} {leftResult rightResult : LengthResult}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (leftSource : LengthAt text context position leftLiteral left leftResult)
    (rightSource : LengthAt text context (comparisonAt text leftResult.after).after rightLiteral right rightResult)
    (positionBound : position ≤ text.length + 1) (finishBound : rightResult.after ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter rightResult.after := by
  have leftBound := length_source_bound leftSource
  have compareBound := comparison_bound text _ leftBound
  have comparePositive := length_source_input rightSource
  have compared := comparison_source_advance leftBound comparePositive
  have rightAdvance := length_source_advance rightSource compareBound
  have afterLeft := trace.lengthSyntax leftSource positionBound (by omega)
  have afterComparison := afterLeft.comparison leftBound comparePositive (by omega)
  exact afterComparison.lengthSyntax rightSource compareBound finishBound

theorem ActualNameFreeTrace.scalarPair {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
    {target : Cell} {left right : Integer.Expr} {leftResult rightResult : ScalarExpression.Result}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (leftSource : ScalarExpression.At text (context.readingNames facts) position left leftResult
      (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating))
    (rightSource : ScalarExpression.At text (context.readingNames facts) (comparisonAt text leftResult.after).after right rightResult
      (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating))
    (finishBound : rightResult.after ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
    integerMentions target.scalarIndex left = false ∧ integerMentions target.scalarIndex right = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter rightResult.after := by
  have leftBounds := leftSource.cursorBounds
  have rightBounds := rightSource.cursorBounds
  have comparePositive := Nat.ne_of_gt rightBounds.1
  have compared := comparison_source_advance leftBounds.2.2 comparePositive
  obtain ⟨leftFree, afterLeft⟩ := trace.scalar leftSource (by omega)
    (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
  have afterComparison := afterLeft.comparison leftBounds.2.2 comparePositive (by omega)
  obtain ⟨rightFree, afterRight⟩ := afterComparison.scalar rightSource finishBound
    (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
  exact ⟨leftFree, rightFree, afterRight⟩

private theorem stringTail_positive {text names scalarNames integerHidden arrays initials elaborating scan expression result}
    (source : ExpressionTailAt text names scan expression result scalarNames integerHidden arrays initials elaborating) :
    result.after ≠ 0 := by
  induction source with
  | done positive _ => exact positive
  | last _ _ positive _ _ => exact positive
  | next _ _ _ _ _ _ _ ih => exact ih

private theorem stringTail_nondecreasing {text names scalarNames integerHidden arrays initials elaborating scan expression result}
    (source : ExpressionTailAt text names scan expression result scalarNames integerHidden arrays initials elaborating) :
    scan.position ≤ result.after := by
  have advance := Compose.Expressions.model_tail_nondecreasing (scalarNames := scalarNames)
    (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names scan
  rw [expressionTail_complete source] at advance
  exact advance.resolve_left (stringTail_positive source)

theorem ActualNameFreeTrace.stringPair {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
    {target : Cell} {left right : Expression} {leftResult rightResult : ExpressionResult}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (leftSource : ExpressionAt text context.names position left leftResult (scalarNames := context.readingNames facts)
      (integerHidden := context.integerHidden text) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating))
    (rightSource : ExpressionAt text context.names (comparisonAt text leftResult.after).after right rightResult
      (scalarNames := context.readingNames facts) (integerHidden := context.integerHidden text)
      (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating))
    (positionBound : position ≤ text.length + 1) (finishBound : rightResult.after ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
    left.any (stringMentions target.scalarIndex) = false ∧ right.any (stringMentions target.scalarIndex) = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter rightResult.after := by
  have leftBound := stringTail_source_bound leftSource positionBound
  have compareBound := comparison_bound text _ leftBound
  have comparePositive : (comparisonAt text leftResult.after).after ≠ 0 := by
    cases rightSource <;> assumption
  have compared := comparison_source_advance leftBound comparePositive
  have rightAdvance := stringTail_nondecreasing rightSource
  change (comparisonAt text leftResult.after).after ≤ rightResult.after at rightAdvance
  obtain ⟨leftFree, afterLeft⟩ := trace.stringSyntax leftSource positionBound (by omega)
    (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
  have afterComparison := afterLeft.comparison leftBound comparePositive (by omega)
  obtain ⟨rightFree, afterRight⟩ := afterComparison.stringSyntax rightSource compareBound finishBound
    (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
  exact ⟨leftFree, rightFree, afterRight⟩

theorem ActualNameFreeTrace.characterPair {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {initials : ArrayBindings.Initials} {position limit targetFirst targetAfter : Nat}
    {target : Cell} {condition : Condition} {result : ConditionResult}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : CharacterRelationAt text context position facts initials condition result)
    (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
    conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
  cases source with
  | comparison left right _ comparePositive _ _ =>
      have leftBound := character_after_bounded left
      have compareBound := comparison_bound text _ leftBound
      have compared := comparison_source_advance leftBound comparePositive
      have rightAdvance := character_advances right compareBound
      dsimp only at finishBound
      obtain ⟨leftFree, afterLeft⟩ := trace.characterSyntax left positionBound (by omega)
        (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
      have afterComparison := afterLeft.comparison leftBound comparePositive (by omega)
      obtain ⟨rightFree, afterRight⟩ := afterComparison.characterSyntax right compareBound finishBound
        (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
      refine ⟨?_, afterRight⟩
      cases target with
      | integer => exact Bool.or_eq_false_iff.mpr ⟨leftFree, rightFree⟩
      | boolean => rfl

end Silver.Predicate
