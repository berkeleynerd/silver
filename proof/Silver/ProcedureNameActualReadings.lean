module

public import Silver.ProcedureNameConditionReadings

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

/-- A function-style value actual keeps the endpoint of its selected source
reader, independently of the declared parameter domain. -/
theorem ActualAt.advance {text context position facts formal actual after}
    (source : ActualAt text context position facts formal actual after) : position < after := by
  cases source.payload with
  | integer kind reading nonempty included =>
      have bounds := reading.cursorBounds
      have positive : (readScalarInFlow text context position facts).after ≠ 0 := by omega
      have finish := source.equation
      simp only [actualAfter, kind, reduceCtorEq, ↓reduceIte, positive, nonempty, included,
        Bool.not_true, Bool.false_eq_true, or_self] at finish
      omega
  | boolean kind reading =>
      have finish : (readCondition text context position facts).after = after := by
        simpa only [actualAfter, kind, ↓reduceIte] using source.equation
      rw [← finish]
      exact condition_source_advance reading

theorem ActualNameFreeTrace.valueActual {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position limit targetFirst targetAfter after : Nat} {formal : FunctionBindings.Formal}
    {actual : ScalarFunctions.Actual} {target : Cell}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ActualAt text context position facts formal actual after)
    (positionBound : position ≤ text.length + 1) (finishBound : after ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
    valueMentions target actual = false ∧ ActualNameFreeTrace text limit targetFirst targetAfter after := by
  cases source.payload with
  | integer kind reading nonempty included =>
      have bounds := reading.cursorBounds
      have positive : (readScalarInFlow text context position facts).after ≠ 0 := by omega
      have finish := source.equation
      simp only [actualAfter, kind, reduceCtorEq, ↓reduceIte, positive, nonempty, included,
        Bool.not_true, Bool.false_eq_true, or_self] at finish
      rw [← finish] at finishBound ⊢
      obtain ⟨free, following⟩ := trace.scalar reading finishBound
        (spelling.scalarLookup facts) (scalarIndex_bounded targetBound)
      refine ⟨?_, following⟩
      cases target with
      | integer => exact free
      | boolean => rfl
  | boolean kind reading =>
      have finish : (readCondition text context position facts).after = after := by
        simpa only [actualAfter, kind, ↓reduceIte] using source.equation
      rw [← finish] at finishBound ⊢
      exact trace.conditionSyntax reading positionBound finishBound spelling targetBound

theorem WritableNameAt.advance {text : Source} {context : ParseContext} {position after : Nat} {cell : Cell}
    (source : WritableNameAt text context position after cell) (positionBound : position ≤ text.length + 1) :
    position < after := by
  cases source with
  | name skipped positive identifier _ =>
      have start := ScalarExpression.skip_bounds text position positionBound
      change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at start
      have advance := (Named.identifier_bounds identifier).2.2.1
      omega

theorem ProcedureActualAt.advance {text context position facts formal actual after}
    (source : ProcedureActualAt text context position facts formal actual after)
    (positionBound : position ≤ text.length + 1) : position < after := by
  cases source with
  | input _ reading => exact reading.advance
  | target _ positive => exact (procedureTargetActual_name positive).advance positionBound

def _root_.Silver.ScalarProcedures.Actual.avoids (cell : Cell) : ScalarProcedures.Actual → Bool
  | .value expression => !valueMentions cell expression
  | .target object => targetCell object != cell

theorem ActualNameFreeTrace.procedureActual {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {position limit targetFirst targetAfter after : Nat} {formal : ProcedureBindings.Formal}
    {actual : ScalarProcedures.Actual} {target : Cell}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ProcedureActualAt text context position facts formal actual after)
    (positionBound : position ≤ text.length + 1) (finishBound : after ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
    Actual.avoids target actual = true ∧ ActualNameFreeTrace text limit targetFirst targetAfter after := by
  cases source with
  | input _ reading =>
      obtain ⟨free, following⟩ := trace.valueActual reading positionBound finishBound spelling targetBound
      exact ⟨by simp only [Actual.avoids, free, Bool.not_false], following⟩
  | target _ positive =>
      have name := procedureTargetActual_name positive
      have advance := name.advance positionBound
      obtain ⟨apart, following⟩ := name.apart spelling trace (by omega) finishBound
      exact ⟨by simp only [Actual.avoids, bne_iff_ne]; exact apart, following⟩

theorem ProcedureActualsAt.advance {text context facts catalog position first last actuals after}
    (source : ProcedureActualsAt text context facts catalog position first last actuals after)
    (positionBound : position ≤ text.length + 1) : position < after := by
  induction source with
  | last reading closed =>
      have one := reading.advance positionBound
      have close := Compose.Expressions.model_fixed_advances text _ ")" false reading.bounded (by decide) closed
      omega
  | next _ reading comma rest ih =>
      have one := reading.advance positionBound
      have delimiter := Compose.Expressions.model_fixed_advances text _ "," false reading.bounded (by decide) comma
      have restAdvance := ih (fixedAfter_result_bound text _ "," false (by decide))
      omega

theorem ActualNameFreeTrace.procedureActuals {text : Source} {context : ParseContext} {facts : ActiveFlow}
    {catalog : ProcedureBindings.Metadata} {position first last limit targetFirst targetAfter after : Nat}
    {actuals : List ScalarProcedures.Actual} {target : Cell}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ProcedureActualsAt text context facts catalog position first last actuals after)
    (positionBound : position ≤ text.length + 1) (finishBound : after ≤ limit)
    (spelling : CellSpelling text context targetFirst targetAfter target) (targetBound : target.InScalarNamespace) :
    actuals.all (Actual.avoids target) = true ∧ ActualNameFreeTrace text limit targetFirst targetAfter after := by
  induction source with
  | last reading closed =>
      have closeAdvance := Compose.Expressions.model_fixed_advances text _ ")" false reading.bounded (by decide) closed
      obtain ⟨free, afterActual⟩ := trace.procedureActual reading positionBound (by omega) spelling targetBound
      exact ⟨by simp only [List.all_cons, free, List.all_nil, Bool.and_self],
        afterActual.fixedSymbol (byte := ')') reading.bounded (by unfold OrdinarySymbol; decide) closed finishBound⟩
  | @next position first last actual after actuals result _ reading comma rest ih =>
      have commaBound := fixedAfter_result_bound text after "," false (by decide)
      have commaAdvance := Compose.Expressions.model_fixed_advances text _ "," false reading.bounded (by decide) comma
      have restAdvance := rest.advance commaBound
      obtain ⟨free, afterActual⟩ := trace.procedureActual reading positionBound (by omega) spelling targetBound
      have afterComma := afterActual.fixedSymbol (byte := ',') reading.bounded (by unfold OrdinarySymbol; decide) comma
        (by change fixedAfter text after "," false ≤ limit; omega)
      obtain ⟨restFree, following⟩ := ih afterComma commaBound finishBound
      exact ⟨by simp only [List.all_cons, free, restFree, Bool.and_self], following⟩

end Silver.Predicate
