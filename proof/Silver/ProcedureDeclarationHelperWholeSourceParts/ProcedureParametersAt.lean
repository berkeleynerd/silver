module

public import Silver.ProcedureDeclarationHelperSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureDeclarationHelperWholeSourceCandidate.Parts

theorem headers_4 :
    let item := HelperSourceChecks.headers.get ⟨4, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_5 :
    let item := HelperSourceChecks.headers.get ⟨5, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem loops_0 :
    let item := HelperSourceChecks.loops.get ⟨0, by decide⟩
    Silver.Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1
      Output.SourceShape.outputImplementation = some item.2 := by
  decide +kernel

end Silver.ProcedureDeclarationHelperWholeSourceCandidate.Parts
