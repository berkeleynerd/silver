module

public import Silver.PredicateBasicReadings
public import Silver.PredicateProcedureCallReadings

@[expose] public section

/-! Procedure calls occupy the existing final basic-statement branch. The
other branches retain their original source readings, connected by the exact
branch guards rather than a separate assumed scanner meaning. -/
namespace Silver.Predicate
open Compose

def procedureBasicSelected (text : Source) (context : ParseContext) (scan : BodyScan)
    (procedures : ProcedureBindings.Metadata) : Prop :=
  basicKind text context scan = .assignment ∧ procedureCalleeAt text context scan.position procedures ≠ 0

instance (text : Source) (context : ParseContext) (scan : BodyScan)
    (procedures : ProcedureBindings.Metadata) : Decidable (procedureBasicSelected text context scan procedures) :=
  inferInstanceAs (Decidable (_ ∧ _))

theorem basicRaw_withoutProcedure (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata)
    (ordinary : ¬ procedureBasicSelected text context scan procedures) :
    basicRaw text context scan catalog procedures = basicRaw text context scan catalog := by
  cases kind : basicKind text context scan <;> simp only [basicRaw, kind]
  all_goals try rfl
  have absent : procedureCalleeAt text context scan.position procedures = 0 := by
    by_cases absent : procedureCalleeAt text context scan.position procedures = 0
    · exact absent
    · exact False.elim (ordinary ⟨kind, absent⟩)
  simp only [absent, procedureCalleeAt_empty, ne_eq, not_true_eq_false, ↓reduceIte]

theorem basicBody_withoutProcedure (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata)
    (ordinary : ¬ procedureBasicSelected text context scan procedures) :
    basicBody text context scan catalog procedures = basicBody text context scan catalog := by
  simp only [basicBody, basicRaw_withoutProcedure text context scan catalog procedures ordinary]

theorem basicStep_after_raw {text context scan catalog procedures}
    (accepted : (basicBody text context scan catalog procedures).position ≠ 0) :
    basicBody text context scan catalog procedures =
      bodyToken text (basicRaw text context scan catalog procedures) (.symbol ";") := by
  unfold basicBody at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i nonzero
    rw [ite_eq_right nonzero]
    dsimp only at accepted ⊢
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i advanced
      exact ite_eq_right advanced

inductive BasicStepPayload (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata) : SourceStatement → Prop
  | primitive {item} : ¬ procedureBasicSelected text context scan procedures →
      BasicPayload text context scan catalog item → BasicStepPayload text context scan catalog procedures item
  | procedure {call} : procedureBasicSelected text context scan procedures →
      ProcedureCallAt text context scan procedures call (procedureCallBody text context scan procedures) →
      BasicStepPayload text context scan catalog procedures (.procedureCall call)

structure BasicStepAt (text : Source) (context : ParseContext) (scan : BodyScan)
    (item : SourceStatement) (result : BodyScan) (catalog : FunctionBindings.Metadata := {})
    (procedures : ProcedureBindings.Metadata := {}) : Prop where
  positive : result.position ≠ 0
  equation : basicBody text context scan catalog procedures = result
  payload : BasicStepPayload text context scan catalog procedures item

theorem BasicStepAt.primitive {text context scan item result catalog procedures}
    (parsed : BasicStepAt text context scan item result catalog procedures)
    (ordinary : ¬ procedureBasicSelected text context scan procedures) :
    BasicAt text context scan item result catalog := by
  refine ⟨parsed.positive, ?_, ?_⟩
  · exact (basicBody_withoutProcedure text context scan catalog procedures ordinary).symm.trans parsed.equation
  · cases parsed.payload with
    | primitive _ payload => exact payload
    | procedure selected _ => exact False.elim (ordinary selected)

theorem BasicStepAt.empty_primitive {text context scan item result catalog}
    (parsed : BasicStepAt text context scan item result catalog {}) :
    BasicAt text context scan item result catalog :=
  parsed.primitive (by simp [procedureBasicSelected, procedureCalleeAt_empty])

theorem basicStep_sound {text context scan catalog procedures}
    (tv : Compose.Expressions.ValidText text) (nv : Compose.Expressions.ValidNames text context.names)
    (accepted : (basicBody text context scan catalog procedures).position ≠ 0) :
    ∃ item, BasicStepAt text context scan item (basicBody text context scan catalog procedures) catalog procedures := by
  by_cases selected : procedureBasicSelected text context scan procedures
  · have raw : (basicRaw text context scan catalog procedures).position ≠ 0 := by
      rw [basicStep_after_raw accepted] at accepted
      exact fixedAfter_nonzero accepted
    have callEquation : basicRaw text context scan catalog procedures = procedureCallBody text context scan procedures := by
      rw [basicRaw, selected.1]
      exact ite_eq_left selected.2
    rw [callEquation] at raw
    obtain ⟨call, parsed⟩ := procedureCall_sound tv nv raw
    exact ⟨.procedureCall call, ⟨accepted, rfl, .procedure selected parsed⟩⟩
  · have ordinary := basicBody_withoutProcedure text context scan catalog procedures selected
    obtain ⟨item, parsed⟩ := basic_sound tv nv (ordinary ▸ accepted)
    exact ⟨item, ⟨accepted, rfl, .primitive selected parsed.payload⟩⟩

theorem basicStep_unique {text context scan left right first second catalog procedures}
    (one : BasicStepAt text context scan left first catalog procedures)
    (two : BasicStepAt text context scan right second catalog procedures) : left = right := by
  cases one.payload with
  | primitive ordinary _ => exact (basic_unique (one.primitive ordinary) (two.primitive ordinary)).1
  | procedure selected parsed =>
      cases two.payload with
      | primitive ordinary _ => exact False.elim (ordinary selected)
      | procedure _ other => exact congrArg SourceStatement.procedureCall (procedureCall_unique parsed other)

end Silver.Predicate
