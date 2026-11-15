module

public import Silver.ComposeBooleanDeclarationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.BooleanDeclarationFieldProbe

theorem precedence :
    Compose.BooleanDeclarationNative.body.wellFormed = true := by
  decide +kernel

theorem scope :
    Compose.BooleanDeclarationNative.body.scoped {} = true := by
  decide +kernel

theorem ordinaryBody :
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
      "boolean_declaration_at" Output.SourceShape.outputImplementation =
      some Compose.BooleanDeclarationNative.rendered := by
  decide +kernel

theorem implementationHeader :
    SourceBridge.functionHeader "boolean_declaration_at" "is"
      Output.SourceShape.outputImplementation =
      some Compose.BooleanDeclarationNative.SourceChecks.implHeader := by
  decide +kernel

theorem specificationHeader :
    SourceBridge.functionHeader "boolean_declaration_at" ";"
      Output.SourceShape.outputImplementation =
      some Compose.BooleanDeclarationNative.SourceChecks.specHeader := by
  decide +kernel

end Silver.BooleanDeclarationFieldProbe
