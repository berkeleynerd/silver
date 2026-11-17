module

public import Silver.ProcedureNameTargets
public import Silver.ProcedureNameCharacterReadings
public import Silver.PredicateConditionReadings
public import Silver.PredicateFlowInvariant

@[expose] public section

set_option maxHeartbeats 800000

namespace Silver.Predicate
open Compose ScalarProcedures

def _root_.Silver.ScalarProcedures.Cell.scalarIndex : Cell → Nat
  | .integer index => index
  | .boolean _ => 0

def _root_.Silver.ScalarProcedures.Cell.InScalarNamespace : Cell → Prop
  | .integer index => index ≤ ArrayBindings.scalarLimit
  | .boolean index => index ≤ BooleanBindings.maxBindings

theorem CellSpelling.scalarLookup {text : Source} {context : ParseContext}
    {first after : Nat} {cell : Cell}
    (spelling : CellSpelling text context first after cell) (facts : ActiveFlow) :
    ScalarExpression.lookup text (context.readingNames facts) first after = cell.scalarIndex := by
  simp only [ParseContext.readingNames, ScalarMetadata.readingNames_lookup]
  cases spelling with
  | integer found _ => exact found
  | boolean absent _ _ => exact absent

theorem scalarIndex_bounded {cell : Cell} (bounded : cell.InScalarNamespace) :
    cell.scalarIndex ≤ ArrayBindings.scalarLimit := by
  cases cell with
  | integer => exact bounded
  | boolean => exact Nat.zero_le _

theorem ActualNameFreeTrace.booleanAtom {text : Source} {context : ParseContext}
    {position limit targetFirst targetAfter finish : Nat} {condition : Condition} {target : Cell}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : BooleanAtomAt text context position condition finish)
    (positive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : finish ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target) :
    conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  have skipped := ScalarExpression.skip_bounds text position positionBound
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at skipped
  have firstPositive : skipAt text position ≠ 0 := by omega
  cases source with
  | name identifier found =>
      have bounds := Named.identifier_bounds identifier
      cases spelling with
      | integer =>
          refine ⟨by simp [conditionMentions], (trace.identifier (by omega) rfl firstPositive identifier finishBound).2⟩
      | boolean _ targetFound targetPositive =>
          obtain ⟨apart, rest⟩ := trace.booleanName (by omega) rfl firstPositive identifier finishBound rfl targetFound targetPositive
          refine ⟨?_, rest⟩
          simp only [conditionMentions, beq_eq_false_iff_ne]
          intro same
          exact apart (Cell.boolean.inj same).symm
  | literal identifier _ _ =>
      have bounds := Named.identifier_bounds identifier
      exact ⟨rfl, (trace.identifier (by omega) rfl firstPositive identifier finishBound).2⟩

theorem ActualNameFreeTrace.booleanArray {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position limit targetFirst targetAfter finish : Nat} {condition : Condition} {target : Cell}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : BooleanArrayAt text context position facts condition finish)
    (positionBound : position ≤ text.length + 1) (finishBound : finish ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target)
    (targetBound : target.InScalarNamespace) :
    conditionMentions target condition = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  cases source with
  | @read index subscript _ _ _ _ scalarSource _ _ advance =>
      have scalarBounds := scalarSource.cursorBounds
      have opening : fixedAfter text (nameAfter text (skipAt text position)) "(" false ≠ 0 := Nat.ne_of_gt scalarBounds.1
      have namePositive := Compose.Expressions.model_fixed_input_nonzero text _ "(" false opening
      have nameBound := Compose.Expressions.model_name_valid text (skipAt text position)
      have openAdvance := Compose.Expressions.model_fixed_advances text _ "(" false nameBound (by decide) opening
      have closing : fixedAfter text subscript.after ")" false ≠ 0 := by omega
      have closeAdvance := Compose.Expressions.model_fixed_advances text _ ")" false scalarBounds.2.2 (by decide) closing
      have afterName := trace.nameEnd positionBound namePositive (by omega)
      have afterOpen := afterName.fixedSymbol (byte := '(') nameBound (by unfold OrdinarySymbol; decide) opening
        (show fixedAfter text (nameAfter text (skipAt text position)) "(" false ≤ limit by omega)
      obtain ⟨indexFree, afterIndex⟩ := afterOpen.scalar scalarSource (by omega) (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
      refine ⟨?_, afterIndex.fixedSymbol (byte := ')') scalarBounds.2.2 (by unfold OrdinarySymbol; decide) closing finishBound⟩
      cases target with
      | integer => exact indexFree
      | boolean identity =>
          have apart : ¬(ArrayBindings.binding context.arrayNames
              (ArrayBindings.lookup text context.arrayNames (skipAt text position)
                (nameAfter text (skipAt text position)))).booleanDescriptor.ContainsCell identity := by
            simp only [ArrayBindings.Binding.booleanDescriptor, Boolean.ArrayDescriptor.ContainsCell,
              Boolean.ArrayDescriptor.layout, Integer.ArrayDescriptor.ContainsCell]
            change identity ≤ BooleanBindings.maxBindings at targetBound
            omega
          simp only [conditionMentions, apart, decide_false]

end Silver.Predicate
