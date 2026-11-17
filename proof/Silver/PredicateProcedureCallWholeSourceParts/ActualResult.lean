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

theorem actualResult : Silver.Lexical.SourceBridge.recordDeclaration "procedure_actual_result" Output.SourceShape.outputImplementation =
    some (["record", "first", ",", "after", ":", "literal_position", ";", "scalar", ":", "scalar_expressions", ".", "binding_count", ";", "flag", ":", "boolean_count", ";", "end", "record"]) := by
  decide +kernel

end Silver.PredicateProcedureCallWholeSourceCandidate.Parts
