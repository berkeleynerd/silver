module

public import Silver.ProcedureNameActualReadings

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

theorem CellSpelling.inNamespace {text context first after cell}
    (spelling : CellSpelling text context first after cell)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings) : cell.InScalarNamespace := by
  cases spelling with
  | integer found _ =>
      have bound := ScalarExpression.lookup_bound text context.scalarNames first after
      rw [found] at bound
      exact Nat.le_trans bound scalarBound
  | boolean _ found _ =>
      have bound := BooleanBindings.lookup_bound text context.booleanNames first after
      rw [found] at bound
      exact Nat.le_trans bound booleanBound

theorem procedureTargetActual_first {text context position facts parameter}
    (accepted : (procedureTargetActual text context position facts parameter).after ≠ 0) :
    (procedureTargetActual text context position facts parameter).first = skipAt text position := by
  dsimp only [procedureTargetActual] at accepted ⊢
  repeat' split <;> simp_all [invalidProcedureActual]

theorem procedureTargetActual_spelling {text context position facts parameter}
    (accepted : (procedureTargetActual text context position facts parameter).after ≠ 0) :
    CellSpelling text context
      (procedureTargetActual text context position facts parameter).first
      (procedureTargetActual text context position facts parameter).after
      (targetCell (procedureTargetIdentity context (procedureTargetActual text context position facts parameter))) := by
  have source := procedureTargetActual_name accepted
  cases source with
  | name skipped _ _ spelling =>
      simpa only [procedureTargetActual_first accepted, skipped] using spelling

theorem procedureWritableUpdate_position (scan : BodyScan) (parameter : ProcedureBindings.Formal)
    (target : ProcedureActualResult) : (procedureWritableUpdate scan parameter target).position = target.after := by
  unfold procedureWritableUpdate
  split <;> rfl

/-- A writable payload retains the source spelling and the complete replay
that checked every other payload, including inputs before this occurrence. -/
theorem ProcedureUpdateAt.targetOrigin {text context incoming parameter catalog first last callFirst callAfter scan object result}
    (source : ProcedureUpdateAt text context incoming parameter catalog first last callFirst callAfter scan (.target object) result) :
    ∃ nameFirst, CellSpelling text context nameFirst result.position (targetCell object) ∧
      procedurePayloadsFree text context callFirst incoming catalog first last callAfter nameFirst result.position = true := by
  cases source with
  | writable _ accepted _ _ free =>
      simp only [procedureWritableUpdate_position]
      exact ⟨_, procedureTargetActual_spelling accepted, free⟩

theorem ProcedureUpdatesTailAt.targetOrigin
    {text context incoming catalog first last callFirst callAfter scan ordinal named seen entries result entry object}
    (source : ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan ordinal named seen entries result)
    (member : entry ∈ entries) (writable : entry.2.actual = .target object) :
    ∃ nameFirst, CellSpelling text context nameFirst entry.2.after (targetCell object) ∧
      procedurePayloadsFree text context callFirst incoming catalog first last callAfter nameFirst entry.2.after = true := by
  induction source with
  | last _ _ step _ =>
      have same := List.mem_singleton.mp member
      subst entry
      dsimp only at writable ⊢
      rw [writable] at step
      exact step.targetOrigin
  | next _ _ _ step _ rest ih =>
      rcases List.mem_cons.mp member with same | later
      · subst entry
        dsimp only at writable ⊢
        rw [writable] at step
        exact step.targetOrigin
      · exact ih later

theorem target_apart_avoids (object : ScalarFunctions.Target) (actual : ScalarProcedures.Actual) :
    Actual.apart (.target object) actual = Actual.avoids (targetCell object) actual := by
  cases actual with
  | value => rfl
  | target other =>
      apply Bool.eq_iff_iff.mpr
      simp only [Actual.apart, Actual.avoids, bne_iff_ne]
      exact ne_comm

end Silver.Predicate
