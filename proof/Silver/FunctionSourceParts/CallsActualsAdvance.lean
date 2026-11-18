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

theorem calls_actuals_advance_spec :
    procedureHeader "lemma_function_actuals_advance" ";" Output.SourceShape.outputImplementation =
      some ActualsAdvance.lemmaSpec := by decide +kernel

theorem calls_actuals_advance_impl :
    procedureHeader "lemma_function_actuals_advance" "is" Output.SourceShape.outputImplementation =
      some ActualsAdvance.lemmaImpl := by decide +kernel

theorem calls_actuals_advance_body :
    ActualsAdvance.ordinaryBody Output.SourceShape.outputImplementation =
      some ActualsAdvance.lemmaBody := by decide +kernel

end Silver.FunctionSourceCandidate.Parts
