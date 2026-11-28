module

public import Silver.ProcedureNameReadings
public import Silver.ProcedureNameQualified
public import Silver.ScalarExpressionAdmission
public import Silver.ScalarProcedureSyntax

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

private theorem skipAt_eq_scalarSkip (text : Source) (position : Nat) :
    skipAt text position = ScalarExpression.skip text position := rfl

theorem ActualNameFreeTrace.scalarSymbol {text : Source}
    {position byte finish limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.SymbolAt text position byte finish)
    (ordinary : OrdinarySymbol byte) (positionBound : position ≤ text.length + 1)
    (finishBound : finish ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  have skipped := ScalarExpression.skip_bounds text position positionBound
  rcases source with ⟨positive, within, found, rfl⟩
  apply trace.symbol (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
  simpa only [show skipAt text position = ScalarExpression.skip text position from rfl, found] using ordinary

theorem ActualNameFreeTrace.scalarSign {text : Source}
    {position limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (fixed : skipAt text position = position)
    (sign : ScalarExpression.Sign (Cursor.byteAt text position))
    (before : position < limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (position + 1) := by
  apply trace.symbol before fixed before
  rcases sign with plus | minus
  · rw [plus]; unfold OrdinarySymbol; decide
  · rw [minus]; unfold OrdinarySymbol; decide

theorem ActualNameFreeTrace.scalarOpening {text : Source}
    {position limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.Opens text position)
    (positionBound : position ≤ text.length + 1)
    (innerBefore : ScalarExpression.inner text position < limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (ScalarExpression.inner text position) := by
  have bounds := ScalarExpression.opens_bounds positionBound source
  have within := source.2.1
  have first := ScalarExpression.skip_bounds text position positionBound
  have next := ScalarExpression.skip_bounds text (ScalarExpression.skip text position + 1) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
  have opening : ScalarExpression.SymbolAt text position 40 (ScalarExpression.skip text position + 1) :=
    ⟨source.1, source.2.1, source.2.2.1, rfl⟩
  have advanced := trace.scalarSymbol opening (by unfold OrdinarySymbol; decide) positionBound (by
    change ScalarExpression.skip text (ScalarExpression.skip text position + 1) < limit at innerBefore
    omega)
  apply advanced.skipped
  · change ScalarExpression.inner text position ≠ 0
    omega
  · exact innerBefore
  · omega

theorem ActualNameFreeTrace.scalarOperator {text : Source}
    {position finish limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.BinaryTokenAt text (ScalarExpression.skip text position) finish)
    (positionBound : position ≤ text.length + 1) (finishBound : finish ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  have first := ScalarExpression.skip_bounds text position positionBound
  have bounds := ScalarExpression.binaryToken_bounds source
  cases source with
  | symbol positive within operator =>
      apply trace.symbol (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      rcases operator with plus | minus | times
      · rw [show skipAt text position = ScalarExpression.skip text position from rfl, plus]; unfold OrdinarySymbol; decide
      · rw [show skipAt text position = ScalarExpression.skip text position from rfl, minus]; unfold OrdinarySymbol; decide
      · rw [show skipAt text position = ScalarExpression.skip text position from rfl, times]; unfold OrdinarySymbol; decide
  | divide positive within operator _ =>
      apply trace.symbol (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      rw [show skipAt text position = ScalarExpression.skip text position from rfl, operator]
      unfold OrdinarySymbol
      decide
  | word positive identifier _ =>
      exact (trace.identifier (first := ScalarExpression.skip text position) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) identifier finishBound).2

theorem ActualNameFreeTrace.scalarAtom {text : Source} {names : ScalarExpression.Environment}
    {maskFirst maskAfter position target limit targetFirst targetAfter : Nat}
    {allowSign : Bool} {value : ScalarExpression.Parsed}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.AtomAt text names maskFirst maskAfter allowSign position value)
    (positionBound : position ≤ text.length + 1) (finishBound : value.after ≤ limit)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target) :
    integerMentions target value.expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter value.after := by
  have first := ScalarExpression.skip_bounds text position positionBound
  cases source with
  | unsigned _ _ _ number =>
      have bounds := ScalarLiteral.integer_bounds number
      exact ⟨rfl, trace.number (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl number finishBound⟩
  | @signed value finish positive within sign _ number =>
      have bounds := ScalarLiteral.integer_bounds number
      have next := ScalarExpression.skip_bounds text (ScalarExpression.skip text position + 1) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      have atSign := trace.skipped positive (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) positionBound
      have afterSign := atSign.scalarSign (skipAt_idempotent _ _) sign (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      exact ⟨rfl, afterSign.number (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) rfl number finishBound⟩
  | @name resolved index positive _ _ _ reference found indexPositive _ =>
      have atPosition : QualifiedNames.At text position resolved := by
        have equation := QualifiedNames.read_complete reference
        change QualifiedNames.read text (QualifiedNames.skip text position) = resolved at equation
        rw [QualifiedNames.read_skipped] at equation
        have success : (QualifiedNames.read text position).after ≠ 0 := by
          cases reference with
          | bare _ identifier _ =>
              have bounds := Named.identifier_bounds identifier
              rw [equation]
              dsimp only
              omega
          | qualified _ _ _ _ identifier =>
              have bounds := Named.identifier_bounds identifier
              rw [equation]
              dsimp only
              omega
        simpa only [equation] using QualifiedNames.read_sound text position success
      have following := trace.reference atPosition positionBound finishBound
      refine ⟨?_, following⟩
      cases atPosition with
      | bare namePositive identifier _ =>
          dsimp only at finishBound
          have start : position ≤ QualifiedNames.skip text position := first.1
          have bounds := Named.identifier_bounds identifier
          by_cases targetPositive : target = 0
          · simp only [integerMentions, targetPositive, beq_eq_false_iff_ne]
            exact Ne.symm indexPositive
          · obtain ⟨different, _⟩ := trace.scalarName (by omega) rfl
              (Nat.ne_of_gt namePositive) identifier finishBound found targetFound targetPositive
            simpa only [integerMentions, beq_eq_false_iff_ne] using different.symm
      | qualified qualifierPositive _ _ _ _ =>
          by_cases targetPositive : target = 0
          · simp only [integerMentions, targetPositive, beq_eq_false_iff_ne]
            exact Ne.symm indexPositive
          · have different := scalarLookup_qualified_ne_bare
              (Nat.ne_of_gt qualifierPositive) found targetFound targetPositive
            simpa only [integerMentions, beq_eq_false_iff_ne] using different.symm

theorem integerMentions_binary {left right result : ScalarExpression.Parsed} {operator target : Nat}
    (source : ScalarExpression.binary left right operator = some result)
    (leftFree : integerMentions target left.expression = false)
    (rightFree : integerMentions target right.expression = false) :
    integerMentions target result.expression = false := by
  unfold ScalarExpression.binary at source
  repeat' first | split at source | (cases source <;> simp [integerMentions, leftFree, rightFree])

/-- The lexical scanner follows every scalar expression production. Each
binding read is excluded using lookup identity, and the resulting trace starts
at the actual expression end, ready for the enclosing grammar. -/
theorem ActualNameFreeTrace.scalarSyntax {text : Source} {names : ScalarExpression.Environment}
    {maskFirst maskAfter position target limit targetFirst targetAfter : Nat}
    {allowSign : Bool} {value : ScalarExpression.Parsed}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ScalarExpression.SyntaxAt text names maskFirst maskAfter allowSign position value)
    (positionBound : position ≤ text.length + 1) (finishBound : value.after ≤ limit)
    (targetFound : ScalarExpression.lookup text names targetFirst targetAfter = target) :
    integerMentions target value.expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter value.after := by
  induction source with
  | @atom position allowSign value positive within _ atom =>
      have first := ScalarExpression.skip_bounds text position positionBound
      have progress := ScalarExpression.atom_bounds first.2 (ScalarExpression.atom_complete first.2 atom)
      exact (trace.skipped positive (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) positionBound).scalarAtom atom first.2
        finishBound targetFound
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
      have childBounds := ScalarExpression.syntax_bounds next.2 child
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
      have childBounds := ScalarExpression.syntax_bounds (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) child
      have closeSkip := ScalarExpression.skip_bounds text value.after childBounds.2.2
      have closed := closing.2.2.2
      obtain ⟨free, afterChild⟩ := ih (trace.scalarOpening opened positionBound (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega))
        (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega)
      exact ⟨free, afterChild.scalarSymbol closing (by unfold OrdinarySymbol; decide) childBounds.2.2 finishBound⟩
  | @binary position closed operatorEnd allowSign left right combined opened _ leftSource _ _ operator rightSource combination closing ihl ihr =>
      have start := ScalarExpression.opens_bounds positionBound opened
      have leftBounds := ScalarExpression.syntax_bounds (by (try dsimp only [ScalarExpression.inner] at *); (try simp only [skipAt_eq_scalarSkip] at *); omega) leftSource
      have operatorSkip := ScalarExpression.skip_bounds text left.after leftBounds.2.2
      have operatorBounds := ScalarExpression.binaryToken_bounds operator
      have rightBounds := ScalarExpression.syntax_bounds operatorBounds.2.2 rightSource
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

end Silver.Predicate
