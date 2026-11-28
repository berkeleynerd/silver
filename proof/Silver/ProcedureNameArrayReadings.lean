module

public import Silver.ProcedureNameAttributes
public import Silver.ProcedureNameScalarReadings
public import Silver.ScalarArrayGrammarSyntax

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

private theorem skipAt_eq_scalarSkip (text : Source) (position : Nat) :
    skipAt text position = ScalarExpression.skip text position := rfl

/-- A bounds query traverses its prefix and the full attribute designator.
All admitted designators are long enough to exclude a Character literal at the tick. -/
theorem ActualNameFreeTrace.arrayAttribute {text : Source} {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {position maskFirst maskAfter limit targetFirst targetAfter : Nat}
    {rangeQuery : Bool} {query : ScalarExpression.ArrayAttributes.ParsedQuery}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.ArrayAttributes.At text names arrays position maskFirst maskAfter rangeQuery query)
    (positionBound : position ≤ text.length + 1) (finishBound : query.after ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter query.after := by
  cases source with
  | @read prefixBytes prefixEnd tickEnd designator finish shape query positive identifier _ _ _ tick _ spelling word =>
      change finish ≤ limit at finishBound
      have start := ScalarExpression.skip_bounds text position positionBound
      have prefixBounds := Named.identifier_bounds identifier
      have tickStart := ScalarExpression.skip_bounds text prefixEnd prefixBounds.2.2.2
      rcases tick with ⟨_, tickWithin, tickByte, rfl⟩
      have wordStart := ScalarExpression.skip_bounds text (ScalarExpression.skip text prefixEnd + 1) (by omega)
      have nameBounds := Named.identifier_bounds spelling
      have matched := word.2
      simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq] at matched
      have wordLength : 2 ≤ query.word.length := by cases query <;> decide
      have longName : 2 ≤ designator.length := by omega
      have afterPrefix := (trace.identifier (first := ScalarExpression.skip text position)
        (by omega) rfl positive identifier (by omega)).2
      exact afterPrefix.attribute (by omega) rfl tickWithin tickByte spelling longName finishBound

