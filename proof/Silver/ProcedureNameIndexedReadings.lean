module

public import Silver.ProcedureNameCharacterReadings
public import Silver.ProcedureNameCompoundTokens

@[expose] public section

set_option maxHeartbeats 800000

namespace Silver.Predicate
open Compose ScalarProcedures

/-- A String slice retains two separately checked scalar source expressions.
The alias trace traverses both, including the two-byte range delimiter. -/
theorem ActualNameFreeTrace.indexedSlice {text : Source}
    {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position target limit targetFirst targetAfter : Nat} {info : BindingInfo}
    {lower upper : Integer.Expr}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : IndexedReading text names scalarNames arrays initials elaborating false position info lower upper)
    (positionBound : position ≤ text.length + 1)
    (finishBound : (indexedParts text position names scalarNames arrays initials elaborating false).following ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target lower = false ∧ integerMentions target upper = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter
        (indexedParts text position names scalarNames arrays initials elaborating false).following := by
  have nameFields := lookupName_found source.targetPositive
  have namePositive : nameAfter text (skipAt text position) ≠ 0 := by
    have advance : skipAt text position < nameAfter text (skipAt text position) := nameFields.2.1
    omega
  have nameBound := Compose.Expressions.model_name_valid text (skipAt text position)
  have lowerSource := source.lowerSource
  have lowerBounds := lowerSource.cursorBounds
  change 0 < fixedAfter text (nameAfter text (skipAt text position)) "(" false ∧
    fixedAfter text (nameAfter text (skipAt text position)) "(" false <
      (indexedParts text position names scalarNames arrays initials elaborating false).lower.after ∧
    (indexedParts text position names scalarNames arrays initials elaborating false).lower.after ≤ text.length + 1 at lowerBounds
  have upperSource := source.upperSource rfl
  have upperBounds := upperSource.cursorBounds
  have opening : fixedAfter text (nameAfter text (skipAt text position)) "(" false ≠ 0 := Nat.ne_of_gt lowerBounds.1
  have openAdvance := Compose.Expressions.model_fixed_advances text _ "(" false nameBound (by decide) opening
  have rangePositive : fixedAfter text
      (indexedParts text position names scalarNames arrays initials elaborating false).lower.after ".." false ≠ 0 :=
    Nat.ne_of_gt upperBounds.1
  have rangeAdvance := Compose.Expressions.model_fixed_advances text _ ".." false lowerBounds.2.2 (by decide) rangePositive
  have following := source.following
  change position < fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating false).upper.after ")" false at following
  change fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating false).upper.after ")" false ≤ limit at finishBound
  have closing : fixedAfter text
      (indexedParts text position names scalarNames arrays initials elaborating false).upper.after ")" false ≠ 0 := by omega
  have closeAdvance := Compose.Expressions.model_fixed_advances text _ ")" false upperBounds.2.2 (by decide) closing
  have afterName := trace.nameEnd positionBound namePositive (by omega)
  have openLimit : fixedAfter text (nameAfter text (skipAt text position)) "(" false ≤ limit := by omega
  have afterOpen := afterName.fixedSymbol (byte := '(') nameBound (by unfold OrdinarySymbol; decide) opening openLimit
  obtain ⟨lowerFree, afterLower⟩ := afterOpen.scalar lowerSource (by omega) targetFound targetBound
  have afterRange := afterLower.fixedPair (left := '.') (right := '.') lowerBounds.2.2
    (by unfold OrdinarySymbol; decide) (by unfold OrdinarySymbol; decide) (by decide) (by decide)
    rangePositive (show fixedAfter text (indexedParts text position names scalarNames arrays initials elaborating false).lower.after ".." false ≤ limit by omega)
  obtain ⟨upperFree, afterUpper⟩ := afterRange.scalar upperSource (by omega) targetFound targetBound
  exact ⟨lowerFree, upperFree,
    afterUpper.fixedSymbol (byte := ')') upperBounds.2.2 (by unfold OrdinarySymbol; decide) closing finishBound⟩

end Silver.Predicate
