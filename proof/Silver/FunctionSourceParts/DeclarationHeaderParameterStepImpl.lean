module

public import Silver.FunctionDeclarationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem declaration_header_parameter_step_impl :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.headers.get ⟨3, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts
