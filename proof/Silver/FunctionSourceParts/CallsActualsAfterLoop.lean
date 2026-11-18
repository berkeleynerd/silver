module

public import Silver.PredicateFunctionCallSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.FunctionCallNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem calls_actualsAfter_body :
    Silver.Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "actuals_after"
      Output.SourceShape.outputImplementation = some SourceChecks.actualsAfterBody := by decide +kernel

end Silver.FunctionSourceCandidate.Parts
