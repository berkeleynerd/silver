module

public import Silver.ComposeBooleanArraySource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

/-! Kernel checks for the Boolean initializer and aggregate source requirements.
The complete source is checked against every contract header and typed body
rendering, retaining all original requirements without lexing long expected strings. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.BooleanArraySource
open Silver.SourceBridge

private theorem model_spec_source :
    functionHeader "boolean_array_values_model" ";" Output.SourceShape.outputImplementation =
      some modelSpec := by
  decide +kernel

private theorem executable_spec_source :
    functionHeader "boolean_array_values_at" ";" Output.SourceShape.outputImplementation =
      some executableSpec := by
  decide +kernel

private theorem initializer_source :
    BooleanInitializerNative.SourceChecks.Checked Output.SourceShape.outputImplementation := by
  constructor <;> decide +kernel

private theorem body_source :
    expressionDeclaration "boolean_array_values_model" Output.SourceShape.outputImplementation =
      some (Expressions.booleanArrayValuesModelBody.render, []) := by
  decide +kernel

private theorem model_impl_source :
    functionHeader "boolean_array_values_model" "is" Output.SourceShape.outputImplementation =
      some modelImpl := by
  decide +kernel

private theorem executable_impl_source :
    functionHeader "boolean_array_values_at" "is" Output.SourceShape.outputImplementation =
      some executableImpl := by
  decide +kernel

/-- Every original initializer, tree, complete header and contract requirement
is retained, including both complete spec-header equalities. -/
theorem candidate_checked : Checked Output.SourceShape.outputImplementation where
  initializer := initializer_source
  body := body_source
  modelSpec := model_spec_source
  modelImpl := model_impl_source
  executableSpec := executable_spec_source
  executableImpl := executable_impl_source

end Silver.Compose.BooleanArraySource
