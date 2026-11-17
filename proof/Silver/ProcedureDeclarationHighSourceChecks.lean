module

public import Silver.ProcedureDeclarationHighSourceCandidate
public import Silver.OutputSourceBridge

@[expose] public section

namespace Silver.ProcedureDeclarationHighSourceChecks

theorem checked_source : Compose.ProcedureDeclarationNative.HighSourceChecks.Checked Source.outputBodyTokens := by
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact ProcedureDeclarationHighSourceCandidate.checked

end Silver.ProcedureDeclarationHighSourceChecks
