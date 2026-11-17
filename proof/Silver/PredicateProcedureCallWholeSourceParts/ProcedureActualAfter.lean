module

public import Silver.PredicateProcedureCallSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.ProcedureCallNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.PredicateProcedureCallWholeSourceCandidate.Parts

theorem headers_2 :
    let item := SourceChecks.headers.get ⟨2, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_3 :
    let item := SourceChecks.headers.get ⟨3, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem expressions_0 :
    let item := SourceChecks.expressions.get ⟨0, by decide⟩
    expressionDeclaration item.1 Output.SourceShape.outputImplementation = some (item.2.1, item.2.2) := by
  decide +kernel

end Silver.PredicateProcedureCallWholeSourceCandidate.Parts
