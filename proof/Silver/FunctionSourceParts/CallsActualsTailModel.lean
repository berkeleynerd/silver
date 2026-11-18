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

theorem calls_actualsTailModel_spec :
    functionHeader "function_actuals_tail_model" ";" Output.SourceShape.outputImplementation = some actualsTailModelSpec := by
  decide +kernel

theorem calls_actualsTailModel_impl :
    functionHeader "function_actuals_tail_model" "is" Output.SourceShape.outputImplementation = some actualsTailModelImpl := by
  decide +kernel

theorem calls_actuals_tail_model_body :
    Source.expressionBody "function_actuals_tail_model" Output.SourceShape.outputImplementation = some actualsTailBody.render := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts
