module

public import Silver.ProcedureNameSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.ProcedureNameNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureNameSourceCandidate.Parts

theorem step :
    Silver.Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
      "actual_name_step" Output.SourceShape.outputImplementation =
        some (stepBody.render ++ ["end", "actual_name_step", ";"]) := by
  decide +kernel

end Silver.ProcedureNameSourceCandidate.Parts

