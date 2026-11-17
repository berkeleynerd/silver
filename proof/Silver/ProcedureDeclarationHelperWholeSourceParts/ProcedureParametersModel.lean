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

theorem headers_2 :
    let item := HelperSourceChecks.headers.get ⟨2, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_3 :
    let item := HelperSourceChecks.headers.get ⟨3, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem expressions_1 :
    let item := HelperSourceChecks.expressions.get ⟨1, by decide⟩
    expressionDeclaration item.1 Output.SourceShape.outputImplementation = some (item.2.1, item.2.2) := by
  decide +kernel

end Silver.ProcedureDeclarationHelperWholeSourceCandidate.Parts
