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

theorem headers_0 :
    let item := SourceChecks.headers.get ⟨0, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_1 :
    let item := SourceChecks.headers.get ⟨1, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem ordinary_0 :
    let item := SourceChecks.ordinary.get ⟨0, by decide⟩
    Silver.Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1
      Output.SourceShape.outputImplementation = some item.2 := by
  decide +kernel

end Silver.PredicateProcedureCallWholeSourceCandidate.Parts
