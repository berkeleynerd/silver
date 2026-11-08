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

theorem calls_call_assignment_model_body :
    Source.expressionBody "call_assignment_model" Output.SourceShape.outputImplementation = some (assignmentBody false).render := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts
