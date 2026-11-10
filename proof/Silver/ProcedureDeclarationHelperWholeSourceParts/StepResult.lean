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

theorem stepResult : Silver.Lexical.SourceBridge.recordDeclaration "procedure_parameter_step_result" Output.SourceShape.outputImplementation =
    some ["record", "state", ":", "parser_state", ";", "closed", ":", "boolean", ";", "end", "record"] := by
  decide +kernel

end Silver.ProcedureDeclarationHelperWholeSourceCandidate.Parts
