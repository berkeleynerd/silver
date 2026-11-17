module

public import Silver.PredicateProcedureCallAdmission

@[expose] public section

namespace Silver.Predicate
open Compose

theorem procedureTargetActual_bounds (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) :
    (procedureTargetActual text context position facts parameter).scalar ≤ context.scalarNames.length ∧
      (procedureTargetActual text context position facts parameter).flag ≤ context.booleanNames.length := by
  have scalar : scalarTarget text context position ≤ context.scalarNames.length :=
    ScalarExpression.lookup_bound text context.scalarNames _ _
  have flag : booleanTarget text context position ≤ context.booleanNames.length := by
    dsimp only [booleanTarget]
    split
    · exact Nat.zero_le _
    · exact BooleanBindings.lookup_bound ..
  dsimp only [procedureTargetActual]
  split
  · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
  · split
    · split
      · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
      · exact ⟨scalar, Nat.zero_le _⟩
    · split
      · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
      · exact ⟨Nat.zero_le _, flag⟩

theorem procedureTargetActual_zero (text : Source) (context : ParseContext)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) :
    procedureTargetActual text context 0 facts parameter = invalidProcedureActual := by
  simp [procedureTargetActual, skipAt]

theorem procedureActualAfter_zero (text : Source) (context : ParseContext)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) :
    procedureActualAfter text context 0 facts parameter = 0 := by
  unfold procedureActualAfter
  split
  · exact actualAfter_zero ..
  · rw [procedureTargetActual_zero]
    rfl

theorem procedureActualsTailModel_zero (text : Source) (context : ParseContext)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (seen : FormalSet) :
    procedureActualsTailModel text context 0 facts catalog first last ordinal named seen = 0 := by
  rw [procedureActualsTailModel, procedureAssociation_zero]
  rfl

theorem procedureActualsAfter_zero (text : Source) (context : ParseContext)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last : Nat) :
    procedureActualsAfter text context 0 facts catalog first last = 0 :=
  procedureActualsTailModel_zero ..

theorem procedureUpdateStep_count (text : Source) (context : ParseContext)
    (incoming : ActiveFlow) (scan : BodyScan) (parameter : ProcedureBindings.Formal)
    (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) :
    (procedureUpdateStep text context incoming scan parameter catalog first last callFirst callAfter).count = scan.count := by
  dsimp only [procedureUpdateStep]
  split
  · split <;> rfl
  · split
    · rfl
    · split
      · rfl
      · exact ActiveFlow.replace_count ..

theorem procedureUpdatesTailModel_count (text : Source) (context : ParseContext)
    (incoming : ActiveFlow) (scan : BodyScan) (catalog : ProcedureBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) (seen : FormalSet) (callFirst callAfter : Nat) :
    (procedureUpdatesTailModel text context incoming scan catalog first last ordinal named seen callFirst callAfter).count = scan.count := by
  rw [procedureUpdatesTailModel]
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split
      · exact procedureUpdateStep_count ..
      · split
        · rfl
        · split
          · exact (procedureUpdatesTailModel_count text context incoming _ catalog first last (ordinal + 1)
              _ _ callFirst callAfter).trans (procedureUpdateStep_count ..)
          · rfl
termination_by last - ordinal

theorem procedureUpdatesModel_count (text : Source) (context : ParseContext)
    (incoming : ActiveFlow) (scan : BodyScan) (catalog : ProcedureBindings.Metadata)
    (first last callFirst callAfter : Nat) :
    (procedureUpdatesModel text context incoming scan catalog first last callFirst callAfter).count = scan.count :=
  procedureUpdatesTailModel_count ..

theorem procedureCallBody_count (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) :
    (procedureCallBody text context scan catalog).count = scan.count := by
  dsimp only [procedureCallBody]
  split
  · rfl
  · split
    · rfl
    · exact procedureUpdatesModel_count ..

end Silver.Predicate
