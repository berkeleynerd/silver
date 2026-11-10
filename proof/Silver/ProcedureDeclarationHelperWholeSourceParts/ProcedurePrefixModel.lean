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

theorem headers_13 :
    let item := HelperSourceChecks.headers.get ⟨13, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_14 :
    let item := HelperSourceChecks.headers.get ⟨14, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem expressions_4 :
    let item := HelperSourceChecks.expressions.get ⟨4, by decide⟩
    expressionDeclaration item.1 Output.SourceShape.outputImplementation = some (item.2.1, item.2.2) := by
  decide +kernel

end Silver.ProcedureDeclarationHelperWholeSourceCandidate.Parts