/-- Scanner traversal proves scalar noninterference for the complete expression
grammar. The array descriptor base lies above every scalar cell for both local
storage and symbolic input views. -/
theorem ActualNameFreeTrace.arraySyntax {text : Source} {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {mode : ScalarExpression.ArrayReadMode}
    {maskFirst maskAfter position target limit targetFirst targetAfter : Nat}
    {allowSign : Bool} {value : ScalarExpression.Parsed}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.ArrayGrammar.SourceAt text names arrays maskFirst maskAfter mode allowSign position value)
    (positionBound : position ≤ text.length + 1) (finishBound : value.after ≤ limit)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target value.expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter value.after := by
  induction source with
  | @ordinary mode position allowSign value positive _ _ atom =>
      have first := ScalarExpression.skip_bounds text position positionBound
      have progress := ScalarExpression.atom_bounds first.2 (ScalarExpression.atom_complete first.2 atom)
      have atName := trace.skipped positive (by simpa only [skipAt_eq_scalarSkip] using
        (show ScalarExpression.skip text position < limit by omega)) positionBound
      exact atName.scalarAtom atom first.2 finishBound targetFound
  | shape _ _ _ _ query =>
      exact ⟨rfl, trace.arrayAttribute query positionBound finishBound⟩
  | @indexed mode position allowSign bytes after arrayTarget opened closed index
      positive _ _ _ _ _ identifier _ _ _ _ _ _ _ opening child closing _ ih =>
      change closed ≤ limit at finishBound
      have first := ScalarExpression.skip_bounds text position positionBound
      have nameBounds := Named.identifier_bounds identifier
      have openStart := ScalarExpression.skip_bounds text after nameBounds.2.2.2
      have openEnd := opening.2.2.2
      have openedWithin := opening.2.1
      have indexBounds := ScalarExpression.ArrayGrammar.SourceAt.bounds (by omega) child
      have closeStart := ScalarExpression.skip_bounds text index.after indexBounds.2.2
      have closeEnd := closing.2.2.2
      have afterName := (trace.identifier (first := ScalarExpression.skip text position)
        (by omega) rfl positive identifier (by omega)).2
      have afterOpen := afterName.scalarSymbol opening (by unfold OrdinarySymbol; decide)
        nameBounds.2.2.2 (by omega)
      obtain ⟨indexFree, afterIndex⟩ := ih afterOpen (by omega) (by omega)
      have apart : ¬(ArrayBindings.binding arrays.items arrayTarget).viewDescriptor.ContainsCell target := by
        unfold ArrayBindings.Binding.viewDescriptor
        split <;> simp only [ArrayBindings.Binding.descriptor, Integer.ArrayDescriptor.ContainsCell] <;> omega
      refine ⟨?_, afterIndex.scalarSymbol closing (by unfold OrdinarySymbol; decide) indexBounds.2.2 finishBound⟩
      simp only [integerMentions, apart, decide_false, Bool.false_or, indexFree]
  | @signed mode position value finish closed allowSign opened sign number closing =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have numberBounds := ScalarLiteral.integer_bounds number
      have next := ScalarExpression.skip_bounds text (ScalarExpression.inner text position + 1) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have closeSkip := ScalarExpression.skip_bounds text finish numberBounds.2.1
      have closed := closing.2.2.2
      have innerTrace := trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have signTrace := innerTrace.scalarSign (skipAt_idempotent _ _) sign (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have afterNumber := signTrace.number (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl number (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      exact ⟨rfl, afterNumber.scalarSymbol closing (by unfold OrdinarySymbol; decide) numberBounds.2.1 finishBound⟩
  | @unary mode position closed allowSign value opened sign _ child closing ih =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have next := ScalarExpression.skip_bounds text (ScalarExpression.inner text position + 1) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have childBounds := ScalarExpression.ArrayGrammar.SourceAt.bounds next.2 child
      have closeSkip := ScalarExpression.skip_bounds text value.after childBounds.2.2
      have closed := closing.2.2.2
      have innerTrace := trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have signTrace := innerTrace.scalarSign (skipAt_idempotent _ _) sign (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have childTrace := signTrace.skipped (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      obtain ⟨free, afterChild⟩ := ih childTrace next.2 (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      refine ⟨?_, afterChild.scalarSymbol closing (by unfold OrdinarySymbol; decide) childBounds.2.2 finishBound⟩
      simp only [ScalarExpression.unary]
      split <;> exact free
  | @grouped mode position closed allowSign value opened _ child closing ih =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have childBounds := ScalarExpression.ArrayGrammar.SourceAt.bounds (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) child
      have closeSkip := ScalarExpression.skip_bounds text value.after childBounds.2.2
      have closed := closing.2.2.2
      obtain ⟨free, afterChild⟩ := ih (trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega))
        (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      exact ⟨free, afterChild.scalarSymbol closing (by unfold OrdinarySymbol; decide) childBounds.2.2 finishBound⟩
  | @binary mode position closed operatorEnd allowSign left right combined opened _ leftSource _ _ operator rightSource combination closing ihl ihr =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have leftBounds := ScalarExpression.ArrayGrammar.SourceAt.bounds (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) leftSource
      have operatorSkip := ScalarExpression.skip_bounds text left.after leftBounds.2.2
      have operatorBounds := ScalarExpression.binaryToken_bounds operator
      have rightBounds := ScalarExpression.ArrayGrammar.SourceAt.bounds operatorBounds.2.2 rightSource
      have same := ScalarExpression.binary_result combination
      have closeSkip := ScalarExpression.skip_bounds text combined.after (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have closed := closing.2.2.2
      obtain ⟨leftFree, afterLeft⟩ := ihl (trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega))
        (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      obtain ⟨rightFree, afterRight⟩ := ihr (afterLeft.scalarOperator operator leftBounds.2.2 (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega))
        operatorBounds.2.2 (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      refine ⟨by simpa only using integerMentions_binary combination leftFree rightFree, ?_⟩
      rw [← same] at afterRight
      exact afterRight.scalarSymbol closing (by unfold OrdinarySymbol; decide) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) finishBound


theorem ActualNameFreeTrace.scalar {text : Source} {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {mode : ScalarExpression.ArrayReadMode} {maskFirst maskAfter position target limit targetFirst targetAfter : Nat}
    {expression : Integer.Expr} {result : ScalarExpression.Result}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.ArrayGrammar.At text names position expression result maskFirst maskAfter allowSign
      arrays initials elaborating mode)
    (finishBound : result.after ≤ limit) (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter result.after :=
  trace.arraySyntax source.source source.positionBound finishBound targetFound targetBound

end Silver.Predicate
