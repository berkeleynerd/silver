module

public import Silver.ProcedureMetadataSourceCandidate
public import Silver.OutputSourceBridge

@[expose] public section

namespace Silver.ProcedureMetadataSourceChecks

theorem checked_source : Predicate.ProcedureMetadataNative.SourceChecks.Checked
    Source.outputSpecTokens Source.outputBodyTokens := by
  rw [Output.SourceBridge.actual_complete_shape.1, Output.SourceBridge.actual_complete_shape.2.1]
  exact ProcedureMetadataSourceCandidate.checked

end Silver.ProcedureMetadataSourceChecks
