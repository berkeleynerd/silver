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

theorem declaration_expression_parameters_model :
    let item := Silver.Compose.FunctionDeclarationNative.SourceChecks.expressions.get ⟨2, by decide⟩
    expressionDeclaration item.1 Output.SourceShape.outputImplementation = some (item.2.1, item.2.2) := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts
