module

public import Silver.FunctionSourceCandidate
public import Silver.OutputSourceBridge

@[expose] public section

namespace Silver.FunctionSourceChecks

/-- Every declaration, visibility and call pin is joined to freshly certified
authoritative source tokens. Semantic interpretations remain separate required
parts of the composed source bridge. -/
structure CheckedSource : Prop where
  declarations : Compose.FunctionDeclarationNative.SourceChecks.Checked Source.outputBodyTokens
  visibility : Compose.FunctionVisibilityNative.SourceChecks.Checked Source.outputBodyTokens
  calls : Predicate.FunctionCallNative.SourceChecks.Checked Source.outputBodyTokens

theorem checked_source : CheckedSource where
  declarations := by
    rw [Output.SourceBridge.actual_complete_shape.2.1]
    exact FunctionSourceCandidate.declarations
  visibility := by
    rw [Output.SourceBridge.actual_complete_shape.2.1]
    exact FunctionSourceCandidate.visibility
  calls := by
    rw [Output.SourceBridge.actual_complete_shape.2.1]
    exact FunctionSourceCandidate.calls

end Silver.FunctionSourceChecks
