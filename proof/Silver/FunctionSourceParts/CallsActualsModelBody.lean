module

public import Silver.PredicateFunctionCallSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.FunctionCallNative
open Silver.Predicate.FunctionCallNative.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem calls_actuals_model_body :
    Source.expressionBody "actuals_model" Output.SourceShape.outputImplementation = some actualsBody.render := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts
