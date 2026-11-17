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

theorem headers_6 :
    let item := SourceChecks.headers.get ⟨6, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_7 :
    let item := SourceChecks.headers.get ⟨7, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem loops_0 :
    let item := SourceChecks.loops.get ⟨0, by decide⟩
    Silver.Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1
      Output.SourceShape.outputImplementation = some item.2 := by
  decide +kernel

end Silver.PredicateProcedureCallWholeSourceCandidate.Parts
