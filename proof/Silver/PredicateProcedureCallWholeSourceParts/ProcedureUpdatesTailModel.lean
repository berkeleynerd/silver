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

theorem headers_24 :
    let item := SourceChecks.headers.get ⟨24, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_25 :
    let item := SourceChecks.headers.get ⟨25, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem expressions_6 :
    let item := SourceChecks.expressions.get ⟨6, by decide⟩
    expressionDeclaration item.1 Output.SourceShape.outputImplementation = some (item.2.1, item.2.2) := by
  decide +kernel

end Silver.PredicateProcedureCallWholeSourceCandidate.Parts
