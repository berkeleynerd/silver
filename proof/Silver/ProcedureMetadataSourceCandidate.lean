module

public import Silver.ProcedureMetadataSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureMetadataSourceCandidate
open Silver.Predicate.ProcedureMetadataNative

/-- Both selectors and the imported Read_Form refinement are checked against
reviewed tokens; the authoritative adapter binds those tokens to source. -/
theorem checked : SourceChecks.Checked Output.SourceShape.outputSpecification
    Output.SourceShape.outputImplementation where
  scope := checked_scope
  specHeaders := by decide +kernel
  bodyHeaders := by decide +kernel
  model := by decide +kernel
  executable := by decide +kernel

end Silver.ProcedureMetadataSourceCandidate
