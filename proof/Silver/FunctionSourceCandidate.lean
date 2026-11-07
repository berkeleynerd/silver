module

public import Silver.FunctionDeclarationSource
public import Silver.FunctionVisibilitySource
public import Silver.PredicateFunctionCallSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

/-! Function declarations, name visibility and calls are checked against the
complete reviewed compiler source. The authoritative adapter transports these
claims through the certified equality with the actual Ada tokens. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate

theorem declarations :
    Compose.FunctionDeclarationNative.SourceChecks.Checked
      Output.SourceShape.outputImplementation := by
  constructor
  · exact Compose.FunctionDeclarationNative.checked_trees
  all_goals decide +kernel

theorem visibility :
    Compose.FunctionVisibilityNative.SourceChecks.Checked
      Output.SourceShape.outputImplementation := by
  constructor
  · exact Compose.FunctionVisibilityNative.SourceChecks.checked_trees
  all_goals decide +kernel

theorem calls :
    Predicate.FunctionCallNative.SourceChecks.Checked
      Output.SourceShape.outputImplementation := by
  constructor
  · exact Predicate.FunctionCallNative.checked_trees
  all_goals decide +kernel

end Silver.FunctionSourceCandidate
