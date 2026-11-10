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

theorem parameterCursor : Silver.Lexical.SourceBridge.subtypeDeclaration "procedure_parameter_cursor" Output.SourceShape.outputImplementation =
    some ["positive", "range", "1", "..", "procedures", ".", "max_formals", "+", "1"] := by
  decide +kernel

end Silver.ProcedureDeclarationHelperWholeSourceCandidate.Parts
