module

public import Silver.ProcedureNameAliasOrigins

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

theorem ProcedureActualsAt.equation {text context facts catalog position first last actuals after}
    (source : ProcedureActualsAt text context facts catalog position first last actuals after) :
    procedureActualsAfter text context position facts catalog first last = after := by
  induction source with
  | last actual closed =>
      rw [procedureActualsAfter]
      simp only [actual.equation, actual.positive, ↓reduceIte]
  | next within actual comma rest ih =>
      rw [procedureActualsAfter]
      simp only [actual.equation, actual.positive, Nat.ne_of_lt within, comma, within, ↓reduceIte, ↓reduceDIte]
      exact ih

theorem ProcedureUpdateAt.followingApart
    {text context incoming parameter callFirst callAfter scan actual next catalog first last actuals result}
    (source : ProcedureUpdateAt text context incoming parameter callFirst callAfter scan actual next)
    (following : ProcedureUpdatesAt text context incoming catalog callFirst callAfter
      (bodyToken text next (.symbol ",")) first last actuals result)
    (comma : fixedAfter text next.position "," false ≠ 0)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (positionBound : scan.position ≤ text.length + 1)
    (finishBound : result.position ≤ callAfter)
    (prior : ActualPrefixAt text context callFirst scan.position) :
    actuals.all (Actual.apart actual) = true := by
  cases source with
  | input _ value advance =>
      apply List.all_eq_true.mpr
      intro other member
      cases other with
      | value => rfl
      | target object =>
          have commaAdvance := Compose.Expressions.model_fixed_advances text _ "," false value.bounded (by decide) comma
          obtain ⟨first, after, ordered, spelling, before⟩ := following.targetOrigin
            (fixedAfter_result_bound text _ "," false (by decide)) member
          change fixedAfter text _ "," false ≤ first at ordered
          dsimp only at ordered
          have targetBound := spelling.inNamespace scalarBound booleanBound
          have atCurrent := prior first after (targetCell object) (by omega) spelling targetBound before
          obtain ⟨free, _⟩ := atCurrent.valueActual value positionBound (by omega) spelling targetBound
          simp only [Actual.apart, free, Bool.not_false]
  | writable _ accepted _ _ _ suffix =>
      have spelling := procedureTargetActual_spelling accepted
      have targetBound := spelling.inNamespace scalarBound booleanBound
      have actualBound := procedureTargetActual_after_bound text context scan.position incoming parameter
      have comma' : fixedAfter text (procedureTargetActual text context scan.position incoming parameter).after "," false ≠ 0 := by
        simpa only [procedureWritableUpdate_position] using comma
      have commaBound := fixedAfter_result_bound text
        (procedureTargetActual text context scan.position incoming parameter).after "," false (by decide)
      have restSource := following.actuals
      simp only [bodyToken, tokenAfter, ShellToken.symbol, procedureWritableUpdate_position] at restSource
      have restAdvance := restSource.advance commaBound
      have afterComma := suffix.fixedSymbol (byte := ',') actualBound (by unfold OrdinarySymbol; decide) comma'
        (by change fixedAfter text (procedureTargetActual text context scan.position incoming parameter).after "," false ≤ callAfter; omega)
      obtain ⟨free, _⟩ := afterComma.procedureActuals restSource commaBound finishBound spelling targetBound
      apply List.all_eq_true.mpr
      intro other member
      rw [target_apart_avoids]
      exact List.all_eq_true.mp free other member

/-- Every pair is discharged from the exact writable actual's native scan.
The induction carries source prior traversal, so a later writable target is
also separated from earlier value actuals. -/
theorem ProcedureUpdatesAt.actualsApart {text context incoming catalog callFirst callAfter scan first last actuals result}
    (source : ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals result)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (positionBound : scan.position ≤ text.length + 1)
    (finishBound : result.position ≤ callAfter)
    (prior : ActualPrefixAt text context callFirst scan.position) :
    actualsApart actuals = true := by
  induction source with
  | last => rfl
  | @next scan first last actual next actuals result _ step comma rest ih =>
      have commaBound := fixedAfter_result_bound text next.position "," false (by decide)
      have nextPrefix := prior.next step.actual positionBound comma
      have restApart := ih commaBound finishBound nextPrefix
      exact Bool.and_eq_true_iff.mpr
        ⟨step.followingApart rest comma scalarBound booleanBound positionBound finishBound prior, restApart⟩

theorem ProcedureCallAt.actualsApart {text context scan catalog call result}
    (source : ProcedureCallAt text context scan catalog call result)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings) :
    actualsApart call.actuals = true := by
  have finish := source.updates.actuals.equation
  exact source.updates.actualsApart scalarBound booleanBound
    (fixedAfter_result_bound text _ "(" false (by decide))
    (Nat.le_of_eq finish.symm) (ActualPrefixAt.start text context _)

end Silver.Predicate
