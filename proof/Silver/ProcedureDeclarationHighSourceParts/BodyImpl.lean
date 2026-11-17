module

public import Silver.ProcedureDeclarationHighSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose
open Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureDeclarationHighSourceCandidate.Parts

theorem header_1 :
    let item := HighSourceChecks.headers.get ⟨1, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

end Silver.ProcedureDeclarationHighSourceCandidate.Parts
