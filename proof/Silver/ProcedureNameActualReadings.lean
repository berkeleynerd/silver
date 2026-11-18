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

theorem ProcedureActualsTailAt.advance {text context facts catalog position first last ordinal named seen entries after}
    (source : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    (positionBound : position ≤ text.length + 1) : position < after := by
  induction source with
  | last selected _ reading closed =>
      have payloadOrder := procedureAssociation_payload_order positionBound selected
      have one := reading.advance (procedureAssociation_payload_bound _ _ _ _ _ _ _ positionBound)
      have close := Compose.Expressions.model_fixed_advances text _ ")" false reading.bounded (by decide) closed
      omega
  | next _ selected _ reading comma rest ih =>
      have payloadOrder := procedureAssociation_payload_order positionBound selected
      have one := reading.advance (procedureAssociation_payload_bound _ _ _ _ _ _ _ positionBound)
      have delimiter := Compose.Expressions.model_fixed_advances text _ "," false reading.bounded (by decide) comma
      have restAdvance := ih (fixedAfter_result_bound text _ "," false (by decide))
      omega

theorem ProcedureActualsAt.advance {text context facts catalog position first last actuals after}
    (source : ProcedureActualsAt text context facts catalog position first last actuals after)
    (positionBound : position ≤ text.length + 1) : position < after := by
  cases source with
  | actuals source => exact source.advance positionBound

/-- Each retained payload lies after the start of its source tail and strictly
before the tail's closing cursor. These are source positions, not values. -/
theorem ProcedureActualsTailAt.locations {text context facts catalog position first last ordinal named seen entries after}
    (source : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    (positionBound : position ≤ text.length + 1) :
    ∀ entry ∈ entries, position ≤ entry.2.position ∧ entry.2.position < entry.2.after ∧
      entry.2.after < after ∧ entry.2.position ≤ text.length + 1 := by
  induction source with
  | @last position named seen actual after selected _ reading closed =>
      intro entry present
      have same := List.mem_singleton.mp present
      subst entry
      have payloadOrder := procedureAssociation_payload_order positionBound selected
      have payloadBound := procedureAssociation_payload_bound text position catalog first last last named positionBound
      have one := reading.advance payloadBound
      have close := Compose.Expressions.model_fixed_advances text _ ")" false reading.bounded (by decide) closed
      exact ⟨payloadOrder, one, close, payloadBound⟩
  | @next position ordinal named seen actual after entries result _ selected _ reading comma rest ih =>
      intro entry present
      have payloadOrder := procedureAssociation_payload_order positionBound selected
      have payloadBound := procedureAssociation_payload_bound text position catalog first last ordinal named positionBound
      have one := reading.advance payloadBound
      have delimiter := Compose.Expressions.model_fixed_advances text _ "," false reading.bounded (by decide) comma
      have commaBound := fixedAfter_result_bound text after "," false (by decide)
      have restAdvance := rest.advance commaBound
      rcases List.mem_cons.mp present with same | later
      · subst entry
        exact ⟨payloadOrder, one, by dsimp only; omega, payloadBound⟩
      · have location := ih commaBound entry later
        exact ⟨by omega, location.2⟩

theorem ProcedureActualsTailAt.after_order {text context facts catalog position first last ordinal named seen entries after}
    (source : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    (positionBound : position ≤ text.length + 1) :
    entries.Pairwise (fun left right => left.2.after < right.2.after) := by
  induction source with
  | last => exact List.pairwise_singleton _ _
  | @next position ordinal named seen actual after entries result _ _ _ reading comma rest ih =>
      have commaBound := fixedAfter_result_bound text after "," false (by decide)
      have commaAdvance := Compose.Expressions.model_fixed_advances text _ "," false reading.bounded (by decide) comma
      apply List.pairwise_cons.mpr
      refine ⟨?_, ih commaBound⟩
      intro entry present
      have location := rest.locations commaBound entry present
      dsimp only
      omega

/-- Replay and admission select the same formal and reader at every source
position. Its success exposes the actual lexical exclusion for every payload. -/
theorem ProcedureActualsTailAt.replayFree {text context facts catalog position first last ordinal named seen entries after}
    (source : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after)
    {callAfter targetFirst targetAfter : Nat}
    (accepted : procedurePayloadsFreeModel text context position facts catalog first last ordinal named
      callAfter targetFirst targetAfter = true) :
    ∀ entry ∈ entries,
      (skipAt text entry.2.position = targetFirst ∧ entry.2.after = targetAfter) ∨
      actualNameFree text entry.2.position entry.2.after targetFirst targetAfter = true := by
  induction source with
  | @last position named seen actual after selected _ reading closed =>
      rw [procedurePayloadsFreeModel] at accepted
      dsimp only at accepted
      simp only [selected, or_false, reading.equation, reading.positive, ↓reduceIte] at accepted
      split at accepted
      · contradiction
      · split at accepted
        · contradiction
        · rename_i checked
          have good : ((skipAt text (procedureAssociation text position catalog first last last named).payloadFirst == targetFirst && after == targetAfter) ||
              actualNameFree text (procedureAssociation text position catalog first last last named).payloadFirst after targetFirst targetAfter) = true := by
            exact Bool.of_not_eq_false (fun no => checked (by simp only [no, Bool.not_false]))
          intro entry present
          have same := List.mem_singleton.mp present
          subst entry
          simpa only [Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] using good
  | @next position ordinal named seen actual after entries result within selected _ reading comma rest ih =>
      rw [procedurePayloadsFreeModel] at accepted
      dsimp only at accepted
      simp only [selected, or_false, reading.equation, reading.positive, ↓reduceIte] at accepted
      split at accepted
      · contradiction
      · split at accepted
        · contradiction
        · rename_i checked
          have good : ((skipAt text (procedureAssociation text position catalog first last ordinal named).payloadFirst == targetFirst && after == targetAfter) ||
              actualNameFree text (procedureAssociation text position catalog first last ordinal named).payloadFirst after targetFirst targetAfter) = true := by
            exact Bool.of_not_eq_false (fun no => checked (by simp only [no, Bool.not_false]))
          simp only [Nat.ne_of_lt within, ↓reduceIte] at accepted
          intro entry present
          rcases List.mem_cons.mp present with same | later
          · subst entry
            simpa only [Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] using good
          · exact ih accepted entry later

end Silver.Predicate
