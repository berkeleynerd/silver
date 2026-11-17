module

public import Silver.PredicateProcedureCallProperties

@[expose] public section

namespace Silver.Predicate
open Compose PathFacts

/-- Procedure actual passes preserve the non-value controls. Failure clears
them and the path, while retaining the native scalar-table shape. -/
structure StableCallFields (before after : BodyScan) : Prop where
  target : after.target ≤ before.target
  capacity : after.capacity ≤ before.capacity
  path : after.facts.path = before.facts.path ∨ after.facts.path = Context.empty

theorem StableCallFields.refl (scan : BodyScan) : StableCallFields scan scan :=
  ⟨Nat.le_refl _, Nat.le_refl _, .inl rfl⟩

theorem StableCallFields.invalid (scan : BodyScan) : StableCallFields scan (invalidBody scan) :=
  ⟨Nat.zero_le _, Nat.zero_le _, .inr rfl⟩

theorem StableCallFields.trans {before middle after : BodyScan}
    (one : StableCallFields before middle) (two : StableCallFields middle after) :
    StableCallFields before after := by
  refine ⟨Nat.le_trans two.target one.target, Nat.le_trans two.capacity one.capacity, ?_⟩
  rcases two.path with unchanged | empty
  · rcases one.path with old | cleared
    · exact .inl (unchanged.trans old)
    · exact .inr (unchanged.trans cleared)
  · exact .inr empty

theorem StableCallFields.token {before after : BodyScan} (stable : StableCallFields before after)
    (text : Source) (token : ShellToken) : StableCallFields before (bodyToken text after token) :=
  ⟨stable.target, stable.capacity, stable.path⟩

theorem procedureUpdateStep_fields (text : Source) (context : ParseContext)
    (incoming : ActiveFlow) (scan : BodyScan) (parameter : ProcedureBindings.Formal)
    (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) :
    StableCallFields scan (procedureUpdateStep text context incoming scan parameter catalog first last callFirst callAfter) := by
  dsimp only [procedureUpdateStep]
  split
  · split
    · exact .invalid scan
    · exact ⟨Nat.le_refl _, Nat.le_refl _, .inl rfl⟩
  · split
    · exact .invalid scan
    · split
      · exact ⟨Nat.le_refl _, Nat.le_refl _, .inl rfl⟩
      · exact ⟨Nat.le_refl _, Nat.le_refl _, .inl (ActiveFlow.replace_path scan.facts _ _)⟩

theorem procedureUpdatesTailModel_fields (text : Source) (context : ParseContext)
    (incoming : ActiveFlow) (scan : BodyScan) (catalog : ProcedureBindings.Metadata)
    (first last ordinal : Nat) (named : Bool) (seen : FormalSet) (callFirst callAfter : Nat) :
    StableCallFields scan
      (procedureUpdatesTailModel text context incoming scan catalog first last ordinal named seen callFirst callAfter) := by
  rw [procedureUpdatesTailModel]
  dsimp only
  split
  · exact .invalid scan
  · let association := procedureAssociation text scan.position catalog first last ordinal named
    have moved : StableCallFields scan {scan with position := association.payloadFirst} :=
      ⟨Nat.le_refl _, Nat.le_refl _, .inl rfl⟩
    have step := moved.trans (procedureUpdateStep_fields text context incoming
      {scan with position := association.payloadFirst} (ProcedureBindings.parameter catalog association.formal)
      catalog first last callFirst callAfter)
    split
    · exact .invalid scan
    · split
      · exact step.token text _
      · split
        · exact .invalid scan
        · split
          · exact (step.token text _).trans
              (procedureUpdatesTailModel_fields text context incoming _ catalog first last (ordinal + 1)
                association.named (markFormal seen association.formal) callFirst callAfter)
          · exact .invalid scan
termination_by last - ordinal
decreasing_by omega

theorem procedureUpdatesModel_fields (text : Source) (context : ParseContext)
    (incoming : ActiveFlow) (scan : BodyScan) (catalog : ProcedureBindings.Metadata)
    (first last callFirst callAfter : Nat) :
    StableCallFields scan (procedureUpdatesModel text context incoming scan catalog first last callFirst callAfter) :=
  procedureUpdatesTailModel_fields ..

theorem procedureCallBody_fields (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) : StableCallFields scan (procedureCallBody text context scan catalog) := by
  dsimp only [procedureCallBody]
  split
  · exact .invalid scan
  · split
    · exact .invalid scan
    · let signature := ProcedureBindings.signature catalog (procedureCalleeAt text context scan.position catalog)
      let start := fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false
      have fields := procedureUpdatesModel_fields text context scan.facts {scan with position := start}
        catalog signature.formalFirst (signature.formalFirst + signature.count - 1) start
        (procedureActualsAfter text context start scan.facts catalog signature.formalFirst
          (signature.formalFirst + signature.count - 1))
      exact ⟨fields.target, fields.capacity, fields.path⟩

end Silver.Predicate
