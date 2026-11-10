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

theorem model :
    Source.expressionBody "actual_name_free_model" Output.SourceShape.outputImplementation =
      some freeBody.render := by
  decide +kernel

end Silver.ProcedureNameSourceCandidate.Parts

