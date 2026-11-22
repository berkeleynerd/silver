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

theorem calls_arrayActual_spec :
    functionHeader "array_actual_after" ";" Output.SourceShape.outputImplementation = some arrayActualSpec := by
  decide +kernel

theorem calls_arrayActual_impl :
    functionHeader "array_actual_after" "is" Output.SourceShape.outputImplementation = some arrayActualImpl := by
  decide +kernel

theorem calls_arrayActual_body :
    Source.expressionBody "array_actual_after" Output.SourceShape.outputImplementation = some arrayActualBody.render := by
  decide +kernel

theorem calls_actualAfter_body :
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "actual_after" Output.SourceShape.outputImplementation =
      some actualImplementation.render := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts
