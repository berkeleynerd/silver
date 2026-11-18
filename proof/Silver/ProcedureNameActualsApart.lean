module

public import Silver.ProcedureNameAliasOrigins

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

theorem ProcedureActualsTailAt.equation {text context facts catalog position first last ordinal named seen entries after}
    (source : ProcedureActualsTailAt text context facts catalog first last position ordinal named seen entries after) :
    procedureActualsTailModel text context position facts catalog first last ordinal named seen = after := by
  induction source with
  | last selected fresh actual closed =>
      rw [procedureActualsTailModel]
      simp only [selected, fresh, Bool.false_eq_true, or_self, ↓reduceIte, actual.equation, actual.positive]
  | next within selected fresh actual comma rest ih =>
      rw [procedureActualsTailModel]
      simp only [selected, fresh, Bool.false_eq_true, or_self, ↓reduceIte, actual.equation, actual.positive,
        Nat.ne_of_lt within, comma, within, ↓reduceDIte]
      exact ih

theorem ProcedureActualsAt.equation {text context facts catalog position first last actuals after}
    (source : ProcedureActualsAt text context facts catalog position first last actuals after) :
    procedureActualsAfter text context position facts catalog first last = after := by
  cases source with
  | actuals source => exact source.equation

theorem actual_apart_symm {left right : ScalarProcedures.Actual}
    (apart : Actual.apart left right = true) : Actual.apart right left = true := by
  cases left <;> cases right <;> simp_all [Actual.apart, bne_iff_ne, ne_comm]

theorem actualsApart_pairwise (actuals : List ScalarProcedures.Actual) :
    actualsApart actuals = true ↔ actuals.Pairwise (fun left right => Actual.apart left right = true) := by
  induction actuals with
  | nil => simp [actualsApart]
  | cons head rest ih => simp [actualsApart, Bool.and_eq_true, List.all_eq_true, List.pairwise_cons, ih]

theorem actualsApart_permutation {left right : List ScalarProcedures.Actual}
    (same : left.Perm right) (apart : actualsApart left = true) : actualsApart right = true := by
  apply (actualsApart_pairwise right).mpr
  exact ((same.pairwise_iff (fun good => actual_apart_symm good)).mp
    ((actualsApart_pairwise left).mp apart))

/-- Every other occurrence has a different endpoint. The exact-own-span
exception therefore cannot waive another actual's lexical exclusion. -/
theorem ProcedureUpdatesTailAt.other_avoids
    {text context incoming catalog first last callFirst callAfter scan entries result targetEntry other object}
    (source : ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan first false noFormals entries result)
    (start : scan.position = callFirst)
    (positionBound : scan.position ≤ text.length + 1)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (targetMember : targetEntry ∈ entries) (writable : targetEntry.2.actual = .target object)
    (otherMember : other ∈ entries) (different : other.2.after ≠ targetEntry.2.after) :
    Actual.avoids (targetCell object) other.2.actual = true := by
  obtain ⟨nameFirst, spelling, replay⟩ := source.targetOrigin targetMember writable
  have replayAt : procedurePayloadsFreeModel text context scan.position incoming catalog first last first false
      callAfter nameFirst targetEntry.2.after = true := by
    simpa only [procedurePayloadsFree, start] using replay
  have free := source.actuals.replayFree replayAt other otherMember
  have excluded : actualNameFree text other.2.position other.2.after nameFirst targetEntry.2.after = true := by
    rcases free with own | checked
    · exact False.elim (different own.2)
    · exact checked
  have payload := source.actuals.payloads other otherMember
  have location := source.actuals.locations positionBound other otherMember
  exact ((actualNameFree_sound excluded).procedureActual payload location.2.2.2
    (Nat.le_refl _) spelling (spelling.inNamespace scalarBound booleanBound)).1

theorem ProcedureUpdatesTailAt.actualsApart
    {text context incoming catalog first last callFirst callAfter scan entries result}
    (source : ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan first false noFormals entries result)
    (start : scan.position = callFirst)
    (positionBound : scan.position ≤ text.length + 1)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings) :
    actualsApart (entries.map (fun entry => entry.2.actual)) = true := by
  apply (actualsApart_pairwise _).mpr
  rw [List.pairwise_map]
  apply (source.actuals.after_order positionBound).imp_of_mem
  intro left right leftMember rightMember ordered
  cases leftActual : left.2.actual with
  | target object =>
      rw [target_apart_avoids]
      exact source.other_avoids start positionBound scalarBound booleanBound leftMember leftActual rightMember (by omega)
  | value expression =>
      cases rightActual : right.2.actual with
      | value other => rfl
      | target object =>
          apply actual_apart_symm
          rw [target_apart_avoids]
          simpa only [leftActual] using
            source.other_avoids start positionBound scalarBound booleanBound rightMember rightActual leftMember (by omega)

theorem ProcedureUpdatesAt.actualsApart {text context incoming catalog callFirst callAfter scan first last actuals result}
    (source : ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals result)
    (start : scan.position = callFirst)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (positionBound : scan.position ≤ text.length + 1) : actualsApart actuals = true := by
  cases source with
  | updates source =>
      apply actualsApart_permutation
        ((ScalarAssociations.arrange_permutation defaultProcedureActual source.actuals.fresh.nodup source.actuals.complete).map
          (fun entry => entry.2.actual))
      exact source.actualsApart start positionBound scalarBound booleanBound

theorem ProcedureCallAt.actualsApart {text context scan catalog call result}
    (source : ProcedureCallAt text context scan catalog call result)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings) :
    actualsApart call.actuals = true := by
  exact source.updates.actualsApart rfl scalarBound booleanBound
    (fixedAfter_result_bound text _ "(" false (by decide))

end Silver.Predicate
