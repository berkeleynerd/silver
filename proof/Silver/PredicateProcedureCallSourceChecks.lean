module

public import Silver.PredicateProcedureCallWholeSourceCandidate
public import Silver.OutputSourceBridge

@[expose] public section

namespace Silver.PredicateProcedureCallSourceChecks

theorem checked_source : Predicate.ProcedureCallNative.SourceChecks.Checked Source.outputBodyTokens := by
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact PredicateProcedureCallWholeSourceCandidate.checked

end Silver.PredicateProcedureCallSourceChecks
