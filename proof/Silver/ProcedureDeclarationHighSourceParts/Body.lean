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

theorem ordinary_0 :
    let item := HighSourceChecks.ordinary.get ⟨0, by decide⟩
    BooleanDeclarationNative.SourceChecks.ordinaryFunction item.1 Output.SourceShape.outputImplementation = some item.2 := by
  decide +kernel

theorem metadata_append_header :
    procedureHeader "lemma_procedure_metadata_append" "is" Output.SourceShape.outputImplementation =
      some HighSourceChecks.metadataAppendHeader := by
  decide +kernel

end Silver.ProcedureDeclarationHighSourceCandidate.Parts
