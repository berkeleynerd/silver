module

public import Silver.ProcedureNameScalarReadings

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

private theorem skipAt_eq_scalarSkip (text : Source) (position : Nat) :
    skipAt text position = ScalarExpression.skip text position := rfl

theorem ActualNameFreeTrace.arrayAtom {text : Source} {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Metadata}
    {maskFirst maskAfter position target limit targetFirst targetAfter : Nat}
    {allowSign : Bool} {value : ScalarExpression.Parsed}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.ArrayAtomAt text names arrays maskFirst maskAfter allowSign position value)
    (positionBound : position ≤ text.length + 1) (finishBound : value.after ≤ limit)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target value.expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter value.after := by
  have first := ScalarExpression.skip_bounds text position positionBound
  cases source with
  | ordinary atom => exact trace.scalarAtom atom positionBound finishBound targetFound
  | @indexed bytes after arrayTarget opened closed index positive within _ _ identifier _ _ _ _ _ opening indexSource closing _ =>
      have nameBounds := Named.identifier_bounds identifier
      have openSkip := ScalarExpression.skip_bounds text after nameBounds.2.2.2
      have openEnd := opening.2.2.2
      have openedWithin := opening.2.1
      have indexBounds := ScalarExpression.syntax_bounds (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) indexSource
      have closeSkip := ScalarExpression.skip_bounds text index.after indexBounds.2.2
      have closeEnd := closing.2.2.2
      have afterName := (trace.identifier (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl positive identifier (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)).2
      have afterOpen := afterName.scalarSymbol opening (by unfold OrdinarySymbol; decide) nameBounds.2.2.2 (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      obtain ⟨indexFree, afterIndex⟩ := afterOpen.scalarSyntax indexSource (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
        targetFound
      refine ⟨?_, afterIndex.scalarSymbol closing (by unfold OrdinarySymbol; decide) indexBounds.2.2 finishBound⟩
      have apart : ¬(ArrayBindings.binding arrays arrayTarget).descriptor.ContainsCell target := by
        simp only [ArrayBindings.Binding.descriptor, Integer.ArrayDescriptor.ContainsCell]
        omega
      simp only [integerMentions, apart, decide_false, Bool.false_or, indexFree]

theorem ActualNameFreeTrace.arraySyntax {text : Source} {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Metadata}
    {maskFirst maskAfter position target limit targetFirst targetAfter : Nat}
    {allowSign : Bool} {value : ScalarExpression.Parsed}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position value)
    (positionBound : position ≤ text.length + 1) (finishBound : value.after ≤ limit)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target value.expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter value.after := by
  induction source with
  | @atom position allowSign value positive within _ atom =>
      have first := ScalarExpression.skip_bounds text position positionBound
      have progress := ScalarExpression.arrayAtom_syntax_bounds first.2 atom
      exact (trace.skipped positive (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) positionBound).arrayAtom atom first.2
        finishBound targetFound targetBound
  | @signed position value finish closed allowSign opened sign number closing =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have numberBounds := ScalarLiteral.integer_bounds number
      have next := ScalarExpression.skip_bounds text (ScalarExpression.inner text position + 1) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have closeSkip := ScalarExpression.skip_bounds text finish numberBounds.2.1
      have closed := closing.2.2.2
      have innerTrace := trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have signTrace := innerTrace.scalarSign (skipAt_idempotent _ _) sign (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have afterNumber := signTrace.number (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl number (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      exact ⟨rfl, afterNumber.scalarSymbol closing (by unfold OrdinarySymbol; decide) numberBounds.2.1 finishBound⟩
  | @unary position closed allowSign value opened sign _ child closing ih =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have next := ScalarExpression.skip_bounds text (ScalarExpression.inner text position + 1) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have childBounds := ScalarExpression.arrays_syntax_bounds next.2 child
      have closeSkip := ScalarExpression.skip_bounds text value.after childBounds.2.2
      have closed := closing.2.2.2
      have innerTrace := trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have signTrace := innerTrace.scalarSign (skipAt_idempotent _ _) sign (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have childTrace := signTrace.skipped (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      obtain ⟨free, afterChild⟩ := ih childTrace next.2 (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      refine ⟨?_, afterChild.scalarSymbol closing (by unfold OrdinarySymbol; decide) childBounds.2.2 finishBound⟩
      simp only [ScalarExpression.unary]
      split <;> exact free
  | @grouped position closed allowSign value opened _ child closing ih =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have childBounds := ScalarExpression.arrays_syntax_bounds (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) child
      have closeSkip := ScalarExpression.skip_bounds text value.after childBounds.2.2
      have closed := closing.2.2.2
      obtain ⟨free, afterChild⟩ := ih (trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega))
        (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      exact ⟨free, afterChild.scalarSymbol closing (by unfold OrdinarySymbol; decide) childBounds.2.2 finishBound⟩
  | @binary position closed operatorEnd allowSign left right combined opened _ leftSource _ _ operator rightSource combination closing ihl ihr =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have leftBounds := ScalarExpression.arrays_syntax_bounds (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) leftSource
      have operatorSkip := ScalarExpression.skip_bounds text left.after leftBounds.2.2
      have operatorBounds := ScalarExpression.binaryToken_bounds operator
      have rightBounds := ScalarExpression.arrays_syntax_bounds operatorBounds.2.2 rightSource
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
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {maskFirst maskAfter position target limit targetFirst targetAfter : Nat}
    {expression : Integer.Expr} {result : ScalarExpression.Result}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating)
    (finishBound : result.after ≤ limit)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
  cases arrays with
  | nil => exact trace.scalarSyntax source.grammar source.positionBound finishBound targetFound
  | cons => exact trace.arraySyntax source.grammar source.positionBound finishBound targetFound targetBound

end Silver.Predicate
