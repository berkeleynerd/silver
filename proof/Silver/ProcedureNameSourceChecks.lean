module

public import Silver.ProcedureNameSourceCandidate
public import Silver.OutputSourceBridge

@[expose] public section

namespace Silver.ProcedureNameSourceChecks

/-- Join every scanner header, body and native loop contract to freshly
certified authoritative Ada tokens. Complete-domain semantic interpretation
is provided by ProcedureNameNative.SourceChecks.checked_scanner. -/
theorem checked_source : Predicate.ProcedureNameNative.SourceChecks.Checked Source.outputBodyTokens := by
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact ProcedureNameSourceCandidate.checked

end Silver.ProcedureNameSourceChecks

