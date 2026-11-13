module

public import Silver.PredicateProcedureCallSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.PredicateProcedureCallWholeSourceCandidate.Parts
open Silver.Predicate.ProcedureCallNative

theorem bodyEquality : BodyEquality.Checked Output.SourceShape.outputImplementation := by
  constructor <;> decide +kernel

end Silver.PredicateProcedureCallWholeSourceCandidate.Parts
