module

public import Silver.PredicateBasicStepReadings
public import Silver.PredicateProcedureCallMeaning

@[expose] public section

namespace Silver.Predicate
open Compose

/-- A primitive reading has no procedure-call node; changing the procedure
signature table therefore does not change its check. -/
theorem BasicPayload.check_procedures {text context scan catalog item}
    (source : BasicPayload text context scan catalog item)
    (shape : Bindings.Shape) (analysis : Integer.Analysis) (flow : Flow)
    (booleans : Boolean.Analysis) (functions : ScalarFunctions.Signatures)
    (procedures : ScalarProcedures.Signatures) :
    item.lower.check shape analysis flow booleans functions procedures =
      item.lower.check shape analysis flow booleans functions := by
  cases source <;> simp only [SourceStatement.lower, Statement.check]

theorem basicStep_meaning {text context scan item result catalog procedures}
    (normal : NamesNormal context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (nv : Compose.Expressions.ValidNames text context.names)
    (bounded : scan.facts.path.Bounded) (bodyMode : context.elaborating = false)
    (valid : FunctionBindings.ValidMetadata text catalog)
    (procedureValid : ProcedureBindings.ValidMetadata text procedures)
    (source : BasicStepAt text context scan item result catalog procedures) :
    item.WellFormed context.hasArguments context.names.shape
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
    item.lower.check context.names.shape context.analysis (context.flow scan.facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (catalogSignatures catalog) (ProcedureBindings.catalogSignatures procedures) = some (context.flow result.facts) := by
  cases source.payload with
  | primitive ordinary payload =>
      have meaning := basic_meaning normal base arraysReady booleansBound compatible nv bounded bodyMode valid
        (source.primitive ordinary)
      exact ⟨meaning.1, (payload.check_procedures ..).trans meaning.2⟩
  | procedure selected reading =>
      have accepted : (basicBody text context scan catalog procedures).position ≠ 0 := source.equation ▸ source.positive
      have afterRaw := (basicStep_after_raw accepted).symm.trans source.equation
      have selectedRaw : basicRaw text context scan catalog procedures =
          procedureCallBody text context scan procedures := by
        rw [basicRaw, selected.1]
        exact ite_eq_left selected.2
      rw [selectedRaw] at afterRaw
      have facts := congrArg BodyScan.facts afterRaw
      simp only [bodyToken_facts] at facts
      have meaning := reading.meaning normal nv base arraysReady booleansBound compatible bounded bodyMode procedureValid
      refine ⟨?_, ?_⟩
      · simpa only [SourceStatement.WellFormed] using meaning.1
      · simp only [SourceStatement.lower, Statement.check, meaning.2.1, ↓reduceIte, meaning.2.2, facts]

end Silver.Predicate
