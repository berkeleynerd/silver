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

theorem declaration_ordinary_function_return_after :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.ordinary.get ⟨0, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts
