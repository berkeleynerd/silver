module

public import Silver.ProcedureDeclarationHelperWholeSourceCandidate
public import Silver.OutputSourceBridge

@[expose] public section

namespace Silver.ProcedureDeclarationHelperSourceChecks

theorem checked_source : Compose.ProcedureDeclarationNative.HelperSourceChecks.Checked Source.outputBodyTokens := by
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact ProcedureDeclarationHelperWholeSourceCandidate.checked

end Silver.ProcedureDeclarationHelperSourceChecks
