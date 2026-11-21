module

public import Silver.ProcedureNameArrayReadings
public import Silver.ProcedureNameTerminals
public import Silver.ProcedureNameLiteralTraversal
public import Silver.ComposeCharacterBounds

@[expose] public section

set_option maxHeartbeats 800000

namespace Silver.Predicate
open Compose ScalarProcedures

/-- A successful name cursor retains the independent identifier grammar. -/
theorem nameAfter_source {text : Source} {first : Nat}
    (accepted : nameAfter text first ≠ 0) :
    first ≠ 0 ∧ ∃ bytes, Named.IdentifierAt text first bytes (nameAfter text first) := by
  have positive : first ≠ 0 := by
    intro zero
    simp [nameAfter, zero] at accepted
  obtain ⟨bytes, source⟩ := Named.identifierEnd_sound text first
    (by simpa only [nameAfter, positive, ↓reduceIte] using accepted)
  exact ⟨positive, bytes, by simpa only [nameAfter, positive, ↓reduceIte] using source⟩

theorem ActualNameFreeTrace.nameEnd {text : Source}
    {position limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (accepted : nameAfter text (skipAt text position) ≠ 0)
    (finishBound : nameAfter text (skipAt text position) ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (nameAfter text (skipAt text position)) := by
  obtain ⟨positive, bytes, source⟩ := nameAfter_source accepted
  have start := skipAt_advances text position positionBound positive
  have bounds := Named.identifier_bounds source
  exact (trace.identifier (by omega) rfl positive source finishBound).2

/-- Indexed Characters traverse the String identifier, both parentheses and
exactly the scalar expression retained by the source reading. -/
theorem ActualNameFreeTrace.indexedElement {text : Source}
    {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position target limit targetFirst targetAfter : Nat} {info : BindingInfo}
    {lower upper : Integer.Expr}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : IndexedReading text names scalarNames arrays initials elaborating true position info lower upper)
    (positionBound : position ≤ text.length + 1)
    (finishBound : (indexedParts text position names scalarNames arrays initials elaborating true).following ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target lower = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter
        (indexedParts text position names scalarNames arrays initials elaborating true).following := by
  have nameFields := lookupName_found source.targetPositive
  have namePositive : nameAfter text (skipAt text position) ≠ 0 := by
    have advance : skipAt text position < nameAfter text (skipAt text position) := nameFields.2.1
    omega
  have nameBound := Compose.Expressions.model_name_valid text (skipAt text position)
  have lowerSource := source.lowerSource
  have lowerBounds := lowerSource.cursorBounds
  change 0 < fixedAfter text (nameAfter text (skipAt text position)) "(" false ∧
    fixedAfter text (nameAfter text (skipAt text position)) "(" false <
      (indexedParts text position names scalarNames arrays initials elaborating true).lower.after ∧
    (indexedParts text position names scalarNames arrays initials elaborating true).lower.after ≤ text.length + 1 at lowerBounds
  change fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating true).lower.after ")" false ≤ limit at finishBound
  have opening : fixedAfter text (nameAfter text (skipAt text position)) "(" false ≠ 0 := by
    have positive := lowerBounds.1
    exact Nat.ne_of_gt positive
  have openAdvance := Compose.Expressions.model_fixed_advances text _ "(" false nameBound (by decide) opening
  have following := source.following
  change position < fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating true).lower.after ")" false at following
  have closing : fixedAfter text
      (indexedParts text position names scalarNames arrays initials elaborating true).lower.after ")" false ≠ 0 := by
    exact Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) following)
  have closeAdvance := Compose.Expressions.model_fixed_advances text _ ")" false lowerBounds.2.2 (by decide) closing
  have afterName := trace.nameEnd positionBound namePositive (by omega)
  have openLimit : fixedAfter text (nameAfter text (skipAt text position)) "(" false ≤ limit := by omega
  have afterOpen : ActualNameFreeTrace text limit targetFirst targetAfter
      (fixedAfter text (nameAfter text (skipAt text position)) "(" false) :=
    afterName.fixedSymbol (byte := '(') nameBound (by unfold OrdinarySymbol; decide) opening openLimit
  obtain ⟨free, afterLower⟩ := afterOpen.scalar lowerSource (by omega) targetFound targetBound
  exact ⟨free, afterLower.fixedSymbol (byte := ')') lowerBounds.2.2 (by unfold OrdinarySymbol; decide) closing finishBound⟩

/-- Character source expressions cannot hide an Integer read from the native
alias scanner, including scalar indexes inside parenthesized String indexing. -/
theorem ActualNameFreeTrace.characterSyntax {text : Source}
    {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position target limit targetFirst targetAfter : Nat} {expression : Character.Expr} {result : ValueResult}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : CharacterAt text names scalarNames arrays initials elaborating position expression result)
    (positionBound : position ≤ text.length + 1) (finishBound : result.after ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    characterMentions target expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter result.after := by
  induction source with
  | literal _ literal =>
      have start := skipAt_advances text _ positionBound literal.positive
      have finish := literal.following
      exact ⟨rfl, trace.character (by dsimp only [characterValue] at finishBound; omega) rfl literal finishBound⟩
  | reference _ _ selected nonzero _ _ _ =>
      have nameFields := lookupName_found (selected ▸ nonzero)
      exact ⟨rfl, trace.nameEnd positionBound (by omega) finishBound⟩
  | indexed _ _ _ indexed =>
      exact trace.indexedElement indexed positionBound finishBound targetFound targetBound
  | @parenthesized position inner result opening _ child closing ih =>
      have openBound := fixedAfter_result_bound text (skipAt text position) "(" false (by decide)
      have childBound := character_after_bounded child
      have childAdvance := character_advances child openBound
      have closeAdvance := Compose.Expressions.model_fixed_advances text _ ")" false childBound (by decide) closing
      have positionPositive : position ≠ 0 := by
        intro zero
        simp [zero, skipAt, fixedAfter] at opening
      have firstPositive := Compose.Expressions.model_fixed_input_nonzero text (skipAt text position) "(" false opening
      have triviaPositive : Cursor.triviaPosition text position ≠ 0 := by
        simpa only [skipAt, positionPositive, ↓reduceIte] using firstPositive
      have repeated : Cursor.triviaPosition text (Cursor.triviaPosition text position) =
          Cursor.triviaPosition text position := by
        simpa only [skipAt, positionPositive, triviaPositive, ↓reduceIte] using skipAt_idempotent text position
      have sameOpen : fixedAfter text (skipAt text position) "(" false = fixedAfter text position "(" false := by
        simp only [fixedAfter, skipAt, positionPositive, triviaPositive, ↓reduceIte, repeated]
      have opening' : fixedAfter text position "(" false ≠ 0 := by
        simpa only [sameOpen] using opening
      have openLimit : fixedAfter text position "(" false ≤ limit := by
        dsimp only at finishBound
        rw [sameOpen] at childAdvance
        omega
      have afterOpen : ActualNameFreeTrace text limit targetFirst targetAfter
          (fixedAfter text position "(" false) :=
        trace.fixedSymbol (byte := '(') positionBound (by unfold OrdinarySymbol; decide) opening' openLimit
      rw [← sameOpen] at afterOpen
      obtain ⟨free, afterChild⟩ := ih afterOpen openBound (by dsimp only at finishBound; omega)
      exact ⟨free, afterChild.fixedSymbol (byte := ')') childBound (by unfold OrdinarySymbol; decide) closing finishBound⟩

end Silver.Predicate
