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

/-- Every retained writable actual has its own accepted prior exclusion,
starting at the original call's opening parenthesis. -/
theorem ProcedureUpdateAt.targetOrigin {text context incoming parameter callFirst callAfter scan object result}
    (source : ProcedureUpdateAt text context incoming parameter callFirst callAfter scan (.target object) result)
    (positionBound : scan.position ≤ text.length + 1) :
    ∃ first after, scan.position ≤ first ∧ CellSpelling text context first after (targetCell object) ∧
      ActualNameFreeTrace text first first after callFirst := by
  cases source with
  | writable _ accepted _ _ before _ =>
      have skipped := ScalarExpression.skip_bounds text scan.position positionBound
      change scan.position ≤ skipAt text scan.position ∧ skipAt text scan.position ≤ text.length + 1 at skipped
      exact ⟨_, _, by rw [procedureTargetActual_first accepted]; exact skipped.1,
        procedureTargetActual_spelling accepted, before⟩

theorem ProcedureUpdatesAt.targetOrigin {text context incoming catalog callFirst callAfter scan first last actuals result object}
    (source : ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals result)
    (positionBound : scan.position ≤ text.length + 1) (member : Actual.target object ∈ actuals) :
    ∃ nameFirst nameAfter, scan.position ≤ nameFirst ∧ CellSpelling text context nameFirst nameAfter (targetCell object) ∧
      ActualNameFreeTrace text nameFirst nameFirst nameAfter callFirst := by
  induction source with
  | last step _ =>
      have same := List.mem_singleton.mp member
      rw [← same] at step
      exact step.targetOrigin positionBound
  | @next scan first last actual next actuals result _ step comma rest ih =>
      rcases List.mem_cons.mp member with same | later
      · rw [← same] at step
        exact step.targetOrigin positionBound
      · have stepAdvance := step.actual.advance positionBound
        have commaAdvance := Compose.Expressions.model_fixed_advances text _ "," false step.actual.bounded (by decide) comma
        have commaBound := fixedAfter_result_bound text next.position "," false (by decide)
        obtain ⟨nameFirst, nameAfter, ordered, spelling, before⟩ := ih commaBound later
        refine ⟨nameFirst, nameAfter, ?_, spelling, before⟩
        change fixedAfter text _ "," false ≤ nameFirst at ordered
        omega

/-- Prefix traversal is constructed from the already processed source actuals.
It converts a later writable actual's native prior check to the current
actual's cursor; no semantic separation is assumed. -/
def ActualPrefixAt (text : Source) (context : ParseContext) (callFirst position : Nat) : Prop :=
  ∀ first after cell, position ≤ first → CellSpelling text context first after cell → cell.InScalarNamespace →
    ActualNameFreeTrace text first first after callFirst → ActualNameFreeTrace text first first after position

theorem ActualPrefixAt.start (text : Source) (context : ParseContext) (position : Nat) :
    ActualPrefixAt text context position position := by
  intro first after cell ordered spelling bounded source
  exact source

theorem ActualPrefixAt.next {text context callFirst position facts parameter actual after}
    (prior : ActualPrefixAt text context callFirst position)
    (source : ProcedureActualAt text context position facts parameter actual after)
    (positionBound : position ≤ text.length + 1) (comma : fixedAfter text after "," false ≠ 0) :
    ActualPrefixAt text context callFirst (fixedAfter text after "," false) := by
  intro first finish cell ordered spelling bounded before
  have stepAdvance := source.advance positionBound
  have commaAdvance := Compose.Expressions.model_fixed_advances text after "," false source.bounded (by decide) comma
  have atStart := prior first finish cell (by omega) spelling bounded before
  obtain ⟨_, afterActual⟩ := atStart.procedureActual source positionBound (by omega) spelling bounded
  exact afterActual.fixedSymbol (byte := ',') source.bounded (by unfold OrdinarySymbol; decide) comma ordered

theorem target_apart_avoids (object : ScalarFunctions.Target) (actual : ScalarProcedures.Actual) :
    Actual.apart (.target object) actual = Actual.avoids (targetCell object) actual := by
  cases actual with
  | value => rfl
  | target other =>
      apply Bool.eq_iff_iff.mpr
      simp only [Actual.apart, Actual.avoids, bne_iff_ne]
      exact ne_comm

end Silver.Predicate
