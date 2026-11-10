module

public import Silver.PredicateProcedureUpdatesMeaning

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

/-- The exact two-pass procedure call admits one incoming tuple, derives
semantic alias separation from its lexical scans, and exports only formal
output domains. All facts below follow from source readings. -/
theorem ProcedureCallAt.meaning {text context scan catalog call result}
    (source : ProcedureCallAt text context scan catalog call result)
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (bounded : scan.facts.path.Bounded) (bodyMode : context.elaborating = false)
    (valid : ProcedureBindings.ValidMetadata text catalog) :
    call.Readable context.hasArguments context.names.shape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
    call.check (ProcedureBindings.catalogSignatures catalog) context.names.shape context.analysis (context.flow scan.facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = true ∧
    call.after (ProcedureBindings.catalogSignatures catalog) (context.flow scan.facts) = context.flow result.facts := by
  have inside : call.callee ≤ catalog.items.length := by
    rw [source.callee]
    exact procedureCalleeAt_bound ..
  have positive : 0 < call.callee := Nat.pos_of_ne_zero source.positive
  have signatureValid := valid.2.2.2 _ (ProcedureBindings.signature_mem positive inside)
  have count : (ProcedureBindings.signature catalog call.callee).formalFirst +
      (ProcedureBindings.signature catalog call.callee).count - 1 -
      (ProcedureBindings.signature catalog call.callee).formalFirst + 1 =
      (ProcedureBindings.signature catalog call.callee).count := by
    have nonempty := signatureValid.2.1
    omega
  have arguments := source.updates.meaning
    (scan := {scan with position := fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false})
    normal nv base arraysReady booleansBound compatible bounded bodyMode compatible.count valid
  rw [count] at arguments
  obtain ⟨bound, bindings, readable, inputs, outputs, changed⟩ := arguments.binding
  have resolved : call.resolve (ProcedureBindings.catalogSignatures catalog) =
      some ⟨ProcedureBindings.signatureModel catalog (ProcedureBindings.signature catalog call.callee), bound⟩ := by
    simp only [Call.resolve, ProcedureBindings.catalogSignatures_lookup positive inside, Option.bind_some,
      ProcedureBindings.signatureModel, bindings, Option.map_some]
  refine ⟨readable, ?_, ?_⟩
  · simp only [Call.check, resolved, source.actualsApart base.size booleansBound,
      ProcedureBindings.signatureModel, inputs, outputs, Bool.and_self]
  · simpa only [Call.after, resolved, ProcedureBindings.signatureModel] using changed

end Silver.Predicate
